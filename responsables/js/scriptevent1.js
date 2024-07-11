const XHR = new XMLHttpRequest();
XHR.addEventListener('load', traiterevensrvapp);
XHR.addEventListener('timeout', traiterevensrvapp);

function traiterevensrvapp(e)
{
	switch (e.type) 
	{
		case 'timeout':
            //signalerexception(null, "Chargement de la requete terminee. Timeout.");
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
							
						case 'signalersucces':
							switch(resp.body.data.categorie)
							{
								case 'succescmdesidentifier':	
									rendermessage(resp.body.data.msg, 1);										
									mettreajourselectlist('profils', resp.body.data.profils)
									supprimercontainer('loaderblock');
									setdata('codecompte', resp.body.data.codecompte);
									var data = new FormData();
									data.append('sidxhr', sessionStorage.getItem("sidxhr"));
									data.append('action', "initialiserunevue");
									data.append('nomesptrav', sessionStorage.getItem("nomesptrav"));
									data.append('nomvue', 'choixprofilconnexion');
									envoyerequete(data);
									break;
									
								case 'succescmdeannulerconnexion':	
									rendermessage(resp.body.data.msg, 1);	
									viderformulaire('identificationweb');	
									supprimercontainer('loaderblock');
									var data = new FormData();
									data.append('sidxhr', sessionStorage.getItem("sidxhr"));
									data.append('action', "initialiserunevue");
									data.append('nomesptrav', sessionStorage.getItem("nomesptrav"));
									data.append('nomvue', 'identificationcompte');
									envoyerequete(data);
									break;
									
								case 'succescmdevaliderconnexion':	
									rendermessage(resp.body.data.msg, 1);
									supprimercontainer('loaderblock');									
									location.href = resp.body.data.lienesptrav + '/index.html?conn=' + resp.body.data.codeconn;
									viderformulaire('identificationweb');	
									ouvrir(document.body.id);
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
								case 'echecmdesidentifier':
								case 'echecmdeannulerconnexion':
								case 'echecmdevaliderconnexion':
								case 'echecvidersession':
									rendermessage(resp.body.data.msg, 0);
									supprimercontainer('loaderblock');
									break;
							}
					}
				}
			}
			catch(err)
			{
				rendermessage(err, 0);
			}
            break;
    }
}

function envoyerequete(data)
{
	//XHR.open('POST', 'http://127.0.0.1:5500/page3.html');
	XHR.open('POST', 'https://appliwebservey.sowitelsrv.com/control');
	/*XHR.open('POST', 'https://appzcash.bsiges.com/control');*/
	/*XHR.open('POST', 'https://appangarapay.bsiges.com/control');*/
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

function sidentifier()
{
	buildoperatinloader();
	if(loginetmdpnonvide())
	{
		var data = new FormData();
		data.append('sidxhr', sessionStorage.getItem("sidxhr"));
		data.append('action', "cmdesidentifier");
		data.append('login', getdata('login'));
		data.append('mdp', getdata('mdp'));
		envoyerequete(data);
	}
	else
	{
		rendermessage("Les données saisies sont incoherentes.", 0);
		supprimercontainer('loaderblock');
	}
}

function loginetmdpnonvide()
{
	if(getdata('login') === null || getdata('mdp') === null)
	{
		return false;
	}
	
	return true;
}

function viderformulaire(pnomform)
{			
	sessionStorage.removeItem('codesptrav');
	if(pnomform == 'identificationweb')
	{		
		sessionStorage.removeItem('login');	
		sessionStorage.removeItem('mdp');
		viderformidentificationweb();
	}
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
}

function annuler()
{
	buildoperatinloader();
	var data = new FormData();
	data.append('sidxhr', sessionStorage.getItem("sidxhr"));
	data.append('action', "cmdeannulerconnexion");
	envoyerequete(data);
}

function valider()
{
	buildoperatinloader();
	var data = new FormData();
	data.append('sidxhr', sessionStorage.getItem("sidxhr"));
	data.append('action', "cmdevaliderconnexion");
	data.append('codecompte', getdata('codecompte'));
	data.append('codesptrav', getdata('codesptrav'));
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
            ouvrir(e.target.body.id);
        	setlang(e.target.documentElement.lang);
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

function setlogin(plogin)
{
	sessionStorage.setItem("login", plogin);
}

function getlogin()
{
	return sessionStorage.getItem("login");
}

function setmdp(pmdp)
{
	sessionStorage.setItem("mdp", pmdp);
}

function getmdp()
{
	return sessionStorage.getItem("mdp");
}

function setcodesptrav(pcodesptrav)
{
	sessionStorage.setItem("codesptrav", pcodesptrav);
}

function getcodesptrav()
{
	return sessionStorage.getItem("codesptrav");
}

function traiterevenform(e)
{
	e.preventDefault();	
	var data = new FormData();
	data.append('action', e.target.dataset.action);
	switch(e.target.dataset.action)
	{
		case 'setlogin':
			setdata('login', e.target.value);
			break;			
			
		case 'setmdp':
			setdata('mdp', e.target.value);
			break;
			
		case 'sidentifier':
			sidentifier();
			break;			
			
		case 'setcodesptrav':
			setdata('codesptrav', e.target.value);
			break;
			
		case 'annulerconnexion':
			annuler();
			break;
			
		case 'validerconnexion':
			valider();
			break;
	}	
}