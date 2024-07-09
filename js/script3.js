const XHR = new XMLHttpRequest();
XHR.addEventListener('load', traiterevensrvapp);
XHR.addEventListener('timeout', traiterevensrvapp);

function traiterevensrvapp(e)
{
	switch (e.type) 
	{
		case 'timeout':
            signalerexception(null, "Chargement de la requete terminee. Timeout.");
            break;
            
		case 'load':
            try
            {
				var resp = JSON.parse(e.target.response);
				if (resp.head)
				{
					switch(resp.body.action)
					{
						case 'construirelavuecourante':							
							sessionStorage.setItem('sidxhr', resp.body.data.sidxhr);
							sessionStorage.setItem('nomesptrav', resp.body.data.nomesptrav);
							sessionStorage.setItem('nomvue', resp.body.data.vuecourante.nomvue);
							mettreajourprofilutilis(resp.body.data.connexion);
							construirevue(resp.body.data.nomesptrav, resp.body.data.vuecourante.nomvue);
							var nomcompos = '';
							var i = 0;
							for (composant of resp.body.data.vuecourante.composants) 
							{
								if(i == 0)
								{
									nomcompos = composant.nomcompo;
								}
								else
								{
									nomcompos = nomcompos + ',' + composant.nomcompo;
								}
								i = i + 1;
							}
							sessionStorage.setItem('nomcompos', nomcompos);
							initialisercomposant();						
							break;
							
						case 'construireuncomposant':							
							construirecomposant(sessionStorage.getItem("nomesptrav"), sessionStorage.getItem("nomvue"), resp.body.data.composant.nomcompo, resp.body.data.composant.contenus);
							initialisercomposant();
							break;
							
						case 'redirigerversconnexion':	
							location.href = resp.body.data.url;
							break;
							
						case 'signalersucces':	
							switch(resp.body.data.categorie)
							{
								case 'succescmdeobtenirleserveys':
									mettreajourtable('serveys', resp.body.data.serveys);
									//supprimercontainer('loaderblock');
									break;
									
								case 'succescmdeobtenirlistepays':
									mettreajourselectlist('pays', resp.body.data.listepays);
									//supprimercontainer('loaderblock');
									break;
									
								case 'succescmdeobtenirlisteville':
								 	mettreajourselectlist('ville', resp.body.data.listeville);
								// 	//supprimercontainer('loaderblock');
								break;
									
								case 'succescmdeobtenirlisteoperateur':
								 	mettreajourselectlist('lstoperateur', resp.body.data.listeoperateur);
								// 	//supprimercontainer('loaderblock');
								break;
									
								case 'succescmdecreerunservey':
								 	initialiserunevue("editionserveys");
								// 	//supprimercontainer('loaderblock');
								break;
							}
					}				
				}
				else
				{
					switch(resp.body.action)
					{
						case 'signalerexception':	
							switch(resp.body.data.categorie)
							{
								case 'echecinitesptrav':
								case 'echecinitvue':
								case 'echecinitcompo':
								case 'echecmodiflang':
								case 'echecsedeconn':
								case 'echecmdeobtenirleserveys':
								case 'echecmdeobtenirlistepays':
								case 'echecmdeobtenirlisteville':
								case 'echecmdeobtenirlisteoperateur':
								case 'echecmdecreerunservey':
									rendermessage(resp.body.data.msg, 0);
									//supprimercontainer('loaderblock');
									break;
							}
					}
				}
			}
			catch(err)
			{
				rendermessage(err, 0);
				//supprimercontainer('loaderblock');
			}
            break;
    }
}

function envoyerequete(data)
{
	XHR.open('POST', 'https://appliwebservey.sowitelsrv.com/control');
	XHR.send(data);
}

function setlang(plang)
{
	switch(plang)
    {
		case 'fr':
			sessionStorage.setItem('lang', "fra");
			break;
			
		case 'en':
			sessionStorage.setItem('lang', "eng");
			break;
	}	
}

function getlang()
{
	return sessionStorage.getItem("lang");
}

function ouvrir(pnomesptrav)
{	
	sessionStorage.clear();
	var data = new FormData();
	data.append('action', "initialiserunespacetravail");
	data.append('nomesptrav', pnomesptrav);
	envoyerequete(data);
}

function initialiserunevue(pnomvue)
{	
	//buildoperatinloader();
	var data = new FormData();
	data.append('sidxhr', sessionStorage.getItem("sidxhr"));
	data.append('action', "initialiserunevue");
	data.append('nomesptrav', getdata('nomesptrav'));
	data.append('nomvue', pnomvue);
	envoyerequete(data);
}

function initialisercomposant()
{
	var nomcompos = sessionStorage.getItem("nomcompos");
	if( nomcompos !== null)
	{
		var tabnomcompos = nomcompos.split(',');
		var nomcompo = tabnomcompos.pop();
		if( nomcompo !== undefined)
		{
			tabnomcompos.length == 0 ? sessionStorage.removeItem('nomcompos') : sessionStorage.setItem('nomcompos', tabnomcompos.join(','));				
			var data = new FormData();
			data.append('sidxhr', sessionStorage.getItem("sidxhr"));
			data.append('action', 'initialiseruncomposant');
			data.append('nomesptrav', sessionStorage.getItem("nomesptrav"));
			data.append('nomvue', sessionStorage.getItem("nomvue"));
			data.append('nomcompo', nomcompo);
			data.append('lang', getlang());
			envoyerequete(data);
		}
	}
	else
	{
		switch(getdata('nomvue'))
	    {
			case 'editionserveys':	
				editerleserveys();
				break;	
				
			case 'creationservey':	
				chargerlespays();
				break;
		}
	}
}

function verifierconnexion(pnomesptrav, pcodeconn)
{
	//buildoperatinloader();
	var data = new FormData();
	data.append('action', "verifierlaconnexion");
	data.append('nomesptrav', pnomesptrav);
	data.append('codeconn', pcodeconn);
	envoyerequete(data);
}

function sedeconnecter()
{
	//buildoperatinloader();
	var data = new FormData();
	data.append('action', "sedeconnecter");
	data.append('sidxhr', sessionStorage.getItem("sidxhr"));
	data.append('codeconn', getdata('conn'));
	envoyerequete(data);
}

function editerleserveys()
{
	var data = new FormData();
	data.append('sidxhr', sessionStorage.getItem("sidxhr"));
	data.append('action', 'cmdeobtenirleserveys');
	data.append('critere', "");
	data.append('debut', 0);
	data.append('limit', 100);
	envoyerequete(data);
}

function chargerlespays()
{
	var data = new FormData();
	data.append('sidxhr', sessionStorage.getItem("sidxhr"));
	data.append('action', 'cmdeobtenirlistepays');
	envoyerequete(data);
}

function chargerlesvilles()
{
	var data = new FormData();
	data.append('sidxhr', sessionStorage.getItem("sidxhr"));
	data.append('action', 'cmdeobtenirlisteville');
	data.append('codepays', getdata('codepays'));
	envoyerequete(data);
}

function chargerlesoperateurs()
{
	var data = new FormData();
	data.append('sidxhr', sessionStorage.getItem("sidxhr"));
	data.append('action', 'cmdeobtenirlisteoperateur');
	data.append('codepays', getdata('codepays'));
	envoyerequete(data);
}

function annulercreationservey(pnomvue)
{
	sessionStorage.removeItem('nomreseau');
	sessionStorage.removeItem('dateservey');
	sessionStorage.removeItem('codepays');
	sessionStorage.removeItem('codeville');
	sessionStorage.removeItem('clientmobile');
	sessionStorage.removeItem('clientbtob');
	sessionStorage.removeItem('nomsite');
	sessionStorage.removeItem('immeuble');
	sessionStorage.removeItem('hauteur');
	sessionStorage.removeItem('dalle');
	sessionStorage.removeItem('descrdalle');
	sessionStorage.removeItem('sourcelectrique');
	sessionStorage.removeItem('priseterre');
	sessionStorage.removeItem('operateurs');
	sessionStorage.removeItem('codesoperateurs');
	sessionStorage.removeItem('latitude');
	sessionStorage.removeItem('longitude');
	sessionStorage.removeItem('adresse');
	sessionStorage.removeItem('descriptenviron');
	initialiserunevue(pnomvue);
}

function creationservey()
{
	var data = new FormData();
	data.append('sidxhr', sessionStorage.getItem("sidxhr"));
	data.append('action', 'cmdecreerunservey');
	data.append('nomreseau', getdata('nomreseau'));
	data.append('dateservey', getdata('dateservey'));
	data.append('codepays', getdata('codepays'));
	data.append('codeville', getdata('codeville'));
	data.append('clientmobile', getdata('clientmobile'));
	data.append('clientbtob', getdata('clientbtob'));
	data.append('nomsite', getdata('nomsite'));
	data.append('immeuble', getdata('immeuble'));
	data.append('hauteur', getdata('hauteur'));
	data.append('dalle', getdata('dalle'));
	data.append('descrdalle', getdata('descrdalle'));
	data.append('sourcelectrique', getdata('sourcelectrique'));
	data.append('priseterre', getdata('priseterre'));
	data.append('operateurs', getdata('operateurs'));
	//data.append('codesoperateurs', getdata('codesoperateurs'));
	data.append('latitude', getdata('latitude'));
	data.append('longitude', getdata('longitude'));
	data.append('adresse', getdata('adresse'));
	data.append('descriptenviron', getdata('descriptenviron'));
	envoyerequete(data);
}

function editerunetransaction(pcodetrans)
{
	var data = new FormData();
	data.append('sidxhr', sessionStorage.getItem("sidxhr"));
	data.append('action', 'cmdeobtenirunetransaction');
	data.append('nomreseau', pcodetrans);
	envoyerequete(data);
}

function editerunwallet(pcodewallet)
{
	var data = new FormData();
	data.append('sidxhr', sessionStorage.getItem("sidxhr"));
	data.append('action', 'cmdeobtenirunwallet');
	data.append('codewallet', pcodewallet);
	envoyerequete(data);
}

function editerlestransactionsunwallet(pcodewallet)
{
	var data = new FormData();
	data.append('sidxhr', sessionStorage.getItem("sidxhr"));
	data.append('action', 'cmdeobtenirlestransactionswallet');
	data.append('codewallet', pcodewallet);
	data.append('debut', 0);
	data.append('limit', 100);
	envoyerequete(data);
}

document.addEventListener("readystatechange", traiterevenpage);

function traiterevenpage(e) 
{
	switch (e.target.readyState) 
	{
        case 'interactive':
        	break;
            
        case 'complete':	
            setlang(e.target.documentElement.lang);
        	var tab = document.URL.split('?');
        	if(tab.length == 2)
        	{
				var prm =tab[1].split('=');
				setdata(prm[0], prm[1]);
        		history.replaceState(null, '', tab[0]);	
			}        	
            verifierconnexion(e.target.body.id, getdata('conn'));
            break;
    }
	
}  

function setdata(pkey, pvalue)
{
	sessionStorage.setItem(pkey, pvalue);
}

function getdata(pkey)
{
	return sessionStorage.getItem(pkey);
}

function traiterevenform(e)
{
	e.preventDefault();	
	switch(e.target.dataset.action)
	{
		case 'sedeconnecter':
			sedeconnecter();
			break;
			
		case 'initialiserunevue':
			initialiserunevue(e.target.dataset.nomvue);
			break;
			
		case 'initialiserunevuetype2':
			initialiserunevue(e.target.dataset.nomvue);
			setdata(e.target.dataset.libcode, e.target.dataset.valcode);
			break;			
			
		case 'setcodepays':
			setdata('codepays', e.target.value);
			chargerlesvilles();
			break;	
			
		case 'setcodeville':
			setdata('codeville', e.target.value);
			break;
			
		case 'setcodeoperateur':
			var options = e.target.selectedOptions;
			var codesoperateurs = "{";
			for ( var i = 0; i < options.length; i++) 
			{
				if(i == 0)
				{
					codesoperateurs = codesoperateurs + options[i].value;
				}
				else
				{
					codesoperateurs = codesoperateurs + "," + options[i].value;
				}
			}
			codesoperateurs = codesoperateurs + "}";
			setdata('codesoperateurs', codesoperateurs);
			break;
			
		case 'setnomreseau':
			setdata('nomreseau', e.target.value);
			break;
			
		case 'setnomsite':
			setdata('nomsite', e.target.value);
			break;
			
		case 'setdateservey':
			setdata('dateservey', e.target.value);
			break;
			
		case 'setimmeubleyes':
			if(e.target.checked)
			{
				setdata('immeuble', 'yes');	
			}
			else
			{
				setdata('immeuble', 'no');	
			}
			break;
			
		case 'setimmeubleno':
			if(e.target.checked)
			{
				setdata('immeuble', 'no');	
			}
			break;
			
		case 'sethauteur':
			setdata('hauteur', e.target.value);
			break;
			
		case 'setdalleyes':
			if(e.target.checked)
			{
				setdata('dalle', 'yes');	
			}
			else
			{
				setdata('dalle', 'no');	
			}
			break;
			
		case 'setdalleno':
			if(e.target.checked)
			{
				setdata('dalle', 'no');	
			}
			break;
			
		case 'setdescrdalle':
			setdata('descrdalle', e.target.value);
			break;
			
		case 'setsourcelectriqueyes':
			if(e.target.checked)
			{
				setdata('sourcelectrique', 'yes');	
			}
			else
			{
				setdata('sourcelectrique', 'no');	
			}
			break;
			
		case 'setsourcelectriqueno':
			if(e.target.checked)
			{
				setdata('sourcelectrique', 'no');	
			}
			break;
			
		case 'setpriseterreyes':
			if(e.target.checked)
			{
				setdata('priseterre', 'yes');	
			}
			else
			{
				setdata('priseterre', 'no');	
			}
			break;
			
		case 'setpriseterreno':
			if(e.target.checked)
			{
				setdata('priseterre', 'no');	
			}
			break;
			
		case 'setlongitude':
			setdata('longitude', e.target.value);
			break;
			
		case 'setlatitude':
			setdata('latitude', e.target.value);
			break;
			
		case 'setadresse':
			setdata('adresse', e.target.value);
			break;
			
		case 'setoperateuryes':
			if(e.target.checked)
			{
				setdata('operateurs', 'yes');
				chargerlesoperateurs();	
			}
			else
			{
				setdata('operateurs', 'no');	
			}
			break;
			
		case 'setoperateurno':
			if(e.target.checked)
			{
				setdata('operateurs', 'no');	
			}
			break;
			
		case 'setclientmobile':
			setdata('clientmobile', e.target.value);
			break;
			
		case 'setclientbtob':
			setdata('clientbtob', e.target.value);
			break;
			
		case 'setdescriptenviron':
			setdata('descriptenviron', e.target.value);
			break;
			
		case 'annulercreationservey':
			annulercreationservey(e.target.dataset.nomvue);
			break;
			
		case 'creationservey':
			creationservey();
			break;
	}	
}

function traitereventable(e)
{
	e.preventDefault();	
	switch(e.target.parentNode.dataset.action)
	{
		case 'initialiserunevuetype2':
			initialiserunevue(e.target.parentNode.dataset.nomvue);
			setdata(e.target.parentNode.dataset.libcode, e.target.parentNode.dataset.valcode);
			break;
	}	
}