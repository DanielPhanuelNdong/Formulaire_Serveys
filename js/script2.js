function construirevue(nomesptrav, nomvue)
{
	switch(nomesptrav)
    {
		case 'webresposervey':
			document.getElementById('editionserveys').setAttribute("style", "padding: 0; display: none;");
			document.getElementById('formservey').setAttribute("style", "padding: 0; display: none;");
			document.getElementById('formservey').setAttribute("style", "padding: 0; display: none;");
			document.getElementById('mod').setAttribute("style", "padding: 0; display: none;");
			switch(nomvue)
            {
				case 'editionserveys':
					document.getElementById(nomvue).setAttribute("style", "padding: 0; display: block;");
					break;
					
				case 'editionservey':
					document.getElementById('formservey').setAttribute("style", "padding: 0; display: block;");
					document.getElementById('bouts').setAttribute("style", "padding: 0; display: block;");
					document.getElementById('creationservey').setAttribute("style", "padding: 0; display: none;");
					break;

				case 'creationservey':
					document.getElementById('formservey').setAttribute("style", "padding: 0; display: block;");
					document.getElementById('bouts').setAttribute("style", "padding: 0; display: none;");
					document.getElementById('creationservey').setAttribute("style", "padding: 0; display: flex;");
                    
					break;
					
				case 'confirmationcreationservey':
					document.getElementById('mod').setAttribute("style", "padding: 0; display: block;");
					break;
					
				case 'confirmatiosuppressionservey':
					document.getElementById('mod').setAttribute("style", "padding: 0; display: block;");
					break;
					
				case 'confirmationsoumissionservey':
					document.getElementById('mod').setAttribute("style", "padding: 0; display: block;");
					break;
					
				case 'modificationunservey':
					document.getElementById('formservey').setAttribute("style", "padding: 0; display: block;");
					document.getElementById('bouts').setAttribute("style", "padding: 0; display: none;");
					document.getElementById('creationservey').setAttribute("style", "padding: 0; display: flex;");
					break;
					
				case 'confirmationmodificationservey':
					document.getElementById('mod').setAttribute("style", "padding: 0; display: block;");
					break;
			}
		break;
	}
}

function construirecomposant(nomesptrav, nomvue, nomcompo, contenus)
{
  	switch(nomesptrav)
    {
		case 'webresposervey':
			switch(nomvue)
            {
				case 'editionserveys':
					switch(nomcompo)
		            {
						case 'sidebar':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
					            {
									case 'lbdeconnexion':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										document.getElementById(conten.nomconten).setAttribute("data-action", 'sedeconnecter');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
										break;
										
									case 'lbgestionserveys':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										document.getElementById(conten.nomconten).setAttribute("data-action", 'initialiserunevue');
										document.getElementById(conten.nomconten).setAttribute("data-nomvue", 'editionserveys');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
										break;
								}
							}
							break;
							
						case 'gestionbar1':	
							for (const conten of contenus) 
							{
								switch(conten.nomconten)
					            {
									case 'lbgestdeserveys':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
										
									case 'lbeditserveys':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
										
									case 'btncreerservey':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										document.getElementById(conten.nomconten).setAttribute("data-action", 'initialiserunevue');
										document.getElementById(conten.nomconten).setAttribute("data-nomvue", 'creationservey');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
										//demasquercomposant('bouts', !bool);
										break;
								}
							}
							break;

						case 'espacecontenair':	
							for (const conten of contenus) 
							{
								switch(conten.nomconten)
					            {
									case 'lblistserveys':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							break;
							
						case 'tableserveys':
							for (const conten of contenus) 
							{
								switch(conten.nomconten)
					            {
									case 'colnumeros':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
									case 'colnomsites':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
									case 'colvilles':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
									case 'coldates':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
									case 'colpays':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
									case 'colnomreseaux':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							break;
					}
					break;
					
				case 'editionservey':
					switch(nomcompo)
		            {
						case 'sidebar':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
					            {
									case 'lbdeconnexion':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										document.getElementById(conten.nomconten).setAttribute("data-action", 'sedeconnecter');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
										break;
										
									case 'lbgestionserveys':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										document.getElementById(conten.nomconten).setAttribute("data-action", 'initialiserunevue');
										document.getElementById(conten.nomconten).setAttribute("data-nomvue", 'editionserveys');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
										break;
								}
							}
							break;
							
						case 'gestionbar2':	
							for (const conten of contenus) 
							{
								switch(conten.nomconten)
					            {
									case 'lbgestunservey':
									case 'lbeditunservey':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							break;

						case 'bodyservey1':	
							for (const conten of contenus) 
							{
								switch(conten.nomconten)
					            {
									case 'lbcarateristiques':
									case 'lbimmeuble':
									case 'lbimbleoui':
									case 'lbimblenon':
									case 'lbhauteur':
									case 'lbdalle':
									case 'lbdaloui':
									case 'lbdalnon':
									case 'lbetatdal':
									case 'lbsourcelect':
									case 'lbsourcelectoui':
									case 'lbsourcelectnon':
									case 'lbpriseterre':
									case 'lbpriseterreoui':
									case 'lbpriseterrenon':
									case 'lbcoordgps':
									case 'lboperateurexist':
									case 'lboperateurexistoui':
									case 'lboperateurexistnon':
									case 'lboperateur':
									case 'lbetatdal':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							break;
							
						case 'enteteservey':
							for (const conten of contenus) 
							{
								switch(conten.nomconten)
					            {
									case 'lbnomsite':
									case 'lbpays':
									case 'lbville':
									case 'lbdate':
									case 'lbnomreseau':
									case 'lbinfoservey':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							break;
							
						case 'bodyservey2':
							for (const conten of contenus) 
							{
								switch(conten.nomconten)
					            {
									case 'lbclientcible':
									case 'lbmobile':
									case 'lbbtob':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							break;
							
						case 'bodyservey3':
						for (const conten of contenus)
							{
								switch(conten.nomconten)
								{
									case 'lbscanperiphwifi':
										document.getElementById('lbscanperiphwifi').innerText = conten.lib;
										break;
										
									case 'btnwifi':
										document.getElementById('btnwifi').innerText = conten.lib;
										//document.getElementById('annuler').setAttribute("data-action", 'initialiserunevue');
										//document.getElementById('annuler').setAttribute("data-nomvue", 'editionserveys');
										//document.getElementById('annuler').addEventListener("click", traiterevenform);
										break;
								}
							}
							break;
							
						case 'bodyservey4':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
								{
									case 'lbphotos':
										document.getElementById('lbphotos').innerText = conten.lib; 
										break;

									case 'btnphotos':
										document.getElementById('btnphotos').innerText = conten.lib;
										break;
										
																		
								}
							}
							break;
							
						case 'footerservey':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
								{
									case 'btnmodifservey':
										document.getElementById('btnmodifservey').innerText = conten.lib;
										document.getElementById(conten.nomconten).setAttribute("data-action", 'initialiserunevue');
										document.getElementById(conten.nomconten).setAttribute("data-nomvue", 'modificationunservey');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
										break;

									case 'btnsuppservey':
										document.getElementById('btnsuppservey').innerText = conten.lib;
										document.getElementById(conten.nomconten).setAttribute("data-action", 'initialiserunevue');
										document.getElementById(conten.nomconten).setAttribute("data-nomvue", 'confirmatiosuppressionservey');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
										break;
										
									case 'btnsoumservey':
										document.getElementById('btnsoumservey').innerText = conten.lib;
										document.getElementById(conten.nomconten).setAttribute("data-action", 'initialiserunevue');
										document.getElementById(conten.nomconten).setAttribute("data-nomvue", 'confirmationsoumissionservey');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
										break;
										
																		
								}
							}
							break;
					}
					break;	

			    case 'creationservey': 
					switch(nomcompo)
					{
						case 'sidebar':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
					            {
									case 'lbdeconnexion':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										document.getElementById(conten.nomconten).setAttribute("data-action", 'sedeconnecter');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
										break;
										
									case 'lbgestionserveys':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										document.getElementById(conten.nomconten).setAttribute("data-action", 'initialiserunevue');
										document.getElementById(conten.nomconten).setAttribute("data-nomvue", 'editionserveys');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
										break;
								}
							}
							break;

						case 'entetecreatservey':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
								{
									case 'placenomsite':
										document.getElementById('nomsite').setAttribute("placeholder", conten.lib);
										break;
										
									case 'placenomreseau':
										document.getElementById('nomreseau').setAttribute("placeholder", conten.lib);
										break;
										
									case 'lbnomsite':
									case 'lbpays':
									case 'lbville':
									case 'lbdate':
									case 'lbnomreseau':
									case 'lbinfoservey':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							
							document.getElementById('nomreseau').setAttribute("data-action", 'setnomreseau');
							document.getElementById('nomreseau').addEventListener("change", traiterevenform);
							
							document.getElementById('nomsite').setAttribute("data-action", 'setnomsite');
							document.getElementById('nomsite').addEventListener("change", traiterevenform);
							
							document.getElementById('dateservey').setAttribute("data-action", 'setdateservey');
							document.getElementById('dateservey').addEventListener("change", traiterevenform);
							
							document.getElementById('oui1').setAttribute("data-action", 'setimmeubleyes');
							document.getElementById('oui1').addEventListener("change", traiterevenform);							
							document.getElementById('non1').setAttribute("data-action", 'setimmeubleno');
							document.getElementById('non1').addEventListener("change", traiterevenform);
							
							document.getElementById('hauteurimmeuble').setAttribute("data-action", 'sethauteur');
							document.getElementById('hauteurimmeuble').addEventListener("change", traiterevenform);
							
							document.getElementById('oui2').setAttribute("data-action", 'setdalleyes');
							document.getElementById('oui2').addEventListener("change", traiterevenform);							
							document.getElementById('non2').setAttribute("data-action", 'setdalleno');
							document.getElementById('non2').addEventListener("change", traiterevenform);
							
							document.getElementById('descrdalle').setAttribute("data-action", 'setdescrdalle');
							document.getElementById('descrdalle').addEventListener("change", traiterevenform);
							
							document.getElementById('oui3').setAttribute("data-action", 'setsourcelectriqueyes');
							document.getElementById('oui3').addEventListener("change", traiterevenform);							
							document.getElementById('non3').setAttribute("data-action", 'setsourcelectriqueno');
							document.getElementById('non3').addEventListener("change", traiterevenform);
							
							document.getElementById('oui5').setAttribute("data-action", 'setpriseterreyes');
							document.getElementById('oui5').addEventListener("change", traiterevenform);							
							document.getElementById('non5').setAttribute("data-action", 'setpriseterreno');
							document.getElementById('non5').addEventListener("change", traiterevenform);
							
							document.getElementById('longitude').setAttribute("data-action", 'setlongitude');
							document.getElementById('longitude').addEventListener("change", traiterevenform);
							
							document.getElementById('latitude').setAttribute("data-action", 'setlatitude');
							document.getElementById('latitude').addEventListener("change", traiterevenform);
							
							document.getElementById('adresse').setAttribute("data-action", 'setadresse');
							document.getElementById('adresse').addEventListener("change", traiterevenform);
							
							document.getElementById('oui4').setAttribute("data-action", 'setoperateuryes');
							document.getElementById('oui4').addEventListener("change", traiterevenform);							
							document.getElementById('non4').setAttribute("data-action", 'setoperateurno');
							document.getElementById('non4').addEventListener("change", traiterevenform);
							
							document.getElementById('clientmobile').setAttribute("data-action", 'setclientmobile');
							document.getElementById('clientmobile').addEventListener("change", traiterevenform);
							
							document.getElementById('clientbtob').setAttribute("data-action", 'setclientbtob');
							document.getElementById('clientbtob').addEventListener("change", traiterevenform);
							
							document.getElementById('descriptenviron').setAttribute("data-action", 'setdescriptenviron');
							document.getElementById('descriptenviron').addEventListener("change", traiterevenform);
							break;

						case 'bodycreatservey1':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
								{
									case 'placehauteur':
										document.getElementById('hauteurimmeuble').setAttribute("placeholder", conten.lib);
										break;
										
									case 'placetatdal':
										document.getElementById('descrdalle').setAttribute("placeholder", conten.lib);
										break;
										
									case 'placelongitude':
										document.getElementById('longitude').setAttribute("placeholder", conten.lib);
										break;
										
									case 'placelatitude':
										document.getElementById('latitude').setAttribute("placeholder", conten.lib);
										break;
										
									case 'placeadresse':
										document.getElementById('adresse').setAttribute("placeholder", conten.lib);
										break;
										
									case 'lbcarateristiques':
									case 'lbimmeuble':
									case 'lbimbleoui':
									case 'lbimblenon':
									case 'lbhauteur':
									case 'lbdalle':
									case 'lbdaloui':
									case 'lbdalnon':
									case 'lbetatdal':
									case 'lbsourcelect':
									case 'lbsourcelectoui':
									case 'lbsourcelectnon':
									case 'lbpriseterre':
									case 'lbpriseterreoui':
									case 'lbpriseterrenon':
									case 'lbcoordgps':
									case 'lboperateurexist':
									case 'lboperateurexistoui':
									case 'lboperateurexistnon':
									case 'lboperateur':
									case 'lbetatdal':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							break;

						case 'bodycreatservey2':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
								{
									case 'placembile':
										document.getElementById('clientmobile').setAttribute("placeholder", conten.lib);
										break;

									case 'placebtob':
										document.getElementById('clientbtob').setAttribute("placeholder", conten.lib);
										break;
										
									case 'lbclientcible':
									case 'lbmobile':
									case 'lbbtob':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							break;

						case 'bodyservey4':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
								{
									case 'lbphotos':
										document.getElementById('lbphotos').innerText = conten.lib; 
										break;

									case 'btnphotos':
										document.getElementById('btnphotos').innerText = conten.lib;
										break;
										
																		
								}
							}
							break;

						case 'bodycreatservey4':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
								{
									case 'placedescriptenviron':
										document.getElementById('descriptenviron').innerText = "";
										document.getElementById('descriptenviron').setAttribute("placeholder", conten.lib);
										break;
										
																			
								}
							}
							break;

						case 'footercreatservey':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
								{
									case 'btnvalidercreatservey':
										document.getElementById('valider').innerText = conten.lib;
										document.getElementById('valider').setAttribute("data-action", 'initialiserunevue');
										document.getElementById('valider').setAttribute("data-nomvue", 'confirmationcreationservey');
										document.getElementById('valider').addEventListener("click", traiterevenform);
										break;
										
									case 'btnannulercreatservey':
										document.getElementById('annuler').innerText = conten.lib;
										document.getElementById('annuler').setAttribute("data-action", 'annulercreationservey');
										document.getElementById('annuler').setAttribute("data-nomvue", 'editionserveys');
										document.getElementById('annuler').addEventListener("click", traiterevenform);
										break;
								}
							}
							break;
							
						case 'bodyservey3':
						for (const conten of contenus)
							{
								switch(conten.nomconten)
								{
									case 'lbscanperiphwifi':
										document.getElementById('lbscanperiphwifi').innerText = conten.lib;
										break;
										
									case 'btnwifi':
										document.getElementById('btnwifi').innerText = conten.lib;
										//document.getElementById('annuler').setAttribute("data-action", 'initialiserunevue');
										//document.getElementById('annuler').setAttribute("data-nomvue", 'editionserveys');
										//document.getElementById('annuler').addEventListener("click", traiterevenform);
										break;
								}
							}
							break;
						
					}
					break;
					
			  case 'confirmationcreationservey':
	
	                switch(nomcompo)
					 {
						case 'modalconfirmcreatservey':
							for (const conten of contenus)
							{
								
								switch(conten.nomconten)
								{
									case 'btnvalidconfirmcreatservey':
										document.getElementById('valid').innerText = conten.lib;
										document.getElementById('valid').setAttribute("data-action", 'creationservey');
										document.getElementById('valid').addEventListener("click", traiterevenform);
										break;
										
									case 'btnannulconfirmcreatservey':
										document.getElementById('annul').innerText = conten.lib;
										document.getElementById('annul').setAttribute("data-action", 'initialiserunevue');
										document.getElementById('annul').setAttribute("data-nomvue", 'creationservey');
										document.getElementById('annul').addEventListener("click", traiterevenform);
										break;
										
									case 'lbmodalconfcreatservey':
										document.getElementById('confirm-mod').innerText = conten.lib;
										break;
								}
							}
							break;
					
					}
					break;	
					
			  case 'confirmatiosuppressionservey':
	
	                switch(nomcompo)
					 {
						case 'confirsuppservey':
							for (const conten of contenus)
							{
								
								switch(conten.nomconten)
								{
									case 'btnvalidconfirmsuppservey':
										document.getElementById('valid').innerText = conten.lib;
										document.getElementById('valid').setAttribute("data-action", 'initialiserunevue');
										document.getElementById('valid').setAttribute("data-nomvue", 'editionserveys');
										document.getElementById('valid').addEventListener("click", traiterevenform);
										break;
										
									case 'btnannulconfirmsuppservey':
										document.getElementById('annul').innerText = conten.lib;
										document.getElementById('annul').setAttribute("data-action", 'initialiserunevue');
										document.getElementById('annul').setAttribute("data-nomvue", 'editionservey');
										document.getElementById('annul').addEventListener("click", traiterevenform);
										break;
										
									case 'lbconfirmsuppservey':
										document.getElementById('confirm-mod').innerText = conten.lib;
										break;
								}
							}
							break;
					
					}
					break;
					
			  case 'confirmationsoumissionservey':
	
	                switch(nomcompo)
					 {
						case 'confirmsoumservey':
							for (const conten of contenus)
							{
								
								switch(conten.nomconten)
								{
									case 'btnvalidconfirmsoumservey':
										document.getElementById('valid').innerText = conten.lib;
										document.getElementById('valid').setAttribute("data-action", 'initialiserunevue');
										document.getElementById('valid').setAttribute("data-nomvue", 'editionserveys');
										document.getElementById('valid').addEventListener("click", traiterevenform);
										break;
										
									case 'btnannulconfirmsoumservey':
										document.getElementById('annul').innerText = conten.lib;
										document.getElementById('annul').setAttribute("data-action", 'initialiserunevue');
										document.getElementById('annul').setAttribute("data-nomvue", 'editionservey');
										document.getElementById('annul').addEventListener("click", traiterevenform);
										break;
										
									case 'lbconfirmsoumservey':
										document.getElementById('confirm-mod').innerText = conten.lib;
										break;
								}
							}
							break;
					
					}
					break;	
					
				case 'modificationunservey':
	
	                switch(nomcompo)
					 {
							
						case 'sidebar':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
					            {
									case 'lbdeconnexion':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										document.getElementById(conten.nomconten).setAttribute("data-action", 'sedeconnecter');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
										break;
										
									case 'lbgestionserveys':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										document.getElementById(conten.nomconten).setAttribute("data-action", 'initialiserunevue');
										document.getElementById(conten.nomconten).setAttribute("data-nomvue", 'editionserveys');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
										break;
								}
							}
							break;
							
						case 'gestionbar2':	
							for (const conten of contenus) 
							{
								switch(conten.nomconten)
					            {
									case 'lbgestunservey':
									case 'lbeditunservey':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							break;

						case 'bodyservey1':	
							for (const conten of contenus) 
							{
								switch(conten.nomconten)
					            {
									case 'lbcarateristiques':
									case 'lbimmeuble':
									case 'lbimbleoui':
									case 'lbimblenon':
									case 'lbhauteur':
									case 'lbdalle':
									case 'lbdaloui':
									case 'lbdalnon':
									case 'lbetatdal':
									case 'lbsourcelect':
									case 'lbsourcelectoui':
									case 'lbsourcelectnon':
									case 'lbpriseterre':
									case 'lbpriseterreoui':
									case 'lbpriseterrenon':
									case 'lbcoordgps':
									case 'lboperateurexist':
									case 'lboperateurexistoui':
									case 'lboperateurexistnon':
									case 'lboperateur':
									case 'lbetatdal':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							break;
							
						case 'enteteservey':
							for (const conten of contenus) 
							{
								switch(conten.nomconten)
					            {
									case 'lbnomsite':
									case 'lbpays':
									case 'lbville':
									case 'lbdate':
									case 'lbnomreseau':
									case 'lbinfoservey':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							break;
							
						case 'bodyservey2':
							for (const conten of contenus) 
							{
								switch(conten.nomconten)
					            {
									case 'lbclientcible':
									case 'lbmobile':
									case 'lbbtob':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							break;
							
						case 'bodyservey3':
						for (const conten of contenus)
							{
								switch(conten.nomconten)
								{
									case 'lbscanperiphwifi':
										document.getElementById('lbscanperiphwifi').innerText = conten.lib;
										break;
										
									case 'btnwifi':
										document.getElementById('btnwifi').innerText = conten.lib;
										//document.getElementById('annuler').setAttribute("data-action", 'initialiserunevue');
										//document.getElementById('annuler').setAttribute("data-nomvue", 'editionserveys');
										//document.getElementById('annuler').addEventListener("click", traiterevenform);
										break;
								}
							}
							break;
							
						case 'bodyservey4':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
								{
									case 'lbphotos':
										document.getElementById('lbphotos').innerText = conten.lib; 
										break;

									case 'btnphotos':
										document.getElementById('btnphotos').innerText = conten.lib;
										break;
										
																		
								}
							}
							break;
							
						case 'footermodifservey':
							for (const conten of contenus)
							{
								
								switch(conten.nomconten)
								{
									case 'btnvalidermodifservey':
										document.getElementById('valider').innerText = conten.lib;
										document.getElementById('valid').setAttribute("data-action", 'initialiserunevue');
										//document.getElementById('valid').setAttribute("data-nomvue", 'editionserveys');
										//document.getElementById('valid').addEventListener("click", traiterevenform);
										break;
										
									case 'btnannulermodifservey':
										document.getElementById('annuler').innerText = conten.lib;
										document.getElementById('annuler').setAttribute("data-action", 'initialiserunevue');
										document.getElementById('annuler').setAttribute("data-nomvue", 'editionservey');
										document.getElementById('annuler').addEventListener("click", traiterevenform);
										break;
								}
							}
							break;
					
					}
					break;
					
				case 'confirmationmodificationservey':
	
	                switch(nomcompo)
					 {
						case 'confirmodifservey':
							for (const conten of contenus)
							{
								
								switch(conten.nomconten)
								{
									case 'btnvalidconfirmodifservey':
										document.getElementById('valid').innerText = conten.lib;
										document.getElementById('valid').setAttribute("data-action", 'initialiserunevue');
										document.getElementById('valid').setAttribute("data-nomvue", 'editionserveys');
										document.getElementById('valid').addEventListener("click", traiterevenform);
										break;
										
									case 'btnannulconfirmodifservey':
										document.getElementById('annul').innerText = conten.lib;
										document.getElementById('annul').setAttribute("data-action", 'initialiserunevue');
										document.getElementById('annul').setAttribute("data-nomvue", 'editionservey');
										document.getElementById('annul').addEventListener("click", traiterevenform);
										break;
										
									case 'lbconfirmodifservey':
										document.getElementById('confirm-mod').innerText = conten.lib;
										break;
								}
							}
							break;
					
					}
					break;						
			}
		break;
	}
}

function supprimercontainer(idcontainer)
{
    var contentdiv = document.getElementById(idcontainer);
    if (contentdiv !== null) 
    {
        contentdiv.remove();
    }
}

function demasquercomposant(nomcomposant, bool)
{
	if (!bool) 
	{
        document.getElementById(nomcomposant).setAttribute("style", "padding: 0; display: none;");
    } 
    else 
    {
        document.getElementById(nomcomposant).setAttribute("style", "padding: 0; display: block;");
    }
}

function mettreajourselectlist(selectid, data)
{
	var select = document.getElementById(selectid);
	var length = select.options.length;
	for (i = length-1; i > 0; i--) 
	{
	  select.remove(i);
	}
	var opt = null;
	
	switch(selectid)
    {
		case 'profils':
			for (conten of data) 
			{ 
		        opt = document.createElement('option');
		        opt.value = conten.codesptrav;
		        opt.textContent = conten.nomprofil;
		        select.appendChild(opt);
		    }
			select.selectedIndex = 0;
			select.setAttribute("data-action", 'setcodesptrav');
			select.addEventListener("change", traiterevenform);
			break;
			
		case 'pays':
			for (conten of data) 
			{ 
		        opt = document.createElement('option');
		        opt.value = conten.code;
		        opt.textContent = conten.lib;
		        select.appendChild(opt);
		    }
			select.selectedIndex = 0;
			select.setAttribute("data-action", 'setcodepays');
			select.addEventListener("change", traiterevenform);
			break;
			
		case 'ville':
			for (conten of data) 
			{ 
		        opt = document.createElement('option');
		        opt.value = conten.code;
		        opt.textContent = conten.lib;
		        select.appendChild(opt);
		    }
			select.selectedIndex = 0;
			select.setAttribute("data-action", 'setcodeville');
			select.addEventListener("change", traiterevenform);
			break;
			
		case 'lstoperateur':
			for (conten of data) 
			{ 
		        opt = document.createElement('option');
		        opt.value = conten.code;
		        opt.textContent = conten.lib;
		        select.appendChild(opt);
		    }
			select.selectedIndex = 0;
			select.setAttribute("data-action", 'setcodeoperateur');
			select.addEventListener("change", traiterevenform);
			break;
	}
	
}

function mettreajourprofilutilis(connexion)
{
	document.getElementById('username').innerText = connexion.nomcompte;
}

function remplirformulaire(formid, data)
{
	switch(formid)
    {
		case 'editiontransaction':
       		for (const item in data) 
	       	{
	       		switch(item)
	            {
					case 'codetrans':
					case 'nomcommis':
					case 'datetrans':
					case 'descrtrans':
					case 'senstrans':
					case 'montantrans':
					case 'tauxcommis':
					case 'fraistrans':
					case 'totaltrans':
					case 'statutrans':
					case 'nomsutilistrans':
					case 'intitulewalletrans':
					case 'soldewalletrans':
					case 'nouveausoldetrans':
					case 'nomsmomo':
					case 'numtelmomo':
					case 'opermomo':
					case 'paysmomo':
					case 'nomsutilispart':
					case 'intitulewalletpart':
						document.getElementById(item).value = data[item];
						break;
				}			  
			}
	        break;
	        
        case 'editionwallet':
        	
       		for (const item in data) 
	       	{
	       		switch(item)
	            {
					case 'codewallet':
						const transwalletBtn = document.querySelector("#editranswallet");
						transwalletBtn.setAttribute("data-action", 'initialiserunevuetype2');
						transwalletBtn.setAttribute("data-nomvue", 'editiontransactionswallet');
						transwalletBtn.setAttribute("data-libcode", 'codewallet');
						transwalletBtn.setAttribute("data-valcode", data[item]);
						transwalletBtn.addEventListener("click", traiterevenform);
						transwalletBtn.addEventListener("dblclick", traiterevenform);
						document.getElementById(item).value = data[item];
						break;
					case 'intitulewallet':
					case 'soldewallet':
					case 'statutwallet':
					case 'codeclientwallet':
					case 'typeutiliswallet':
					case 'nomsutiliswallet':
					case 'numtelutiliswallet':
					case 'emailutiliswallet':
					case 'statutcomptewallet':
						document.getElementById(item).value = data[item];
						break;
				}			  
			}
	        break;
	}
}

function mettreajourtable(tableid, data)
{
	

	switch(tableid)
    {
		
		case 'serveys':
			var table = document.getElementById(tableid);
			var tbody = document.createElement("tbody");
			var j = 1;
			data.forEach(item => 
			{
		        var tr = document.createElement("tr");      
				tr.setAttribute("data-action", 'initialiserunevuetype2');
				tr.setAttribute("data-nomvue", 'editionservey');
				tr.setAttribute("data-libcode", 'codeservey');
				tr.setAttribute("data-valcode", item.code);
				tr.addEventListener("click", traitereventable);
				tr.addEventListener("dblclick", traiterevenform);
		        tr.setAttribute('id', item.nomsite);
		        var td = document.createElement("td");
		        td.setAttribute('class', 'text-center');
		        td.innerText = j;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.nomsite;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.nomreseau;
		        tr.appendChild(td);

				td = document.createElement("td");
		        td.innerText = item.dateservey;
		        tr.appendChild(td);

				td = document.createElement("td");
		        td.innerText = item.enumville;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.enumpays;
		        tr.appendChild(td);
		        		        
		        tbody.appendChild(tr);
		        j = j + 1;
		    });
			var anctbody = document.querySelector("table#" + tableid + ">tbody");
			if (anctbody !== null)
		    {
		        table.removeChild(anctbody);
		    }
	    	table.appendChild(tbody);
			break;
			
		case 'administrateurs':
			var table = document.getElementById(tableid);
			var tbody = document.createElement("tbody");
			var j = 1;
			data.forEach(item =>
			{
		        var tr = document.createElement("tr");
		        tr.setAttribute('id', item.code);
		        var td = document.createElement("td");
		        td.setAttribute('class', 'text-center');
		        td.innerText = j;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.noms;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.numtel;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.email;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        if(item.statut == '1')
		        {
		        	var i = document.createElement("i");
		        	i.setAttribute('class', 'icon-feather-check-circle');
		        }
		        else
		        {
		        	var i = document.createElement("i");
		        	i.setAttribute('class', 'icon-feather-lock');
		        }
		        td.appendChild(i);
		        tr.appendChild(td);
		        		        
		        tbody.appendChild(tr);
		        j = j + 1;
		    });						
			var anctbody = document.querySelector("table#" + tableid + ">tbody");
			if (anctbody !== null) 
		    {
		        table.removeChild(anctbody);
		    }
	    	table.appendChild(tbody);
			break;	
			
		case 'wallets':
			var table = document.getElementById(tableid);
			var tbody = document.createElement("tbody");
			var j = 1;
			data.forEach(item => 
			{
		        var tr = document.createElement("tr");	        
				tr.setAttribute("data-action", 'initialiserunevuetype2');
				tr.setAttribute("data-nomvue", 'editionwalletedit');
				tr.setAttribute("data-libcode", 'codewallet');
				tr.setAttribute("data-valcode", item.code);
				tr.addEventListener("click", traitereventable);
				tr.addEventListener("dblclick", traitereventable);
		        var td = document.createElement("td");
		        td.setAttribute('class', 'text-center');
		        td.innerText = j;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.intitule;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.solde;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.noms;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.numtel;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.email;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        if(item.statut == '1')
		        {
		        	var i = document.createElement("i");
		        	i.setAttribute('class', 'icon-feather-check-circle');
		        }
		        else
		        {
		        	var i = document.createElement("i");
		        	i.setAttribute('class', 'icon-feather-lock');
		        }
		        td.appendChild(i);
		        tr.appendChild(td);
		        		        
		        tbody.appendChild(tr);
		        j = j + 1;
		    });						
			var anctbody = document.querySelector("table#" + tableid + ">tbody");
			if (anctbody !== null) 
		    {
		        table.removeChild(anctbody);
		    }
	    	table.appendChild(tbody);
			break;
			
		case 'clients':
			var table = document.getElementById(tableid);
			var tbody = document.createElement("tbody");
			var j = 1;
			data.forEach(item => 
			{
		        var tr = document.createElement("tr");
		        tr.setAttribute('id', item.code);
		        var td = document.createElement("td");
		        td.setAttribute('class', 'text-center');
		        td.innerText = j;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.noms;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.numtel;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.email;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        if(item.statut == '1')
		        {
		        	var i = document.createElement("i");
		        	i.setAttribute('class', 'icon-feather-check-circle');
		        }
		        else
		        {
		        	var i = document.createElement("i");
		        	i.setAttribute('class', 'icon-feather-lock');
		        }
		        td.appendChild(i);
		        tr.appendChild(td);
		        		        
		        tbody.appendChild(tr);
		        j = j + 1;
		    });						
			var anctbody = document.querySelector("table#" + tableid + ">tbody");
			if (anctbody !== null) 
		    {
		        table.removeChild(anctbody);
		    }
	    	table.appendChild(tbody);
			break;
			
		case 'agents':
			var table = document.getElementById(tableid);
			var tbody = document.createElement("tbody");
			var j = 1;
			data.forEach(item => 
			{
		        var tr = document.createElement("tr");
		        tr.setAttribute('id', item.code);
		        var td = document.createElement("td");
		        td.setAttribute('class', 'text-center');
		        td.innerText = j;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.noms;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.numtel;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.email;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        if(item.statut == '1')
		        {
		        	var i = document.createElement("i");
		        	i.setAttribute('class', 'icon-feather-check-circle');
		        }
		        else
		        {
		        	var i = document.createElement("i");
		        	i.setAttribute('class', 'icon-feather-lock');
		        }
		        td.appendChild(i);
		        tr.appendChild(td);
		        		        
		        tbody.appendChild(tr);
		        j = j + 1;
		    });						
			var anctbody = document.querySelector("table#" + tableid + ">tbody");
			if (anctbody !== null) 
		    {
		        table.removeChild(anctbody);
		    }
	    	table.appendChild(tbody);
			break;
			
		case 'transactions':
			var table = document.getElementById(tableid);
			var tbody = document.createElement("tbody");
			var j = 1;
			data.forEach(item => 
			{
		        var tr = document.createElement("tr");	        
				tr.setAttribute("data-action", 'initialiserunevuetype2');
				tr.setAttribute("data-nomvue", 'editiontransactionedit');
				tr.setAttribute("data-libcode", 'codetrans');
				tr.setAttribute("data-valcode", item.code);
				tr.addEventListener("click", traitereventable);
				tr.addEventListener("dblclick", traitereventable);
		        var td = document.createElement("td");
		        td.setAttribute('class', 'text-center');
		        td.innerText = j;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.type;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.date;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.montant;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.taux;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.sens;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.intitule;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.noms;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        if(item.statut == '1')
		        {
		        	var i = document.createElement("i");
		        	i.setAttribute('class', 'icon-feather-check-circle');
		        }
		        else
		        {
		        	var i = document.createElement("i");
		        	i.setAttribute('class', 'icon-feather-lock');
		        }
		        td.appendChild(i);
		        tr.appendChild(td);
		        		        
		        tbody.appendChild(tr);
		        j = j + 1;
		    });						
			var anctbody = document.querySelector("table#" + tableid + ">tbody");
			if (anctbody !== null) 
		    {
		        table.removeChild(anctbody);
		    }
	    	table.appendChild(tbody);	    	
			break;
			
		case 'transactionswallet':
			var table = document.getElementById(tableid);
			var tbody = document.createElement("tbody");
			var j = 1;
			data.forEach(item => 
			{
		        var tr = document.createElement("tr");	        
				tr.setAttribute("data-action", 'initialiserunevuetype2');
				tr.setAttribute("data-nomvue", 'editiontransactionedit');
				tr.setAttribute("data-libcode", 'codetrans');
				tr.setAttribute("data-valcode", item.code);
				tr.addEventListener("click", traitereventable);
				tr.addEventListener("dblclick", traitereventable);
		        var td = document.createElement("td");
		        td.setAttribute('class', 'text-center');
		        td.innerText = j;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.type;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.date;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.montant;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.taux;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.sens;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.intitule;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        td.innerText = item.noms;
		        tr.appendChild(td);
		        
		        td = document.createElement("td");
		        if(item.statut == '1')
		        {
		        	var i = document.createElement("i");
		        	i.setAttribute('class', 'icon-feather-check-circle');
		        }
		        else
		        {
		        	var i = document.createElement("i");
		        	i.setAttribute('class', 'icon-feather-lock');
		        }
		        td.appendChild(i);
		        tr.appendChild(td);
		        		        
		        tbody.appendChild(tr);
		        j = j + 1;
		    });						
			var anctbody = document.querySelector("table#" + tableid + ">tbody");
			if (anctbody !== null) 
		    {
		        table.removeChild(anctbody);
		    }
	    	table.appendChild(tbody);	    	
			break;
	}
}

function viderformidentificationweb() 
{
	document.getElementById("lblogin").value = '';
	document.getElementById("lbmdp").value = '';
}

function rendermessage(msg, type) 
{
    var class1 = "", class2 = "";
    switch (type) 
    {
        case 0:
            class1 = "alert fade alert-danger lgalert";
            class2 = "icon icon-feather-alert-triangle";
            break;

        case 1:
            class1 = "alert fade alert-success lgalert";
            class2 = "icon icon-feather-check-circle";
            break;

        case 2:
            class1 = "alert fade alert-warning lgalert";
            class2 = "icon icon-feather-alert-triangle";
            break;

        case 3:
            class1 = "alert fade alert-info lgalert";
            class2 = "icon icon-feather-info";
            break;
    }

    var contentmessage = document.getElementById('message');
	contentmessage.innerHTML = '';
    var divmessage = document.createElement("div");
    divmessage.setAttribute("class", class1);
    var buttonmsgclose = document.createElement("button");
    buttonmsgclose.setAttribute("class", "closealert");
    buttonmsgclose.setAttribute("id", "closemsg")
    var ibuttonmsgclose = document.createElement("i");
    ibuttonmsgclose.setAttribute("class", "icon icon-feather-x-circle");
    buttonmsgclose.appendChild(ibuttonmsgclose);
    divmessage.appendChild(buttonmsgclose);
    var iconmsg = document.createElement("i");
    iconmsg.setAttribute("class", class2);
    divmessage.appendChild(iconmsg);
    var spanmsg = document.createElement("span");
    spanmsg.innerText = msg;
    divmessage.appendChild(spanmsg);

    contentmessage.appendChild(divmessage);

   	const closeMsg = document.querySelector("#closemsg");

    closeMsg.addEventListener('click', () => {
        divmessage.remove();
    })
}

function buildoperatinloader() 
{
    var contentviewloader = document.getElementById('loader');

    var divloadercontent = document.createElement("div");
    divloadercontent.setAttribute("style", "background-color: rgba(254, 254, 254, 0.8); position: fixed; left: 0; right: 0; top: 0; bottom: 0; font-weight: 400; display: flex; flex-direction: column; justify-content: center; align-items: center; z-index: 999;");
    divloadercontent.setAttribute("id", "loaderblock");
    var divwifiloader = document.createElement("div");
    divwifiloader.setAttribute("class", "lds-ripple");
    var _contentloader = `<div></div><div></div>`;

    divwifiloader.innerHTML = _contentloader;

    divloadercontent.appendChild(divwifiloader);

    contentviewloader.appendChild(divloadercontent);
}