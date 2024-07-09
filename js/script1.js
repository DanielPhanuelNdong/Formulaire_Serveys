// //clicks sur les h3
// const mesh = document.getElementsByClassName('mes');

// console.log(mesh);
// Array.from(mesh).forEach(element => {
//     element.addEventListener('click', () => {
//         element.classList.add('cliquer');
//     })
//     // element.addEventListener('mouseout', () => {
//     //     element.style.backgroundColor = '#171d34';
//     // })

// })

// const mesh3 = document.getElementsByClassName('hh3');

// Array.from(mesh3).forEach(element => {
//     element.addEventListener('click', () => {
//         element.classList.add('h');
//     })
//     // element.addEventListener('mouseout', () => {
//     //     element.style.backgroundColor = '#171d34';
//     // })

// })

// Sélectionner tous les éléments avec la classe 'mes'
const chang = document.getElementsByClassName('tableau');
const chang2 = document.getElementsByClassName('infowall');
const mesh = document.getElementsByClassName('mes');
const mesh2 = document.getElementsByClassName('hh3');
// Sélectionner l'élément original
const originalElement = document.querySelector('.gestion');
const originalElement2 = document.querySelector('.edition');
const paragraph = document.getElementById('para');
//enlever
Array.from(chang2).forEach(element => {
    element.classList.add('dis');
});

Array.from(chang).forEach(element => {
    element.classList.remove('dis');
});

// Appliquer la classe 'cliquer' au premier élément
if (mesh.length > 0) {
    mesh[0].classList.add('cliquer');
}
if (mesh2.length > 0) {
    mesh2[0].classList.add('h');
}

// Fonction pour gérer le clic sur un élément
function handleClick(event) {
    // Supprimer la classe 'cliquer' de l'élément actuellement actif
    const activeElement = document.querySelector('.mes.cliquer');
    if (activeElement) {
        activeElement.classList.remove('cliquer');
    }

    // Ajouter la classe 'cliquer' à l'élément cliqué
    event.currentTarget.classList.add('cliquer');

    Array.from(chang2).forEach(element => {
        element.classList.add('dis');
    });

    Array.from(chang).forEach(element => {
        element.classList.remove('dis');
    });
}
function handleClick2(event) {
    // Supprimer la classe 'cliquer' de l'élément actuellement actif
    const activeElement = document.querySelector('.hh3.h');
    if (activeElement) {
        activeElement.classList.remove('h');
    }

    // Ajouter la classe 'cliquer' à l'élément cliqué
    event.currentTarget.classList.add('h');

}


// Ajouter un écouteur d'événement de clic à chaque élément
Array.from(mesh).forEach(element => {
    element.addEventListener('click', handleClick);
});
Array.from(mesh2).forEach(element => {
    element.addEventListener('click', handleClick2);
});

// cocher et decocher les checbox ..................................................................

const checbox_oui = document.getElementById('oui1')
const checbox_non = document.getElementById('non1')
const checbox_oui2 = document.getElementById('oui2')
const checbox_non2 = document.getElementById('non2')
const checbox_oui3 = document.getElementById('oui3')
const checbox_non3 = document.getElementById('non3')
const checbox_oui4 = document.getElementById('oui4')
const checbox_non4 = document.getElementById('non4')
const checbox_oui5 = document.getElementById('oui5')
const checbox_non5 = document.getElementById('non5')

// variables pour display si oui ou non................................
const hauteur = document.getElementById('hauteur')
const dalles = document.getElementById('dalles')
const etat_dalles = document.getElementById('etat_dalles')
const gps = document.getElementById('gps')
const operateur = document.getElementById('operateur')

// ecouter oui immeuble
checbox_oui.addEventListener('change', () => {
    if (checbox_oui.checked) {
        checbox_non.checked = false;
        hauteur.classList.remove('disp')
        dalles.classList.remove('disp')
    }else{
        hauteur.classList.add('disp')
        dalles.classList.add('disp')
    }
})

// ecouter non immeuble
checbox_non.addEventListener('change', () => {
    if (checbox_non.checked) {
        checbox_oui.checked = false;
        hauteur.classList.add('disp')
        dalles.classList.add('disp')
    }else{
        hauteur.classList.add('disp')
        dalles.classList.add('disp')
    }
})

// ecouter oui Dalles
checbox_oui2.addEventListener('change', () => {
    if (checbox_oui2.checked) {
        checbox_non2.checked = false;
        etat_dalles.classList.remove('disp')
    }else{
        etat_dalles.classList.add('disp')
    }
})

// ecouter non Dalles
checbox_non2.addEventListener('change', () => {
    if (checbox_non2.checked) {
        checbox_oui2.checked = false;
        etat_dalles.classList.add('disp')
    }else{
        etat_dalles.classList.add('disp')
    }
})

// ecouter oui Source électrique
checbox_oui3.addEventListener('change', () => {
    if (checbox_oui3.checked) {
        checbox_non3.checked = false;
    }
})

// ecouter non Source électrique
checbox_non3.addEventListener('change', () => {
    if (checbox_non3.checked) {
        checbox_oui3.checked = false;
    }
})

// ecouter oui Opérateur existant
checbox_oui4.addEventListener('change', () => {
    if (checbox_oui4.checked) {
        checbox_non4.checked = false;
        operateur.classList.remove('disp')
    }else{
        operateur.classList.add('disp')
    }
})

// ecouter non Opérateur existant
checbox_non4.addEventListener('change', () => {
    if (checbox_non4.checked) {
        checbox_oui4.checked = false;
        operateur.classList.add('disp')
    }else{
        operateur.classList.add('disp')
    }
})

// ecouter oui Prise terre
checbox_oui5.addEventListener('change', () => {
    if (checbox_oui5.checked) {
        checbox_non5.checked = false;
    }
})

// ecouter non Prise terre
checbox_non5.addEventListener('change', () => {
    if (checbox_non5.checked) {
        checbox_oui5.checked = false;
    }
})

// bouton validation.....................................
//const valider = document.getElementById('valider')
//const annuler = document.getElementById('annuler')
const disp = getSelection('.disp')
//const modal = document.getElementById('mod')
//const close_modal = document.getElementById('annul')
//const valider_modal = document.getElementById('valid')

//valider.addEventListener('click', () => {
//    modal.classList.remove('disp')
//})
//close_modal.addEventListener('click', () => {
//    modal.classList.add('disp')
//})
//valider_modal.addEventListener('click', () => {
//    modal.classList.add('disp')
//})

// modal pour afficher l'image apres un click sur l'image
const images = document.querySelectorAll('.imgs')
const mod_image = document.getElementById('mod_image')
const img_contenu = document.getElementById('img_contenu')
const back = document.getElementById('back')
images.forEach(image => {
    image.addEventListener('click', () => {
        mod_image.classList.remove('disp')
        img_contenu.src = image.src
    })
    back.addEventListener('click', () => {
        mod_image.classList.add('disp')
    })
})
window.addEventListener('click', (event) => {
    if (event.target == mod_image) {
        mod_image.classList.add('disp')
    }
})

// bouton photos..........................
const mes_photos = document.getElementById('btnphotos')
const id_contenant_images = document.getElementById('id-contenant-images')
mes_photos.addEventListener('click', () => {
    id_contenant_images.classList.contains('disp') ? id_contenant_images.classList.remove('disp') : id_contenant_images.classList.add('disp')
})


// afficher le tableau 2 apres appuis sur wifi
const wifi = document.getElementById('btnwifi')
const tableau_2 = document.getElementById('tableau_2')

wifi.addEventListener('click', () => {
    tableau_2.classList.contains('disp') ? tableau_2.classList.remove('disp') : tableau_2.classList.add('disp')
})

// ouvrir et fermer la sidebar
const monMenu = document.getElementById('monMenu')
const cancelMenu = document.getElementById('CancelMenu')
const maSidebar = document.getElementById('maSidebar')
const Mesh3 = document.getElementById('Mesh3')

Mesh3.addEventListener('click', () => {
    maSidebar.classList.add('col1none')
})
monMenu.addEventListener('click', () => {
    maSidebar.classList.remove('col1none')
})

cancelMenu.addEventListener('click', () => {
    maSidebar.classList.add('col1none')
})