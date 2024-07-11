function construirevue(nomesptrav, nomvue)
{
	switch(nomesptrav)
    {
		case 'webconnexion':
			document.getElementById('identificationcompte').setAttribute("style", "padding: 0; display: none;");
			document.getElementById('choixprofilconnexion').setAttribute("style", "padding: 0; display: none;");
			switch(nomvue)
            {
				case 'identificationcompte':	
				document.getElementById(nomvue).setAttribute("style", "padding: 0; display: block;");
				break;
				
				case 'choixprofilconnexion':								
				document.getElementById(nomvue).setAttribute("style", "padding: 0; display: block;");
				break;					
			}
		break;		
	}
}

function construirecomposant(nomesptrav, nomvue, nomcompo, contenus)
{
  	switch(nomesptrav)
    {
		case 'webconnexion':
			switch(nomvue)
            {
				case 'identificationcompte':	
					switch(nomcompo)
		            {
						case 'formidentificationweb':	
						
							for (const conten of contenus) 
							{
								switch(conten.nomconten)
					            {
									case 'soustitre':
										
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
										
									case 'lblogin':
										document.getElementById(conten.nomconten).setAttribute("placeholder", conten.lib);
										document.getElementById(conten.nomconten).setAttribute("data-action", 'setlogin');
										document.getElementById(conten.nomconten).addEventListener("change", traiterevenform);
										break;
										
									case 'lbmdp':
										document.getElementById(conten.nomconten).setAttribute("placeholder", conten.lib);
										document.getElementById(conten.nomconten).setAttribute("data-action", 'setmdp');
										document.getElementById(conten.nomconten).addEventListener("change", traiterevenform);
										break;
										
									case 'valbtnsidentifier':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										document.getElementById(conten.nomconten).setAttribute("data-action", 'sidentifier');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
										break;
								}
							}
							break;
							
							case 'enteteconnexionweb':	
							for (const conten of contenus) 
							{
								switch(conten.nomconten)
					            {
									case 'logo':
										document.getElementById(conten.nomconten).setAttribute("src", "" + conten.lib);
										break;
										
									case 'titre':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							break;
					}
					break;
					
				case 'choixprofilconnexion':
					switch(nomcompo)
		            {
						case 'enteteconnexionweb':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
					            {
									case 'logo':
										document.getElementById(conten.nomconten).setAttribute("src", "" + conten.lib);
										break;
										
									case 'titre':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
								}
							}
							break;
							
						case 'formchoixprofilconnexionweb':
							for (const conten of contenus)
							{
								switch(conten.nomconten)
					            {
									case 'soustitre':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
										
									// case 'lbprofils':
									// 	document.getElementById(conten.nomconten).innerText = conten.lib;
									// 	break;
										
									case 'liboption0profils':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										break;
										
									case 'valbtnvalider':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										console.log(conten.lib)
										document.getElementById(conten.nomconten).setAttribute("data-action", 'validerconnexion');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
										break;
										
									case 'valbtnannuler':
										document.getElementById(conten.nomconten).innerText = conten.lib;
										console.log(conten.lib)
										document.getElementById(conten.nomconten).setAttribute("data-action", 'annulerconnexion');
										document.getElementById(conten.nomconten).addEventListener("click", traiterevenform);
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
{/* <i class="fa-solid fa-xmark"></i> */}
    var contentmessage = document.getElementById('message');
	contentmessage.innerHTML = '';
    var divmessage = document.createElement("div");
    divmessage.setAttribute("class", class1);
    var buttonmsgclose = document.createElement("button");
    buttonmsgclose.setAttribute("class", "closealert");
    buttonmsgclose.setAttribute("id", "closemsg")
    var ibuttonmsgclose = document.createElement("i");
    ibuttonmsgclose.setAttribute("class", "fa-solid fa-xmark");
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