-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== Creation des objets du schema public
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create domain public.identifiant as char(20);
alter domain public.identifiant add constraint tailleidentifiant check(char_length(value)=20);

create domain public.prefixe as varchar(5);
alter domain public.prefixe add constraint tailleprefixe check(char_length(value)>=2 and char_length(value)<=5);

create domain public.etat as integer;
alter domain public.etat add constraint intervaletat check(value>=1 and value<=10);

create domain public.enaturel as integer;
alter domain public.enaturel add constraint intervalenaturel check(value>=0);

create domain public.enaturelnn as integer;
alter domain public.enaturelnn add constraint intervalenaturelnn check(value>=1);

create domain public.nom as varchar(300);
alter domain public.nom add constraint taillenom check(char_length(value)>=1 and char_length(value)<=300);
alter domain public.nom add constraint motifnom check(value ~ '^[A-Za-z0-9`~\!@#\$%\^&\*\(\)\+\=\{\}\[\]|\\:;''"\<\>\,\?/._-]+$');

create domain public.libelle as varchar(3000);
alter domain public.libelle add constraint taillelibelle check(char_length(value)<=3000);

create domain public.motdepasse as char(32);
alter domain public.motdepasse add constraint taillemotdepasse check(char_length(value)=32);

create domain public.email as varchar(200);
alter domain public.email add constraint tailleemail check(char_length(value)>=6 and char_length(value)<=200);
alter domain public.email add constraint motifemail check(value ~ '^[A-Za-z0-9._-]+@[A-Za-z0-9._-]+\.[a-z]{2,}$');

create domain public.numtel as varchar(200);
alter domain public.numtel add constraint taillenumtel check(char_length(value)>=3 and char_length(value)<=50);
alter domain public.numtel add constraint motifnumtel check(value ~ '^\+[0-9]{3,}$');

create domain public.codepin as char(5);
alter domain public.codepin add constraint taillecodepin check(char_length(value)=5);
alter domain public.codepin add constraint motifcodepin check(value ~ '^[0-9]{5}$');

create type public.langue as enum ('francais','anglais');
create type public.isolangue as enum ('fra','eng');
create type public."habilitation" as enum ('seconnecter','sedeconnecter',
											'editerleserveys','editerunservey','creerunservey','modifierunservey','supprimerunservey','soumettreunservey','accepterunservey','rejeterunservey',
											'editerlesimagesunservey','editeruneimageunservey','creeruneimageunservey','supprimeruneimageunservey',
											'editerlesadministrateurs','ajouterunadministrateur','modifierunadministrateur','supprimerunadministrateur','activerdesactiverunadministrateur','editerlesdroitsunadministrateur','mettreajourlesdroitsunadministrateur',
											'editerlesexploitants','ajouterunexploitant','modifierunexploitant','supprimerunexploitant','activerdesactiverunexploitant','editerlesdroitsunexploitant','mettreajourlesdroitsunexploitant');
create type public.typeutilisateur as enum ('resposervey','responsable','administrateur','exploitant');
create type public."enumdomaine" as enum ('continent','pays','ville','genre','civilite','operateurtelecom');
create type public."enumnomenclature" as enum ('afrique','europe','amerique','asie','oceanie'
												,'cameroun','rdc','france','bresil','chine','australie'
												,'yaounde','douala'
												,'bandundu','baraka','beni','boende','boma','bukavu','bunia','buta','butembo','gbadolite','gemena','goma','inongo','isoro','kabinda','kalemie','kamina','kananga','kenge','kikwit','kindu','kisangani','kinshasa','kolwesi','likasi','lisala','lubumbashi','lusambo','matadi','mbandaka','mbujimayi','mueneditu','tshikapa','uvira','zongo'
												,'paris','marseille'
												,'riodejaneiro','saopaulo'
												,'pekin','shanghai'
												,'sydney','melbourne'
												,'masculin','feminin'
												,'monsieur','madame','mademoiselle'
												,'orangecmr','mtncmr','camtel'
												,'africellrdc','airtelcongordc','ephratatelecom','ghinvestment','orangerdc','smiletelecom','standartelecom','tatemtelecom','vodacomcongordc');
											
create or replace function public.existenceschema(pnomschema public.nom)
 	returns boolean
 	language plpgsql
	as $$
	declare
		resp boolean = false;
	begin
		execute format('select exists (select schema_name  from information_schema.schemata  where schema_name = $1)')
		into resp
		using pnomschema;
		return resp;
	end
	$$;

create or replace function public.existencetable(pnomschema public.nom, pnomtable public.nom)
 	returns boolean
 	language plpgsql
	as $$
	declare
		resp boolean = false;
	begin
		assert(pnomschema is not null),'Le nom du schema est vide.';
		assert(public.existenceschema(pnomschema)),'Le schema <'|| pnomschema ||'> n''existe pas.';
	
		execute format('select exists (select * from information_schema.tables where table_schema = $1 and table_name = $2)')
		into resp
		using pnomschema, pnomtable;
		return resp;
	end
	$$;

create or replace function public.existencetable(pnomtable public.nom)
 	returns boolean
 	language plpgsql
	as $$
	declare
		resp boolean = false;
	begin
		execute format('select exists (select * from information_schema.tables where table_name = $1)')
		into resp
		using pnomtable;
		return resp;
	end
	$$;

create or replace function public.existencetuple(pnomschema public.nom, pnomtable public.nom, pnomcolonnecode public.nom, pcode public.nom)
 	returns boolean
 	language plpgsql
	as $$
	declare
		resp boolean = false;
	begin
		execute format('select exists (select * from '||pnomschema||'.'||pnomtable||' where lower('||pnomcolonnecode||') = LOWER($1))')
		into resp
		using pcode;
		return resp;
	end
	$$;

create or replace function public.existencetuple(pnomschema public.nom, pnomtable public.nom, pnomcolonnecode public.nom, pcode public.isolangue)
 	returns boolean
 	language plpgsql
	as $$
	declare
		resp boolean = false;
	begin
		execute format('select exists (select * from '||pnomschema||'.'||pnomtable||' where '||pnomcolonnecode||' = $1)')
		into resp
		using pcode;
		return resp;
	end
	$$;

create or replace function public.existencetuple(pnomschema public.nom, pnomtable public.nom, pnomcolonnecode public.nom, pcode public.habilitation)
 	returns boolean
 	language plpgsql
	as $$
	declare
		resp boolean = false;
	begin
		execute format('select exists (select * from '||pnomschema||'.'||pnomtable||' where '||pnomcolonnecode||' = $1)')
		into resp
		using pcode;
		return resp;
	end
	$$;

create or replace function public.obtentionordremax(pnomschema public.nom, pnomtab public.nom, pnomcolonneord public.nom)
 	returns public.enaturelnn
 	language plpgsql
	as $$
	declare
	vordmax public.enaturelnn;
	begin 
 		execute format('select coalesce (max('||pnomcolonneord||')+1,1) from '||pnomschema||'.'||pnomtab||'')
 		into vordmax;
 		return vordmax;
	end
	$$;

create or replace function public.obtentionombretuple(pnomschema public.nom, pnomtable public.nom)
 	returns public.enaturel
 	language plpgsql
	as $$
	declare
		vcount public.enaturel;
	begin
		assert(pnomschema is not null),'Le nom du schema est vide.';
		assert(public.existenceschema(pnomschema)),'Le schema <'|| pnomschema ||'> n''existe pas.';
		assert(pnomtable is not null),'Le nom de la table est vide.';
		assert(public.existencetable(pnomschema, pnomtable)),'La table <'|| pnomtable ||'> n''existe pas.';
	
		execute format('select count(*) from '|| pnomschema ||'.'|| pnomtable ||' where etat in (1,2)')
		into vcount;
		return vcount;
	end
	$$;

create or replace procedure public.attacher(pnomschema public.nom, pnomtable public.nom, pnomcolonnecode public.nom, pcode public.identifiant)
	language plpgsql
	as $$
	declare
		vcardprec public.enaturel; 
		vcard public.enaturel; 
	begin
	
		assert(public.existenceschema(pnomschema)),'La schema est absent de la base de donnees.';
		assert(public.existencetable(pnomschema, pnomtable)),'La table est absente de la base de donnees.';
		assert(public.existencetuple(pnomschema, pnomtable, pnomcolonnecode, pcode)),'Ce tuple est absent de la table.';
		execute format('select card from '|| pnomschema ||'.'|| pnomtable ||' where '|| pnomcolonnecode ||' = $1')
		into vcardprec
		using pcode;
	
		execute format('update '|| pnomschema ||'.'|| pnomtable ||' set card = card + 1, etat = 2, dateupda = current_timestamp where '|| pnomcolonnecode ||' = $1')
		using pcode;
		
		execute format('select card from '|| pnomschema ||'.'|| pnomtable ||' where '|| pnomcolonnecode ||' = $1')
		into vcard
		using pcode;
		assert(vcard = vcardprec + 1),'Incoherences des donnees apres attachement.';
		
	end
	$$;

create or replace procedure public.detacher(pnomschema public.nom, pnomtable public.nom, pnomcolonnecode public.nom, pcode public.identifiant)
	language plpgsql
	as $$
	declare
		vcardprec public.enaturel; 
		vcard public.enaturel; 
	begin
	
		assert(public.existenceschema(pnomschema)),'La schema est absent de la base de donnees.';
		assert(public.existencetable(pnomschema, pnomtable)),'La table est absente de la base de donnees.';
		assert(public.existencetuple(pnomschema, pnomtable, pnomcolonnecode, pcode)),'Ce tuple est absent de la table.';
		execute format('select card from '|| pnomschema ||'.'|| pnomtable ||' where '|| pnomcolonnecode ||' = $1')
		into vcardprec
		using pcode;
		assert(vcardprec > 0),'Incoherences des donnees avant le detachement.';
	
		execute format('update '|| pnomschema ||'.'|| pnomtable ||' set card = card - 1, etat = case when card - 1 = 0 then 1 else 2 end, dateupda = current_timestamp where '|| pnomcolonnecode ||' = $1')
		using pcode;
		
		execute format('select card from '|| pnomschema ||'.'|| pnomtable ||' where '|| pnomcolonnecode ||' = $1')
		into vcard
		using pcode;
		assert(vcard = vcardprec - 1),'Incoherences des donnees apres detachement.';
		
	end
	$$;

create or replace procedure public.supprimer(pnomschema public.nom, pnomtable public.nom, pnomcolonnecode public.nom, pcode public.identifiant)
	language plpgsql
	as $$
	declare
		vcard public.enaturel; 
		vetat public.etat; 
	begin
	
		assert(public.existenceschema(pnomschema)),'La schema est absent de la base de donnees.';
		assert(public.existencetable(pnomschema, pnomtable)),'La table est absente de la base de donnees.';
		assert(public.existencetuple(pnomschema, pnomtable, pnomcolonnecode, pcode)),'Ce tuple est absent de la table.';
		execute format('select etat, card from '|| pnomschema ||'.'|| pnomtable ||' where '|| pnomcolonnecode ||' = $1')
		into vetat, vcard
		using pcode;
		assert(vcard = 0 and vetat = 1),'Incoherences des donnees avant la suppression. card=<'|| vcard ||'> et etat=<'|| vetat ||'>';
	
		execute format('update '|| pnomschema ||'.'|| pnomtable ||' set etat = 3, dateupda = current_timestamp where '|| pnomcolonnecode ||' = $1')
		using pcode;
		
		execute format('select etat, card from '|| pnomschema ||'.'|| pnomtable ||' where '|| pnomcolonnecode ||' = $1')
		into vetat, vcard
		using pcode;
		assert(vcard = 0 and vetat = 3),'Incoherences des donnees apres la suppression.';
	
		execute format('delete from '|| pnomschema ||'.'|| pnomtable ||' where '|| pnomcolonnecode ||' = $1')
		using pcode;
		
	end
	$$;

create or replace procedure public.mettreajouretatuple(pnomschema public.nom, pnomtable public.nom, pnomcolonnecode public.nom, pcode public.identifiant, petat public.etat, pdateupda timestamp)
 	language plpgsql
	as $$
	declare
		vetat public.etat;
		vdateupda timestamp;
	begin
		assert(pnomschema is not null),'Le nom du schema est vide.';
		assert(public.existenceschema(pnomschema)),'Le schema <'|| pnomschema ||'> n''existe pas.';
		assert(pnomtable is not null),'Le nom de la table est vide.';
		assert(public.existencetable(pnomschema, pnomtable)),'La table <'|| pnomtable ||'> n''existe pas.';
		assert(pnomcolonnecode is not null),'Le nom de la colonne code de la table est vide.';
		assert(pcode is not null),'L''identifiant du tuple de la table est vide.';
		assert(public.existencetuple(pnomschema, pnomtable, pnomcolonnecode, pcode)),'Le tuple d''identifiant <'|| pcode ||'> n''existe pas.';
		assert(petat is not null),'L''etat est vide.';
		assert(petat >= 1 and petat <= 3),'L''etat est vide.';
		assert(pdateupda is not null),'La date de mise a jour est vide.';
		execute format('select dateupda from '|| pnomschema ||'.'|| pnomtable ||' where '|| pnomcolonnecode ||' = $1')
		into vdateupda
		using pcode;
		assert(pdateupda >= vdateupda or vdateupda is null);
	
		execute format('update '|| pnomschema ||'.'|| pnomtable ||' set etat = $1, dateupda = $2 where '|| pnomcolonnecode ||' = $3')
		using petat, pdateupda, pcode;
		
		execute format('select etat, dateupda from '|| pnomschema ||'.'|| pnomtable ||' where '|| pnomcolonnecode ||' = $1')
		into vetat, vdateupda
		using pcode;
		assert(vetat = petat),'Incoherence des donnees mises a jour. etat';
		assert(vdateupda = pdateupda),'Incoherence des donnees mises a jour. dateupda';
	end
	$$;

create or replace function public.cryptagemotdepasse(pmdp public.nom, psel public.identifiant, pdatecrea timestamp)
 	returns public.motdepasse
 	language plpgsql
	as $$
	declare
		vhash public.nom;
		vminute integer;
	begin
		vminute := extract(minute from pdatecrea);
		vhash := pmdp || '' || psel;
		vhash := md5(vhash::bytea);
		while vminute > 0 loop
			vhash := md5(vhash::bytea);
			vminute := vminute - 1;
		end loop;
		return vhash;
	end
	$$;

-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== Initialiser la base de donnees
-- ==========================================================================================================================================
create or replace procedure public.initialiserdonnees()
	language plpgsql
	as $$
	declare
		vcodeprofil public.identifiant;
		vcodecompte public.identifiant;
		vcodecommis public.identifiant;
		vcodesdroit public.identifiant array[1];
		vdroits public.identifiant array[1];
		vcodesvue public.identifiant array[1];
		vcodesptrav public.identifiant array[1];
		vcodesprofil public.identifiant array[1];
		vcodescompo public.identifiant array[1];
		vcodeconten public.identifiant;
		vcodevalconten public.identifiant;
		vcodenreg public.identifiant;
		venregistrement record;
		vcodesdom public.identifiant array[1];
		vcodesnomen public.identifiant array[1];
		vcodevalnomen public.identifiant;
	begin 
		
		call cudincrement.ajouterincrement('fichier', 'fich');
			
		call cudincrement.ajouterincrement('domaine', 'domai');
		call cudincrement.ajouterincrement('nomenclature', 'nomen');
		call cudincrement.ajouterincrement('valeurnomenclature', 'valno');
	
		call cudincrement.ajouterincrement('droit', 'droit');
		call cudincrement.ajouterincrement('espacetravail', 'sptrv');
		call cudincrement.ajouterincrement('profil', 'profi');
		call cudincrement.ajouterincrement('compte', 'cpte');
		call cudincrement.ajouterincrement('connexion', 'conn');
		call cudincrement.ajouterincrement('activite', 'activ');
	
		call cudincrement.ajouterincrement('vue', 'vue');
		call cudincrement.ajouterincrement('composant', 'compo');
		call cudincrement.ajouterincrement('contenu', 'conte');
		call cudincrement.ajouterincrement('valeurcontenu', 'vcont');
	
		call cudincrement.ajouterincrement('enregistrement', 'enreg');
		call cudincrement.ajouterincrement('utilisateur', 'utili');
		call cudincrement.ajouterincrement('resposervey', 'reser');
		call cudincrement.ajouterincrement('responsable', 'respo');
		call cudincrement.ajouterincrement('exploitant', 'expl');
		call cudincrement.ajouterincrement('administrateur', 'admin');
	
		call cudincrement.ajouterincrement('photo', 'photo');
		call cudincrement.ajouterincrement('wifi', 'wifi');
		call cudincrement.ajouterincrement('site', 'site');
		call cudincrement.ajouterincrement('servey', 'serve');
	
		vcodesdom[0] := cuddomaine.creationdomaine('continent', 'continent', 1, convert_from('Les continents de la planète terre.', 'WIN1252'), null, null);
		vcodesdom[1] := cuddomaine.creationdomaine('pays', 'pays', 2, convert_from('Les pays d''un continent.', 'WIN1252'), vcodesdom[0], null);
		vcodesdom[2] := cuddomaine.creationdomaine('ville', 'ville', 2, convert_from('Les villes d''un pays.', 'WIN1252'), vcodesdom[1], null);
		vcodesdom[3] := cuddomaine.creationdomaine('genre', 'genre', 1, convert_from('Les différentes genres.', 'WIN1252'), null, null);
		vcodesdom[4] := cuddomaine.creationdomaine('civilite', 'civilite', 2, convert_from('Les différentes civilités.', 'WIN1252'), vcodesdom[3], null);
		vcodesdom[5] := cuddomaine.creationdomaine('operateurtelecom', 'operateurtelecom', 2, convert_from('Les opérateurs de télécoms de la RDC.', 'WIN1252'), vcodesdom[1], null);
		
		vcodesnomen[0] := cuddomaine.creationomenclature('afrique', 'continent', null, null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[0], null, convert_from('Afrique', 'WIN1252'), convert_from('Continent africain.', 'WIN1252'));	
		vcodesnomen[1] := cuddomaine.creationomenclature('europe', 'continent', null, null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[1], null, convert_from('Europe', 'WIN1252'), convert_from('Continent européen.', 'WIN1252'));
		vcodesnomen[2] := cuddomaine.creationomenclature('amerique', 'continent', null, null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[2], null, convert_from('Amérique', 'WIN1252'), convert_from('Continent américain.', 'WIN1252'));
		vcodesnomen[3] := cuddomaine.creationomenclature('asie', 'continent', null, null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[3], null, convert_from('Asie', 'WIN1252'), convert_from('Continent asiatique.', 'WIN1252'));
		vcodesnomen[4] := cuddomaine.creationomenclature('oceanie', 'continent', null, null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[4], null, convert_from('Océanie', 'WIN1252'), convert_from('Continent océanie.', 'WIN1252'));
		
		vcodesnomen[5] := cuddomaine.creationomenclature('cameroun','pays', vcodesnomen[0], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[5], null, convert_from('Cameroun', 'WIN1252'), convert_from('Pays le Cameroun.', 'WIN1252'));
		vcodesnomen[6] := cuddomaine.creationomenclature('rdc','pays', vcodesnomen[0], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[6], null, convert_from('RDC', 'WIN1252'), convert_from('Pays la République Démocratique du Congo.', 'WIN1252'));		
		vcodesnomen[7] := cuddomaine.creationomenclature('france','pays', vcodesnomen[1], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[7], null, convert_from('France', 'WIN1252'), convert_from('Pays la France.', 'WIN1252'));
		vcodesnomen[8] := cuddomaine.creationomenclature('bresil','pays', vcodesnomen[2], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[8], null, convert_from('Brésil', 'WIN1252'), convert_from('Pays le Brésil.', 'WIN1252'));
		vcodesnomen[9] := cuddomaine.creationomenclature('chine','pays', vcodesnomen[3], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[9], null, convert_from('Chine', 'WIN1252'), convert_from('Pays la Chine.', 'WIN1252'));
		vcodesnomen[10] := cuddomaine.creationomenclature('australie','pays', vcodesnomen[4], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[10], null, convert_from('Australie', 'WIN1252'), convert_from('Pays l''Australie.', 'WIN1252'));
		
		vcodesnomen[11] := cuddomaine.creationomenclature('yaounde','ville', vcodesnomen[5], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[11], null, convert_from('Yaoundé', 'WIN1252'), convert_from('La ville capitale du Cameroun.', 'WIN1252'));	
		vcodesnomen[12] := cuddomaine.creationomenclature('douala','ville', vcodesnomen[5], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[12], null, convert_from('Douala', 'WIN1252'), convert_from('La ville capitale économique du Cameroun.', 'WIN1252'));
		vcodesnomen[13] := cuddomaine.creationomenclature('bandundu','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[13], null, convert_from('Bandundu', 'WIN1252'), convert_from('La ville de Bandundu.', 'WIN1252'));	
		vcodesnomen[14] := cuddomaine.creationomenclature('baraka','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[14], null, convert_from('Baraka', 'WIN1252'), convert_from('La ville de Baraka.', 'WIN1252'));
		vcodesnomen[15] := cuddomaine.creationomenclature('beni','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[15], null, convert_from('Beni', 'WIN1252'), convert_from('La ville de Beni.', 'WIN1252'));	
		vcodesnomen[16] := cuddomaine.creationomenclature('boende','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[16], null, convert_from('Boende', 'WIN1252'), convert_from('La ville de Boende.', 'WIN1252'));
		vcodesnomen[17] := cuddomaine.creationomenclature('boma','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[17], null, convert_from('Boma', 'WIN1252'), convert_from('La ville de Boma.', 'WIN1252'));	
		vcodesnomen[18] := cuddomaine.creationomenclature('bukavu','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[18], null, convert_from('Bukavu', 'WIN1252'), convert_from('La ville de Bukavu.', 'WIN1252'));
		vcodesnomen[19] := cuddomaine.creationomenclature('bunia','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[19], null, convert_from('Bunia', 'WIN1252'), convert_from('La ville de Bunia.', 'WIN1252'));	
		vcodesnomen[20] := cuddomaine.creationomenclature('buta','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[20], null, convert_from('Buta', 'WIN1252'), convert_from('La ville de Buta.', 'WIN1252'));
		vcodesnomen[21] := cuddomaine.creationomenclature('butembo','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[21], null, convert_from('Butembo', 'WIN1252'), convert_from('La ville de Butembo.', 'WIN1252'));	
		vcodesnomen[22] := cuddomaine.creationomenclature('gbadolite','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[22], null, convert_from('Gbadolite', 'WIN1252'), convert_from('La ville de Gbadolite.', 'WIN1252'));
		vcodesnomen[23] := cuddomaine.creationomenclature('gemena','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[23], null, convert_from('Gemena', 'WIN1252'), convert_from('La ville de Gemena.', 'WIN1252'));	
		vcodesnomen[24] := cuddomaine.creationomenclature('goma','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[24], null, convert_from('Goma', 'WIN1252'), convert_from('La ville de Goma.', 'WIN1252'));
		vcodesnomen[25] := cuddomaine.creationomenclature('inongo','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[25], null, convert_from('Inongo', 'WIN1252'), convert_from('La ville de Inongo.', 'WIN1252'));	
		vcodesnomen[26] := cuddomaine.creationomenclature('isoro','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[26], null, convert_from('Isoro', 'WIN1252'), convert_from('La ville de Isoro.', 'WIN1252'));
		vcodesnomen[27] := cuddomaine.creationomenclature('kabinda','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[27], null, convert_from('Kabinda', 'WIN1252'), convert_from('La ville de Kabinda.', 'WIN1252'));	
		vcodesnomen[28] := cuddomaine.creationomenclature('kalemie','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[28], null, convert_from('Kalemie', 'WIN1252'), convert_from('La ville de Kalemie.', 'WIN1252'));
		vcodesnomen[29] := cuddomaine.creationomenclature('kamina','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[29], null, convert_from('Kamina', 'WIN1252'), convert_from('La ville de Kamina.', 'WIN1252'));	
		vcodesnomen[30] := cuddomaine.creationomenclature('kananga','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[30], null, convert_from('Kananga', 'WIN1252'), convert_from('La ville de Kananga.', 'WIN1252'));
		vcodesnomen[31] := cuddomaine.creationomenclature('kenge','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[31], null, convert_from('Kenge', 'WIN1252'), convert_from('La ville de Kenge.', 'WIN1252'));	
		vcodesnomen[32] := cuddomaine.creationomenclature('kikwit','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[32], null, convert_from('Kikwit', 'WIN1252'), convert_from('La ville de Kikwit.', 'WIN1252'));
		vcodesnomen[33] := cuddomaine.creationomenclature('kindu','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[33], null, convert_from('Kindu', 'WIN1252'), convert_from('La ville de Kindu.', 'WIN1252'));	
		vcodesnomen[34] := cuddomaine.creationomenclature('kisangani','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[34], null, convert_from('Kisangani', 'WIN1252'), convert_from('La ville de Kisangani.', 'WIN1252'));
		vcodesnomen[35] := cuddomaine.creationomenclature('kinshasa','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[35], null, convert_from('Kinshasa', 'WIN1252'), convert_from('La ville de Kinshasa.', 'WIN1252'));	
		vcodesnomen[36] := cuddomaine.creationomenclature('kolwesi','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[36], null, convert_from('Kolwesi', 'WIN1252'), convert_from('La ville de Kolwesi.', 'WIN1252'));
		vcodesnomen[37] := cuddomaine.creationomenclature('likasi','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[37], null, convert_from('Likasi', 'WIN1252'), convert_from('La ville de Likasi.', 'WIN1252'));	
		vcodesnomen[38] := cuddomaine.creationomenclature('lisala','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[38], null, convert_from('Lisala', 'WIN1252'), convert_from('La ville de Lisala.', 'WIN1252'));
		vcodesnomen[39] := cuddomaine.creationomenclature('lubumbashi','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[39], null, convert_from('Lubumbashi', 'WIN1252'), convert_from('La ville de Lubumbashi.', 'WIN1252'));	
		vcodesnomen[40] := cuddomaine.creationomenclature('lusambo','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[40], null, convert_from('Lusambo', 'WIN1252'), convert_from('La ville de Lusambo.', 'WIN1252'));
		vcodesnomen[41] := cuddomaine.creationomenclature('matadi','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[41], null, convert_from('Matadi', 'WIN1252'), convert_from('La ville de Matadi.', 'WIN1252'));	
		vcodesnomen[42] := cuddomaine.creationomenclature('mbandaka','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[42], null, convert_from('Mbandaka', 'WIN1252'), convert_from('La ville de Mbandaka', 'WIN1252'));
		vcodesnomen[43] := cuddomaine.creationomenclature('mbujimayi','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[43], null, convert_from('Mbujimayi', 'WIN1252'), convert_from('La ville de Mbujimayi.', 'WIN1252'));	
		vcodesnomen[44] := cuddomaine.creationomenclature('mueneditu','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[44], null, convert_from('Mueneditu', 'WIN1252'), convert_from('La ville de Mueneditu.', 'WIN1252'));
		vcodesnomen[45] := cuddomaine.creationomenclature('tshikapa','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[45], null, convert_from('Tshikapa', 'WIN1252'), convert_from('La ville de Tshikapa.', 'WIN1252'));	
		vcodesnomen[46] := cuddomaine.creationomenclature('uvira','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[46], null, convert_from('Uvira', 'WIN1252'), convert_from('La ville de Uvira.', 'WIN1252'));
		vcodesnomen[47] := cuddomaine.creationomenclature('zongo','ville', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[47], null, convert_from('Zongo', 'WIN1252'), convert_from('La ville de Zongo.', 'WIN1252'));
		vcodesnomen[48] := cuddomaine.creationomenclature('paris','ville', vcodesnomen[7], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[48], null, convert_from('Paris', 'WIN1252'), convert_from('La ville capitale de la France.', 'WIN1252'));	
		vcodesnomen[49] := cuddomaine.creationomenclature('marseille','ville', vcodesnomen[7], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[49], null, convert_from('Marseille', 'WIN1252'), convert_from('Une autre ville de la France.', 'WIN1252'));
		vcodesnomen[50] := cuddomaine.creationomenclature('riodejaneiro','ville', vcodesnomen[8], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[50], null, convert_from('Rio de Janeiro', 'WIN1252'), convert_from('La ville capitale du Brésil.', 'WIN1252'));	
		vcodesnomen[51] := cuddomaine.creationomenclature('saopaulo','ville', vcodesnomen[8], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[51], null, convert_from('Sao Paulo', 'WIN1252'), convert_from('Une autre ville du Brésil.', 'WIN1252'));
		vcodesnomen[52] := cuddomaine.creationomenclature('pekin','ville', vcodesnomen[9], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[52], null, convert_from('Pékin', 'WIN1252'), convert_from('La ville capitale de la Chine.', 'WIN1252'));	
		vcodesnomen[53] := cuddomaine.creationomenclature('shanghai','ville', vcodesnomen[9], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[53], null, convert_from('Shanghai', 'WIN1252'), convert_from('Une autre ville de la Chine.', 'WIN1252'));
		vcodesnomen[54] := cuddomaine.creationomenclature('sydney','ville', vcodesnomen[10], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[54], null, convert_from('Sydney', 'WIN1252'), convert_from('La ville capitale de l''Australie.', 'WIN1252'));	
		vcodesnomen[55] := cuddomaine.creationomenclature('melbourne','ville', vcodesnomen[10], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[55], null, convert_from('Melbourne', 'WIN1252'), convert_from('Une autre ville de l''Australie.', 'WIN1252'));
		
		vcodesnomen[56] := cuddomaine.creationomenclature('masculin', 'genre', null, null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[56], null, convert_from('Masculin', 'WIN1252'), convert_from('Masculin.', 'WIN1252'));
		vcodesnomen[57] := cuddomaine.creationomenclature('feminin', 'genre', null, null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[57], null, convert_from('Féminin', 'WIN1252'), convert_from('Féminin.', 'WIN1252'));
		
		vcodesnomen[58] := cuddomaine.creationomenclature('monsieur','civilite', vcodesnomen[56], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[58], null, convert_from('Monsieur', 'WIN1252'), convert_from('Monsieur.', 'WIN1252'));		
		vcodesnomen[59] := cuddomaine.creationomenclature('madame','civilite', vcodesnomen[57], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[59], null, convert_from('Madame', 'WIN1252'), convert_from('Madame.', 'WIN1252'));
		vcodesnomen[60] := cuddomaine.creationomenclature('mademoiselle','civilite', vcodesnomen[57], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[60], null, convert_from('Mademoiselle', 'WIN1252'), convert_from('Mademoiselle.', 'WIN1252'));
		
		vcodesnomen[61] := cuddomaine.creationomenclature('orangecmr','operateurtelecom', vcodesnomen[5], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[61], null, convert_from('Orange Cameroun', 'WIN1252'), convert_from('Orange Cameroun.', 'WIN1252'));
		vcodesnomen[62] := cuddomaine.creationomenclature('mtncmr','operateurtelecom', vcodesnomen[5], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[62], null, convert_from('MTN Cameroun', 'WIN1252'), convert_from('MTN Cameroun.', 'WIN1252'));
		vcodesnomen[63] := cuddomaine.creationomenclature('camtel','operateurtelecom', vcodesnomen[5], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[63], null, convert_from('CAMTEL', 'WIN1252'), convert_from('CAMTEL.', 'WIN1252'));
		vcodesnomen[64] := cuddomaine.creationomenclature('africellrdc','operateurtelecom', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[64], null, convert_from('AFRICELL RDC S.A', 'WIN1252'), convert_from('Mademoiselle.', 'WIN1252'));
		vcodesnomen[65] := cuddomaine.creationomenclature('airtelcongordc','operateurtelecom', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[65], null, convert_from('AIRTEL CONGO RDC S.A', 'WIN1252'), convert_from('Mademoiselle.', 'WIN1252'));
		vcodesnomen[66] := cuddomaine.creationomenclature('ephratatelecom','operateurtelecom', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[66], null, convert_from('EPHRATA TELECOM NETWORK SARL', 'WIN1252'), convert_from('Mademoiselle.', 'WIN1252'));
		vcodesnomen[67] := cuddomaine.creationomenclature('ghinvestment','operateurtelecom', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[67], null, convert_from('G.H. INVESTMENT', 'WIN1252'), convert_from('Mademoiselle.', 'WIN1252'));
		vcodesnomen[68] := cuddomaine.creationomenclature('orangerdc','operateurtelecom', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[68], null, convert_from('ORANGE RDC S.A', 'WIN1252'), convert_from('Mademoiselle.', 'WIN1252'));
		vcodesnomen[69] := cuddomaine.creationomenclature('smiletelecom','operateurtelecom', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[69], null, convert_from('SMILE TELECOMMUNICATIONS', 'WIN1252'), convert_from('Mademoiselle.', 'WIN1252'));
		vcodesnomen[70] := cuddomaine.creationomenclature('standartelecom','operateurtelecom', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[70], null, convert_from('STANDARD TELECOM', 'WIN1252'), convert_from('Mademoiselle.', 'WIN1252'));
		vcodesnomen[71] := cuddomaine.creationomenclature('tatemtelecom','operateurtelecom', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[71], null, convert_from('TAT''EM TELECOM', 'WIN1252'), convert_from('Mademoiselle.', 'WIN1252'));
		vcodesnomen[72] := cuddomaine.creationomenclature('vodacomcongordc','operateurtelecom', vcodesnomen[6], null);
		vcodevalnomen := cuddomaine.creationvaleurnomenclature(vcodesnomen[72], null, convert_from('VODACOM CONGO RDC S.A', 'WIN1252'), convert_from('Mademoiselle.', 'WIN1252'));
		
		vcodesdroit[0] := cudsecurite.creationdroit('seconnecter', convert_from('Permet de se connecter à un espace de travail.', 'WIN1252'));
		vcodesdroit[1] := cudsecurite.creationdroit('sedeconnecter', convert_from('Permet de se déconnecter d''un espace de travail.', 'WIN1252'));
		vcodesdroit[2] := cudsecurite.creationdroit('editerleserveys', convert_from('Permet de consulter les serveys.', 'WIN1252'));
		vcodesdroit[3] := cudsecurite.creationdroit('editerunservey', convert_from('Permet de consulter un servey.', 'WIN1252'));
		vcodesdroit[4] := cudsecurite.creationdroit('creerunservey', convert_from('Permet de créer un nouveau servey.', 'WIN1252'));
		vcodesdroit[5] := cudsecurite.creationdroit('modifierunservey', convert_from('Permet de modifier un servey existant.', 'WIN1252'));
		vcodesdroit[6] := cudsecurite.creationdroit('supprimerunservey', convert_from('Permet de supprimer un servey existant.', 'WIN1252'));
		vcodesdroit[7] := cudsecurite.creationdroit('soumettreunservey', convert_from('Permet de soumettre un servey existant.', 'WIN1252'));
		vcodesdroit[8] := cudsecurite.creationdroit('accepterunservey', convert_from('Permet d''acepter un servey soumis.', 'WIN1252'));
		vcodesdroit[9] := cudsecurite.creationdroit('rejeterunservey', convert_from('Permet de rejeter un servey soumis.', 'WIN1252'));
		vcodesdroit[10] := cudsecurite.creationdroit('editerlesimagesunservey', convert_from('Permet de consulter les images d''un servey existant.', 'WIN1252'));
		vcodesdroit[11] := cudsecurite.creationdroit('editeruneimageunservey', convert_from('Permet de consulter une imgage d''un servey existant.', 'WIN1252'));
		vcodesdroit[12] := cudsecurite.creationdroit('creeruneimageunservey', convert_from('Permet de créer une image d''un servey existant.', 'WIN1252'));
		vcodesdroit[13] := cudsecurite.creationdroit('supprimeruneimageunservey', convert_from('Permet de de supprimer une image d''un servey existant.', 'WIN1252'));
	
		vcodesvue[0] := cudcms.creationvue('identificationcompte', convert_from('La vue d''identification d''un compte utilisateur.', 'WIN1252'));
		vcodesvue[1] := cudcms.creationvue('choixprofilconnexion', convert_from('La vue du choix d''un profil de connexion à un espace de travail.', 'WIN1252'));
	
		vcodesvue[2] := cudcms.creationvue('editionserveys', convert_from('Le formulaire d''édition des serveys.', 'WIN1252'));	
		vcodesvue[3] := cudcms.creationvue('editionservey', convert_from('Le formulaire d''édition d''un servey.', 'WIN1252'));	
		vcodesvue[4] := cudcms.creationvue('editionimages', convert_from('Le formulaire d''édition des images des serveys.', 'WIN1252'));	
		vcodesvue[5] := cudcms.creationvue('editionimage', convert_from('Le formulaire d''édition d''une image d''un servey.', 'WIN1252'));
		vcodesvue[6] := cudcms.creationvue('creationservey', convert_from('Le formulaire de création d''un nouveau servey.', 'WIN1252'));		
		vcodesvue[7] := cudcms.creationvue('creationimage', convert_from('Le formulaire de création d''une nouvelle image d''un servey.', 'WIN1252'));	
		vcodesvue[8] := cudcms.creationvue('confirmationcreationservey', convert_from('Le formulaire de confirmation de la création d''un servey.', 'WIN1252'));
		vcodesvue[9] := cudcms.creationvue('confirmationmodificationservey', convert_from('Le formulaire de confirmation de la modification d''un servey.', 'WIN1252'));
		vcodesvue[10] := cudcms.creationvue('confirmatiosuppressionservey', convert_from('Le formulaire de confirmation de la suppression d''un servey.', 'WIN1252'));
		vcodesvue[11] := cudcms.creationvue('confirmationsoumissionservey', convert_from('Le formulaire de confirmation de la soumission d''un servey.', 'WIN1252'));
		vcodesvue[12] := cudcms.creationvue('confirmationacceptationservey', convert_from('Le formulaire de confirmation de l''acceptation d''un servey.', 'WIN1252'));
		vcodesvue[13] := cudcms.creationvue('confirmationrejetservey', convert_from('Le formulaire de confirmation du rejet d''un servey.', 'WIN1252'));
		vcodesvue[14] := cudcms.creationvue('confirmationcreationimage', convert_from('Le formulaire de confirmation de la création d''une image d''un servey.', 'WIN1252'));
		vcodesvue[15] := cudcms.creationvue('confirmatiosuppressionimage', convert_from('Le formulaire de confirmation de la suppression d''une image d''un servey.', 'WIN1252'));
		vcodesvue[16] := cudcms.creationvue('modificationservey', convert_from('Le formulaire de modification d''un servey existant.', 'WIN1252'));	
	
		vcodesptrav[0] := cudsecurite.creationespacetravail('webresposervey', 'https://servey.sowitelgroup.com/resposervey', 'Espace web des responsables des serveys de la plateforme.');
		vcodesprofil[0] := cudsecurite.creationprofil('resposervey', 'responsable des serveys de la plateforme', vcodesptrav[0]);	
		call cudsecurite.mettreajourdroitsespacetravail(vcodesptrav[0], ARRAY[vcodesdroit[2], vcodesdroit[3], vcodesdroit[4], vcodesdroit[5], vcodesdroit[6], vcodesdroit[7], vcodesdroit[10], vcodesdroit[11], vcodesdroit[12], vcodesdroit[13]]);
		call cudcms.mettreajourvuespacetravail(vcodesptrav[0], ARRAY[vcodesvue[2],vcodesvue[3],vcodesvue[4],vcodesvue[5],vcodesvue[6],vcodesvue[7],vcodesvue[8],vcodesvue[9],vcodesvue[10],vcodesvue[11],vcodesvue[14],vcodesvue[15]]);
		call cudcms.mettreajourvuedefautvuespacetravail(vcodesptrav[0], vcodesvue[2]);
	
		vcodesptrav[1] := cudsecurite.creationespacetravail('webresponsable', 'https://servey.sowitelgroup.com/responsable', 'Espace web des responsables de la plateforme.');
		vcodesprofil[1] := cudsecurite.creationprofil('responsable', 'responsable de la plateforme', vcodesptrav[1]);
		call cudsecurite.mettreajourdroitsespacetravail(vcodesptrav[1], ARRAY[vcodesdroit[2], vcodesdroit[3], vcodesdroit[8], vcodesdroit[9], vcodesdroit[10], vcodesdroit[11]]);
		call cudcms.mettreajourvuespacetravail(vcodesptrav[1], ARRAY[vcodesvue[2],vcodesvue[3],vcodesvue[4],vcodesvue[5],vcodesvue[12],vcodesvue[13]]);
		call cudcms.mettreajourvuedefautvuespacetravail(vcodesptrav[1], vcodesvue[2]);
	
		vcodesptrav[2] := cudsecurite.creationespacetravail('webconnexion', 'https://servey.sowitelgroup.com', 'Espace web de connexion de la plateforme.');
		call cudsecurite.mettreajourdroitsespacetravail(vcodesptrav[2], ARRAY[vcodesdroit[0], vcodesdroit[1]]);
		call cudcms.mettreajourvuespacetravail(vcodesptrav[2], ARRAY[vcodesvue[0],vcodesvue[1]]);
		call cudcms.mettreajourvuedefautvuespacetravail(vcodesptrav[2], vcodesvue[0]);
		
		--composants de la vue identificationcompte et choixprofilconnexion
		vcodescompo[0] := cudcms.creationcomposant('enteteconnexionweb', convert_from('Entête du formulaire de connexion web.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('logo', 'Logo de Sowitel.', vcodescompo[0]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', 'images/logo.png', vcodeconten);
		vcodeconten := cudcms.creationcontenu('titre', 'Titre du formulaire de connexion web.', vcodescompo[0]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', 'Bienvenue,', vcodeconten);
		--composants de la vue identificationcompte
		vcodescompo[1] := cudcms.creationcomposant('formidentificationweb', convert_from('Formulaire d''identification du compte utilisateur.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('soustitre', 'Sous-titre du formulaire d''identification web.', vcodescompo[1]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Indiquez vos paramètres de connexion, afin d''être identifié.', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lblogin', 'Label du champ de saisie du login.', vcodescompo[1]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', 'Login', vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbmdp', 'Label du champ de saisie du mot de passe.', vcodescompo[1]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', 'Mot de passe', vcodeconten);
		vcodeconten := cudcms.creationcontenu('valbtnsidentifier', 'Valeur du bouton S''identifier.', vcodescompo[1]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', 'S''identifier', vcodeconten);
		--composants de la vue choixprofilconnexion
		vcodescompo[2] := cudcms.creationcomposant('formchoixprofilconnexionweb', convert_from('Formulaire de choix d''un profil de connexion.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('soustitre', 'Sous-titre du formulaire de choix d''un profil de connexion.', vcodescompo[2]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Choisissez votre profil de connexion.', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbprofils', convert_from('Label du champ de sélection d''un profil.', 'WIN1252'), vcodescompo[2]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', 'Profils', vcodeconten);
		vcodeconten := cudcms.creationcontenu('valbtnvalider', 'Valeur du bouton Valider.', vcodescompo[2]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', 'Valider', vcodeconten);
		vcodeconten := cudcms.creationcontenu('valbtnannuler', 'Valeur du bouton Annuler.', vcodescompo[2]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', 'Annuler', vcodeconten);
		--composants de la vue identificationcompte et choixprofilconnexion
		call cudcms.mettreajourcomposantsvue(vcodesvue[0], array[vcodescompo[0], vcodescompo[1]]);
		call cudcms.mettreajourcomposantsvue(vcodesvue[1], array[vcodescompo[0], vcodescompo[2]]);
	
		--composants de la vue editionserveys
		vcodescompo[3] := cudcms.creationcomposant('navbar', convert_from('La barre haute de l''application.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('imgprofil', convert_from('image de profile pour administrateur.', 'WIN1252'), vcodescompo[3]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('images/avatar.png', 'WIN1252'), vcodeconten);
		
		vcodescompo[4] := cudcms.creationcomposant('sidebar', convert_from('La barre gauche de l''application.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('lbgestionserveys', convert_from('Le label gestions serveys.', 'WIN1252'), vcodescompo[4]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Gestion serveys', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbdeconnexion', convert_from('Bouton pour se decnnecter.', 'WIN1252'), vcodescompo[4]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Déconnexion', 'WIN1252'), vcodeconten);
		
		vcodescompo[5] := cudcms.creationcomposant('gestionbar1', convert_from('La barre de gestion sur édition des serveys.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('lbgestdeserveys', convert_from('Le label gestions des serveys.', 'WIN1252'), vcodescompo[5]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Gestion des serveys', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbeditserveys', convert_from('Le label pour edition serveys.', 'WIN1252'), vcodescompo[5]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Edition des serveys', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btncreerservey', convert_from('Le bouton pour la création des serveys.', 'WIN1252'), vcodescompo[5]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Créer', 'WIN1252'), vcodeconten);
		
		vcodescompo[6] := cudcms.creationcomposant('espacecontenair', convert_from('Espace contenant les serveys.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('lblistserveys', convert_from('Le label pour la liste des serveys.', 'WIN1252'), vcodescompo[6]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Liste serveys', 'WIN1252'), vcodeconten);
		
		vcodescompo[7] := cudcms.creationcomposant('tableserveys', convert_from('Le tableau des serveys.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('colnumeros', convert_from('colonne des numéros des serveys.', 'WIN1252'), vcodescompo[7]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('#', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('colnomsites', convert_from('colonne des noms des sites des serveys.', 'WIN1252'), vcodescompo[7]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Nom du Site', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('colvilles', convert_from('colonne des villes des serveys.', 'WIN1252'), vcodescompo[7]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Ville', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('coldates', convert_from('colonne des dates.', 'WIN1252'), vcodescompo[7]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Date', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('colpays', convert_from('colonne des pays.', 'WIN1252'), vcodescompo[7]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Pays', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('colnomreseaux', convert_from('colonne des réseaux.', 'WIN1252'), vcodescompo[7]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Nom du Réseau', 'WIN1252'), vcodeconten);

		call cudcms.mettreajourcomposantsvue(vcodesvue[2], array[vcodescompo[3], vcodescompo[4], vcodescompo[5], vcodescompo[6], vcodescompo[7]]);
	
		--composants de la vue Editionservey ..............................................................................
		--la vue Editionservey contient egalement les composants Navbar et Sidebar
		
		vcodescompo[8] := cudcms.creationcomposant('gestionbar2', convert_from('La barre de gestion sur édition d''un servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('lbgestunservey', convert_from('Le label pour gestion du servey.', 'WIN1252'), vcodescompo[8]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Gestion du servey', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbeditunservey', convert_from('le label pour edition du servey.', 'WIN1252'), vcodescompo[8]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Edition du servey', 'WIN1252'), vcodeconten);
		
		vcodescompo[9] := cudcms.creationcomposant('enteteservey', convert_from('Partie entete du servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('lbnomsite', convert_from('Le label du nom du site.', 'WIN1252'), vcodescompo[9]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Nom du site', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbpays', convert_from('le label du pays.', 'WIN1252'), vcodescompo[9]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Pays', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbville', convert_from('le label de la ville.', 'WIN1252'), vcodescompo[9]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Ville', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbdate', convert_from('le label de la date.', 'WIN1252'), vcodescompo[9]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Date', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbnomreseau', convert_from('le label du nom du reseau.', 'WIN1252'), vcodescompo[9]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Nom du réseau', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbinfoservey', convert_from('le label informations sur le servey.', 'WIN1252'), vcodescompo[9]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Information sur le servey', 'WIN1252'), vcodeconten);
		
		vcodescompo[10] := cudcms.creationcomposant('bodyservey1', convert_from('Partie body 1 du servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('lbcarateristiques', convert_from('Le label pour la partie caractéristiques.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Caractéristiques', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbimmeuble', convert_from('le label immeuble.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Immeuble ?', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbimbleoui', convert_from('le label immeuble oui', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Oui', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbimblenon', convert_from('le label immeuble non.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Non', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbhauteur', convert_from('le label de la hauteur.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Hauteur', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbdalle', convert_from('le label de dalle.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Dalle ?', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbdaloui', convert_from('le label dalle oui.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Oui', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbdalnon', convert_from('le label dalle non.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Non', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbetatdal', convert_from('le label etats des dalles.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Etats des Dalles', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbsourcelect', convert_from('le label source électrique.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Source électrique ?', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbsourcelectoui', convert_from('le label source électrique oui.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Oui', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbsourcelectnon', convert_from('le label source électrique non.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Non', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbpriseterre', convert_from('le label prise terre.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Prise terre ?', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbpriseterreoui', convert_from('le label prise terre oui.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Oui', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbpriseterrenon', convert_from('le label prise terre non.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Non', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbcoordgps', convert_from('le label coordonnées GPS.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Coordonnées GPS', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lboperateurexist', convert_from('le label opérateur existant.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Opérateur existant ?', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lboperateurexistoui', convert_from('le label opérateur existant oui.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Oui', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lboperateurexistnon', convert_from('le label opérateur existant non.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Non', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lboperateur', convert_from('le label pour l''opérateur existant.', 'WIN1252'), vcodescompo[10]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Opérateur existant', 'WIN1252'), vcodeconten);
		
		vcodescompo[11] := cudcms.creationcomposant('bodyservey2', convert_from('Partie body 2 du servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('lbclientcible', convert_from('Le label pour la partie client cible.', 'WIN1252'), vcodescompo[11]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Client cible', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbmobile', convert_from('Le label pour mobile.', 'WIN1252'), vcodescompo[11]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Mobile', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbbtob', convert_from('le label pour B to B.', 'WIN1252'), vcodescompo[11]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('B to B', 'WIN1252'), vcodeconten);
		
		vcodescompo[12] := cudcms.creationcomposant('bodyservey3', convert_from('Partie body 3 du servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('lbscanperiphwifi', convert_from('Le label pour la partie scan périphériques wifi.', 'WIN1252'), vcodescompo[12]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Scan périfériques Wifi', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnwifi', convert_from('Le label pour bouton wifi.', 'WIN1252'), vcodescompo[12]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Wifi', 'WIN1252'), vcodeconten);
		
		vcodescompo[13] := cudcms.creationcomposant('bodyservey4', convert_from('Partie body 4 du servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('lbphotos', convert_from('Le label pour photos.', 'WIN1252'), vcodescompo[13]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Photos', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnphotos', convert_from('bouton photos.', 'WIN1252'), vcodescompo[13]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Photos', 'WIN1252'), vcodeconten);
		
		vcodescompo[14] := cudcms.creationcomposant('footerservey', convert_from('Partie footer du servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('btnmodifservey', convert_from('bouton pour modifier un servey.', 'WIN1252'), vcodescompo[14]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Modifier', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnsuppservey', convert_from('bouton pour supprimer un servey.', 'WIN1252'), vcodescompo[14]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Supprimer', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnsoumservey', convert_from('bouton pour soumettre un servey.', 'WIN1252'), vcodescompo[14]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Soumettre', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnacceptservey', convert_from('bouton pour accepter un servey.', 'WIN1252'), vcodescompo[14]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Accepter', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnrejetservey', convert_from('bouton pour rejeter un servey.', 'WIN1252'), vcodescompo[14]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Rejeter', 'WIN1252'), vcodeconten);

		call cudcms.mettreajourcomposantsvue(vcodesvue[3], array[vcodescompo[3], vcodescompo[4], vcodescompo[8], vcodescompo[9], vcodescompo[10], vcodescompo[11], vcodescompo[12], vcodescompo[13], vcodescompo[14]]);
		
		--composants de la vue Creationservey.............................................................................
		--la vue Créationservey contient egalement les composants Navbar et Sidebar
		
		vcodescompo[15] := cudcms.creationcomposant('entetecreatservey', convert_from('Partie entete pour création du servey.', 'WIN1252'), null);
		--ce composant contient tout le contenu de enteteservey1 d'aboord, plus d'autres elements tels;
		vcodeconten := cudcms.creationcontenu('lbnomsite', convert_from('Le label du nom du site.', 'WIN1252'), vcodescompo[15]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Nom du site', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbpays', convert_from('le label du pays.', 'WIN1252'), vcodescompo[15]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Pays', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbville', convert_from('le label de la ville.', 'WIN1252'), vcodescompo[15]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Ville', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbdate', convert_from('le label de la date.', 'WIN1252'), vcodescompo[15]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Date', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbnomreseau', convert_from('le label du nom du reseau.', 'WIN1252'), vcodescompo[15]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Nom du réseau', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbinfoservey', convert_from('le label informations sur le servey.', 'WIN1252'), vcodescompo[15]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Information sur le servey', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('placenomsite', convert_from('Placeholder du nom du site.', 'WIN1252'), vcodescompo[15]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Nom du site', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('placenomreseau', convert_from('Placeholder du nom du reseau.', 'WIN1252'), vcodescompo[15]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Nom du réseau', 'WIN1252'), vcodeconten);
		
		vcodescompo[16] := cudcms.creationcomposant('bodycreatservey1', convert_from('Partie body 1 pour création du servey.', 'WIN1252'), null);
		--ce composant contient tout le contenu de bodyservey1 d'aboord, plus d'autres elements tels;
		vcodeconten := cudcms.creationcontenu('lbcarateristiques', convert_from('Le label pour la partie caractéristiques.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Caractéristiques', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbimmeuble', convert_from('le label immeuble.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Immeuble ?', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbimbleoui', convert_from('le label immeuble oui', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Oui', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbimblenon', convert_from('le label immeuble non.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Non', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbhauteur', convert_from('le label de la hauteur.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Hauteur', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbdalle', convert_from('le label de dalle.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Dalle ?', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbdaloui', convert_from('le label dalle oui.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Oui', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbdalnon', convert_from('le label dalle non.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Non', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbetatdal', convert_from('le label etats des dalles.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Etats des Dalles', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbsourcelect', convert_from('le label source électrique.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Source électrique ?', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbsourcelectoui', convert_from('le label source électrique oui.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Oui', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbsourcelectnon', convert_from('le label source électrique non.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Non', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbpriseterre', convert_from('le label prise terre.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Prise terre ?', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbpriseterreoui', convert_from('le label prise terre oui.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Oui', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbpriseterrenon', convert_from('le label prise terre non.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Non', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbcoordgps', convert_from('le label coordonnées GPS.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Coordonnées GPS', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lboperateurexist', convert_from('le label opérateur existant.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Opérateur existant ?', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lboperateurexistoui', convert_from('le label opérateur existant oui.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Oui', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lboperateurexistnon', convert_from('le label opérateur existant non.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Non', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lboperateur', convert_from('le label pour l''opérateur existant.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Opérateur existant', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('placehauteur', convert_from('Placeholder pour la hauteur.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Hauteur', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('placetatdal', convert_from('Placeholder pour etat des dalles.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Etat des dalles', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('placelongitude', convert_from('Placeholder pour la longitude.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Longitude', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('placelatitude', convert_from('Placeholder pour la latitude.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Latitude', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('placeadresse', convert_from('Placeholder pour adresse.', 'WIN1252'), vcodescompo[16]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Adresse', 'WIN1252'), vcodeconten);
		
		vcodescompo[17] := cudcms.creationcomposant('bodycreatservey2', convert_from('Partie body 2 pour création du servey.', 'WIN1252'), null);
		--ce composant contient tout le contenu de bodyservey1 d'aboord, plus d'autres elements tels;
		vcodeconten := cudcms.creationcontenu('lbclientcible', convert_from('Le label pour la partie client cible.', 'WIN1252'), vcodescompo[17]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Client cible', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbmobile', convert_from('Le label pour mobile.', 'WIN1252'), vcodescompo[17]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Mobile', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbbtob', convert_from('le label pour B to B.', 'WIN1252'), vcodescompo[17]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('B to B', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('placembile', convert_from('Placeholder pour mobile.', 'WIN1252'), vcodescompo[17]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Mobile', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('placebtob', convert_from('Placeholder pour B to B.', 'WIN1252'), vcodescompo[17]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('B to B', 'WIN1252'), vcodeconten);
	
		
		vcodescompo[18] := cudcms.creationcomposant('bodycreatservey4', convert_from('Partie body 4 pour création du servey.', 'WIN1252'), null);
		--ce composant contient tout le contenu de bodyservey1 d'aboord, plus d'autres elements tels;
		vcodeconten := cudcms.creationcontenu('lbphotos', convert_from('Le label pour photos.', 'WIN1252'), vcodescompo[18]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Photos', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnphotos', convert_from('bouton photos.', 'WIN1252'), vcodescompo[18]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Photos', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('placedescriptenviron', convert_from('Placeholder pour la description de l''environnement.', 'WIN1252'), vcodescompo[18]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Description de l''environnement.', 'WIN1252'), vcodeconten);
		
		vcodescompo[19] := cudcms.creationcomposant('footercreatservey', convert_from('Partie footer pour création du servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('btnvalidercreatservey', convert_from('bouton pour valider la création de servey.', 'WIN1252'), vcodescompo[19]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Valider', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnannulercreatservey', convert_from('bouton pour annuler la création de servey.', 'WIN1252'), vcodescompo[19]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Annuler', 'WIN1252'), vcodeconten);
		
		call cudcms.mettreajourcomposantsvue(vcodesvue[6], array[vcodescompo[3], vcodescompo[4]
																, vcodescompo[8], vcodescompo[9], vcodescompo[10], vcodescompo[11], vcodescompo[12], vcodescompo[13]
																, vcodescompo[15], vcodescompo[16], vcodescompo[17], vcodescompo[18], vcodescompo[19]]);
				
		--composants de la vue Modificationservey ..............................................................................
		--la vue Modificationservey contient tout les elements de la vue  creationservey plus les composants suivants;
		
		vcodescompo[20] := cudcms.creationcomposant('footermodifservey', convert_from('Partie footer pour la modification du servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('btnvalidermodifservey', convert_from('bouton pour valider la modification de servey.', 'WIN1252'), vcodescompo[20]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Valider', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnannulermodifservey', convert_from('bouton pour annuler la modification de servey.', 'WIN1252'), vcodescompo[20]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Annuler', 'WIN1252'), vcodeconten);
	
		call cudcms.mettreajourcomposantsvue(vcodesvue[16], array[vcodescompo[3], vcodescompo[4]
																, vcodescompo[8], vcodescompo[9], vcodescompo[10], vcodescompo[11], vcodescompo[12], vcodescompo[13], vcodescompo[14]
																, vcodescompo[15], vcodescompo[16], vcodescompo[17], vcodescompo[18], vcodescompo[19], vcodescompo[20]]);
		
		--composants de la vue Editionimages ..............................................................................
		vcodescompo[21] := cudcms.creationcomposant('suppeditionimages', convert_from('suppression image.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('btnsuppimage', convert_from('bouton pour supprimer une image.', 'WIN1252'), vcodescompo[21]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Valider', 'WIN1252'), vcodeconten);
	
		call cudcms.mettreajourcomposantsvue(vcodesvue[4], array[vcodescompo[21]]);
		
		--composants de la vue Editionimage ..............................................................................
		vcodescompo[22] := cudcms.creationcomposant('modaleditionimage', convert_from('Modal pour editer une image.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('btnback', convert_from('bouton pour retour.', 'WIN1252'), vcodescompo[22]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('images/cancel.png', 'WIN1252'), vcodeconten);
	
		call cudcms.mettreajourcomposantsvue(vcodesvue[5], array[vcodescompo[22]]);
		
		--composants de la vue confirmationsuppressionimage ..............................................................................
		vcodescompo[23] := cudcms.creationcomposant('confirmsuppimages', convert_from('confirmation de la suppression d''une image.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('btnvalidsuppimage', convert_from('bouton pour valider la suppression image.', 'WIN1252'), vcodescompo[23]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Valider', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnannulsuppimage', convert_from('bouton pour annuler la suppression image.', 'WIN1252'), vcodescompo[23]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Annuler', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbconfirmsuppimage', convert_from('label de confirmation de la suppression image.', 'WIN1252'), vcodescompo[23]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Voulez-vous vraiment supprimer cette image ?', 'WIN1252'), vcodeconten);
	
		call cudcms.mettreajourcomposantsvue(vcodesvue[15], array[vcodescompo[23]]);						
									
		--composants de la vue confirmationcreationservey ..............................................................................
		vcodescompo[24] := cudcms.creationcomposant('modalconfirmcreatservey', convert_from('modal de confirmation de la creation servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('btnvalidconfirmcreatservey', convert_from('bouton pour valider la création servey.', 'WIN1252'), vcodescompo[24]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Valider', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnannulconfirmcreatservey', convert_from('bouton pour annuler la création servey.', 'WIN1252'), vcodescompo[24]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Annuler', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbmodalconfcreatservey', convert_from('label de confirmation de la creation servey.', 'WIN1252'), vcodescompo[24]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Voulez-vous vraiment créer ce servey ?', 'WIN1252'), vcodeconten);
		
		call cudcms.mettreajourcomposantsvue(vcodesvue[8], array[vcodescompo[24]]);		
	
		--composants de la vue confirmationmodificationservey ..............................................................................
		vcodescompo[25] := cudcms.creationcomposant('confirmodifservey', convert_from('confirmation de la modification servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('btnvalidconfirmodifservey', convert_from('bouton pour valider la modification servey.', 'WIN1252'), vcodescompo[25]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Valider', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnannulconfirmodifservey', convert_from('bouton pour annuler la modification servey.', 'WIN1252'), vcodescompo[25]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Annuler', 'WIN1252'), vcodeconten);
	
		call cudcms.mettreajourcomposantsvue(vcodesvue[9], array[vcodescompo[25]]);	
	
		--composants de la vue confirmationsuppressionservey ..............................................................................
		vcodescompo[26] := cudcms.creationcomposant('confirsuppservey', convert_from('confirmation de la suppréssion servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('btnvalidconfirmodifservey', convert_from('bouton pour valider la suppréssion servey.', 'WIN1252'), vcodescompo[26]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Valider', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnannulconfirmodifservey', convert_from('bouton pour annuler la suppréssion servey.', 'WIN1252'), vcodescompo[26]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Annuler', 'WIN1252'), vcodeconten);
	
		call cudcms.mettreajourcomposantsvue(vcodesvue[10], array[vcodescompo[26]]);
	
		--composants de la vue confirmationsoumissionservey ..............................................................................
		vcodescompo[27] := cudcms.creationcomposant('confirmsoumservey', convert_from('confirmation de la soumission servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('btnvalidconfirmsoumservey', convert_from('bouton pour valider la soumission servey.', 'WIN1252'), vcodescompo[27]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Valider', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnannulconfirmsoumservey', convert_from('bouton pour annuler la soumission servey.', 'WIN1252'), vcodescompo[27]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Annuler', 'WIN1252'), vcodeconten);
	
		call cudcms.mettreajourcomposantsvue(vcodesvue[11], array[vcodescompo[27]]);

		--composants de la vue confirmationacceptationservey ..............................................................................
		vcodescompo[28] := cudcms.creationcomposant('confirmacceptservey', convert_from('confirmation de la soumission servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('btnvalidconfirmacceptservey', convert_from('bouton pour valider l''acceptation d''un servey.', 'WIN1252'), vcodescompo[28]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Valider', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnannulconfirmacceptservey', convert_from('bouton pour annuler l''acceptation d''un servey.', 'WIN1252'), vcodescompo[28]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Annuler', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbconfirmacceptservey', convert_from('Label pour l''acceptation d''un servey.', 'WIN1252'), vcodescompo[28]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Voulez-vous vraiment accepter ce servey ?', 'WIN1252'), vcodeconten);
	
		call cudcms.mettreajourcomposantsvue(vcodesvue[12], array[vcodescompo[28]]);

		--composants de la vue confirmationrejetservey ...................................................................................
		vcodescompo[29] := cudcms.creationcomposant('confirmrejetservey', convert_from('confirmation de la soumission servey.', 'WIN1252'), null);
		vcodeconten := cudcms.creationcontenu('btnvalidconfirmrejetservey', convert_from('bouton pour valider le rejet  d''un servey.', 'WIN1252'), vcodescompo[29]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Valider', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('btnannulconfirmrejetservey', convert_from('bouton pour annuler le rejet  d''un servey.', 'WIN1252'), vcodescompo[29]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Annuler', 'WIN1252'), vcodeconten);
		vcodeconten := cudcms.creationcontenu('lbconfirmrejetservey', convert_from('Label pour le rejet  d''un servey.', 'WIN1252'), vcodescompo[29]);
		vcodevalconten := cudcms.creationvaleurcontenu('fra', convert_from('Voulez-vous vraiment rejéter ce servey ?', 'WIN1252'), vcodeconten);
	
		call cudcms.mettreajourcomposantsvue(vcodesvue[13], array[vcodescompo[29]]);



		vcodenreg := cudutilisateur.creationenregistrement('resposervey', 'Responsable servey', null, '+237672043519', 'resposervey@sowitelgroup.com', 'resposervey', '12345');
		venregistrement := srutilisateur.obtentionenregistrement(vcodenreg);
		call cudutilisateur.validerenregistrement(vcodenreg, venregistrement.otpenreg);
		vcodenreg := cudutilisateur.creationenregistrement('resposervey', 'TOMUNUA', 'Patrick', '+237672043521', 'patricktomunua@matricomrdc.com', 'resposervey', '12345');
		venregistrement := srutilisateur.obtentionenregistrement(vcodenreg);
		call cudutilisateur.validerenregistrement(vcodenreg, venregistrement.otpenreg);
		vcodenreg := cudutilisateur.creationenregistrement('resposervey', 'MATUSA', 'Arkadie', '+237672043522', 'arkadiematusa@matricomrdc.com', 'resposervey', '12345');
		venregistrement := srutilisateur.obtentionenregistrement(vcodenreg);
		call cudutilisateur.validerenregistrement(vcodenreg, venregistrement.otpenreg);
		vcodenreg := cudutilisateur.creationenregistrement('resposervey', 'MUANDA', 'Beni', '+237672043523', 'benimuanda@matricomrdc.com', 'resposervey', '12345');
		venregistrement := srutilisateur.obtentionenregistrement(vcodenreg);
		call cudutilisateur.validerenregistrement(vcodenreg, venregistrement.otpenreg);
		vcodenreg := cudutilisateur.creationenregistrement('resposervey', 'Info MATRICOM', null, '+237672043524', 'info@matricomrdc.com', 'resposervey', '12345');
		venregistrement := srutilisateur.obtentionenregistrement(vcodenreg);
		call cudutilisateur.validerenregistrement(vcodenreg, venregistrement.otpenreg);
		vcodenreg := cudutilisateur.creationenregistrement('resposervey', 'ELIAKIM', 'Taty Hebreux', '+237672043526', 'tatyeliakimhebreux@matricomrdc.com', 'resposervey', '12345');
		venregistrement := srutilisateur.obtentionenregistrement(vcodenreg);
		call cudutilisateur.validerenregistrement(vcodenreg, venregistrement.otpenreg);
	
		vcodenreg := cudutilisateur.creationenregistrement('responsable', 'Responsable', null, '+237657922668', 'responsable@sowitelgroup.com', 'responsable', '12345');
		venregistrement := srutilisateur.obtentionenregistrement(vcodenreg);
		call cudutilisateur.validerenregistrement(vcodenreg, venregistrement.otpenreg);
		vcodenreg := cudutilisateur.creationenregistrement('responsable', 'BUNSI', 'Flavien', '+237672043525', 'flavienbunsi@matricomrdc.com', 'responsable', '12345');
		venregistrement := srutilisateur.obtentionenregistrement(vcodenreg);
		call cudutilisateur.validerenregistrement(vcodenreg, venregistrement.otpenreg);
	
	end;
	$$;

-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== Vider la base de donnees
-- ==========================================================================================================================================
create or replace procedure public.viderdonnees()
	language plpgsql
	as $$
	declare
	begin 	
		
		truncate table srservey.servey;
		truncate table cudservey.servey cascade;
		truncate table srservey.site;
		truncate table cudservey.site cascade;
		truncate table srservey.photo;
		truncate table cudservey.photo cascade;
		truncate table srservey.wifi;
		truncate table cudservey.wifi cascade;
		truncate table srservey.operateursite;
		truncate table cudservey.operateursite cascade;
		truncate table srservey.photosite;
		truncate table cudservey.photosite cascade;
		truncate table srservey.wifiservey;
		truncate table cudservey.wifiservey cascade;
				
		truncate table srutilisateur.responsable;
		truncate table cudutilisateur.responsable cascade;
		truncate table srutilisateur.resposervey;
		truncate table cudutilisateur.resposervey cascade;
		truncate table srutilisateur.utilisateur;
		truncate table cudutilisateur.utilisateur cascade;
		truncate table srutilisateur.enregistrement;
		truncate table cudutilisateur.enregistrement cascade;
				
		truncate table srcms.valeurcontenu;
		truncate table cudcms.valeurcontenu cascade;
		truncate table srcms.contenu;
		truncate table cudcms.contenu cascade;
		truncate table srcms.composantsvue;
		truncate table cudcms.composantsvue cascade;
		truncate table srcms.composant;
		truncate table cudcms.composant cascade;
		truncate table srcms.vuespacetravail;
		truncate table cudcms.vuespacetravail cascade;
		truncate table srcms.vue;
		truncate table cudcms.vue cascade;
		
		truncate table srsecurite.activite;
		truncate table cudsecurite.activite cascade;
		truncate table srsecurite.connexion;
		truncate table cudsecurite.connexion cascade;
		truncate table srsecurite.droitscompte;
		truncate table cudsecurite.droitscompte cascade;
		truncate table srsecurite.profilscompte;
		truncate table cudsecurite.profilscompte cascade;
		truncate table srsecurite.compte;
		truncate table cudsecurite.compte cascade;
		truncate table srsecurite.droitsprofil;
		truncate table cudsecurite.droitsprofil cascade;
		truncate table srsecurite.profil;
		truncate table cudsecurite.profil cascade;
		truncate table srsecurite.droitsespacetravail;
		truncate table cudsecurite.droitsespacetravail cascade;
		truncate table srsecurite.espacetravail;
		truncate table cudsecurite.espacetravail cascade;
		truncate table srsecurite.droit;
		truncate table cudsecurite.droit cascade;
	
		truncate table srdomaine.valeurnomenclature;
		truncate table cuddomaine.valeurnomenclature cascade;
		truncate table srdomaine.nomenclature;
		truncate table cuddomaine.nomenclature cascade;
		truncate table srdomaine.domaine;
		truncate table cuddomaine.domaine cascade;
	
		truncate table srfichier.fichier;
		truncate table cudfichier.fichier cascade;
	
		truncate table cudincrement.tabincrement;
	end;
	$$;

-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== Creation du role akamcuddbservey
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create role akamcuddbservey with login password 'akamcud';
grant akamcuddbservey to postgres;

-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== Creation du schema cudincrement
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create schema cudincrement;
alter schema cudincrement owner to akamcuddbservey ;

-- ======== Creation de la table tabincrement
-- ==========================================================================================================================================
create table if not exists cudincrement.tabincrement(
	nomtable public.nom not null,
	prefixe public.prefixe not null,
	incr public.enaturel not null default 0,
	incrdate date not null default current_date
);
alter table cudincrement.tabincrement add constraint pktabincrement primary key (nomtable);
alter table cudincrement.tabincrement add constraint unprefixetabincrement unique (prefixe);
alter table cudincrement.tabincrement add constraint chkincrtabincrement check (incr >= 0);
	
create or replace procedure cudincrement.incrementer(pnomtable public.nom)
	language plpgsql
	as $$
	declare
	vincrprec public.enaturel;
	vincr public.enaturel;
	vincrdateprec date;
	vincrdate date;
	begin
	
		assert(pnomtable is not null),'Le nom de la table est absent';
		assert(public.existencetuple('cudincrement', 'tabincrement', 'nomtable', pnomtable)),'Le nom de la table est absente de la table tabincrement.';
	
		execute format('select incr, incrdate from cudincrement.tabincrement where nomtable = $1')
		into vincrprec, vincrdateprec
		using pnomtable;
		if (vincrdateprec = current_date) then
			execute format('update cudincrement.tabincrement set incr = incr + 1 where nomtable = $1')
			using pnomtable;
		else
			execute format('update cudincrement.tabincrement set incr = 1, incrdate = current_date where nomtable = $1')
			using pnomtable;
		end if;		
	
		execute format('select incr, incrdate from cudincrement.tabincrement where nomtable=$1')
		into vincr, vincrdate
		using pnomtable;
		if (vincrdateprec = current_date) then
			assert(vincr = vincrprec + 1),'Incoherence des donnees inserees. incr';
			assert(vincrdate = vincrdateprec),'Incoherence des donnees inserees. incrdate';
		else
			assert(vincr = 1),'Incoherence des donnees inserees. incr';
			assert(vincrdate = current_date),'Incoherence des donnees inserees. incrdate';
		end if;
		
	end
	$$;
	
create or replace function cudincrement.generationidentifiant(pnomtable public.nom)
 	returns public.identifiant
 	language plpgsql
	as $$
	declare
		vincr public.enaturel;
		vpref public.prefixe;
		vjour varchar(2);
		vmois varchar(2);
		van varchar(4);
		vcode varchar(20);
		vcodepref varchar(20);
	begin
		assert(pnomtable is not null),'Le nom de la table est absent.';
		assert(public.existencetuple('cudincrement', 'tabincrement', 'nomtable', pnomtable)),'il n existe pas d''increment pour cette table.';
		
		call cudincrement.incrementer(pnomtable);
		execute format('select incr, prefixe from cudincrement.tabincrement where nomtable = $1')
		into vincr, vpref
		using pnomtable;
		vjour := extract(day from current_timestamp);
		vmois := extract (month from current_timestamp);
		van := extract (year from current_timestamp);
		vcodepref := vpref || vjour || vmois || van;
		vcode := vcodepref;
		for i in (length(vcodepref)+1)..(20-length(vincr::varchar))
			loop
				vcode := vcode || 0;
			end loop;
		vcode := vcode || vincr;
		
		return vcode;
	end
	$$;
	
create or replace procedure cudincrement.ajouterincrement(pnomtable public.nom, pprefixe public.prefixe)
	language plpgsql
	as $$
	declare
	vincr public.enaturel;
	vprefixe public.prefixe;
	begin
	
		assert(public.existencetable(pnomtable)),'Aucune table dans la BD ne porte ce nom.';
		assert(not public.existencetuple('cudincrement', 'tabincrement', 'nomtable', pnomtable)),'Il existe deja un increment pour cette table.';
		assert(not public.existencetuple('cudincrement', 'tabincrement', 'prefixe', pprefixe)),'Il existe deja un prefixe ayant le meme nom.';
	
		execute format('insert into cudincrement.tabincrement(nomtable,prefixe) values($1, $2)')
		using pnomtable, pprefixe;
	
		execute format('select prefixe, incr from cudincrement.tabincrement where nomtable = $1')
		into vprefixe, vincr
		using pnomtable;
		assert(vprefixe = pprefixe),'Incoherence des donnees inserees. prefixe';
		assert(vincr = 0),'Incoherence des donnees inserees. incr';
	end
	$$;
	
-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== Creation du schema cudsecurite
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create schema cudsecurite;
alter schema cudsecurite owner to akamcuddbservey;

-- ======== Creation de la table droit
-- ==========================================================================================================================================
create table cudsecurite.droit(
	codedroit public.identifiant not null,
	nomdroit public.habilitation not null,
	libdroit public.libelle not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudsecurite.droit add constraint pkdroit primary key (codedroit);
alter table cudsecurite.droit add constraint unnomdroit unique (nomdroit);
alter table cudsecurite.droit add constraint chkinvariantcardetatdroit check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudsecurite.droit add constraint chkinvariantdatecreaupdadroit check (datecrea <= dateupda);

create or replace function cudsecurite.creationdroit(pnom public.habilitation, plib public.libelle)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vnom public.habilitation;
		vlib public.libelle;
	begin 
		
		assert(pnom is not null),'Le nom du droit est vide.';
		assert(not public.existencetuple('cudsecurite', 'droit', 'nomdroit', pnom)),'Le nom <'|| pnom ||'> du droit existe deja.';
		assert(plib is not null),'Le libelle du droit est vide.';
		
		vcode := cudincrement.generationidentifiant('droit');
		vordmax := public.obtentionordremax('cudsecurite', 'droit', 'ord');
		execute format('insert into cudsecurite.droit (codedroit, nomdroit, libdroit, ord) values ($1, $2, $3, $4)')
		using vcode, pnom, plib, vordmax;
	
		execute format('select nomdroit, libdroit from cudsecurite.droit where codedroit = $1')
		into vnom, vlib
		using vcode;	
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomdroit';
		assert(vlib = plib),'Incoherence sur les donnees inserees. libdroit';
		
		return vcode;
	end;
	$$;

create or replace function cudsecurite.aftercreationdroit()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		
		call srsecurite.ajouterdroit(new.codedroit, new.nomdroit, new.libdroit, new.etat, new.ord, new.datecrea);	
		return null;
	
	end;
	$$;	

create trigger ajoutdroit after insert on cudsecurite.droit for each row execute function cudsecurite.aftercreationdroit();

create or replace procedure cudsecurite.modifierdroit(pcode public.identifiant, pnom public.habilitation, plib public.libelle)
	language plpgsql
	as $$
	declare
		vnom public.habilitation;
		vlib public.libelle;
	begin 
		
		assert(pcode is not null),'Le code du droit est vide.';
		assert(public.existencetuple('cudsecurite', 'droit', 'codedroit', pcode)),'Le code <'|| pcode ||'> du droit est inconnu.';	
		assert(pnom is not null),'Le nom du droit est vide.';
		execute format('select nomdroit from cudsecurite.droit where codedroit = $1')
		into vnom
		using pcode;
		if (vnom != pnom) then			
			assert(not public.existencetuple('cudsecurite', 'droit', 'nomdroit', pnom)),'Le nom <'|| pnom ||'> du droit existe deja.';
		end if;
		assert(plib is not null),'Le libelle du droit est vide.';
		
		execute format('update cudsecurite.droit set nomdroit = $1, libdroit = $2, dateupda = current_timestamp where codedroit = $3')
		using pnom, plib, pcode;
	
		execute format('select nomdroit, libdroit from cudsecurite.droit where codedroit = $1')
		into vnom, vlib
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees mises a jour. nomdroit';
		assert(vlib = plib),'Incoherence sur les donnees mises a jour. libdroit';
		
	end;
	$$;

create or replace procedure cudsecurite.supprimerdroit(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudsecurite', 'droit', 'codedroit', pcode)),'Le code <'|| pcode ||'> du droit est inconnu.';	
		
		call public.supprimer('cudsecurite', 'droit', 'codedroit', pcode);
	
		assert(not public.existencetuple('cudsecurite', 'droit', 'codedroit', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudsecurite.aftermiseajourdroit()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srsecurite', 'droit', 'codedroit', old.codedroit, new.etat, new.dateupda);
		else
			call srsecurite.mettreajourdroit(old.codedroit, new.nomdroit, new.libdroit, new.dateupda);
		end if;	
		return null;
	
	end;
	$$;	

create trigger miseajourdroit after update on cudsecurite.droit for each row execute function cudsecurite.aftermiseajourdroit();

create or replace function cudsecurite.aftersuppressiondroit()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		return null;
	
	end;
	$$;	

create trigger suppressiondroit after delete on cudsecurite.droit for each row execute function cudsecurite.aftersuppressiondroit();

-- ======== Creation de la table espacetravail
-- ==========================================================================================================================================
create table cudsecurite.espacetravail(
	codesptrav public.identifiant not null,
	nomesptrav public.nom not null,
	lienesptrav public.nom null,
	libesptrav public.libelle not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudsecurite.espacetravail add constraint pkespacetravail primary key (codesptrav);
alter table cudsecurite.espacetravail add constraint unnomesptrav unique (nomesptrav);
alter table cudsecurite.espacetravail add constraint chkinvariantcardetatespacetravail check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudsecurite.espacetravail add constraint chkinvariantdatecreaupdaespacetravail check (datecrea <= dateupda);

create or replace function cudsecurite.creationespacetravail(pnom public.nom, plien public.nom, plib public.libelle)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vnom public.nom;
		vlien public.nom;
		vlib public.libelle;
	begin 
		
		assert(pnom is not null),'Le nom de l''espace de travail est vide.';
		assert(not public.existencetuple('cudsecurite', 'espacetravail', 'nomesptrav', pnom)),'Le nom <'|| pnom ||'> de l''espace de travail existe deja.';
		assert(plib is not null),'Le libelle de l''espace de travail est vide.';
		
		vcode := cudincrement.generationidentifiant('espacetravail');
		vordmax := public.obtentionordremax('cudsecurite', 'espacetravail', 'ord');
		execute format('insert into cudsecurite.espacetravail (codesptrav, nomesptrav, lienesptrav, libesptrav, ord) values ($1, $2, $3, $4, $5)')
		using vcode, pnom, plien, plib, vordmax;
	
		execute format('select nomesptrav, lienesptrav, libesptrav from cudsecurite.espacetravail where codesptrav = $1')
		into vnom, vlien, vlib
		using vcode;	
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomesptrav';
		assert(vlien = plien),'Incoherence sur les donnees inserees. lienesptrav';
		assert(vlib = plib),'Incoherence sur les donnees inserees. libesptrav';
		
		return vcode;
	end;
	$$;

create or replace function cudsecurite.aftercreationespacetravail()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		
		call srsecurite.ajouterespacetravail(new.codesptrav, new.nomesptrav, new.lienesptrav, new.libesptrav, new.etat, new.ord, new.datecrea);	
		return null;
	
	end;
	$$;	

create trigger ajoutespacetravail after insert on cudsecurite.espacetravail for each row execute function cudsecurite.aftercreationespacetravail();

create or replace procedure cudsecurite.modifierespacetravail(pcode public.identifiant, pnom public.nom, plien public.nom, plib public.libelle)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vlien public.nom;
		vlib public.libelle;
	begin 
		
		assert(pcode is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('cudsecurite', 'espacetravail', 'codesptrav', pcode)),'Le code <'|| pcode ||'> de l''espace de travail est inconnu.';	
		assert(pnom is not null),'Le nom de l''espace de travail est vide.';
		execute format('select nomesptrav from cudsecurite.espacetravail where codesptrav = $1')
		into vnom
		using pcode;
		if (vnom != pnom) then			
			assert(not public.existencetuple('cudsecurite', 'espacetravail', 'nomesptrav', pnom)),'Le nom <'|| pnom ||'> de l''espace de travail existe deja.';
		end if;
		assert(plib is not null),'Le libelle de l''espace de travail est vide.';
		
		execute format('update cudsecurite.espacetravail set nomesptrav = $1, lienesptrav = $2, libesptrav = $3, dateupda = current_timestamp where codesptrav = $4')
		using pnom, plien, plib, pcode;
	
		execute format('select nomesptrav, lienesptrav, libesptrav from cudsecurite.espacetravail where codesptrav = $1')
		into vnom, vlien, vlib
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees mises a jour. nomesptrav';
		assert(vlien = plien),'Incoherence sur les donnees mises a jour. lienesptrav';
		assert(vlib = plib),'Incoherence sur les donnees mises a jour. libesptrav';
		
	end;
	$$;

create or replace procedure cudsecurite.supprimerespacetravail(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudsecurite', 'espacetravail', 'codesptrav', pcode)),'Le code <'|| pcode ||'> de l''espace de travail est inconnu.';	
		
		call public.supprimer('cudsecurite', 'espacetravail', 'codesptrav', pcode);
	
		assert(not public.existencetuple('cudsecurite', 'espacetravail', 'codesptrav', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudsecurite.aftermiseajourespacetravail()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srsecurite', 'espacetravail', 'codesptrav', old.codesptrav, new.etat, new.dateupda);
		else
			call srsecurite.mettreajourespacetravail(old.codesptrav, new.nomesptrav, new.lienesptrav, new.libesptrav, new.dateupda);
		end if;	
		return null;
	
	end;
	$$;	

create trigger miseajourespacetravail after update on cudsecurite.espacetravail for each row execute function cudsecurite.aftermiseajourespacetravail();

create or replace function cudsecurite.aftersuppressionespacetravail()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		return null;
	
	end;
	$$;	

create trigger suppressionespacetravail after delete on cudsecurite.espacetravail for each row execute function cudsecurite.aftersuppressionespacetravail();

-- ======== Creation de la table droitsespacetravail
-- ==========================================================================================================================================
create table cudsecurite.droitsespacetravail(
	codesptrav public.identifiant not null,
	codedroit public.identifiant not null);

alter table cudsecurite.droitsespacetravail add constraint pkdroitsespacetravail primary key (codesptrav, codedroit);
alter table cudsecurite.droitsespacetravail add constraint fkdroitsespacetravailespacetravail foreign key (codesptrav) references cudsecurite.espacetravail(codesptrav) on delete cascade;
alter table cudsecurite.droitsespacetravail add constraint fkdroitsespacetravaildroit foreign key (codedroit) references cudsecurite.droit(codedroit) on delete cascade;

create or replace procedure cudsecurite.mettreajourdroitsespacetravail(pcodesptrav public.identifiant, pcodesdroits public.identifiant[])
	language plpgsql
	as $$
	declare
		pcodedroit public.identifiant;
		vtrouv boolean;
	begin
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide 1.';
		assert(public.existencetuple('cudsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';
		foreach pcodedroit in array pcodesdroits
		loop
			assert(pcodedroit is not null),'Le code du droit est vide.';
			assert(public.existencetuple('cudsecurite', 'droit', 'codedroit', pcodedroit)),'Le code <'|| pcodedroit ||'> du droit est inconnu.';
		end loop;		
	
		delete from cudsecurite.droitsespacetravail where codesptrav = pcodesptrav;
		foreach pcodedroit in array pcodesdroits
		loop
			insert into cudsecurite.droitsespacetravail(codesptrav, codedroit) values (pcodesptrav, pcodedroit);
		end loop;
		
		foreach pcodedroit in array pcodesdroits
		loop
			execute format('select exists (select * from cudsecurite.droitsespacetravail de where de.codesptrav = $1 and de.codedroit = $2)')
			into vtrouv
			using pcodesptrav, pcodedroit;
			assert(vtrouv),'Incoherences sur les donnees inserees.';
		end loop;
	end;
	$$;

create or replace function cudsecurite.aftersupprimerdroitespacetravail()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srsecurite.retirerdroitespacetravail(old.codesptrav, old.codedroit);
		call public.detacher('cudsecurite', 'espacetravail', 'codesptrav', old.codesptrav);
		call public.detacher('cudsecurite', 'droit', 'codedroit', old.codedroit);
		return null;
	end;
	$$;	

create trigger retraitdroitespacetravail after delete on cudsecurite.droitsespacetravail for each row execute function cudsecurite.aftersupprimerdroitespacetravail();

create or replace function cudsecurite.aftercreerdroitespacetravail()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srsecurite.ajouterdroitespacetravail(new.codesptrav, new.codedroit);
		call public.attacher('cudsecurite', 'espacetravail', 'codesptrav', new.codesptrav);
		call public.attacher('cudsecurite', 'droit', 'codedroit', new.codedroit);
		return null;
	end;
	$$;	

create trigger ajoutdroitespacetravail after insert on cudsecurite.droitsespacetravail for each row execute function cudsecurite.aftercreerdroitespacetravail();

-- ======== Creation de la table profil
-- ==========================================================================================================================================
create table cudsecurite.profil(
	codeprofil public.identifiant not null,
	nomprofil public.nom not null,
	libprofil public.libelle not null,
	codesptrav public.identifiant not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudsecurite.profil add constraint pkprofil primary key (codeprofil);
alter table cudsecurite.profil add constraint unnomprofil unique (nomprofil);
alter table cudsecurite.profil add constraint chkinvariantcardetatprofil check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudsecurite.profil add constraint chkinvariantdatecreaupdaprofil check (datecrea <= dateupda);
alter table cudsecurite.profil add constraint fkprofilespacetravail foreign key (codesptrav) references cudsecurite.espacetravail(codesptrav) on delete cascade;

create or replace function cudsecurite.creationprofil(pnom public.nom, plib public.libelle, pcodesptrav public.identifiant)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vnom public.nom;
		vlib public.libelle;
		vcodesptrav public.identifiant;
	begin 
		
		assert(pnom is not null),'Le nom du profil est vide.';
		assert(not public.existencetuple('cudsecurite', 'profil', 'nomprofil', pnom)),'Le nom <'|| pnom ||'> du profil existe deja.';
		assert(plib is not null),'Le libelle du profil est vide.';
		assert(pcodesptrav is not null),'Le code de l''espace de travail parent du profil est vide.';
		assert(public.existencetuple('cudsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail parent du profil est inconnu.';
		
		vcode := cudincrement.generationidentifiant('profil');
		vordmax := public.obtentionordremax('cudsecurite', 'profil', 'ord');
		execute format('insert into cudsecurite.profil (codeprofil, nomprofil, libprofil, codesptrav, ord) values ($1, $2, $3, $4, $5)')
		using vcode, pnom, plib, pcodesptrav, vordmax;
	
		execute format('select nomprofil, libprofil, codesptrav from cudsecurite.profil where codeprofil = $1')
		into vnom, vlib, vcodesptrav
		using vcode;	
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomprofil';
		assert(vlib = plib),'Incoherence sur les donnees inserees. libprofil';
		assert(vcodesptrav = pcodesptrav),'Incoherence sur les donnees inserees. codesptrav';
		
		return vcode;
	end;
	$$;

create or replace function cudsecurite.aftercreationprofil()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		
		call srsecurite.ajouterprofil(new.codeprofil, new.nomprofil, new.libprofil, new.codesptrav, new.etat, new.ord, new.datecrea);	
		call public.attacher('cudsecurite', 'espacetravail', 'codesptrav', new.codesptrav);
		return null;
	
	end;
	$$;	

create trigger ajoutprofil after insert on cudsecurite.profil for each row execute function cudsecurite.aftercreationprofil();

create or replace procedure cudsecurite.modifierprofil(pcode public.identifiant, pnom public.nom, plib public.libelle)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vlib public.libelle;
	begin 
		
		assert(pcode is not null),'Le code du profil est vide.';
		assert(public.existencetuple('cudsecurite', 'profil', 'codeprofil', pcode)),'Le code <'|| pcode ||'> du profil est inconnu.';	
		assert(pnom is not null),'Le nom du profil est vide.';
		execute format('select nomprofil from cudsecurite.profil where codeprofil = $1')
		into vnom
		using pcode;
		if (vnom != pnom) then			
			assert(not public.existencetuple('cudsecurite', 'profil', 'nomprofil', pnom)),'Le nom <'|| pnom ||'> du profil existe deja.';
		end if;
		assert(plib is not null),'Le libelle du profil est vide.';
		
		execute format('update cudsecurite.profil set nomprofil = $1, libprofil = $2, dateupda = current_timestamp where codeprofil = $3')
		using pnom, plib, pcode;
	
		execute format('select nomprofil, libprofil from cudsecurite.profil where codeprofil = $1')
		into vnom, vlib
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees mises a jour. nomprofil';
		assert(vlib = plib),'Incoherence sur les donnees mises a jour. libprofil';
		
	end;
	$$;

create or replace procedure cudsecurite.supprimerprofil(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudsecurite', 'profil', 'codeprofil', pcode)),'Le code <'|| pcode ||'> du profil est inconnu.';	
		
		call public.supprimer('cudsecurite', 'profil', 'codeprofil', pcode);
	
		assert(not public.existencetuple('cudsecurite', 'profil', 'codeprofil', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudsecurite.aftermiseajourprofil()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srsecurite', 'profil', 'codeprofil', old.codeprofil, new.etat, new.dateupda);
		else
			call srsecurite.mettreajourprofil(old.codeprofil, new.nomprofil, new.libprofil, new.dateupda);
		end if;	
		return null;
	
	end;
	$$;	

create trigger miseajourprofil after update on cudsecurite.profil for each row execute function cudsecurite.aftermiseajourprofil();

create or replace function cudsecurite.aftersuppressionprofil()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		call public.detacher('cudsecurite', 'espacetravail', 'codesptrav', old.codesptrav);
		return null;
	
	end;
	$$;	

create trigger suppressionprofil after delete on cudsecurite.profil for each row execute function cudsecurite.aftersuppressionprofil();

-- ======== Creation de la table droitsprofil
-- ==========================================================================================================================================
create table cudsecurite.droitsprofil(
	codeprofil public.identifiant not null,
	codedroit public.identifiant not null);

alter table cudsecurite.droitsprofil add constraint pkdroitsprofil primary key (codeprofil, codedroit);
alter table cudsecurite.droitsprofil add constraint fkdroitsprofilprofil foreign key (codeprofil) references cudsecurite.profil(codeprofil) on delete cascade;
alter table cudsecurite.droitsprofil add constraint fkdroitsprofildroit foreign key (codedroit) references cudsecurite.droit(codedroit) on delete cascade;

create or replace procedure cudsecurite.mettreajourdroitsprofil(pcodeprofil public.identifiant, pcodesdroits public.identifiant[])
	language plpgsql
	as $$
	declare
		pcodedroit public.identifiant;
		vtrouv boolean;
	begin
		assert(pcodeprofil is not null),'Le code du profil est vide.';
		assert(public.existencetuple('cudsecurite', 'profil', 'codeprofil', pcodeprofil)),'Le code <'|| pcodeprofil ||'> du profil est inconnu.';
		foreach pcodedroit in array pcodesdroits
		loop
			assert(pcodedroit is not null),'Le code du droit est vide.';
			assert(public.existencetuple('cudsecurite', 'droit', 'codedroit', pcodedroit)),'Le code <'|| pcodedroit ||'> du droit est inconnu.';
		end loop;		
	
		delete from cudsecurite.droitsprofil where codeprofil = pcodeprofil;
		foreach pcodedroit in array pcodesdroits
		loop
			insert into cudsecurite.droitsprofil(codeprofil, codedroit) values (pcodeprofil, pcodedroit);
		end loop;
		
		foreach pcodedroit in array pcodesdroits
		loop
			execute format('select exists (select * from cudsecurite.droitsprofil dp where dp.codeprofil = $1 and dp.codedroit = $2)')
			into vtrouv
			using pcodeprofil, pcodedroit;
			assert(vtrouv),'Incoherences sur les donnees inserees.';
		end loop;
	end;
	$$;

create or replace function cudsecurite.aftersupprimerdroitprofil()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srsecurite.retirerdroitprofil(old.codeprofil, old.codedroit);
		call public.detacher('cudsecurite', 'profil', 'codeprofil', old.codeprofil);
		call public.detacher('cudsecurite', 'droit', 'codedroit', old.codedroit);
		return null;
	end;
	$$;	

create trigger retraitdroitprofil after delete on cudsecurite.droitsprofil for each row execute function cudsecurite.aftersupprimerdroitprofil();

create or replace function cudsecurite.aftercreerdroitprofil()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srsecurite.ajouterdroitprofil(new.codeprofil, new.codedroit);
		call public.attacher('cudsecurite', 'profil', 'codeprofil', new.codeprofil);
		call public.attacher('cudsecurite', 'droit', 'codedroit', new.codedroit);
		return null;
	end;
	$$;	

create trigger ajoutdroitprofil after insert on cudsecurite.droitsprofil for each row execute function cudsecurite.aftercreerdroitprofil();

-- ======== Creation de la table compte
-- ==========================================================================================================================================
create table cudsecurite.compte(
	codecompte public.identifiant not null,
	nomcompte public.libelle not null,
	logincompte public.nom not null,
	mdpcompte public.motdepasse not null,
	statutcompte public.etat not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudsecurite.compte add constraint pkcompte primary key (codecompte);
alter table cudsecurite.compte add constraint unlogincompte unique (logincompte);
alter table cudsecurite.compte add constraint chkinvariantcardetatcompte check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudsecurite.compte add constraint chkinvariantdatecreaupdacompte check (datecrea <= dateupda);

create or replace function cudsecurite.creationcompte(pnom public.libelle, plogin public.nom, pmdp public.nom, pstatut public.etat)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vhash public.motdepasse;
		vdatecrea timestamp;
		vcodecompte public.identifiant;
		vnomcompte public.libelle;
		vmdpcompte public.motdepasse;
		vdatecreacompte timestamp;
		vstatut public.etat;
	begin 
				
		assert(pnom is not null),'Le nom du compte est vide.';
		assert(plogin is not null),'Le login du compte est vide.';
		assert(pmdp is not null),'Le mot de passe est vide.';
		assert(pstatut is not null),'Le statut du compte est vide.';
		assert(not public.existencetuple('cudsecurite', 'compte', 'logincompte', plogin)),'Le login <'|| plogin ||'> existe deja.';	
		
		vcode = cudincrement.generationidentifiant('compte');
		vordmax = public.obtentionordremax('cudsecurite', 'compte', 'ord');
		vdatecrea = current_timestamp;
		vhash = public.cryptagemotdepasse(pmdp, vcode, vdatecrea);
		execute format('insert into cudsecurite.compte (codecompte, nomcompte, logincompte, mdpcompte, statutcompte, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7)')
		using vcode, pnom, plogin, vhash, pstatut, vordmax, vdatecrea;
	
		execute format('select codecompte, nomcompte, mdpcompte, statutcompte, datecrea from cudsecurite.compte where logincompte = $1')
		into vcodecompte, vnomcompte, vmdpcompte, vstatut, vdatecreacompte
		using plogin;	
		assert(vcodecompte = vcode),'Incoherence sur les donnees inserees. codecompte';
		assert(vnomcompte = pnom),'Incoherence sur les donnees inserees. nomcompte';
		assert(vmdpcompte = public.cryptagemotdepasse(pmdp, vcodecompte, vdatecreacompte)),'Incoherence sur les donnees inserees. mdpcompte';
		assert(pstatut = vstatut),'Incoherence sur les donnees inserees. statutcompte';
		
		return vcode;
	end;
	$$;

create or replace function cudsecurite.aftercreationcompte()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		
		call srsecurite.ajoutercompte(new.codecompte, new.nomcompte, new.logincompte, new.mdpcompte, new.statutcompte, new.etat, new.ord, new.datecrea);	
		return null;
	
	end;
	$$;	

create trigger ajoutcompte after insert on cudsecurite.compte for each row execute function cudsecurite.aftercreationcompte();

create or replace procedure cudsecurite.modifiercompte(pcode public.identifiant, pnom public.libelle)
	language plpgsql
	as $$
	declare
		vnom public.libelle;
	begin 
		
		assert(pcode is not null),'Le code du compte est vide.';
		assert(public.existencetuple('cudsecurite', 'compte', 'codecompte', pcode)),'Le code <'|| pcode ||'> du compte est inconnu.';	
		assert(pnom is not null),'Le nom du compte est vide.';
		
		execute format('update cudsecurite.compte set nomcompte = $1, dateupda = current_timestamp where codecompte = $2')
		using pnom, pcode;
	
		execute format('select nomcompte from cudsecurite.compte where codecompte = $1')
		into vnom
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees mises a jour. nomcompte';
		
	end;
	$$;

create or replace procedure cudsecurite.modifierlogincompte(pcode public.identifiant, plogin public.nom)
	language plpgsql
	as $$
	declare
		vlogin public.nom;
	begin 
		
		assert(pcode is not null),'Le code du compte est vide.';
		assert(public.existencetuple('cudsecurite', 'compte', 'codecompte', pcode)),'Le code <'|| pcode ||'> du compte est inconnu.';	
		assert(plogin is not null),'Le nouveau login du compte est vide.';
		execute format('select logincompte from cudsecurite.compte where codecompte = $1')
		into vlogin
		using pcode;
		if (vlogin != plogin) then			
			assert(not public.existencetuple('cudsecurite', 'compte', 'logincompte', plogin)),'Le nouveau login <'|| plogin ||'> du compte existe deja.';
		end if;
		
		execute format('update cudsecurite.compte set logincompte = $1, dateupda = current_timestamp where codecompte = $2')
		using plogin, pcode;
	
		execute format('select logincompte from cudsecurite.compte where codecompte = $1')
		into vlogin
		using pcode;	
		assert(vlogin = plogin),'Incoherence sur les donnees mises a jour. logincompte';
		
	end;
	$$;

create or replace procedure cudsecurite.changermdpcompte(pcode public.identifiant, pmdp public.nom)
	language plpgsql
	as $$
	declare
		vmdp public.nom;
		vdatecrea timestamp;
		vhash public.motdepasse;
	begin 
		
		assert(pcode is not null),'Le code du compte est vide.';
		assert(public.existencetuple('cudsecurite', 'compte', 'codecompte', pcode)),'Le code <'|| pcode ||'> du compte est inconnu.';	
		assert(pmdp is not null),'Le nouveau login du compte est vide.';
		
		execute format('select datecrea from cudsecurite.compte where codecompte = $1')
		into vdatecrea
		using pcode;
		vhash = public.cryptagemotdepasse(pmdp, pcode, vdatecrea);
		execute format('update cudsecurite.compte set mdpcompte = $1, dateupda = current_timestamp where codecompte = $2')
		using vhash, pcode;
	
		execute format('select mdpcompte from cudsecurite.compte where codecompte = $1')
		into vmdp
		using pcode;	
		assert(vmdp = vhash),'Incoherence sur les donnees mises a jour. mdpcompte';
		
	end;
	$$;

create or replace procedure cudsecurite.activercompte(pcode public.identifiant)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
	begin 
		
		assert(pcode is not null),'Le code du compte est vide.';
		assert(public.existencetuple('cudsecurite', 'compte', 'codecompte', pcode)),'Le code <'|| pcode ||'> du compte est inconnu.';
		execute format('select statutcompte from cudsecurite.compte where codecompte = $1')
		into vstatut
		using pcode;
		assert(vstatut = 2),'Le statut de ce compte est incohenrent par rapport a l''activation.';
		
		execute format('update cudsecurite.compte set statutcompte = 1, dateupda = current_timestamp where codecompte = $1')
		using pcode;
	
		execute format('select statutcompte from cudsecurite.compte where codecompte = $1')
		into vstatut
		using pcode;	
		assert(vstatut = 1),'Incoherence sur les donnees mises a jour. statutcompte';
		
	end;
	$$;

create or replace procedure cudsecurite.desactivercompte(pcode public.identifiant)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
	begin 
		
		assert(pcode is not null),'Le code du compte est vide.';
		assert(public.existencetuple('cudsecurite', 'compte', 'codecompte', pcode)),'Le code <'|| pcode ||'> du compte est inconnu.';
		execute format('select statutcompte from cudsecurite.compte where codecompte = $1')
		into vstatut
		using pcode;
		assert(vstatut = 1),'Le statut de ce compte est incohenrent par rapport a la desactivation.';
		
		execute format('update cudsecurite.compte set statutcompte = 2, dateupda = current_timestamp where codecompte = $1')
		using pcode;
	
		execute format('select statutcompte from cudsecurite.compte where codecompte = $1')
		into vstatut
		using pcode;	
		assert(vstatut = 2),'Incoherence sur les donnees mises a jour. statutcompte';
		
	end;
	$$;

create or replace procedure cudsecurite.supprimercompte(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudsecurite', 'compte', 'codecompte', pcode)),'Le code <'|| pcode ||'> du compte est inconnu.';	
		
		call public.supprimer('cudsecurite', 'compte', 'codecompte', pcode);
	
		assert(not public.existencetuple('cudsecurite', 'compte', 'codecompte', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudsecurite.aftermiseajourcompte()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srsecurite', 'compte', 'codecompte', old.codecompte, new.etat, new.dateupda);
		end if;	
	
		if (old.nomcompte != new.nomcompte) then 
			call srsecurite.mettreajournomcompte(old.codecompte, new.nomcompte, new.dateupda);
		end if;
	
		if (old.logincompte != new.logincompte) then 
			call srsecurite.mettreajourlogincompte(old.codecompte, new.logincompte, new.dateupda);
		end if;
	
		if (old.mdpcompte != new.mdpcompte) then 
			call srsecurite.mettreajourmdpcompte(old.codecompte, new.mdpcompte, new.dateupda);
		end if;
	
		if ((old.statutcompte = 2) and (new.statutcompte = 1) ) then 
			call srsecurite.mettreajouractivationcompte(old.codecompte, new.statutcompte, new.dateupda);
		end if;
	
		if ((old.statutcompte = 1) and (new.statutcompte = 2) ) then 
			call srsecurite.mettreajourdesactivationcompte(old.codecompte, new.statutcompte, new.dateupda);
		end if;
		return null;
	
	end;
	$$;	

create trigger miseajourcompte after update on cudsecurite.compte for each row execute function cudsecurite.aftermiseajourcompte();

create or replace function cudsecurite.aftersuppressioncompte()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		return null;
	
	end;
	$$;	

create trigger suppressioncompte after delete on cudsecurite.compte for each row execute function cudsecurite.aftersuppressioncompte();

-- ======== Creation de la table profilscompte
-- ==========================================================================================================================================
create table cudsecurite.profilscompte(
	codecompte public.identifiant not null,
	codeprofil public.identifiant not null);

alter table cudsecurite.profilscompte add constraint pkprofilscompte primary key (codecompte, codeprofil);
alter table cudsecurite.profilscompte add constraint fkprofilscomptecompte foreign key (codecompte) references cudsecurite.compte(codecompte) on delete cascade;
alter table cudsecurite.profilscompte add constraint fkprofilscompteprofil foreign key (codeprofil) references cudsecurite.profil(codeprofil) on delete cascade;

create or replace procedure cudsecurite.mettreajourprofilscompte(pcodecompte public.identifiant, pcodesprofils public.identifiant[])
	language plpgsql
	as $$
	declare
		pcodeprofil public.identifiant;
		vtrouv boolean;
	begin
		assert(pcodecompte is not null),'Le code du compte est vide.';
		assert(public.existencetuple('cudsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		foreach pcodeprofil in array pcodesprofils
		loop
			assert(pcodeprofil is not null),'Le code du profil est vide.';
			assert(public.existencetuple('cudsecurite', 'profil', 'codeprofil', pcodeprofil)),'Le code <'|| pcodeprofil ||'> du profil est inconnu.';
		end loop;		
	
		delete from cudsecurite.profilscompte where codecompte = pcodecompte;
		foreach pcodeprofil in array pcodesprofils
		loop
			insert into cudsecurite.profilscompte(codecompte, codeprofil) values (pcodecompte, pcodeprofil);
		end loop;
		
		foreach pcodeprofil in array pcodesprofils
		loop
			execute format('select exists (select * from cudsecurite.profilscompte pc where pc.codecompte = $1 and pc.codeprofil = $2)')
			into vtrouv
			using pcodecompte, pcodeprofil;
			assert(vtrouv),'Incoherences sur les donnees inserees.';
		end loop;
	end;
	$$;

create or replace function cudsecurite.aftersupprimerprofilscompte()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srsecurite.retirerprofilcompte(old.codecompte, old.codeprofil);
		call public.detacher('cudsecurite', 'compte', 'codecompte', old.codecompte);
		call public.detacher('cudsecurite', 'profil', 'codeprofil', old.codeprofil);
		return null;
	end;
	$$;	

create trigger retraitprofilscompte after delete on cudsecurite.profilscompte for each row execute function cudsecurite.aftersupprimerprofilscompte();

create or replace function cudsecurite.aftercreerprofilscompte()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srsecurite.ajouterprofilcompte(new.codecompte, new.codeprofil);
		call public.attacher('cudsecurite', 'compte', 'codecompte', new.codecompte);
		call public.attacher('cudsecurite', 'profil', 'codeprofil', new.codeprofil);
		return null;
	end;
	$$;	

create trigger ajoutprofilscompte after insert on cudsecurite.profilscompte for each row execute function cudsecurite.aftercreerprofilscompte();

-- ======== creation de la table droitscompte
-- ==========================================================================================================================================
create table cudsecurite.droitscompte(
	codecompte public.identifiant not null,
	codedroit public.identifiant not null);

alter table cudsecurite.droitscompte add constraint pkdroitscompte primary key (codecompte, codedroit);
alter table cudsecurite.droitscompte add constraint fkdroitscomptecompte foreign key (codecompte) references cudsecurite.compte(codecompte) on delete cascade;
alter table cudsecurite.droitscompte add constraint fkdroitscomptedroit foreign key (codedroit) references cudsecurite.droit(codedroit) on delete cascade;

create or replace procedure cudsecurite.mettreajourdroitscompte(pcodecompte public.identifiant, pcodesdroits public.identifiant[])
	language plpgsql
	as $$
	declare
		pcodedroit public.identifiant;
		vtrouv boolean;
	begin
		assert(pcodecompte is not null),'Le code du compte est vide.';
		assert(public.existencetuple('cudsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		foreach pcodedroit in array pcodesdroits
		loop
			assert(pcodedroit is not null),'Le code du droit est vide.';
			assert(public.existencetuple('cudsecurite', 'droit', 'codedroit', pcodedroit)),'Le code <'|| pcodedroit ||'> du droit est inconnu.';
		end loop;		
	
		delete from cudsecurite.droitscompte where codecompte = pcodecompte;
		foreach pcodedroit in array pcodesdroits
		loop
			insert into cudsecurite.droitscompte(codecompte, codedroit) values (pcodecompte, pcodedroit);
		end loop;
		
		foreach pcodedroit in array pcodesdroits
		loop
			execute format('select exists (select * from cudsecurite.droitscompte pc where pc.codecompte = $1 and pc.codedroit = $2)')
			into vtrouv
			using pcodecompte, pcodedroit;
			assert(vtrouv),'Incoherences sur les donnees inserees.';
		end loop;
	end;
	$$;

create or replace function cudsecurite.aftersupprimerdroitscompte()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srsecurite.retirerdroitcompte(old.codecompte, old.codedroit);
		call public.detacher('cudsecurite', 'compte', 'codecompte', old.codecompte);
		call public.detacher('cudsecurite', 'droit', 'codedroit', old.codedroit);
		return null;
	end;
	$$;	

create trigger retraitdroitscompte after delete on cudsecurite.droitscompte for each row execute function cudsecurite.aftersupprimerdroitscompte();

create or replace function cudsecurite.aftercreerdroitscompte()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srsecurite.ajouterdroitcompte(new.codecompte, new.codedroit);
		call public.attacher('cudsecurite', 'compte', 'codecompte', new.codecompte);
		call public.attacher('cudsecurite', 'droit', 'codedroit', new.codedroit);
		return null;
	end;
	$$;	

create trigger ajoutdroitscompte after insert on cudsecurite.droitscompte for each row execute function cudsecurite.aftercreerdroitscompte();

-- ======== Creation de la table connexion
-- ==========================================================================================================================================
create table cudsecurite.connexion(
	codeconn public.identifiant not null,
	datedebconn timestamp not null default current_timestamp,
	datefinconn timestamp null,
	nomtermconn public.libelle not null,
	adripconn cidr not null,
	adrmaconn macaddr null,
	statutconn public.etat not null default 1,
	codecompte public.identifiant not null,
	codesptrav public.identifiant not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudsecurite.connexion add constraint pkconnexion primary key (codeconn);
alter table cudsecurite.connexion add constraint chkinvariantcardetatconnexion check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudsecurite.connexion add constraint chkinvariantdatecreaupdaconnexion check (datecrea <= dateupda);
alter table cudsecurite.connexion add constraint chkinvariantdatedebdatefinconnexion check (datedebconn <= datefinconn);
alter table cudsecurite.connexion add constraint fkconnexioncompte foreign key (codecompte) references cudsecurite.compte(codecompte) on delete cascade;
alter table cudsecurite.connexion add constraint fkconnexionespacetravail foreign key (codesptrav) references cudsecurite.espacetravail(codesptrav) on delete cascade;

create or replace function cudsecurite.creationconnexion(pnomterm public.libelle, padrip cidr, padrmac macaddr, pcodecompte public.identifiant, pcodesptrav public.identifiant)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vnomterm public.libelle;
		vadrip cidr;
		vadrmac macaddr;
		vcodecompte public.identifiant;
		vcodesptrav public.identifiant;
		vstatutconn public.etat;
		vtrouv boolean;
	begin 
		
		assert(pnomterm is not null),'Le nom du terminal est vide.';
		assert(padrip is not null),'L''adresse IP est vide.';
		assert(pcodecompte is not null),'Le code du compte est vide.';
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('cudsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		assert(public.existencetuple('cudsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';		
		execute format('select exists (select * from cudsecurite.profilscompte pc inner join cudsecurite.profil p on (p.codeprofil = pc.codeprofil and p.codesptrav = $1) where pc.codecompte = $2)')
		into vtrouv
		using pcodesptrav, pcodecompte;
		assert(vtrouv),'Le compte <'|| pcodecompte ||'> n''a pas le profil pour se connecter a l''espace de travail <'|| pcodesptrav ||'>.';	
		execute format('select codeconn, nomtermconn from cudsecurite.connexion c where c.codecompte = $1 and c.codesptrav = $2 and c.statutconn = 1')
		into vcode, vnomterm
		using pcodecompte, pcodesptrav;
		IF (vcode is null) THEN
			vcode = cudincrement.generationidentifiant('connexion');
			vordmax = public.obtentionordremax('cudsecurite', 'connexion', 'ord');
			execute format('insert into cudsecurite.connexion (codeconn, nomtermconn, adripconn, adrmaconn, codecompte, codesptrav, ord) values ($1, $2, $3, $4, $5, $6, $7)')
			using vcode, pnomterm, padrip, padrmac, pcodecompte, pcodesptrav, vordmax;
		
			execute format('select nomtermconn, adripconn, adrmaconn, codecompte, codesptrav, statutconn from cudsecurite.connexion where codeconn = $1')
			into vnomterm, vadrip, vadrmac, vcodecompte, vcodesptrav, vstatutconn
			using vcode;	
			assert(vnomterm = pnomterm),'Incoherence sur les donnees inserees. nomtermconn';
			assert(vadrip = padrip),'Incoherence sur les donnees inserees. adripconn';
			assert((vadrmac is null) or vadrmac = padrmac),'Incoherence sur les donnees inserees. adrmaconn';
			assert(vcodecompte = pcodecompte),'Incoherence sur les donnees inserees. codecompte';
			assert(vcodesptrav = pcodesptrav),'Incoherence sur les donnees inserees. codesptrav';
			assert(vstatutconn = 1),'Incoherence sur les donnees inserees. statutconn';
			
			return vcode;
		ELSE
			assert(vnomterm = pnomterm),'Le compte <'|| pcodecompte ||'> est actuellement connecte a un autre apppareil.';
			return vcode;
		END IF;
	end;
	$$;
	
create or replace function cudsecurite.aftercreationconnexion()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		call srsecurite.ajouterconnexion(new.codeconn, new.datedebconn, new.nomtermconn, new.adripconn, new.adrmaconn, new.codecompte, new.codesptrav, new.statutconn, new.etat, new.ord, new.datecrea);
		call public.attacher('cudsecurite', 'compte', 'codecompte', new.codecompte);
		call public.attacher('cudsecurite', 'espacetravail', 'codesptrav', new.codesptrav);
		return null;
	end;
	$$;	

create trigger ajoutconnexion after insert on cudsecurite.connexion for each row execute function cudsecurite.aftercreationconnexion();

create or replace procedure cudsecurite.fermerconnexion(pcode public.identifiant)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
	begin 
		
		assert(pcode is not null),'Le code de la connexion est vide.';		
		assert(public.existencetuple('cudsecurite', 'connexion', 'codeconn', pcode)),'Le code de la connexion <'|| pcode ||'> est inconnu.';
		execute format('select statutconn from cudsecurite.connexion where codeconn = $1')
		into vstatut
		using pcode;
		assert(vstatut = 1),'Le statut de la connexion est incoherent.';
	
		execute format('update cudsecurite.connexion set statutconn = 2, datefinconn = current_timestamp , dateupda = current_timestamp where codeconn = $1')
		using pcode;
	
		execute format('select statutconn from cudsecurite.connexion where codeconn = $1')
		into vstatut
		using pcode;
		assert(vstatut = 2),'Incoherence sur les donnees mises a jour. statutconn';
		
	end;
	$$;

create or replace procedure cudsecurite.supprimerconnexion(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudsecurite', 'connexion', 'codeconn', pcode)),'Le code <'|| pcode ||'> de la connexion est inconnu.';	
		
		call public.supprimer('cudsecurite', 'connexion', 'codeconn', pcode);
	
		assert(not public.existencetuple('cudsecurite', 'connexion', 'codeconn', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;
	
create or replace function cudsecurite.aftermiseajourconnexion()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srsecurite', 'connexion', 'codeconn', old.codeconn, new.etat, new.dateupda);
		end if;	
		if ((old.statutconn = 1) and (new.statutconn = 2)) then
			call srsecurite.mettreajourfermetureconnexion(old.codeconn, new.statutconn, new.datefinconn, new.dateupda);
		end if;	
		return null;
	end;
	$$;	

create trigger miseajourconnexion after update on cudsecurite.connexion for each row execute function cudsecurite.aftermiseajourconnexion();

create or replace function cudsecurite.aftersuppressionconnexion()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		call public.detacher('cudsecurite', 'compte', 'codecompte', old.codecompte);
		call public.detacher('cudsecurite', 'espacetravail', 'codesptrav', old.codesptrav);
		return null;
	
	end;
	$$;	

create trigger suppressionconnexion after delete on cudsecurite.connexion for each row execute function cudsecurite.aftersuppressionconnexion();

-- ======== Creation de la table activite
-- ==========================================================================================================================================
create table cudsecurite.activite(
	codeactiv public.identifiant not null,
	dateactiv timestamp not null default current_timestamp,
	descractiv public.libelle not null,
	codeconn public.identifiant not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudsecurite.activite add constraint pkactivite primary key (codeactiv);
alter table cudsecurite.activite add constraint chkinvariantcardetatactivite check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudsecurite.activite add constraint chkinvariantdatecreaupdaactivite check (datecrea <= dateupda);
alter table cudsecurite.activite add constraint fkactiviteconnexion foreign key (codeconn) references cudsecurite.connexion(codeconn) on delete cascade;

create or replace function cudsecurite.creationactivite(pdescr public.libelle, pcodeconn public.identifiant)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vdescr public.libelle;
		vcodeconn public.identifiant;
		vtrouv boolean;
	begin 
		
		assert(pdescr is not null),'Le nom du terminal est vide.';
		assert(padrip is not null),'L''adresse IP est vide.';
		assert(pcodeconn is not null),'Le code de la connexion est vide.';
		assert(public.existencetuple('cudsecurite', 'connexion', 'codeconn', pcodeconn)),'Le code <'|| pcodeconn ||'> de la connexion est inconnu.';	
		
		vcode = cudincrement.generationidentifiant('activite');
		vordmax = public.obtentionordremax('cudsecurite', 'activite', 'ord');
		execute format('insert into cudsecurite.activite (codeactiv, descractiv, codeconn, ord) values ($1, $2, $3, $4)')
		using vcode, pdescr, pcodeconn, vordmax;
	
		execute format('select descractiv, codeconn from cudsecurite.activite where codeactiv = $1')
		into vdescr, vcodeconn
		using vcode;	
		assert(vdescr = pdescr),'Incoherence sur les donnees inserees. descractiv';
		assert(vcodeconn = pcodeconn),'Incoherence sur les donnees inserees. codeconn';
		
		return vcode;
	end;
	$$;
	
create or replace function cudsecurite.aftercreationactivite()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		call srsecurite.ajouteractivite(new.codeactiv, new.dateactiv, new.descractiv, new.codeconn, new.etat, new.ord, new.datecrea);
		call public.attacher('cudsecurite', 'connexion', 'codeconn', new.codeconn);
		return null;
	end;
	$$;	

create trigger ajoutactivite after insert on cudsecurite.activite for each row execute function cudsecurite.aftercreationactivite();

create or replace procedure cudsecurite.supprimeractivite(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudsecurite', 'activite', 'codeactiv', pcode)),'Le code <'|| pcode ||'> de l''activite est inconnu.';	
		
		call public.supprimer('cudsecurite', 'activite', 'codeactiv', pcode);
	
		assert(not public.existencetuple('cudsecurite', 'activite', 'codeactiv', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;
	
create or replace function cudsecurite.aftermiseajouractivite()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srsecurite', 'activite', 'codeactiv', old.codeactiv, new.etat, new.dateupda);
		end if;	
		return null;
	end;
	$$;	

create trigger miseajouractivite after update on cudsecurite.activite for each row execute function cudsecurite.aftermiseajouractivite();

create or replace function cudsecurite.aftersuppressionactivite()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		call public.detacher('cudsecurite', 'connexion', 'codeconn', old.codeconn);
		return null;
	
	end;
	$$;	

create trigger suppressionactivite after delete on cudsecurite.activite for each row execute function cudsecurite.aftersuppressionactivite();

-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== Creation du role akamsrdbservey
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create role akamsrdbservey with login password 'akamsr';
grant akamsrdbservey to mvondo;

-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== Creation du schema srsecurite
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create schema srsecurite;
alter schema srsecurite owner to akamsrdbservey;

-- ======== Creation de la table droit
-- ==========================================================================================================================================
create table srsecurite.droit(
	codedroit public.identifiant not null,
	nomdroit public.habilitation not null,
	libdroit public.libelle not null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srsecurite.droit add constraint pkdroit primary key (codedroit);
alter table srsecurite.droit add constraint chkinvariantdatecreaupdadroit check (datecrea <= dateupda);

create or replace procedure srsecurite.ajouterdroit(pcode public.identifiant, pnom public.habilitation, plib public.libelle, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vnom public.habilitation;
		vlib public.libelle;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code du droit est vide.';
		assert(not public.existencetuple('srsecurite', 'droit', 'codedroit', pcode)),'Le code <'|| pcode ||'> du droit existe deja.';
		assert(pnom is not null),'Le nom du droit est vide.';
		assert(plib is not null),'Le libelle du droit est vide.';
		assert(petat = 1),'L''etat du droit est incoherent.';
		assert(pord > 0),'L''ordre du droit est incoherent.';
		assert(pdatecrea is not null),'La date de creation du droit est vide.';
		
		execute format('insert into srsecurite.droit (codedroit, nomdroit, libdroit, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6)')
		using pcode, pnom, plib, petat, pord, pdatecrea;
	
		execute format('select nomdroit, libdroit, etat, ord, datecrea from srsecurite.droit where codedroit = $1')
		into vnom, vlib, vetat, vord, vdatecrea
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomdroit';
		assert(vlib = plib),'Incoherence sur les donnees inserees. libdroit';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srsecurite.mettreajourdroit(pcode public.identifiant, pnom public.habilitation, plib public.libelle, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vnom public.habilitation;
		vlib public.libelle;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du droit est vide.';
		assert(public.existencetuple('srsecurite', 'droit', 'codedroit', pcode)),'Le code <'|| pcode ||'> du droit est inconnu.';
		assert(pdateupda is not null),'La date de mise a jour du droit est vide.';
		assert(pnom is not null),'Le nom du droit est vide.';
		assert(plib is not null),'Le libelle du droit est vide.';
		execute format('select dateupda from srsecurite.droit where codedroit = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour du droit est incoherente.';
	
		execute format('update srsecurite.droit set nomdroit = $1, libdroit = $2, dateupda = $3 where codedroit = $4')
		using pnom, plib, pdateupda, pcode;
	
		execute format('select nomdroit, libdroit, dateupda from srsecurite.droit where codedroit = $1')
		into vnom, vlib, vdateupda
		using pcode;
		assert(vnom = pnom),'Les donnees mises a jour sont incoherentes. nomdroit';
		assert(vlib = plib),'Les donnees mises a jour sont incoherentes. libdroit';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srsecurite.aftermiseajourdroit()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		execute format('update srsecurite.droitsespacetravail set nomdroit = $1, libdroit = $2 where codedroit = $3')
		using new.nomdroit, new.libdroit, old.codedroit;
		return null;
		execute format('update srsecurite.droitsprofil set nomdroit = $1, libdroit = $2 where codedroit = $3')
		using new.nomdroit, new.libdroit, old.codedroit;
		return null;
	
	end;
	$$;	

create trigger miseajourdroit after update on srsecurite.droit for each row execute function srsecurite.aftermiseajourdroit();

create or replace function srsecurite.obtentiondroit(pcode public.identifiant)
	returns table(codedroit public.identifiant, nomdroit public.habilitation, libdroit public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code du droit est vide.';
		assert(public.existencetuple('srsecurite', 'droit', 'codedroit', pcode)),'Le code <'|| pcode ||'> du droit est inconnu.';
		
		return query select d.codedroit, d.nomdroit, d.libdroit from srsecurite.droit d where d.codedroit = pcode;
	
	end;
	$$;

create or replace function srsecurite.obtentiondroit(pnom public.habilitation)
	returns table(codedroit public.identifiant, nomdroit public.habilitation, libdroit public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pnom is not null),'Le nom du droit est vide.';
		assert(public.existencetuple('srsecurite', 'droit', 'nomdroit', pnom)),'Le nom <'|| pnom ||'> du droit est inconnu.';
		
		return query select d.codedroit, d.nomdroit, d.libdroit from srsecurite.droit d where d.nomdroit = pnom;
	
	end;
	$$;

create or replace function srsecurite.recherchedroit(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codedroit public.identifiant, nomdroit public.habilitation, libdroit public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select d.codedroit, d.nomdroit, d.libdroit from srsecurite.droit d where d.etat <> 3 order by d.ord desc limit plimit offset pdebut;
		else
			return query select d.codedroit, d.nomdroit, d.libdroit from srsecurite.droit d where d.etat <> 3 and (d.nomdroit ilike '%'|| pcritere ||'%' or d.libdroit ilike '%'|| pcritere ||'%') order by d.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== Creation de la table espacetravail
-- ==========================================================================================================================================
create table srsecurite.espacetravail(
	codesptrav public.identifiant not null,
	nomesptrav public.nom not null,
	lienesptrav public.nom null,
	libesptrav public.libelle not null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srsecurite.espacetravail add constraint pkespacetravail primary key (codesptrav);
alter table srsecurite.espacetravail add constraint chkinvariantdatecreaupdaespacetravail check (datecrea <= dateupda);

create or replace procedure srsecurite.ajouterespacetravail(pcode public.identifiant, pnom public.nom, plien public.nom, plib public.libelle, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vlien public.nom;
		vlib public.libelle;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code de l''espace de travail est vide.';
		assert(not public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcode)),'Le code <'|| pcode ||'> de l''espace de travail existe deja.';
		assert(pnom is not null),'Le nom de l''espace de travail est vide.';
		assert(plib is not null),'Le libelle de l''espace de travail est vide.';
		assert(petat = 1),'L''etat de l''espace de travail est incoherent.';
		assert(pord > 0),'L''ordre de l''espace de travail est incoherent.';
		assert(pdatecrea is not null),'La date de creation de l''espace de travail est vide.';
		
		execute format('insert into srsecurite.espacetravail (codesptrav, nomesptrav, lienesptrav, libesptrav, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7)')
		using pcode, pnom, plien, plib, petat, pord, pdatecrea;
	
		execute format('select nomesptrav, lienesptrav, libesptrav, etat, ord, datecrea from srsecurite.espacetravail where codesptrav = $1')
		into vnom, vlien, vlib, vetat, vord, vdatecrea
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomesptrav';
		assert(vlien = plien),'Incoherence sur les donnees inserees. lienesptrav';
		assert(vlib = plib),'Incoherence sur les donnees inserees. libesptrav';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srsecurite.mettreajourespacetravail(pcode public.identifiant, pnom public.nom, plien public.nom, plib public.libelle, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vlien public.nom;
		vlib public.libelle;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcode)),'Le code <'|| pcode ||'> de l''espace de travail est inconnu.';
		assert(pnom is not null),'Le nom de l''espace de travail est vide.';
		assert(plib is not null),'Le libelle de l''espace de travail est vide.';
		assert(pdateupda is not null),'La date de mise a jour de l''espace de travail est vide.';
		execute format('select dateupda from srsecurite.espacetravail where codesptrav = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour de l''espace de travail est incoherente.';
	
		execute format('update srsecurite.espacetravail set nomesptrav = $1, lienesptrav = $2, libesptrav = $3, dateupda = $4 where codesptrav = $5')
		using pnom, plien, plib, pdateupda, pcode;
	
		execute format('select nomesptrav, lienesptrav, libesptrav, dateupda from srsecurite.espacetravail where codesptrav = $1')
		into vnom, vlien, vlib, vdateupda
		using pcode;
		assert(vnom = pnom),'Les donnees mises a jour sont incoherentes. nomesptrav';
		assert(vlien = plien),'Les donnees mises a jour sont incoherentes. lienesptrav';
		assert(vlib = plib),'Les donnees mises a jour sont incoherentes. libesptrav';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srsecurite.aftermiseajourespacetravail()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		execute format('update srsecurite.profil set nomesptrav = $1, lienesptrav = $2, libesptrav = $3 where codesptrav = $4')
		using new.nomesptrav, new.lienesptrav, new.libesptrav, old.codesptrav;
		execute format('update srsecurite.connexion set nomesptrav = $1, lienesptrav = $2, libesptrav = $3 where codesptrav = $4')
		using new.nomesptrav, new.lienesptrav, new.libesptrav, old.codesptrav;
		return null;
	
	end;
	$$;	

create trigger miseajourespacetravail after update on srsecurite.espacetravail for each row execute function srsecurite.aftermiseajourespacetravail();

create or replace function srsecurite.obtentionespacetravail(pcode public.identifiant)
	returns table(codesptrav public.identifiant, nomesptrav public.nom, lienesptrav public.nom, libesptrav public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcode)),'Le code <'|| pcode ||'> de l''espace de travail est inconnu.';
		
		return query select e.codesptrav, e.nomesptrav, e.lienesptrav, e.libesptrav from srsecurite.espacetravail e where e.codesptrav = pcode;
	
	end;
	$$;

create or replace function srsecurite.obtentionespacetravailnom(pnom public.nom)
	returns table(codesptrav public.identifiant, nomesptrav public.nom, lienesptrav public.nom, libesptrav public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pnom is not null),'Le nom de l''espace de travail est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'nomesptrav', pnom)),'Le nom <'|| pnom ||'> de l''espace de travail est inconnu.';
		
		return query select e.codesptrav, e.nomesptrav, e.lienesptrav, e.libesptrav from srsecurite.espacetravail e where e.nomesptrav = pnom;
	
	end;
	$$;

create or replace function srsecurite.recherchespacetravail(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codesptrav public.identifiant, nomesptrav public.nom, lienesptrav public.nom, libesptrav public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select e.codesptrav, e.nomesptrav, e.lienesptrav, e.libesptrav from srsecurite.espacetravail e where e.etat <> 3 order by e.ord desc limit plimit offset pdebut;
		else
			return query select e.codesptrav, e.nomesptrav, e.lienesptrav, e.libesptrav from srsecurite.espacetravail e where e.etat <> 3 and (e.nomesptrav ilike '%'|| pcritere ||'%' or e.libesptrav ilike '%'|| pcritere ||'%') order by e.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== Creation de la table droitsespacetravail
-- ==========================================================================================================================================
create table srsecurite.droitsespacetravail(
	codesptrav public.identifiant not null,
	codedroit public.identifiant not null,
	nomdroit public.habilitation not null,
	libdroit public.libelle not null
	);

alter table srsecurite.droitsespacetravail add constraint pkdroitsespacetravail primary key (codesptrav, codedroit);

create or replace procedure srsecurite.ajouterdroitespacetravail(pcodesptrav public.identifiant, pcodedroit public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
		vnomdroit public.habilitation;
		vlibdroit public.libelle;
	begin
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';
		assert(pcodedroit is not null),'Le code du droit est vide.';	
		assert(public.existencetuple('srsecurite', 'droit', 'codedroit', pcodedroit)),'Le code <'|| pcodedroit ||'> du droit est inconnu.';
		execute format('select exists (select * from srsecurite.droitsespacetravail where codesptrav = $1 and codedroit = $2)')
		into vtrouv
		using pcodesptrav, pcodedroit;
		assert(not vtrouv),'L''espace de travail <'|| pcodesptrav ||'> possede deja ce droit <'|| pcodedroit ||'>.';
	
		execute format('select nomdroit, libdroit from srsecurite.droit where codedroit = $1;')
		into vnomdroit, vlibdroit
		using pcodedroit;
		execute format('insert into srsecurite.droitsespacetravail(codesptrav, codedroit, nomdroit, libdroit) values ($1, $2, $3, $4);')
		using pcodesptrav, pcodedroit, vnomdroit, vlibdroit;
	
		execute format('select exists (select * from srsecurite.droitsespacetravail where codesptrav = $1 and codedroit = $2)')
		into vtrouv
		using pcodesptrav, pcodedroit;
		assert(vtrouv),'Incoherence sur les donnees inserees.';
	end;
	$$;

create or replace procedure srsecurite.retirerdroitespacetravail(pcodesptrav public.identifiant, pcodedroit public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
	begin
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';
		assert(pcodedroit is not null),'Le code du droit est vide.';	
		assert(public.existencetuple('srsecurite', 'droit', 'codedroit', pcodedroit)),'Le code <'|| pcodedroit ||'> du droit est inconnu.';
		execute format('select exists (select * from srsecurite.droitsespacetravail where codesptrav = $1 and codedroit = $2)')
		into vtrouv
		using pcodesptrav, pcodedroit;
		assert(vtrouv),'L''espace de travail <'|| pcodesptrav ||'> ne possede pas ce droit <'|| pcodedroit ||'>.';
	
		execute format('delete from srsecurite.droitsespacetravail where codesptrav = $1 and codedroit = $2;')
		using pcodesptrav, pcodedroit;
	
		execute format('select exists (select * from srsecurite.droitsespacetravail where codesptrav = $1 and codedroit = $2)')
		into vtrouv
		using pcodesptrav, pcodedroit;
		assert(not vtrouv),'Incoherence sur les donnees supprimees.';
	end;
	$$;

create or replace function srsecurite.obtentiondroitsespacetravail(pcodesptrav public.identifiant)
	returns table(codedroit public.identifiant, nomdroit public.habilitation, libdroit public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';
		
		return query select de.codedroit, de.nomdroit, de.libdroit from srsecurite.droitsespacetravail de where de.codesptrav = pcodesptrav;
	
	end;
	$$;

-- ======== Creation de la table profil
-- ==========================================================================================================================================
create table srsecurite.profil(
	codeprofil public.identifiant not null,
	nomprofil public.nom not null,
	libprofil public.libelle not null,
	codesptrav public.identifiant not null,
	nomesptrav public.nom not null,
	lienesptrav public.nom null,
	libesptrav public.libelle not null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srsecurite.profil add constraint pkprofil primary key (codeprofil);
alter table srsecurite.profil add constraint chkinvariantdatecreaupdaprofil check (datecrea <= dateupda);

create or replace procedure srsecurite.ajouterprofil(pcode public.identifiant, pnom public.nom, plib public.libelle, pcodesptrav public.identifiant, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vlib public.libelle;
		vcodesptrav public.identifiant;
		vnomesptrav public.nom;
		vlienesptrav public.nom;
		vlibesptrav public.libelle;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code du profil est vide.';
		assert(not public.existencetuple('srsecurite', 'profil', 'codeprofil', pcode)),'Le code <'|| pcode ||'> du profil existe deja.';
		assert(pnom is not null),'Le nom du profil est vide.';
		assert(plib is not null),'Le libelle du profil est vide.';
		assert(pcodesptrav is not null),'Le code de l''espace de travail parent du profil est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail parent du profil est inconnu.';
		assert(petat = 1),'L''etat du profil est incoherent.';
		assert(pord > 0),'L''ordre du profil est incoherent.';
		assert(pdatecrea is not null),'La date de creation du profil est vide.';
		
		execute format('select nomesptrav, lienesptrav, libesptrav from srsecurite.espacetravail where codesptrav = $1;')
		into vnomesptrav, vlienesptrav, vlibesptrav
		using pcodesptrav;
		execute format('insert into srsecurite.profil (codeprofil, nomprofil, libprofil, codesptrav, nomesptrav, lienesptrav, libesptrav, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)')
		using pcode, pnom, plib, pcodesptrav, vnomesptrav, vlienesptrav, vlibesptrav, petat, pord, pdatecrea;
	
		execute format('select nomprofil, libprofil, codesptrav, etat, ord, datecrea from srsecurite.profil where codeprofil = $1')
		into vnom, vlib, vcodesptrav, vetat, vord, vdatecrea
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomprofil';
		assert(vlib = plib),'Incoherence sur les donnees inserees. libprofil';
		assert(vcodesptrav = pcodesptrav),'Incoherence sur les donnees inserees. codesptrav';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srsecurite.mettreajourprofil(pcode public.identifiant, pnom public.nom, plib public.libelle, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vlib public.libelle;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du profil est vide.';
		assert(public.existencetuple('srsecurite', 'profil', 'codeprofil', pcode)),'Le code <'|| pcode ||'> du profil est inconnu.';
		assert(pnom is not null),'Le nom du profil est vide.';
		assert(plib is not null),'Le libelle du profil est vide.';
		assert(pdateupda is not null),'La date de mise a jour du profil est vide.';
		execute format('select dateupda from srsecurite.profil where codeprofil = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour du profil est incoherente.';
	
		execute format('update srsecurite.profil set nomprofil = $1, libprofil = $2, dateupda = $3 where codeprofil = $4')
		using pnom, plib, pdateupda, pcode;
	
		execute format('select nomprofil, libprofil, dateupda from srsecurite.profil where codeprofil = $1')
		into vnom, vlib, vdateupda
		using pcode;
		assert(vnom = pnom),'Les donnees mises a jour sont incoherentes. nomprofil';
		assert(vlib = plib),'Les donnees mises a jour sont incoherentes. libprofil';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srsecurite.aftermiseajourprofil()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		execute format('update srsecurite.profilscompte set nomprofil = $1, libprofil = $2 where codeprofil = $3')
		using new.nomprofil, new.libprofil, old.codeprofil;
		return null;
	
	end;
	$$;	

create trigger miseajourprofil after update on srsecurite.profil for each row execute function srsecurite.aftermiseajourprofil();

create or replace function srsecurite.obtentionprofil(pcode public.identifiant)
	returns table(codeprofil public.identifiant, nomprofil public.nom, libprofil public.libelle, codesptrav public.identifiant, nomesptrav public.nom, lienesptrav public.nom, libesptrav public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code du profil est vide.';
		assert(public.existencetuple('srsecurite', 'profil', 'codeprofil', pcode)),'Le code <'|| pcode ||'> du profil est inconnu.';
		
		return query select p.codeprofil, p.nomprofil, p.libprofil, p.codesptrav, p.nomesptrav, p.lienesptrav, p.libesptrav from srsecurite.profil p where p.codeprofil = pcode;
	
	end;
	$$;

create or replace function srsecurite.obtentionprofil(pnom public.nom)
	returns table(codeprofil public.identifiant, nomprofil public.nom, libprofil public.libelle, codesptrav public.identifiant, nomesptrav public.nom, lienesptrav public.nom, libesptrav public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pnom is not null),'Le nom du profil est vide.';
		assert(public.existencetuple('srsecurite', 'profil', 'nomprofil', pnom)),'Le nom <'|| pnom ||'> du profil est inconnu.';
		
		return query select p.codeprofil, p.nomprofil, p.libprofil, p.codesptrav, p.nomesptrav, p.lienesptrav, p.libesptrav from srsecurite.profil p where p.nomprofil = pnom;
	
	end;
	$$;

create or replace function srsecurite.obtentionprofilsespacetravail(pcodesptrav public.identifiant)
	returns table(codeprofil public.identifiant, nomprofil public.nom, libprofil public.libelle, codesptrav public.identifiant, nomesptrav public.nom, lienesptrav public.nom, libesptrav public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';
		
		return query select p.codeprofil, p.nomprofil, p.libprofil, p.codesptrav, p.nomesptrav, p.lienesptrav, p.libesptrav from srsecurite.profil p where p.codesptrav = pcodesptrav;
	
	end;
	$$;

create or replace function srsecurite.rechercheprofil(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codeprofil public.identifiant, nomprofil public.nom, libprofil public.libelle, codesptrav public.identifiant, nomesptrav public.nom, lienesptrav public.nom, libesptrav public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select p.codeprofil, p.nomprofil, p.libprofil, p.codesptrav, p.nomesptrav, p.lienesptrav, p.libesptrav from srsecurite.profil p where p.etat <> 3 order by p.ord desc limit plimit offset pdebut;
		else
			return query select p.codeprofil, p.nomprofil, p.libprofil, p.codesptrav, p.nomesptrav, p.lienesptrav, p.libesptrav from srsecurite.profil p where p.etat <> 3 and (p.nomprofil ilike '%'|| pcritere ||'%' or p.libprofil ilike '%'|| pcritere ||'%') order by p.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

create or replace function srsecurite.obtenircodeprofil(pnom public.nom)
	returns public.identifiant  
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
	begin 
		
		assert(pnom is not null),'Le nom du profil est vide.';
		assert(public.existencetuple('srsecurite', 'profil', 'nomprofil', pnom)),'Le nom <'|| pnom ||'> est absent.';
	
		execute format('select p.codeprofil from srsecurite.profil p where p.nomprofil = $1')
		into vcode
		using pnom;
	
		return vcode;
		
	end;
	$$;

-- ======== Creation de la table droitsprofil
-- ==========================================================================================================================================
create table srsecurite.droitsprofil(
	codeprofil public.identifiant not null,
	codedroit public.identifiant not null,
	nomdroit public.habilitation not null,
	libdroit public.libelle not null
	);

alter table srsecurite.droitsprofil add constraint pkdroitsprofil primary key (codeprofil, codedroit);

create or replace procedure srsecurite.ajouterdroitprofil(pcodeprofil public.identifiant, pcodedroit public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
		vnomdroit public.habilitation;
		vlibdroit public.libelle;
	begin
		assert(pcodeprofil is not null),'Le code du profil est vide.';
		assert(public.existencetuple('srsecurite', 'profil', 'codeprofil', pcodeprofil)),'Le code <'|| pcodeprofil ||'> du profil est inconnu.';
		assert(pcodedroit is not null),'Le code du droit est vide.';	
		assert(public.existencetuple('srsecurite', 'droit', 'codedroit', pcodedroit)),'Le code <'|| pcodedroit ||'> du droit est inconnu.';
		execute format('select exists (select * from srsecurite.droitsprofil where codeprofil = $1 and codedroit = $2)')
		into vtrouv
		using pcodeprofil, pcodedroit;
		assert(not vtrouv),'L''espace de travail <'|| pcodeprofil ||'> possede deja ce droit <'|| pcodedroit ||'>.';
	
		execute format('select nomdroit, libdroit from srsecurite.droit where codedroit = $1;')
		into vnomdroit, vlibdroit
		using pcodedroit;
		execute format('insert into srsecurite.droitsprofil(codeprofil, codedroit, nomdroit, libdroit) values ($1, $2, $3, $4);')
		using pcodeprofil, pcodedroit, vnomdroit, vlibdroit;
	
		execute format('select exists (select * from srsecurite.droitsprofil where codeprofil = $1 and codedroit = $2)')
		into vtrouv
		using pcodeprofil, pcodedroit;
		assert(vtrouv),'Incoherence sur les donnees inserees.';
	end;
	$$;

create or replace procedure srsecurite.retirerdroitprofil(pcodeprofil public.identifiant, pcodedroit public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
	begin
		assert(pcodeprofil is not null),'Le code du profil est vide.';
		assert(public.existencetuple('srsecurite', 'profil', 'codeprofil', pcodeprofil)),'Le code <'|| pcodeprofil ||'> du profil est inconnu.';
		assert(pcodedroit is not null),'Le code du droit est vide.';	
		assert(public.existencetuple('srsecurite', 'droit', 'codedroit', pcodedroit)),'Le code <'|| pcodedroit ||'> du droit est inconnu.';
		execute format('select exists (select * from srsecurite.droitsprofil where codeprofil = $1 and codedroit = $2)')
		into vtrouv
		using pcodeprofil, pcodedroit;
		assert(vtrouv),'L''espace de travail <'|| pcodeprofil ||'> ne possede pas ce droit <'|| pcodedroit ||'>.';
	
		execute format('delete from srsecurite.droitsprofil where codeprofil = $1 and codedroit = $2;')
		using pcodeprofil, pcodedroit;
	
		execute format('select exists (select * from srsecurite.droitsprofil where codeprofil = $1 and codedroit = $2)')
		into vtrouv
		using pcodeprofil, pcodedroit;
		assert(not vtrouv),'Incoherence sur les donnees supprimees.';
	end;
	$$;

create or replace function srsecurite.obtentiondroitsprofil(pcodeprofil public.identifiant)
	returns table(codedroit public.identifiant, nomdroit public.habilitation, libdroit public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodeprofil is not null),'Le code du profil est vide.';
		assert(public.existencetuple('srsecurite', 'profil', 'codeprofil', pcodeprofil)),'Le code <'|| pcodeprofil ||'> du profil est inconnu.';
		
		return query select de.codedroit, de.nomdroit, de.libdroit from srsecurite.droitsprofil de where de.codeprofil = pcodeprofil;
	
	end;
	$$;

-- ======== Creation de la table compte
-- ==========================================================================================================================================
create table srsecurite.compte(
	codecompte public.identifiant not null,
	nomcompte public.libelle not null,
	logincompte public.nom not null,
	mdpcompte public.motdepasse not null,
	statutcompte public.etat not null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srsecurite.compte add constraint pkcompte primary key (codecompte);
alter table srsecurite.compte add constraint chkinvariantdatecreaupdacompte check (datecrea <= dateupda);

create or replace procedure srsecurite.ajoutercompte(pcode public.identifiant, pnom public.libelle, plogin public.nom, pmdp public.motdepasse, pstatut public.etat, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vnom public.libelle;
		vlogin public.nom;
		vmdp public.motdepasse;
		vstatut public.etat;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code du compte est vide.';
		assert(not public.existencetuple('srsecurite', 'compte', 'codecompte', pcode)),'Le code <'|| pcode ||'> du compte existe deja.';
		assert(pnom is not null),'Le nom du compte est vide.';
		assert(plogin is not null),'Le login du compte est vide.';
		assert(pmdp is not null),'Le mot de passe du compte est vide.';
		assert(pstatut is not null),'Le statut du compte est vide.';
		assert(petat = 1),'L''etat du compte est incoherent.';
		assert(pord > 0),'L''ordre du compte est incoherent.';
		assert(pdatecrea is not null),'La date de creation du compte est vide.';
		
		execute format('insert into srsecurite.compte (codecompte, nomcompte, logincompte, mdpcompte, statutcompte, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8)')
		using pcode, pnom, plogin, pmdp, pstatut, petat, pord, pdatecrea;
	
		execute format('select nomcompte, logincompte, mdpcompte, statutcompte, etat, ord, datecrea from srsecurite.compte where codecompte = $1')
		into vnom, vlogin, vmdp, vstatut, vetat, vord, vdatecrea
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomcompte';
		assert(vlogin = plogin),'Incoherence sur les donnees inserees. logincompte';
		assert(vmdp = pmdp),'Incoherence sur les donnees inserees. mdpcompte';
		assert(vstatut = pstatut),'Incoherence sur les donnees inserees. statutcompte';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srsecurite.mettreajournomcompte(pcode public.identifiant, pnom public.libelle, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vnom public.libelle;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcode)),'Le code <'|| pcode ||'> du compte est inconnu.';
		assert(pnom is not null),'Le nom du compte est vide.';
		assert(pdateupda is not null),'La date de mise a jour du compte est vide.';
		execute format('select dateupda from srsecurite.compte where codecompte = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour du compte est incoherente.';
	
		execute format('update srsecurite.compte set nomcompte = $1, dateupda = $2 where codecompte = $3')
		using pnom, pdateupda, pcode;
	
		execute format('select nomcompte, dateupda from srsecurite.compte where codecompte = $1')
		into vnom, vdateupda
		using pcode;
		assert(vnom = pnom),'Les donnees mises a jour sont incoherentes. nomcompte';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace procedure srsecurite.mettreajourlogincompte(pcode public.identifiant, plogin public.nom, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vlogin public.nom;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcode)),'Le code <'|| pcode ||'> du compte est inconnu.';
		assert(plogin is not null),'Le login du compte est vide.';
		assert(pdateupda is not null),'La date de mise a jour du compte est vide.';
		execute format('select dateupda from srsecurite.compte where codecompte = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour du compte est incoherente.';
	
		execute format('update srsecurite.compte set logincompte = $1, dateupda = $2 where codecompte = $3')
		using plogin, pdateupda, pcode;
	
		execute format('select logincompte, dateupda from srsecurite.compte where codecompte = $1')
		into vlogin, vdateupda
		using pcode;
		assert(vlogin = plogin),'Les donnees mises a jour sont incoherentes. logincompte';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace procedure srsecurite.mettreajourmdpcompte(pcode public.identifiant, pmdp public.motdepasse, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vmdp public.motdepasse;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcode)),'Le code <'|| pcode ||'> du compte est inconnu.';
		assert(pmdp is not null),'Le mot de passe du compte est vide.';
		assert(pdateupda is not null),'La date de mise a jour du compte est vide.';
		execute format('select dateupda from srsecurite.compte where codecompte = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour du compte est incoherente.';
	
		execute format('update srsecurite.compte set mdpcompte = $1, dateupda = $2 where codecompte = $3')
		using pmdp, pdateupda, pcode;
	
		execute format('select mdpcompte, dateupda from srsecurite.compte where codecompte = $1')
		into vmdp, vdateupda
		using pcode;
		assert(vmdp = pmdp),'Les donnees mises a jour sont incoherentes. mdpcompte';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace procedure srsecurite.mettreajouractivationcompte(pcode public.identifiant, pstatut public.etat, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcode)),'Le code <'|| pcode ||'> du compte est inconnu.';
		assert(pstatut is not null),'Le statut du compte est vide.';
		assert(pstatut = 1),'Le statut du compte est incoherent.';
		assert(pdateupda is not null),'La date de mise a jour du compte est vide.';
		execute format('select dateupda from srsecurite.compte where codecompte = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour du compte est incoherente.';
	
		execute format('update srsecurite.compte set statutcompte = $1, dateupda = $2 where codecompte = $3')
		using pstatut, pdateupda, pcode;
	
		execute format('select statutcompte, dateupda from srsecurite.compte where codecompte = $1')
		into vstatut, vdateupda
		using pcode;
		assert(vstatut = pstatut),'Les donnees mises a jour sont incoherentes. statutcompte';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace procedure srsecurite.mettreajourdesactivationcompte(pcode public.identifiant, pstatut public.etat, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcode)),'Le code <'|| pcode ||'> du compte est inconnu.';
		assert(pstatut is not null),'Le statut du compte est vide.';
		assert(pstatut = 2),'Le statut du compte est incoherent.';
		assert(pdateupda is not null),'La date de mise a jour du compte est vide.';
		execute format('select dateupda from srsecurite.compte where codecompte = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour du compte est incoherente.';
	
		execute format('update srsecurite.compte set statutcompte = $1, dateupda = $2 where codecompte = $3')
		using pstatut, pdateupda, pcode;
	
		execute format('select statutcompte, dateupda from srsecurite.compte where codecompte = $1')
		into vstatut, vdateupda
		using pcode;
		assert(vstatut = pstatut),'Les donnees mises a jour sont incoherentes. statutcompte';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srsecurite.aftermiseajourcompte()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		execute format('update srsecurite.connexion set nomcompte = $1, logincompte = $2, statutcompte = $3 where codecompte = $4')
		using new.nomcompte, new.logincompte, new.statutcompte, old.codecompte;
		execute format('update srutilisateur.utilisateur set nomcompte = $1, logincompte = $2, statutcompte = $3 where codecompte = $4')
		using new.nomcompte, new.logincompte, new.statutcompte, old.codecompte;
		return null;
	
	end;
	$$;	

create trigger miseajourcompte after update on srsecurite.compte for each row execute function srsecurite.aftermiseajourcompte();
	
create or replace function srsecurite.identificationcompte(plogin public.nom, pmdp public.nom)
	returns table(codecompte public.identifiant, nomcompte public.libelle)  
	language plpgsql
	as $$
	declare
		vstatut public.etat;
		vcodecompte public.identifiant;
		vmdp public.motdepasse;
		vdatecrea timestamp;
		vhash public.motdepasse;
		vtrouv boolean = false;
	begin 
		
		assert(plogin is not null),'Le login du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'logincompte', plogin)),'Le login <'|| plogin ||'> du compte est inconnu.';
		assert(pmdp is not null),'Le mot de passe du compte est vide.';
	
		execute format('select codecompte, mdpcompte, statutcompte, datecrea from srsecurite.compte where logincompte = $1;')
		into vcodecompte, vmdp, vstatut, vdatecrea
		using plogin;
		vhash = public.cryptagemotdepasse(pmdp, vcodecompte, vdatecrea);
		assert(vhash = vmdp),'Les identifiants de connexion sont incoherents.';
		assert(vstatut = 1),'Le compte est bloque.';
	
		return query select c.codecompte, c.nomcompte from srsecurite.compte c where c.codecompte = vcodecompte;
	end;
	$$;

create or replace function srsecurite.authentificationcompte(pnomprofil public.nom, plogin public.nom, pmdp public.nom)
	returns table(codecompte public.identifiant, codesptrav public.identifiant)	
	language plpgsql
	as $$
	declare
		vstatut public.etat;
		vcodecompte public.identifiant;
		vmdp public.motdepasse;
		vcodesptrav public.identifiant;
		vdatecrea timestamp;
		vhash public.motdepasse;
	begin 
		
		assert(pnomprofil is not null),'Le nom du profil est vide.';
		assert(public.existencetuple('srsecurite', 'profil', 'nomprofil', pnomprofil)),'Le nom <'|| pnomprofil ||'> du profil est inconnu.';
		assert(plogin is not null),'Le login est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'logincompte', plogin)),'Le login <'|| plogin ||'> est inconnu.';
		assert(pmdp is not null),'Le mot de passe est vide.';
		execute format('select codecompte, mdpcompte, statutcompte, datecrea from srsecurite.compte where logincompte = $1;')
		into vcodecompte, vmdp, vstatut, vdatecrea
		using plogin;
		vhash = public.cryptagemotdepasse(pmdp, vcodecompte, vdatecrea);
		assert(vhash = vmdp),'Les identifiants de connexion sont incoherents.';
		assert(vstatut = 1),'Le compte est bloque.';
		execute format('select codesptrav from srsecurite.profilscompte where codecompte = $1 and nomprofil = $2')
		into vcodesptrav
		using vcodecompte, pnomprofil;
		assert(vcodesptrav is not null),'Ce compte n''a pas le profil requis pour se connecter a cet espace de travail.';
		
		return query select pc.codecompte, pc.codesptrav from srsecurite.profilscompte pc where pc.codecompte = vcodecompte and pc.nomprofil = pnomprofil;
		
	end;
	$$;

create or replace function srsecurite.obtentioncompte(pcode public.identifiant)
	returns table(codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcode)),'Le code <'|| pcode ||'> du compte est inconnu.';
		
		return query select c.codecompte, c.nomcompte, c.logincompte, c.statutcompte from srsecurite.compte c where c.codecompte = pcode;
	
	end;
	$$;

create or replace function srsecurite.obtentioncompte(plogin public.nom)
	returns table(codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(plogin is not null),'Le login du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'logincompte', plogin)),'Le login <'|| plogin ||'> du compte est inconnu.';
		
		return query select c.codecompte, c.nomcompte, c.logincompte, c.statutcompte from srsecurite.compte c where c.logincompte = plogin;
	
	end;
	$$;

create or replace function srsecurite.recherchecompte(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select c.codecompte, c.nomcompte, c.logincompte, c.statutcompte from srsecurite.compte c where c.etat <> 3 order by c.ord desc limit plimit offset pdebut;
		else
			return query select c.codecompte, c.nomcompte, c.logincompte, c.statutcompte from srsecurite.compte c where c.etat <> 3 and (c.nomcompte ilike '%'|| pcritere ||'%' or c.logincompte ilike '%'|| pcritere ||'%') order by c.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== Creation de la table profilscompte
-- ==========================================================================================================================================
create table srsecurite.profilscompte(
	codecompte public.identifiant not null,
	codeprofil public.identifiant not null,
	nomprofil public.nom not null,
	libprofil public.libelle not null,
	codesptrav public.identifiant not null
	);

alter table srsecurite.profilscompte add constraint pkprofilscompte primary key (codecompte, codeprofil);

create or replace procedure srsecurite.ajouterprofilcompte(pcodecompte public.identifiant, pcodeprofil public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
		vnomprofil public.nom;
		vlibprofil public.libelle;
		vcodesptrav public.identifiant;
	begin
		assert(pcodecompte is not null),'Le code du compte est vide.';	
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		assert(pcodeprofil is not null),'Le code du profil est vide.';
		assert(public.existencetuple('srsecurite', 'profil', 'codeprofil', pcodeprofil)),'Le code <'|| pcodeprofil ||'> du profil est inconnu.';
		execute format('select exists (select * from srsecurite.profilscompte where codecompte = $1 and codeprofil = $2)')
		into vtrouv
		using pcodecompte, pcodeprofil;
		assert(not vtrouv),'Le compte <'|| pcodecompte ||'> possede deja ce profil <'|| pcodeprofil ||'>.';
	
		execute format('select nomprofil, libprofil, codesptrav from srsecurite.profil where codeprofil = $1;')
		into vnomprofil, vlibprofil, vcodesptrav
		using pcodeprofil;
		execute format('insert into srsecurite.profilscompte(codecompte, codeprofil, nomprofil, libprofil, codesptrav) values ($1, $2, $3, $4, $5);')
		using pcodecompte, pcodeprofil, vnomprofil, vlibprofil, vcodesptrav;
	
		execute format('select exists (select * from srsecurite.profilscompte where codecompte = $1 and codeprofil = $2)')
		into vtrouv
		using pcodecompte, pcodeprofil;
		assert(vtrouv),'Incoherence sur les donnees inserees.';
	end;
	$$;

create or replace procedure srsecurite.retirerprofilcompte(pcodecompte public.identifiant, pcodeprofil public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
	begin
		assert(pcodecompte is not null),'Le code du compte est vide.';	
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		assert(pcodeprofil is not null),'Le code du profil est vide.';
		assert(public.existencetuple('srsecurite', 'profil', 'codeprofil', pcodeprofil)),'Le code <'|| pcodeprofil ||'> du profil est inconnu.';
		execute format('select exists (select * from srsecurite.profilscompte where codecompte = $1 and codeprofil = $2)')
		into vtrouv
		using pcodecompte, pcodeprofil;
		assert(vtrouv),'Le compte <'|| pcodecompte ||'> ne possede pas ce profil <'|| pcodeprofil ||'>.';
	
		execute format('delete from srsecurite.profilscompte where codecompte = $1 and codeprofil = $2;')
		using pcodecompte, pcodeprofil;
	
		execute format('select exists (select * from srsecurite.profilscompte where codecompte = $1 and codeprofil = $2)')
		into vtrouv
		using pcodecompte, pcodeprofil;
		assert(not vtrouv),'Incoherence sur les donnees supprimees.';
	end;
	$$;

create or replace function srsecurite.obtentionprofilscompte(pcodecompte public.identifiant)
	returns table(codeprofil public.identifiant, nomprofil public.nom, libprofil public.libelle, codesptrav public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodecompte is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		
		return query select pc.codeprofil, pc.nomprofil, pc.libprofil, pc.codesptrav from srsecurite.profilscompte pc where pc.codecompte = pcodecompte;
	
	end;
	$$;

-- ======== creation de la table droitscompte
-- ==========================================================================================================================================
create table srsecurite.droitscompte(
	codecompte public.identifiant not null,
	codedroit public.identifiant not null,
	nomdroit public.nom not null,
	libdroit public.libelle not null,
	codesptrav public.identifiant not null
	);

alter table srsecurite.droitscompte add constraint pkdroitscompte primary key (codecompte, codedroit);

create or replace procedure srsecurite.ajouterdroitcompte(pcodecompte public.identifiant, pcodedroit public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
		vnomdroit public.nom;
		vlibdroit public.libelle;
		vcodesptrav public.identifiant;
	begin
		assert(pcodecompte is not null),'Le code du compte est vide.';	
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		assert(pcodedroit is not null),'Le code du droit est vide.';
		assert(public.existencetuple('srsecurite', 'droit', 'codedroit', pcodedroit)),'Le code <'|| pcodedroit ||'> du droit est inconnu.';
		execute format('select exists (select * from srsecurite.droitscompte where codecompte = $1 and codedroit = $2)')
		into vtrouv
		using pcodecompte, pcodedroit;
		assert(not vtrouv),'Le compte <'|| pcodecompte ||'> possede deja ce droit <'|| pcodedroit ||'>.';
	
		execute format('select nomdroit, libdroit, codesptrav from srsecurite.droit where codedroit = $1;')
		into vnomdroit, vlibdroit, vcodesptrav
		using pcodedroit;
		execute format('insert into srsecurite.droitscompte(codecompte, codedroit, nomdroit, libdroit, codesptrav) values ($1, $2, $3, $4, $5);')
		using pcodecompte, pcodedroit, vnomdroit, vlibdroit, vcodesptrav;
	
		execute format('select exists (select * from srsecurite.droitscompte where codecompte = $1 and codedroit = $2)')
		into vtrouv
		using pcodecompte, pcodedroit;
		assert(vtrouv),'Incoherence sur les donnees inserees.';
	end;
	$$;

create or replace procedure srsecurite.retirerdroitcompte(pcodecompte public.identifiant, pcodedroit public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
	begin
		assert(pcodecompte is not null),'Le code du compte est vide.';	
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		assert(pcodedroit is not null),'Le code du droit est vide.';
		assert(public.existencetuple('srsecurite', 'droit', 'codedroit', pcodedroit)),'Le code <'|| pcodedroit ||'> du droit est inconnu.';
		execute format('select exists (select * from srsecurite.droitscompte where codecompte = $1 and codedroit = $2)')
		into vtrouv
		using pcodecompte, pcodedroit;
		assert(vtrouv),'Le compte <'|| pcodecompte ||'> ne possede pas ce droit <'|| pcodedroit ||'>.';
	
		execute format('delete from srsecurite.droitscompte where codecompte = $1 and codedroit = $2;')
		using pcodecompte, pcodedroit;
	
		execute format('select exists (select * from srsecurite.droitscompte where codecompte = $1 and codedroit = $2)')
		into vtrouv
		using pcodecompte, pcodedroit;
		assert(not vtrouv),'Incoherence sur les donnees supprimees.';
	end;
	$$;

create or replace function srsecurite.obtentiondroitscompte(pcodecompte public.identifiant)
	returns table(codedroit public.identifiant, nomdroit public.nom, libdroit public.libelle, codesptrav public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodecompte is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		
		return query select pc.codedroit, pc.nomdroit, pc.libdroit, pc.codesptrav from srsecurite.droitscompte pc where pc.codecompte = pcodecompte;
	
	end;
	$$;

-- ======== Creation de la table connexion
-- ==========================================================================================================================================
create table srsecurite.connexion(
	codeconn public.identifiant not null,
	datedebconn timestamp not null,
	datefinconn timestamp null,
	nomtermconn public.libelle not null,
	adripconn cidr not null,
	adrmaconn macaddr null,
	statutconn public.etat not null,
	codecompte public.identifiant not null,
	nomcompte public.libelle not null,
	logincompte public.nom not null,
	statutcompte public.etat not null,
	codesptrav public.identifiant not null,
	nomesptrav public.nom not null,
	lienesptrav public.nom null,
	libesptrav public.libelle not null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srsecurite.connexion add constraint pkconnexion primary key (codeconn);
alter table srsecurite.connexion add constraint chkinvariantdatecreaupdaconnexion check (datecrea <= dateupda);

create or replace procedure srsecurite.ajouterconnexion(pcode public.identifiant, pdatedeb timestamp, pnomterm public.libelle, padrip cidr, padrmac macaddr, pcodecompte public.identifiant, pcodesptrav public.identifiant, pstatut public.etat, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vdatedeb timestamp;
		vnomterm public.libelle;
		vadrip cidr;
		vadrmac macaddr;
		vstatut public.etat;
		vcodecompte public.identifiant;
		vnomcompte public.libelle;
		vlogincompte public.nom;
		vstatutcompte public.etat;
		vcodesptrav public.identifiant;
		vnomesptrav public.nom;
		vlienesptrav public.nom;
		vlibesptrav public.libelle;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code de la connexion est vide.';
		assert(not public.existencetuple('srsecurite', 'connexion', 'codeconn', pcode)),'Le code <'|| pcode ||'> de connexion existe deja.';
		assert(pdatedeb is not null),'La date de debut de la connexion.';
		assert(pnomterm is not null),'Le nom du terminal est vide.';
		assert(padrip is not null),'L''adresse IP est vide.';
		assert(pstatut = 1),'Le statut de la connexion est incoherent.';
		assert(pcodecompte is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';
		assert(petat = 1),'L''etat de la connexion est incoherent.';
		assert(pord > 0),'L''ordre de la connexion est incoherent.';
		assert(pdatecrea is not null),'La date de creation de la connexion est vide.';
		
		execute format('select nomcompte, logincompte, statutcompte from srsecurite.compte where codecompte = $1;')
		into vnomcompte, vlogincompte, vstatutcompte
		using pcodecompte;
		execute format('select nomesptrav, lienesptrav, libesptrav from srsecurite.espacetravail where codesptrav = $1;')
		into vnomesptrav, vlienesptrav, vlibesptrav
		using pcodesptrav;
		execute format('insert into srsecurite.connexion (codeconn, datedebconn, nomtermconn, adripconn, adrmaconn, statutconn, codecompte, nomcompte, logincompte,	statutcompte, codesptrav, nomesptrav, lienesptrav, libesptrav, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)')
		using pcode, pdatedeb, pnomterm, padrip, padrmac, pstatut, pcodecompte, vnomcompte, vlogincompte, vstatutcompte, pcodesptrav, vnomesptrav, vlienesptrav, vlibesptrav, petat, pord, pdatecrea;
	
		execute format('select datedebconn, nomtermconn, adripconn, adrmaconn, statutconn, codecompte, codesptrav, etat, ord, datecrea from srsecurite.connexion where codeconn = $1')
		into vdatedeb, vnomterm, vadrip, vadrmac, vstatut, vcodecompte, vcodesptrav, vetat, vord, vdatecrea
		using pcode;	
		assert(vdatedeb = pdatedeb),'Incoherence sur les donnees inserees. datedebconn';
		assert(vnomterm = pnomterm),'Incoherence sur les donnees inserees. nomtermconn';
		assert(vadrip = padrip),'Incoherence sur les donnees inserees. adripconn';
		assert(vadrmac is null or vadrmac = padrmac),'Incoherence sur les donnees inserees. adrmaconn';
		assert(vstatut = pstatut),'Incoherence sur les donnees inserees. statutconn';
		assert(vcodecompte = pcodecompte),'Incoherence sur les donnees inserees. codecompte';
		assert(vcodesptrav = pcodesptrav),'Incoherence sur les donnees inserees. codesptrav';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srsecurite.mettreajourfermetureconnexion(pcode public.identifiant, pstatut public.etat, pdatefin timestamp, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
		vdatefin timestamp;
		vdatedeb timestamp;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code de la connexion est vide.';
		assert(public.existencetuple('srsecurite', 'connexion', 'codeconn', pcode)),'Le code <'|| pcode ||'> de la connexion est inconnu.';
		assert(pstatut is not null),'Le statut de la connexion est vide.';
		assert(pstatut = 2),'Le statut de la connexion est incoherent.';
		assert(pdatefin is not null),'La date de fin de la connexion est vide.';
		execute format('select datedebconn from srsecurite.connexion where codeconn = $1')
		into vdatedeb
		using pcode;
		assert(pdatefin >= vdatedeb),'La date de fin de la connexion est incoherente.';
		assert(pdateupda is not null),'La date de mise a jour de la connexion est vide.';
		execute format('select dateupda from srsecurite.connexion where codeconn = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour de la connexion est incoherente.';
	
		execute format('update srsecurite.connexion set statutconn = $1, datefinconn = $2, dateupda = $3 where codeconn = $4')
		using pstatut, pdatefin, pdateupda, pcode;
	
		execute format('select statutconn, datefinconn, dateupda from srsecurite.connexion where codeconn = $1')
		into vstatut, vdatefin, vdateupda
		using pcode;
		assert(vstatut = pstatut),'Les donnees mises a jour sont incoherentes. statutconn';
		assert(vdatefin = pdatefin),'Les donnees mises a jour sont incoherentes. datefinconn';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srsecurite.aftermiseajourconnexion()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		execute format('update srsecurite.activite set datedebconn = $1, nomtermconn = $2, adripconn = $3, adrmaconn = $4, statutconn = $5, codecompte = $6, codesptrav = $7 where codeconn = $8')
		using new.datedebconn, new.nomtermconn, new.adripconn, new.adrmaconn, new.statutconn, new.codecompte, new.codesptrav, old.codeconn;
		return null;
	
	end;
	$$;	

create trigger miseajourconnexion after update on srsecurite.connexion for each row execute function srsecurite.aftermiseajourconnexion();

create or replace function srsecurite.authentificationconnexion(pcodeconn public.identifiant, pnomterm public.libelle, padrip cidr)
	returns table(codeconn public.identifiant, datedebconn timestamp, datefinconn timestamp, nomtermconn public.libelle, adripconn cidr, adrmaconn macaddr, statutconn public.etat, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat, codesptrav public.identifiant, nomesptrav public.nom, lienesptrav public.nom, libesptrav public.libelle)	
	language plpgsql
	as $$
	declare
		vstatut public.etat;
		vnomterm public.libelle;
		vadrip cidr;
	begin 
		
		assert(pcodeconn is not null),'Le code de connexion est vide.';
		assert(public.existencetuple('srsecurite', 'connexion', 'codeconn', pcodeconn)),'Le code <'|| pcodeconn ||'> de la connexion est inconnu.';
		assert(pnomterm is not null),'Le nom du terminal est vide.';
		assert(padrip is not null),'L''adresse IP est vide.';
		execute format('select nomtermconn, adripconn, statutconn from srsecurite.connexion where codeconn = $1;')
		into vnomterm, vadrip, vstatut
		using pcodeconn;
		assert(vstatut = 1),'Le statut de cette connexion est incoherente.';
		assert(vnomterm = pnomterm),'Cette connexion ne correspond pas a cet environnement d''execution.';
		
		return query select c.codeconn, c.datedebconn, c.datefinconn, c.nomtermconn, c.adripconn, c.adrmaconn, c.statutconn, c.codecompte, c.nomcompte, c.logincompte, c.statutcompte, c.codesptrav, c.nomesptrav, c.lienesptrav, c.libesptrav from srsecurite.connexion c where c.codeconn = pcodeconn;
		
	end;
	$$;

create or replace function srsecurite.obtentionconnexion(pcode public.identifiant)
	returns table(codeconn public.identifiant, datedebconn timestamp, datefinconn timestamp, nomtermconn public.libelle, adripconn cidr, adrmaconn macaddr, statutconn public.etat, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat, codesptrav public.identifiant, nomesptrav public.nom, lienesptrav public.nom, libesptrav public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code de la connexion est vide.';
		assert(public.existencetuple('srsecurite', 'connexion', 'codeconn', pcode)),'Le code <'|| pcode ||'> de la connexion est inconnu.';
		
		return query select c.codeconn, c.datedebconn, c.datefinconn, c.nomtermconn, c.adripconn, c.adrmaconn, c.statutconn, c.codecompte, c.nomcompte, c.logincompte, c.statutcompte, c.codesptrav, c.nomesptrav, c.lienesptrav, c.libesptrav from srsecurite.connexion c where c.codeconn = pcode;
	
	end;
	$$;

create or replace function srsecurite.obtentionconnexionscompte(pcodecompte public.identifiant)
	returns table(codeconn public.identifiant, datedebconn timestamp, datefinconn timestamp, nomtermconn public.libelle, adripconn cidr, adrmaconn macaddr, statutconn public.etat, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat, codesptrav public.identifiant, nomesptrav public.nom, lienesptrav public.nom, libesptrav public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodecompte is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		
		return query select c.codeconn, c.datedebconn, c.datefinconn, c.nomtermconn, c.adripconn, c.adrmaconn, c.statutconn, c.codecompte, c.nomcompte, c.logincompte, c.statutcompte, c.codesptrav, c.nomesptrav, c.lienesptrav, c.libesptrav from srsecurite.connexion c where c.etat <> 3 and c.codecompte = pcodecompte;
	
	end;
	$$;

create or replace function srsecurite.obtentionconnexionsespacetravail(pcodesptrav public.identifiant)
	returns table(codeconn public.identifiant, datedebconn timestamp, datefinconn timestamp, nomtermconn public.libelle, adripconn cidr, adrmaconn macaddr, statutconn public.etat, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat, codesptrav public.identifiant, nomesptrav public.nom, lienesptrav public.nom, libesptrav public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';
		
		return query select c.codeconn, c.datedebconn, c.datefinconn, c.nomtermconn, c.adripconn, c.adrmaconn, c.statutconn, c.codecompte, c.nomcompte, c.logincompte, c.statutcompte, c.codesptrav, c.nomesptrav, c.lienesptrav, c.libesptrav from srsecurite.connexion c where c.etat <> 3 and c.codesptrav = pcodesptrav;
	
	end;
	$$;

create or replace function srsecurite.rechercheconnexionsactives(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
 	returns table(codeconn public.identifiant, datedebconn timestamp, datefinconn timestamp, nomtermconn public.libelle, adripconn cidr, adrmaconn macaddr, statutconn public.etat, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat, codesptrav public.identifiant, nomesptrav public.nom, lienesptrav public.nom, libesptrav public.libelle)
 	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select c.codeconn, c.datedebconn, c.datefinconn, c.nomtermconn, c.adripconn, c.adrmaconn, c.statutconn, c.codecompte, c.nomcompte, c.logincompte, c.statutcompte, c.codesptrav, c.nomesptrav, c.lienesptrav, c.libesptrav from srsecurite.connexion c where c.etat <> 3 and c.statutconn = 1 order by c.ord desc limit plimit offset pdebut;
		else
			return query select c.codeconn, c.datedebconn, c.datefinconn, c.nomtermconn, c.adripconn, c.adrmaconn, c.statutconn, c.codecompte, c.nomcompte, c.logincompte, c.statutcompte, c.codesptrav, c.nomesptrav, c.lienesptrav, c.libesptrav from srsecurite.connexion c where c.etat <> 3 and c.statutconn = 1 and (c.nomcompte ilike '%'|| pcritere ||'%' or c.logincompte ilike '%'|| pcritere ||'%') order by c.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== Creation de la table activite
-- ==========================================================================================================================================
create table srsecurite.activite(
	codeactiv public.identifiant not null,
	dateactiv timestamp not null,
	descractiv public.libelle not null,
	codeconn public.identifiant not null,
	datedebconn timestamp not null,
	datefinconn timestamp null,
	nomtermconn public.libelle not null,
	adripconn cidr not null,
	adrmaconn macaddr null,
	statutconn public.etat not null,
	codecompte public.identifiant not null,
	codesptrav public.identifiant not null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srsecurite.activite add constraint pkactivite primary key (codeactiv);
alter table srsecurite.activite add constraint chkinvariantdatecreaupdaactivite check (datecrea <= dateupda);

create or replace procedure srsecurite.ajouteractivite(pcode public.identifiant, pdate timestamp, pdescr public.libelle, pcodeconn public.identifiant, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vdate timestamp;
		vdescr public.libelle;
		vcodeconn public.identifiant;
		vdatedebconn timestamp;
		vnomtermconn public.libelle;
		vadripconn cidr;
		vadrmaconn macaddr;
		vstatutconn public.etat;
		vcodecompte public.identifiant;
		vcodesptrav public.identifiant;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code de l''activite est vide.';
		assert(not public.existencetuple('srsecurite', 'activite', 'codeactiv', pcode)),'Le code <'|| pcode ||'> de l''activite existe deja.';
		assert(pdate is not null),'La date de l''activite est vide.';
		assert(pdescr is not null),'La description de l''activite est vide.';
		assert(pcodeconn is not null),'Le code de la connexion est vide.';
		assert(public.existencetuple('srsecurite', 'connexion', 'codeconn', pcodeconn)),'Le code <'|| pcodeconn ||'> de la connexion est inconnu.';
		assert(petat = 1),'L''etat de l''activite est incoherent.';
		assert(pord > 0),'L''ordre de l''activite est incoherent.';
		assert(pdatecrea is not null),'La date de creation de l''activite est vide.';
		
		execute format('select datedebconn, nomtermconn, adripconn, adrmaconn, statutconn, codecompte, codesptrav from srsecurite.connexion where codeconn = $1;')
		into vdatedebconn, vnomtermconn, vadripconn, vadrmaconn, vstatutconn, vcodecompte, vcodesptrav
		using pcodeconn;
		execute format('insert into srsecurite.activite (codeactiv, dateactiv, descractiv, codeconn, datedebconn, nomtermconn, adripconn, adrmaconn, statutconn, codecompte, codesptrav, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)')
		using pcode, pdate, pdescr, pcodeconn, vdatedebconn, vnomtermconn, vadripconn, vadrmaconn, vstatutconn, vcodecompte, vcodesptrav, petat, pord, pdatecrea;
	
		execute format('select dateactiv, descractiv, codeconn, etat, ord, datecrea from srsecurite.activite where codeactiv = $1')
		into vdate, vdescr, vcodeconn, vetat, vord, vdatecrea
		using pcode;	
		assert(vdate = pdate),'Incoherence sur les donnees inserees. dateactiv';
		assert(vdescr = pdescr),'Incoherence sur les donnees inserees. descractiv';
		assert(vcodeconn = pcodeconn),'Incoherence sur les donnees inserees. codeconn';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace function srsecurite.obtentionactivite(pcode public.identifiant)
	returns table(codeactiv public.identifiant, dateactiv timestamp, descractiv public.libelle, codeconn public.identifiant, datedebconn timestamp, datefinconn timestamp, nomtermconn public.libelle, adripconn cidr, adrmaconn macaddr, statutconn public.etat, codecompte public.identifiant, codesptrav public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code de l''activite est vide.';
		assert(public.existencetuple('srsecurite', 'activite', 'codeactiv', pcode)),'Le code <'|| pcode ||'> de l''activite est inconnu.';
		
		return query select a.codeactiv, a.dateactiv, a.descractiv, a.codeconn, a.datedebconn, a.datefinconn, a.nomtermconn, a.adripconn, a.adrmaconn, a.statutconn, a.codecompte, a.codesptrav from srsecurite.activite a where a.codeactiv = pcode;
	
	end;
	$$;

create or replace function srsecurite.obtentionactivitescompte(pcodecompte public.identifiant)
	returns table(codeactiv public.identifiant, dateactiv timestamp, descractiv public.libelle, codeconn public.identifiant, datedebconn timestamp, datefinconn timestamp, nomtermconn public.libelle, adripconn cidr, adrmaconn macaddr, statutconn public.etat, codecompte public.identifiant, codesptrav public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodecompte is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		
		return query select a.codeactiv, a.dateactiv, a.descractiv, a.codeconn, a.datedebconn, a.datefinconn, a.nomtermconn, a.adripconn, a.adrmaconn, a.statutconn, a.codecompte, a.codesptrav from srsecurite.activite a where a.codecompte = pcodecompte;
	
	end;
	$$;

create or replace function srsecurite.obtentionactivitesespacetravail(pcodesptrav public.identifiant)
	returns table(codeactiv public.identifiant, dateactiv timestamp, descractiv public.libelle, codeconn public.identifiant, datedebconn timestamp, datefinconn timestamp, nomtermconn public.libelle, adripconn cidr, adrmaconn macaddr, statutconn public.etat, codecompte public.identifiant, codesptrav public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';
		
		return query select a.codeactiv, a.dateactiv, a.descractiv, a.codeconn, a.datedebconn, a.datefinconn, a.nomtermconn, a.adripconn, a.adrmaconn, a.statutconn, a.codecompte, a.codesptrav from srsecurite.activite a where a.codesptrav = pcodesptrav;
	
	end;
	$$;

-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== Creation du schema cudfichier
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create schema cudfichier;
alter schema cudfichier owner to akamcuddbservey;

-- ======== Creation de la table fichier
-- ==========================================================================================================================================
create table cudfichier.fichier(
	codefic public.identifiant not null,
	nomfic public.nom not null,
	mimefic public.nom not null,
	taillefic numeric not null,
	contenfic bytea not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudfichier.fichier add constraint pkfichier primary key (codefic);
alter table cudfichier.fichier add constraint chkinvariant1fichier check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudfichier.fichier add constraint chkinvariant2fichier check (datecrea <= dateupda);

create or replace function cudfichier.creationfichier(pnom public.nom, pmime public.nom, ptaille numeric, pconten bytea)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vnom public.nom;
		vmime public.nom;
		vtaille numeric;
	begin 
		
		assert(pnom is not null),'Le nom du fichier est vide.';
		assert(pmime is not null),'Le mime du fichier est vide.';
		assert(ptaille > 0),'La taille du fichier est incoherente.';
		assert(pconten is not null),'Le fichier est vide.';
		
		vcode = cudincrement.generationidentifiant('fichier');
		vordmax = public.obtentionordremax('cudfichier', 'fichier', 'ord');
		execute format('insert into cudfichier.fichier (codefic, nomfic, mimefic, taillefic, contenfic, ord) values ($1, $2, $3, $4, $5, $6)')
		using vcode, pnom, pmime, ptaille, pconten, vordmax;
	
		execute format('select nomfic, mimefic, taillefic from cudfichier.fichier where codefic = $1')
		into vnom, vmime, vtaille
		using vcode;	
		assert(vnom = pnom),'Incoherence 1 sur les donnees inserees. nomfic';
		assert(vmime = pmime),'Incoherence 1 sur les donnees inserees. mimefic';
		assert(vtaille = ptaille),'Incoherence 1 sur les donnees inserees. taillefic';
		
		return vcode;
	end;
	$$;

create or replace function cudfichier.aftercreationfichier()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		
		call srfichier.ajouterfichier(new.codefic, new.nomfic, new.mimefic, new.taillefic, new.contenfic, new.etat, new.ord, new.datecrea);	
		return null;
	
	end;
	$$;	

create trigger ajouterfichier after insert on cudfichier.fichier for each row execute function cudfichier.aftercreationfichier();

create or replace procedure cudfichier.modifierfichier(pcode public.identifiant, pnom public.nom, pmime public.nom, ptaille numeric, pconten bytea)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vmime public.nom;
		vtaille numeric;
	begin 
		
		assert(public.existencetuple('cudfichier', 'fichier', 'codefic', pcode)),'Le code <'|| pcode ||'> du fichier est inconnu.';	
		assert(pnom is not null),'Le nom du fichier est vide.';
		assert(pmime is not null),'Le mime du fichier est vide.';
		assert(ptaille > 0),'La taille du fichier est incoherente.';
		assert(pconten is not null),'Le fichier est vide.';
		
		execute format('update cudfichier.fichier set nomfic = $1, mimefic = $2, taillefic = $3, contenfic = $4, dateupda = current_timestamp where codefic = $5')
		using pnom, pmime, ptaille, pconten, pcode;
	
		execute format('select nomfic, mimefic, taillefic from cudfichier.fichier where codefic = $1')
		into vnom, vmime, vtaille
		using pcode;	
		assert(vnom = pnom),'Incoherence 1 sur les donnees inserees. nomfic';
		assert(vmime = pmime),'Incoherence 1 sur les donnees inserees. mimefic';
		assert(vtaille = ptaille),'Incoherence 1 sur les donnees inserees. taillefic';
		
	end;
	$$;

create or replace procedure cudfichier.supprimerfichier(pcode public.identifiant)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vmime public.nom;
		vtaille numeric;
	begin 
		
		assert(public.existencetuple('cudfichier', 'fichier', 'codefic', pcode)),'Le code <'|| pcode ||'> du fichier est inconnu.';	
		
		call public.supprimer('cudfichier', 'fichier', 'codefic', pcode);
	
		assert(not public.existencetuple('cudfichier', 'fichier', 'codefic', pcode)),'Incoherence 1 sur les donnees inserees.';
		
	end;
	$$;

create or replace function cudfichier.aftermettreajourfichier()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		if (old.etat != new.etat) then 
			call srfichier.mettreajouretatfichier(new.codefic, new.etat, new.dateupda);
		else
			call srfichier.mettreajourfichier(new.codefic, new.nomfic, new.mimefic, new.taillefic, new.contenfic, new.dateupda);
		end if;	
		return null;
	
	end;
	$$;	

create trigger mettreajourfichier after update on cudfichier.fichier for each row execute function cudfichier.aftermettreajourfichier();

create or replace function cudfichier.aftersupprimerfichier()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		return null;
	
	end;
	$$;	

create trigger supprimerfichier after delete on cudfichier.fichier for each row execute function cudfichier.aftersupprimerfichier();

-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== Creation du schema srfichier
-- ==========================================================================================================================================
create schema srfichier;
alter schema srfichier owner to akamsrdbservey;

-- ======== Creation de la table fichier
-- ==========================================================================================================================================
create table srfichier.fichier(
	codefic public.identifiant not null,
	nomfic public.nom not null,
	mimefic public.nom not null,
	taillefic numeric not null,
	contenfic bytea not null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srfichier.fichier add constraint pkfichier primary key (codefic);
alter table srfichier.fichier add constraint chkinvariant2fichier check (datecrea <= dateupda);

create or replace procedure srfichier.ajouterfichier(pcodefic public.identifiant, pnom public.nom, pmime public.nom, ptaille numeric, pconten bytea, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vmime public.nom;
		vtaille numeric;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(not public.existencetuple('srfichier', 'fichier', 'codefic', pcodefic)),'Le code <'|| pcodefic ||'> du fichier est inconnu.';
		assert(pnom is not null),'Le nom du fichier est vide.';
		assert(pmime is not null),'Le mime du fichier est vide.';
		assert(ptaille > 0),'La taille du fichier est incoherente.';
		assert(pconten is not null),'Le fichier est vide.';
		assert(petat = 1),'L''etat du fichier est vide.';
		assert(pord > 0),'L''ordre du fichier est vide.';
		assert(pdatecrea is not null),'La date de creation du fichier est vide.';
		
		execute format('insert into srfichier.fichier (codefic, nomfic, mimefic, taillefic, contenfic, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8)')
		using pcodefic, pnom, pmime, ptaille, pconten, petat, pord, pdatecrea;
	
		execute format('select nomfic, mimefic, taillefic, etat, ord, datecrea from srfichier.fichier where codefic = $1')
		into vnom, vmime, vtaille, vetat, vord, vdatecrea
		using pcodefic;	
		assert(vnom = pnom),'Incoherence 1 sur les donnees inserees. nomfic';
		assert(vmime = pmime),'Incoherence 1 sur les donnees inserees. mimefic';
		assert(vtaille = ptaille),'Incoherence 1 sur les donnees inserees. taillefic';
		assert(vetat = petat),'Incoherence 1 sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence 1 sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence 1 sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srfichier.mettreajouretatfichier(pcode public.identifiant, petat public.etat, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vetat public.etat;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du fichier est vide.';
		assert(public.existencetuple('srfichier', 'fichier', 'codefic', pcode)),'Le code <'|| pcode ||'> du fichier est inconnu.';
		assert(pdateupda is not null),'La date de mise a jour du fichier est vide.';
		assert(petat >= 1 and petat <= 4),'L''etat du fichier est incorrect.';	
		execute format('select dateupda from srfichier.fichier where codefic = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour du fichier est incoherente.';
	
		execute format('update srfichier.fichier set etat = $1, dateupda = $2 where codefic = $3')
		using petat, pdateupda, pcode;
	
		execute format('select etat, dateupda from srfichier.fichier where codefic = $1')
		into vetat, vdateupda
		using pcode;
		assert(vetat = petat),'Les donnees mises a jour sont incoherentes. etat';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace procedure srfichier.mettreajourfichier(pcode public.identifiant, pnom public.nom, pmime public.nom, ptaille numeric, pconten bytea, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vmime public.nom;
		vtaille numeric;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du fichier est vide.';
		assert(public.existencetuple('srfichier', 'fichier', 'codefic', pcode)),'Le code <'|| pcode ||'> du fichier est inconnu.';
		assert(pdateupda is not null),'La date de mise a jour du fichier est vide.';
		assert(pnom is not null),'Le nom du fichier est vide.';
		assert(pmime is not null),'Le mime du fichier est vide.';
		assert(ptaille > 0),'La taille du fichier est incoherente.';
		assert(pconten is not null),'Le fichier est vide.';
		execute format('select dateupda from srfichier.fichier where codefic = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour du fichier est incoherente.';
	
		execute format('update srfichier.fichier set nomfic = $1, mimefic = $2, taillefic = $3, contenfic = $4, dateupda = $5 where codefic = $6')
		using pnom, pmime, ptaille, pconten, pdateupda, pcode;
	
		execute format('select nomfic, mimefic, taillefic, dateupda from srfichier.fichier where codefic = $1')
		into vnom, vmime, vtaille, vdateupda
		using pcode;
		assert(vnom = pnom),'Les donnees mises a jour sont incoherentes. nomfic';
		assert(vmime = pmime),'Les donnees mises a jour sont incoherentes. mimefic';
		assert(vtaille = ptaille),'Les donnees mises a jour sont incoherentes. taillefic';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srfichier.obtentionfichier(pcode public.identifiant)
	returns table(codefic public.identifiant, nomfic public.nom, mimefic public.nom, taillefic numeric, contenfic bytea)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code du fichier est vide.';
		assert(public.existencetuple('srfichier', 'fichier', 'codefic', pcode)),'Le code <'|| pcode ||'> du fichier est inconnu.';
		
		return query select f.codefic, f.nomfic, f.mimefic, f.taillefic, f.contenfic from srfichier.fichier f where f.codefic = pcode;
	
	end;
	$$;
	
-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== création du schema cuddomaine
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create schema cuddomaine;
alter schema cuddomaine owner to akamcuddbservey;

-- ======== création de la table domaine
-- ==========================================================================================================================================
create table cuddomaine.domaine(
	codedom public.identifiant not null,
	nomdom public.nom not null,
	typdom public.etat not null,
	enumdom public.enumdomaine not null,
	libdom public.libelle null,
	parent1 public.identifiant null,
	parent2 public.identifiant null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cuddomaine.domaine add constraint pkdomaine primary key (codedom);
alter table cuddomaine.domaine add constraint unnomdom unique (nomdom);
alter table cuddomaine.domaine add constraint chkinvariantcardetatdomaine check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cuddomaine.domaine add constraint chkinvariantdatecreaupdadomaine check (datecrea <= dateupda);
alter table cuddomaine.domaine add constraint fkdomaineparent1 foreign key (parent1) references cuddomaine.domaine(codedom) on delete cascade;
alter table cuddomaine.domaine add constraint fkdomaineparent2 foreign key (parent2) references cuddomaine.domaine(codedom) on delete cascade;

create or replace function cuddomaine.creationdomaine(penumdom public.enumdomaine, pnom public.nom, ptyp public.etat, plib public.libelle, pparent1 public.identifiant, pparent2 public.identifiant)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		venumdom public.enumdomaine;
		vnom public.nom;
		vtyp public.etat;
		vlib public.libelle;
		vparent1 public.identifiant;
		vparent2 public.identifiant;
	begin 
		
		assert(penumdom is not null),'L''enum du domaine est vide.';
		assert(pnom is not null),'Le nom du domaine est vide.';
		assert(not public.existencetuple('cuddomaine', 'domaine', 'nomdom', pnom)),'Le nom <'|| pnom ||'> du domaine est existant.';
		assert(ptyp is not null),'Le type du domaine est vide.';
		assert(ptyp = 1 or ptyp = 2 or ptyp = 3),'Le type du domaine est incoherent.';
		if (pparent1 is not null) then
			assert(public.existencetuple('cuddomaine', 'domaine', 'codedom', pparent1)),'Le code <'|| pparent1 ||'> du domaine parent1 est inconnu.';
		end if;
		if (pparent2 is not null) then
			assert(public.existencetuple('cuddomaine', 'domaine', 'codedom', pparent2)),'Le code <'|| pparent2 ||'> du domaine parent2 est inconnu.';
		end if;
		
		vcode := cudincrement.generationidentifiant('domaine');
		vordmax := public.obtentionordremax('cuddomaine', 'domaine', 'ord');
		execute format('insert into cuddomaine.domaine (codedom, enumdom, nomdom, typdom, libdom, parent1, parent2, ord) values ($1, $2, $3, $4, $5, $6, $7, $8)')
		using vcode, penumdom, pnom, ptyp, plib, pparent1, pparent2, vordmax;
	
		execute format('select enumdom, nomdom, typdom, libdom, parent1, parent2 from cuddomaine.domaine where codedom = $1')
		into venumdom, vnom, vtyp, vlib, vparent1, vparent2
		using vcode;	
		assert(venumdom = penumdom),'Incoherence sur les donnees inserees. enumdom';
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomdom';
		assert(vtyp = ptyp),'Incoherence sur les donnees inserees. typdom';
		assert((vlib is null) or (vlib = plib)),'Incoherence sur les donnees inserees. libdom';
		assert((vparent1 is null) or (vparent1 = pparent1)),'Incoherence sur les donnees inserees. parent1';
		assert((vparent2 is null) or (vparent2 = pparent2)),'Incoherence sur les donnees inserees. parent2';
		
		return vcode;
	end;
	$$;

create or replace function cuddomaine.aftercreationdomaine()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		call srdomaine.ajouterdomaine(new.codedom, new.enumdom, new.nomdom, new.typdom, new.libdom, new.parent1, new.parent2, new.etat, new.ord, new.datecrea);
		if (new.parent1 is not null) then
			call public.attacher('cuddomaine', 'domaine', 'codedom', new.parent1);
		end if;
		if (new.parent2 is not null) then
			call public.attacher('cuddomaine', 'domaine', 'codedom', new.parent2);
		end if;	
	
		return null;
	end;
	$$;	

create trigger ajoutdomaine after insert on cuddomaine.domaine for each row execute function cuddomaine.aftercreationdomaine();

create or replace procedure cuddomaine.modifierdomaine(pcode public.identifiant, pnom public.nom, plib public.libelle)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vlib public.libelle;
	begin 
		
		assert(pcode is not null),'Le code du domaine est vide.';
		assert(public.existencetuple('cuddomaine', 'domaine', 'codedom', pcode)),'Le nom <'|| pnom ||'> du domaine est inconnu.';
		assert(pnom is not null),'Le nom du comaine est vide.';
		execute format('select nomdom from cuddomaine.domaine where codedom = $1')
		into vnom
		using pcode;
		if (vnom != pnom) then			
			assert(not public.existencetuple('cuddomaine', 'domaine', 'nomdom', pnom)),'Le nom <'|| pnom ||'> du domaine est existant.';
		end if;
		
		execute format('update cuddomaine.domaine set nomdom = $1, libdom = $2, dateupda = current_timestamp where codedom = $3')
		using pnom, plib, pcode;
	
		execute format('select nomdom, libdom from cuddomaine.domaine where codedom = $1')
		into vnom, vlib
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomdom';
		assert((vlib is null) or (vlib = plib)),'Incoherence sur les donnees inserees. libdom';
		
	end;
	$$;

create or replace procedure cuddomaine.supprimerdomaine(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cuddomaine', 'domaine', 'codedom', pcode)),'Le code <'|| pcode ||'> du domaine est inconnu.';	
		
		call public.supprimer('cuddomaine', 'domaine', 'codedom', pcode);
	
		assert(not public.existencetuple('cuddomaine', 'domaine', 'codedom', pcode)),'Incoherence sur le tuple supprimé.';
		
	end;
	$$;

create or replace function cuddomaine.aftermiseajourdomaine()
	returns trigger 
	language plpgsql
	as $$
	begin 
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srdomaine', 'domaine', 'codedom', old.codedom, new.etat, new.dateupda);
		else
			call srdomaine.mettreajourdomaine(old.codedom, new.nomdom, new.libdom, new.dateupda);
		end if;
		return null;
	end;
	$$;	

create trigger miseajourdomaine after update on cuddomaine.domaine for each row execute function cuddomaine.aftermiseajourdomaine();

create or replace function cuddomaine.aftersuppressiondomaine()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		if (old.parent1 is not null) then
			call public.detacher('cuddomaine', 'domaine', 'codedom', old.parent1);
		end if;
		if (old.parent2 is not null) then
			call public.detacher('cuddomaine', 'domaine', 'codedom', old.parent2);
		end if;
		return null;
	
	end;
	$$;	

create trigger suppressiondomaine after delete on cuddomaine.domaine for each row execute function cuddomaine.aftersuppressiondomaine();

-- ======== création de la table nomenclature
-- ==========================================================================================================================================
create table cuddomaine.nomenclature(
	codenomen public.identifiant not null,
	codedom public.identifiant not null,
	enumnomen public.enumnomenclature NULL,
	parent1 public.identifiant null,
	parent2 public.identifiant null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cuddomaine.nomenclature add constraint pknomenclature primary key (codenomen);
alter table cuddomaine.nomenclature add constraint chkinvariantcardetatnomenclature check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cuddomaine.nomenclature add constraint chkinvariantdatecreaupdanomenclature check (datecrea <= dateupda);
alter table cuddomaine.nomenclature add constraint fknomenclaturedomaine foreign key (codedom) references cuddomaine.domaine(codedom) on delete cascade;
alter table cuddomaine.nomenclature add constraint fknomenclatureparent1 foreign key (parent1) references cuddomaine.nomenclature(codenomen) on delete cascade;
alter table cuddomaine.nomenclature add constraint fknomenclatureparent2 foreign key (parent2) references cuddomaine.nomenclature(codenomen) on delete cascade;

create or replace function cuddomaine.creationomenclature(penumnomen public.enumnomenclature, pnomdom public.nom, pparent1 public.identifiant, pparent2 public.identifiant)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vparent1 public.identifiant;
		vparent2 public.identifiant;
		vcodedom public.identifiant;
		venumnomen public.enumnomenclature;
	begin 
		
		assert(penumnomen is not null),'L''enum de la nomenclature est vide.';
		assert(pnomdom is not null),'Le nom du domaine est vide.';
		assert(public.existencetuple('cuddomaine', 'domaine', 'nomdom', pnomdom)),'Le nom <'|| pnomdom ||'> du domaine est inconnu.';
		if (pparent1 is not null) then
			assert(public.existencetuple('cuddomaine', 'nomenclature', 'codenomen', pparent1)),'Le code <'|| pparent1 ||'> de la nomenclature parente1 est inconnu.';
		end if;
		if (pparent2 is not null) then
			assert(public.existencetuple('cuddomaine', 'nomenclature', 'codenomen', pparent2)),'Le code <'|| pparent2 ||'> de la nomenclature parente2 est inconnu.';
		end if;
		
		execute format('select codedom from cuddomaine.domaine where nomdom = $1')
		into vcodedom
		using pnomdom;
		vcode := cudincrement.generationidentifiant('nomenclature');
		vordmax := public.obtentionordremax('cuddomaine', 'nomenclature', 'ord');
		execute format('insert into cuddomaine.nomenclature (codenomen, enumnomen, codedom, parent1, parent2, ord) values ($1, $2, $3, $4, $5, $6)')
		using vcode, penumnomen, vcodedom, pparent1, pparent2, vordmax;
	
		execute format('select enumnomen, parent1, parent2 from cuddomaine.nomenclature where codenomen = $1')
		into venumnomen, vparent1, vparent2
		using vcode;	
		assert(venumnomen = penumnomen),'Incoherence sur les donnees inserees. enumnomen';
		assert((vparent1 is null) or (vparent1 = pparent1)),'Incoherence sur les donnees inserees. parent1';
		assert((vparent2 is null) or (vparent2 = pparent2)),'Incoherence sur les donnees inserees. parent2';
		
		return vcode;
	end;
	$$;

create or replace function cuddomaine.aftercreationomenclature()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		call srdomaine.ajouternomenclature(new.codenomen, new.enumnomen, new.codedom, new.parent1, new.parent2, new.etat, new.ord, new.datecrea);
		call public.attacher('cuddomaine', 'domaine', 'codedom', new.codedom);
		if (new.parent1 is not null) then
			call public.attacher('cuddomaine', 'nomenclature', 'codenomen', new.parent1);
		end if;
		if (new.parent2 is not null) then
			call public.attacher('cuddomaine', 'nomenclature', 'codenomen', new.parent2);
		end if;	
	
		return null;
	end;
	$$;	

create trigger ajoutnomenclature after insert on cuddomaine.nomenclature for each row execute function cuddomaine.aftercreationomenclature();

create or replace procedure cuddomaine.supprimernomenclature(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cuddomaine', 'nomenclature', 'codenomen', pcode)),'Le code <'|| pcode ||'> de la nomenclature est inconnu.';	
		
		call public.supprimer('cuddomaine', 'nomenclature', 'codenomen', pcode);
	
		assert(not public.existencetuple('cuddomaine', 'nomenclature', 'codenomen', pcode)),'Incoherence sur le tuple supprimé.';
		
	end;
	$$;

create or replace function cuddomaine.aftermiseajournomenclature()
	returns trigger 
	language plpgsql
	as $$
	begin 
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srdomaine', 'nomenclature', 'codenomen', old.codenomen, new.etat, new.dateupda);
		end if;
		return null;
	end;
	$$;	

create trigger miseajournomenclature after update on cuddomaine.nomenclature for each row execute function cuddomaine.aftermiseajournomenclature();

create or replace function cuddomaine.aftersuppressionomenclature()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		call public.detacher('cuddomaine', 'domaine', 'codedom', old.codedom);
		if (old.parent1 is not null) then
			call public.detacher('cuddomaine', 'nomenclature', 'codenomen', old.parent1);
		end if;
		if (old.parent2 is not null) then
			call public.detacher('cuddomaine', 'nomenclature', 'codenomen', old.parent2);
		end if;
		return null;
	
	end;
	$$;	

create trigger suppressionomenclature after delete on cuddomaine.nomenclature for each row execute function cuddomaine.aftersuppressionomenclature();

-- ======== création de la table valeurnomenclature
-- ==========================================================================================================================================
create table cuddomaine.valeurnomenclature(
	codevalnomen public.identifiant not null,
	codenomen public.identifiant not null,
	lang public.isolangue null,
	lib public.libelle not null,
	descr public.libelle null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cuddomaine.valeurnomenclature add constraint pkvaleurnomenclature primary key (codevalnomen);
alter table cuddomaine.valeurnomenclature add constraint chkinvariantcardetatvaleurnomenclature check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cuddomaine.valeurnomenclature add constraint chkinvariantdatecreaupdavaleurnomenclature check (datecrea <= dateupda);
alter table cuddomaine.valeurnomenclature add constraint fkvaleurnomenclature foreign key (codenomen) references cuddomaine.nomenclature(codenomen) on delete cascade;

create or replace function cuddomaine.creationvaleurnomenclature(pcodenomen public.identifiant, plang public.isolangue, plib public.libelle, pdescr public.libelle)
	returns public.identifiant
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vcodenomen public.identifiant;
		vlang public.isolangue;
		vlib public.libelle;
		vdescr public.libelle;
		vtrouv boolean;
	begin 
		
		assert(pcodenomen is not null),'Le code de la nomenclature est vide.';
		assert(public.existencetuple('cuddomaine', 'nomenclature', 'codenomen', pcodenomen)),'Le nom <'|| pcodenomen ||'> de la nomenclature est inconnu.';
		assert(plib is not null),'Le libelle de la nomenclature est vide.';		
		if (plang is not null) then
			execute format('select exists (select codevalnomen from cuddomaine.valeurnomenclature where codenomen = $1 and lang = $2)')
			into vtrouv
			using pcodenomen, plang;
			assert(not vtrouv),'Ce contenu possede deja une valeur dans cette langue.';
		else
			execute format('select exists (select codevalnomen from cuddomaine.valeurnomenclature where codenomen = $1 and lang is null)')
			into vtrouv
			using pcodenomen;
			assert(not vtrouv),'Ce contenu possede deja une valeur dans aucune langue.';
		end if;
		
		vcode := cudincrement.generationidentifiant('valeurnomenclature');
		vordmax := public.obtentionordremax('cuddomaine', 'valeurnomenclature', 'ord');
		execute format('insert into cuddomaine.valeurnomenclature (codevalnomen, codenomen, lang, lib, descr, ord) values ($1, $2, $3, $4, $5, $6)')
		using vcode, pcodenomen, plang, plib, pdescr, vordmax;
		
		execute format('select codenomen, lang, lib, descr from cuddomaine.valeurnomenclature where codevalnomen = $1')
		into vcodenomen, vlang, vlib, vdescr
		using vcode;	
		assert(vcodenomen = pcodenomen),'Incoherence sur les donnees inserees. codenomen';
		assert((vlang is null) or (vlang = plang)),'Incoherence sur les donnees inserees. lang';
		assert(vlib = plib),'Incoherence sur les donnees inserees. lib';
		assert((vdescr is null) or (vdescr = pdescr)),'Incoherence sur les donnees inserees. descr';
	
		return vcode;
		
	end;
	$$;

create or replace function cuddomaine.aftercreationvaleurnomenclature()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		call srdomaine.ajoutervaleurnomenclature(new.codevalnomen, new.codenomen, new.lang, new.lib, new.descr, new.etat, new.ord, new.datecrea);
		call public.attacher('cuddomaine', 'nomenclature', 'codenomen', new.codenomen);
			
		return null;
	end;
	$$;	

create trigger ajoutvaleurnomenclature after insert on cuddomaine.valeurnomenclature for each row execute function cuddomaine.aftercreationvaleurnomenclature();

create or replace procedure cuddomaine.modifiervaleurnomenclature(pcode public.identifiant, plib public.libelle, pdescr public.libelle)
	language plpgsql
	as $$
	declare
		vlib public.libelle;
		vdescr public.libelle;
	begin 
		
		assert(pcode is not null),'Le code de la valeur de la nomenclature est vide.';
		assert(public.existencetuple('cuddomaine', 'valeurnomenclature', 'codevalnomen', pcode)),'Le nom <'|| pcode ||'> de la valeur de la nomenclature est inconnu.';
		assert(plib is not null),'Le libelle de la nomenclature est vide.';
		
		execute format('update cuddomaine.valeurnomenclature set lib = $1, descr = $2, dateupda = current_timestamp where codevalnomen = $3')
		using plib, pdescr, pcode;
	
		execute format('select lib, descr from cuddomaine.valeurnomenclature where codevalnomen = $1')
		into vlib, vdescr
		using pcode;	
		assert(vlib = plib),'Incoherence sur les donnees inserees. lib';
		assert((vdescr is null) or (vdescr = pdescr)),'Incoherence sur les donnees inserees. descr';
		
	end;
	$$;

create or replace procedure cuddomaine.supprimervaleurnomenclature(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cuddomaine', 'valeurnomenclature', 'codevalnomen', pcode)),'Le code <'|| pcode ||'> de la valeur de la nomenclature est inconnu.';	
		
		call public.supprimer('cuddomaine', 'valeurnomenclature', 'codevalnomen', pcode);
	
		assert(not public.existencetuple('cuddomaine', 'valeurnomenclature', 'codevalnomen', pcode)),'Incoherence sur le tuple supprimé.';
		
	end;
	$$;

create or replace function cuddomaine.aftermiseajourvaleurnomenclature()
	returns trigger 
	language plpgsql
	as $$
	begin 
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srdomaine', 'valeurnomenclature', 'codevalnomen', old.codevalnomen, new.etat, new.dateupda);
		else
			call srdomaine.mettreajourvaleurnomenclature(new.codevalnomen, new.lib, new.descr, new.dateupda);
		end if;
		return null;
	end;
	$$;	

create trigger miseajourvaleurnomenclature after update on cuddomaine.valeurnomenclature for each row execute function cuddomaine.aftermiseajourvaleurnomenclature();

create or replace function cuddomaine.aftersuppressionvaleurnomenclature()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		call public.detacher('cuddomaine', 'nomenclature', 'codenomen', old.codenomen);
		return null;
	
	end;
	$$;	

create trigger suppressionvaleurnomenclature after delete on cuddomaine.valeurnomenclature for each row execute function cuddomaine.aftersuppressionvaleurnomenclature();

-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== création du schema srdomaine
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create schema srdomaine;
alter schema srdomaine owner to akamsrdbservey;

-- ======== création de la table domaine
-- ==========================================================================================================================================
create table srdomaine.domaine(
	codedom public.identifiant not null,
	nomdom public.nom not null,
	typdom public.etat not null,	
	enumdom public.enumdomaine not null,
	libdom public.libelle null,
	parent1 public.identifiant null,
	nomparent1 public.nom null,
	typparent1 public.etat null,
	libparent1 public.libelle null,
	parent1parent1 public.identifiant null,
	parent2parent1 public.identifiant null,
	parent2 public.identifiant null,
	nomparent2 public.nom null,
	typparent2 public.etat null,
	libparent2 public.libelle null,
	parent1parent2 public.identifiant null,
	parent2parent2 public.identifiant null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srdomaine.domaine add constraint pkdomaine primary key (codedom);
alter table srdomaine.domaine add constraint chkinvariantdatecreaupdadomaine check (datecrea <= dateupda);

create or replace procedure srdomaine.ajouterdomaine(pcode public.identifiant, penumdom public.enumdomaine, pnom public.nom, ptyp public.etat, plib public.libelle, pparent1 public.identifiant, pparent2 public.identifiant, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		venumdom public.enumdomaine;
		vnom public.nom;
		vtyp public.etat;
		vlib public.libelle;
		vparent1 public.identifiant;
		vnomparent1 public.nom;
		vtypparent1 public.etat;
		vlibparent1 public.libelle;
		vparent1parent1 public.identifiant;
		vparent2parent1 public.identifiant;
		vparent2 public.identifiant;
		vnomparent2 public.nom;
		vtypparent2 public.etat;
		vlibparent2 public.libelle;
		vparent1parent2 public.identifiant;
		vparent2parent2 public.identifiant;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code du domaine est vide.';
		assert(not public.existencetuple('srdomaine', 'domaine', 'codedom', pcode)),'Le code <'|| pcode ||'> du domaine est existant.';
		assert(penumdom is not null),'L''enum du domaine est vide.';
		assert(pnom is not null),'Le nom du domaine est vide.';
		assert(ptyp is not null),'Le type du domaine est vide.';
		assert(ptyp = 1 or ptyp = 2 or ptyp = 3),'Le type du domaine est incoherent.';
		if (pparent1 is not null) then
			assert(public.existencetuple('srdomaine', 'domaine', 'codedom', pparent1)),'Le code <'|| pparent1 ||'> du domaine parent1 est inconnu.';
		end if;
		if (pparent2 is not null) then
			assert(public.existencetuple('srdomaine', 'domaine', 'codedom', pparent2)),'Le code <'|| pparent2 ||'> du domaine parent1 est inconnu.';
		end if;
		assert(petat = 1),'L''etat du domaine est incoherent.';
		assert(pord > 0),'L''ordre du domaine est incoherent.';
		assert(pdatecrea is not null),'La date de création du domaine est vide.';
		
		if (pparent1 is not null) then
			execute format('select nomdom, typdom, libdom, parent1, parent2 from srdomaine.domaine where codedom = $1')
			into vnomparent1, vtypparent1, vlibparent1, vparent1parent1, vparent2parent1
			using pparent1;
		else
			vnomparent1 := null;
			vtypparent1 := null;
			vlibparent1 := null;
			vparent1parent1 := null;
			vparent2parent1 := null;
		end if;
		if (pparent2 is not null) then
			execute format('select nomdom, typdom, libdom, parent1, parent2 from srdomaine.domaine where codedom = $1')
			into vnomparent2, vtypparent2, vlibparent2, vparent1parent2, vparent2parent2
			using pparent2;
		else
			vnomparent2 := null;
			vtypparent2 := null;
			vlibparent2 := null;
			vparent1parent2 := null;
			vparent2parent2 := null;
		end if;		
		execute format('insert into srdomaine.domaine (codedom, enumdom, nomdom, typdom, libdom, parent1, nomparent1, typparent1, libparent1, parent1parent1, parent2parent1, parent2, nomparent2, typparent2, libparent2, parent1parent2, parent2parent2, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20)')
		using pcode, penumdom, pnom, ptyp, plib, pparent1, vnomparent1, vtypparent1, vlibparent1, vparent1parent1, vparent2parent1, pparent2, vnomparent2, vtypparent2, vlibparent2, vparent1parent2, vparent2parent2, petat, pord, pdatecrea;
	
		execute format('select enumdom, nomdom, typdom, libdom, parent1, parent2, etat, ord, datecrea from srdomaine.domaine where codedom = $1')
		into venumdom, vnom, vtyp, vlib, vparent1, vparent2, vetat, vord, vdatecrea
		using pcode;	
		assert(venumdom = penumdom),'Incoherence sur les donnees inserees. enumdom';
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomdom';
		assert(vtyp = ptyp),'Incoherence sur les donnees inserees. typdom';
		assert((vlib is null) or (vlib = plib)),'Incoherence sur les donnees inserees. libdom';
		assert((vparent1 is null) or (vparent1 = pparent1)),'Incoherence sur les donnees inserees. parent1';
		assert((vparent2 is null) or (vparent2 = pparent2)),'Incoherence sur les donnees inserees. parent2';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srdomaine.mettreajourdomaine(pcode public.identifiant, pnom public.nom, plib public.libelle, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vlib public.libelle;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du domaine est vide.';
		assert(public.existencetuple('srdomaine', 'domaine', 'codedom', pcode)),'Le code <'|| pcode ||'> du domaine est inconnu.';
		assert(pdateupda is not null),'La date de mise a jour du domaine est vide.';
		assert(pnom is not null),'Le nom du domaine est vide.';
		execute format('select dateupda from srdomaine.domaine where codedom = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour du domaine est incoherente.';
	
		execute format('update srdomaine.domaine set nomdom = $1, libdom = $2, dateupda = $3 where codedom = $4')
		using pnom, plib, pdateupda, pcode;
	
		execute format('select nomdom, libdom, dateupda from srdomaine.domaine where codedom = $1')
		into vnom, vlib, vdateupda
		using pcode;
		assert(vnom = pnom),'Les donnees mises a jour sont incoherentes. nomdom';
		assert((vlib is null) or (vlib = plib)),'Les donnees mises a jour sont incoherentes. libdom';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srdomaine.aftermiseajourdomaine()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		execute format('update srdomaine.domaine set nomparent1 = $1, libparent1 = $2 where parent1 = $3')
		using new.nomdom, new.libdom, old.codedom;
		execute format('update srdomaine.domaine set nomparent2 = $1, libparent2 = $2 where parent2 = $3')
		using new.nomdom, new.libdom, old.codedom;
		return null;
	
	end;
	$$;	

create trigger miseajourdomaine after update on srdomaine.domaine for each row execute function srdomaine.aftermiseajourdomaine();

create or replace function srdomaine.obtentiondomaine(pcode public.identifiant)
	returns table(codedom public.identifiant, nomdom public.nom, typdom public.etat, libdom public.libelle, parent1 public.identifiant, nomparent1 public.nom, typparent1 public.etat, libparent1 public.libelle, parent1parent1 public.identifiant, parent2parent1 public.identifiant, parent2 public.identifiant, nomparent2 public.nom, typparent2 public.etat, libparent2 public.libelle, parent1parent2 public.identifiant, parent2parent2 public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code du domaine est vide.';
		assert(public.existencetuple('srdomaine', 'domaine', 'codedom', pcode)),'Le code <'|| pcode ||'> du domaine est inconnu.';
		
		return query select d.codedom, d.nomdom, d.typdom, d.libdom, d.parent1, d.nomparent1, d.typparent1, d.libparent1, d.parent1parent1, d.parent2parent1, d.parent2, d.nomparent2, d.typparent2, d.libparent2, d.parent1parent2, d.parent2parent2 from srdomaine.domaine d where d.codedom = pcode;
	
	end;
	$$;

create or replace function srdomaine.obtentiondomainenom(pnom public.nom)
	returns table(codedom public.identifiant, nomdom public.nom, typdom public.etat, libdom public.libelle, parent1 public.identifiant, nomparent1 public.nom, typparent1 public.etat, libparent1 public.libelle, parent1parent1 public.identifiant, parent2parent1 public.identifiant, parent2 public.identifiant, nomparent2 public.nom, typparent2 public.etat, libparent2 public.libelle, parent1parent2 public.identifiant, parent2parent2 public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pnom is not null),'Le nom du domaine est vide.';
		assert(public.existencetuple('srdomaine', 'domaine', 'nomdom', pnom)),'Le nom <'|| pnom ||'> du domaine est inconnu.';
		
		return query select d.codedom, d.nomdom, d.typdom, d.libdom, d.parent1, d.nomparent1, d.typparent1, d.libparent1, d.parent1parent1, d.parent2parent1, d.parent2, d.nomparent2, d.typparent2, d.libparent2, d.parent1parent2, d.parent2parent2 from srdomaine.domaine d where d.nomdom = pnom;
	
	end;
	$$;

create or replace function srdomaine.recherchedomaine(pcritere public.libelle, pdebut numeric, plimit numeric)
	returns table(codedom public.identifiant, nomdom public.nom, typdom public.etat, libdom public.libelle, parent1 public.identifiant, nomparent1 public.nom, typparent1 public.etat, libparent1 public.libelle, parent1parent1 public.identifiant, parent2parent1 public.identifiant, parent2 public.identifiant, nomparent2 public.nom, typparent2 public.etat, libparent2 public.libelle, parent1parent2 public.identifiant, parent2parent2 public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select d.codedom, d.nomdom, d.typdom, d.libdom, d.parent1, d.nomparent1, d.typparent1, d.libparent1, d.parent1parent1, d.parent2parent1, d.parent2, d.nomparent2, d.typparent2, d.libparent2, d.parent1parent2, d.parent2parent2 from srdomaine.domaine d where d.etat <> 3 order by d.ord desc limit plimit offset pdebut;
		else
			return query select d.codedom, d.nomdom, d.typdom, d.libdom, d.parent1, d.nomparent1, d.typparent1, d.libparent1, d.parent1parent1, d.parent2parent1, d.parent2, d.nomparent2, d.typparent2, d.libparent2, d.parent1parent2, d.parent2parent2 from srdomaine.domaine d where d.etat <> 3 and (d.nomdom ilike '%'|| pcritere ||'%' or d.libdom ilike '%'|| pcritere ||'%') order by d.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== création de la table nomenclature
-- ==========================================================================================================================================
create table srdomaine.nomenclature(
	codenomen public.identifiant not null,
	enumnomen public.enumnomenclature not null,
	codedom public.identifiant not null,
	nomdom public.nom not null,
	typdom public.etat not null,	
	enumdom public.enumdomaine not null,
	libdom public.libelle null,
	parent1dom public.identifiant null,
	parent2dom public.identifiant null,
	parent1 public.identifiant null,
	codedomparent1 public.identifiant null,
	enumnomenparent1 public.enumnomenclature null,
	parent1parent1 public.identifiant null,
	parent2parent1 public.identifiant null,
	parent2 public.identifiant null,
	codedomparent2 public.identifiant null,
	enumnomenparent2 public.enumnomenclature null,
	parent1parent2 public.identifiant null,
	parent2parent2 public.identifiant null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srdomaine.nomenclature add constraint pknomenclature primary key (codenomen);
alter table srdomaine.nomenclature add constraint chkinvariantdatecreaupdanomenclature check (datecrea <= dateupda);

create or replace procedure srdomaine.ajouternomenclature(pcode public.identifiant, penumnomen public.enumnomenclature, pcodedom public.identifiant, pparent1 public.identifiant, pparent2 public.identifiant, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		venumnomen public.enumnomenclature;
		vcodedom public.identifiant;
		vnomdom public.nom;
		vtypdom public.etat;
		venumdom public.enumdomaine;
		vlibdom public.libelle;
		vparent1dom public.identifiant;
		vparent2dom public.identifiant;
		vparent1 public.identifiant;
		vcodedomparent1 public.identifiant;
		venumnomenparent1 public.enumnomenclature;
		vparent1parent1 public.identifiant;
		vparent2parent1 public.identifiant;
		vparent2 public.identifiant;
		vcodedomparent2 public.identifiant;
		venumnomenparent2 public.enumnomenclature;
		vparent1parent2 public.identifiant;
		vparent2parent2 public.identifiant;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code de la nomenclature est vide.';
		assert(not public.existencetuple('srdomaine', 'nomenclature', 'codenomen', pcode)),'Le code <'|| pcode ||'> de la nomenclature est existant.';
		assert(penumnomen is not null),'L''enum de la nomenclature est vide.';
		assert(pcodedom is not null),'Le code du domaine est vide.';
		assert(public.existencetuple('srdomaine', 'domaine', 'codedom', pcodedom)),'Le code <'|| pcodedom ||'> du domaine est inconnu.';
		if (pparent1 is not null) then
			assert(public.existencetuple('srdomaine', 'nomenclature', 'codenomen', pparent1)),'Le code <'|| pparent1 ||'> de la nomenclature parente1 est inconnu.';
		end if;
		if (pparent2 is not null) then
			assert(public.existencetuple('srdomaine', 'nomenclature', 'codenomen', pparent2)),'Le code <'|| pparent2 ||'> de la nomenclature parente2 est inconnu.';
		end if;
		assert(petat = 1),'L''etat de la nomenclature est incoherent.';
		assert(pord > 0),'L''ordre de la nomenclature est incoherent.';
		assert(pdatecrea is not null),'La date de création de la nomenclature est vide.';
		
		execute format('select nomdom, typdom, enumdom, libdom, parent1, parent2 from srdomaine.domaine where codedom = $1')
		into vnomdom, vtypdom, venumdom, vlibdom, vparent1dom, vparent2dom
		using pcodedom;
		if (pparent1 is not null) then
			execute format('select codedom, enumnomen, parent1, parent2 from srdomaine.nomenclature where codenomen = $1')
			into vcodedomparent1, venumnomenparent1, vparent1parent1, vparent2parent1
			using pparent1;
		else
			vcodedomparent1 := null;
			vparent1parent1 := null;
			vparent2parent1 := null;
		end if;
		if (pparent2 is not null) then
			execute format('select codedom, enumnomen, parent1, parent2 from srdomaine.nomenclature where codenomen = $1')
			into vcodedomparent2, venumnomenparent2, vparent1parent2, vparent2parent2
			using pparent2;
		else
			vcodedomparent2 := null;
			vparent1parent2 := null;
			vparent2parent2 := null;
		end if;		
		execute format('insert into srdomaine.nomenclature (codenomen, enumnomen, codedom, nomdom, typdom, enumdom, libdom, parent1dom, parent2dom, parent1, codedomparent1, enumnomenparent1, parent1parent1, parent2parent1, parent2, codedomparent2, enumnomenparent2, parent1parent2, parent2parent2, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22)')
		using pcode, penumnomen, pcodedom, vnomdom, vtypdom, venumdom, vlibdom, vparent1dom, vparent2dom, pparent1, vcodedomparent1, venumnomenparent1, vparent1parent1, vparent2parent1, pparent2, vcodedomparent2, venumnomenparent2, vparent1parent2, vparent2parent2, petat, pord, pdatecrea;
	
		execute format('select enumnomen, codedom, parent1, parent2, etat, ord, datecrea from srdomaine.nomenclature where codenomen = $1')
		into venumnomen, vcodedom, vparent1, vparent2, vetat, vord, vdatecrea
		using pcode;	
		assert(venumnomen = penumnomen),'Incoherence sur les donnees inserees. enumnomen';
		assert(vcodedom = pcodedom),'Incoherence sur les donnees inserees. codedom';
		assert((vparent1 is null) or (vparent1 = pparent1)),'Incoherence sur les donnees inserees. parent1';
		assert((vparent2 is null) or (vparent2 = pparent2)),'Incoherence sur les donnees inserees. parent2';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace function srdomaine.aftermiseajournomenclature()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		return null;
	
	end;
	$$;	

create trigger miseajournomenclature after update on srdomaine.nomenclature for each row execute function srdomaine.aftermiseajournomenclature();

create or replace function srdomaine.obtentionomenclature(pcode public.identifiant)
	returns table(codenomen public.identifiant, enumnomen public.enumnomenclature, codedom public.identifiant, nomdom public.nom, typdom public.etat, enumdom public.enumdomaine, libdom public.libelle, parent1dom public.identifiant, parent2dom public.identifiant, parent1 public.identifiant, codedomparent1 public.identifiant, enumnomenparent1 public.identifiant, parent1parent1 public.identifiant, parent2parent1 public.identifiant, parent2 public.identifiant, codedomparent2 public.identifiant, enumnomenparent2 public.identifiant, parent1parent2 public.identifiant, parent2parent2 public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code de la nomenclature est vide.';
		assert(public.existencetuple('srdomaine', 'nomenclature', 'codenomen', pcode)),'Le code <'|| pcode ||'> de la nomenclature est inconnu.';
		
		return query select n.codenomen, n.enumnomen, n.codedom, n.nomdom, n.typdom, n.enumdom, n.libdom, n.parent1dom, n.parent2dom, n.parent1, n.codedomparent1, n.enumnomenparent1, n.parent1parent1, n.parent2parent1, n.parent2, n.codedomparent2, n.enumnomenparent2, n.parent1parent2, n.parent2parent2 from srdomaine.nomenclature n where n.codenomen = pcode;
	
	end;
	$$;

create or replace function srdomaine.obtentionomenclaturesdomaine(pcodedom public.identifiant, pdebut numeric, plimit numeric)
	returns table(codenomen public.identifiant, enumnomen public.enumnomenclature, codedom public.identifiant, nomdom public.nom, typdom public.etat, enumdom public.enumdomaine, libdom public.libelle, parent1dom public.identifiant, parent2dom public.identifiant, parent1 public.identifiant, codedomparent1 public.identifiant, enumnomenparent1 public.identifiant, parent1parent1 public.identifiant, parent2parent1 public.identifiant, parent2 public.identifiant, codedomparent2 public.identifiant, enumnomenparent2 public.identifiant, parent1parent2 public.identifiant, parent2parent2 public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pcodedom is not null),'Le code du domaine est vide.';
		assert(public.existencetuple('srdomaine', 'domaine', 'codedom', pcodedom)),'Le code <'|| pcodedom ||'> du domaine est inconnu.';
		
		return query select n.codenomen, n.enumnomen, n.codedom, n.nomdom, n.typdom, n.enumdom, n.libdom, n.parent1dom, n.parent2dom, n.parent1, n.codedomparent1, n.enumnomenparent1, n.parent1parent1, n.parent2parent1, n.parent2, n.codedomparent2, n.enumnomenparent2, n.parent1parent2, n.parent2parent2 from srdomaine.nomenclature n where n.etat <> 3 and n.codedom = pcodedom order by n.ord desc limit plimit offset pdebut;
	
	end;
	$$;

-- ======== création de la table valeurnomenclature
-- ==========================================================================================================================================
create table srdomaine.valeurnomenclature(
	codevalnomen public.identifiant not null,
	codenomen public.identifiant not null,
	codedom public.identifiant not null,
	parent1 public.identifiant null,
	parent2 public.identifiant null,
	lang public.isolangue null,
	lib public.libelle not null,
	descr public.libelle null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srdomaine.valeurnomenclature add constraint pkvaleurnomenclature primary key (codevalnomen);
alter table srdomaine.valeurnomenclature add constraint chkinvariantdatecreaupdavaleurnomenclature check (datecrea <= dateupda);

create or replace procedure srdomaine.ajoutervaleurnomenclature(pcode public.identifiant, pcodenomen public.identifiant, plang public.isolangue, plib public.libelle, pdescr public.libelle, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vcodenomen public.identifiant;
		vcodedom public.identifiant;
		vparent1 public.identifiant;
		vparent2 public.identifiant;
		vlang public.isolangue;
		vlib public.libelle;
		vdescr public.libelle;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code de la valeur de la nomenclature est vide.';
		assert(not public.existencetuple('srdomaine', 'valeurnomenclature', 'codevalnomen', pcode)),'Le code <'|| pcode ||'> de la valeur de la nomenclature est existant.';
		assert(pcodenomen is not null),'Le code de la nomenclature est vide.';
		assert(public.existencetuple('srdomaine', 'nomenclature', 'codenomen', pcodenomen)),'Le code <'|| pcodenomen ||'> de la nomenclature est inconnu.';
		assert(plib is not null),'Le libelle de la valeur de la nomenclature est vide.';
		assert(petat = 1),'L''etat de la valeur de la nomenclature est incoherent.';
		assert(pord > 0),'L''ordre de la valeur de la nomenclature est incoherent.';
		assert(pdatecrea is not null),'La date de création de la valeur de la nomenclature est vide.';
		
		execute format('select codedom, parent1, parent2 from srdomaine.nomenclature where codenomen = $1')
		into vcodedom, vparent1, vparent2
		using pcodenomen;		
		execute format('insert into srdomaine.valeurnomenclature (codevalnomen, codenomen, codedom, parent1, parent2, lang, lib, descr, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)')
		using pcode, pcodenomen, vcodedom, vparent1, vparent2, plang, plib, pdescr, petat, pord, pdatecrea;
	
		execute format('select codenomen, lang, lib, descr, etat, ord, datecrea from srdomaine.valeurnomenclature where codevalnomen = $1')
		into vcodenomen, vlang, vlib, vdescr, vetat, vord, vdatecrea
		using pcode;	
		assert(vcodenomen = pcodenomen),'Incoherence sur les donnees inserees. codenomen';
		assert((vlang is null) or (vlang = plang)),'Incoherence sur les donnees inserees. lang';
		assert(vlib = plib),'Incoherence sur les donnees inserees. lib';
		assert((vdescr is null) or (vdescr = pdescr)),'Incoherence sur les donnees inserees. descr';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srdomaine.mettreajourvaleurnomenclature(pcode public.identifiant, plib public.libelle, pdescr public.libelle, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vlib public.libelle;
		vdescr public.libelle;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code de la valeur de la nomenclature est vide.';
		assert(public.existencetuple('srdomaine', 'valeurnomenclature', 'codevalnomen', pcode)),'Le code <'|| pcode ||'> de la valeur de la nomenclature est inconnu.';
		assert(plib is not null),'Le libelle de la valeur de la nomenclature est vide.';
		assert(pdateupda is not null),'La date de mise a jour de la valeur de la nomenclature est vide.';
		execute format('select dateupda from srdomaine.domaine where codedom = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour de la valeur de la nomenclature est incoherente.';
	
		execute format('update srdomaine.valeurnomenclature set lib = $1, descr = $2, dateupda = $3 where codevalnomen = $4')
		using plib, pdescr, pdateupda, pcode;
	
		execute format('select lib, descr, dateupda from srdomaine.valeurnomenclature where codevalnomen = $1')
		into vlib, vdescr, vdateupda
		using pcode;
		assert(vlib = plib),'Les donnees mises a jour sont incoherentes. lib';
		assert((vdescr is null) or (vdescr = pdescr)),'Les donnees mises a jour sont incoherentes. descr';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srdomaine.aftermiseajourvaleurnomenclature()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		return null;
	
	end;
	$$;	

create trigger miseajourvaleurnomenclature after update on srdomaine.valeurnomenclature for each row execute function srdomaine.aftermiseajourvaleurnomenclature();

create or replace function srdomaine.obtentionvaleurnomenclature(pcode public.identifiant)
	returns table(codevalnomen public.identifiant, codenomen public.identifiant, codedom public.identifiant, parent1 public.identifiant, parent2 public.identifiant, lang public.isolangue, lib public.libelle, descr public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code de la valeur de la nomenclature est vide.';
		assert(public.existencetuple('srdomaine', 'valeurnomenclature', 'codevalnomen', pcode)),'Le code <'|| pcode ||'> de la valeur de la nomenclature est inconnu.';
		
		return query select v.codevalnomen, v.codenomen, v.codedom, v.parent1, v.parent2, v.lang, v.lib, v.descr from srdomaine.valeurnomenclature v where v.codevalnomen = pcode;
	
	end;
	$$;

create or replace function srdomaine.obtentionvaleursnomenclature(pcodenomen public.identifiant)
	returns table(codevalnomen public.identifiant, codenomen public.identifiant, codedom public.identifiant, parent1 public.identifiant, parent2 public.identifiant, lang public.isolangue, lib public.libelle, descr public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pcodenomen is not null),'Le code de la nomenclature est vide.';
		assert(public.existencetuple('srdomaine', 'nomenclature', 'codenomen', pcodenomen)),'Le code <'|| pcodenomen ||'> de la nomenclature est inconnu.';
		
		return query select v.codevalnomen, v.codenomen, v.codedom, v.parent1, v.parent2, v.lang, v.lib, v.descr from srdomaine.valeurnomenclature v where v.etat <> 3 and v.codenomen = pcodenomen order by v.ord desc;
	
	end;
	$$;

create or replace function srdomaine.obtentionvaleursnomenclaturesdomainelangue(pcodedom public.identifiant, plang public.isolangue, pdebut int, plimit int)
	returns table(codevalnomen public.identifiant, codenomen public.identifiant, codedom public.identifiant, parent1 public.identifiant, parent2 public.identifiant, lang public.isolangue, lib public.libelle, descr public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pcodedom is not null),'Le code du domaine est vide.';
		assert(public.existencetuple('srdomaine', 'domaine', 'codedom', pcodedom)),'Le code <'|| pcodedom ||'> du domaine est inconnu.';		
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (plang is null) then
			return query select v.codevalnomen, v.codenomen, v.codedom, v.parent1, v.parent2, v.lang, v.lib, v.descr from srdomaine.valeurnomenclature v where v.etat <> 3 and v.codedom = pcodedom and v.lang is null order by v.ord desc limit plimit offset pdebut;
		else
			return query select v.codevalnomen, v.codenomen, v.codedom, v.parent1, v.parent2, v.lang, v.lib, v.descr from srdomaine.valeurnomenclature v where v.etat <> 3 and v.codedom = pcodedom and v.lang = plang order by v.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

create or replace function srdomaine.obtentionvaleursnomenclaturesnomdomainelangue(pnomdom public.nom, plang public.isolangue, pdebut int, plimit int)
	returns table(codevalnomen public.identifiant, codenomen public.identifiant, codedom public.identifiant, parent1 public.identifiant, parent2 public.identifiant, lang public.isolangue, lib public.libelle, descr public.libelle, enumnomen public.enumnomenclature )
	language plpgsql
	as $$
	declare
	begin 
		assert(pnomdom is not null),'Le nom du domaine est vide.';
		assert(public.existencetuple('srdomaine', 'domaine', 'nomdom', pnomdom)),'Le nom <'|| pnomdom ||'> du domaine est inconnu.';		
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (plang is null) then
			return query select v.codevalnomen, v.codenomen, v.codedom, v.parent1, v.parent2, v.lang, v.lib, v.descr, n.enumnomen 
							from srdomaine.valeurnomenclature v 
								inner join srdomaine.domaine d on (d.codedom = v.codedom and d.nomdom = pnomdom)
								inner join srdomaine.nomenclature n on (n.codenomen = v.codenomen) 
							where v.etat <> 3 and v.lang is null 
							order by v.ord desc 
							limit plimit offset pdebut;
		else
			return query select v.codevalnomen, v.codenomen, v.codedom, v.parent1, v.parent2, v.lang, v.lib, v.descr, n.enumnomen 
							from srdomaine.valeurnomenclature v 
								inner join srdomaine.domaine d on (d.codedom = v.codedom and d.nomdom = pnomdom)
								inner join srdomaine.nomenclature n on (n.codenomen = v.codenomen) 
							where v.etat <> 3 and v.lang = plang 
							order by v.ord desc 
							limit plimit offset pdebut;
		end if;
	
	end;
	$$;

create or replace function srdomaine.obtentionvaleursnomenclatures2nomdomainelangue(pnomdom public.nom, pcodenomen public.identifiant, plang public.isolangue, pdebut int, plimit int)
	returns table(codevalnomen public.identifiant, codenomen public.identifiant, codedom public.identifiant, parent1 public.identifiant, parent2 public.identifiant, lang public.isolangue, lib public.libelle, descr public.libelle, enumnomen public.enumnomenclature )  
	language plpgsql
	as $$
	declare
	begin 
		assert(pnomdom is not null),'Le nom du domaine est vide.';
		assert(public.existencetuple('srdomaine', 'domaine', 'nomdom', pnomdom)),'Le nom <'|| pnomdom ||'> du domaine est inconnu.';		
		assert(pcodenomen is not null),'Le code de la nomenclature est vide.';
		assert(public.existencetuple('srdomaine', 'nomenclature', 'codenomen', pcodenomen)),'Le code <'|| pcodenomen ||'> de la nomenclature est inconnu.';		
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (plang is null) then
			return query select v.codevalnomen, v.codenomen, v.codedom, v.parent1, v.parent2, v.lang, v.lib, v.descr, n.enumnomen 
							from srdomaine.valeurnomenclature v 
								inner join srdomaine.domaine d on (d.codedom = v.codedom and d.nomdom = pnomdom)
								inner join srdomaine.nomenclature n on (n.codenomen = v.codenomen) 
							where v.etat <> 3 and v.parent1 = pcodenomen and v.lang is null 
							order by v.ord desc 
							limit plimit offset pdebut;
		else
			return query select v.codevalnomen, v.codenomen, v.codedom, v.parent1, v.parent2, v.lang, v.lib, v.descr, n.enumnomen
							from srdomaine.valeurnomenclature v 
								inner join srdomaine.domaine d on (d.codedom = v.codedom and d.nomdom = pnomdom)
								inner join srdomaine.nomenclature n on (n.codenomen = v.codenomen) 
							where v.etat <> 3 and v.parent1 = pcodenomen and v.lang = plang 
							order by v.ord desc 
							limit plimit offset pdebut;
		end if;
	
	end;
	$$;

create or replace function srdomaine.obtentionvaleursnomenclatures2nomdomainelanguenum(pnomdom public.nom, penumnomen public.enumnomenclature, plang public.isolangue, pdebut int, plimit int)
	returns table(codevalnomen public.identifiant, codenomen public.identifiant, codedom public.identifiant, parent1 public.identifiant, parent2 public.identifiant, lang public.isolangue, lib public.libelle, descr public.libelle, enumnomen public.enumnomenclature )  
	language plpgsql
	as $$
	declare
	begin 
		assert(pnomdom is not null),'Le nom du domaine est vide.';
		assert(public.existencetuple('srdomaine', 'domaine', 'nomdom', pnomdom)),'Le nom <'|| pnomdom ||'> du domaine est inconnu.';		
		assert(penumnomen is not null),'Le code de la nomenclature est vide.';
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (plang is null) then
			return query select v.codevalnomen, v.codenomen, v.codedom, v.parent1, v.parent2, v.lang, v.lib, v.descr, n.enumnomen 
							from srdomaine.valeurnomenclature v 
								inner join srdomaine.domaine d on (d.codedom = v.codedom and d.nomdom = pnomdom)
								inner join srdomaine.nomenclature n on (n.codenomen = v.codenomen and n.enumnomenparent1 = penumnomen) 
							where v.etat <> 3 and v.lang is null 
							order by v.ord desc 
							limit plimit offset pdebut;
		else
			return query select v.codevalnomen, v.codenomen, v.codedom, v.parent1, v.parent2, v.lang, v.lib, v.descr, n.enumnomen
							from srdomaine.valeurnomenclature v 
								inner join srdomaine.domaine d on (d.codedom = v.codedom and d.nomdom = pnomdom)
								inner join srdomaine.nomenclature n on (n.codenomen = v.codenomen and n.enumnomenparent1 = penumnomen) 
							where v.etat <> 3 and v.lang = plang 
							order by v.ord desc 
							limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== creation du schema cudcms
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create schema cudcms;
alter schema cudcms owner to akamcuddbservey;

-- ======== creation de la table vue
-- ==========================================================================================================================================
create table cudcms.vue(
	codevue public.identifiant not null,
	nomvue public.nom not null,
	descrvue public.libelle null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudcms.vue add constraint pkvue primary key (codevue);
alter table cudcms.vue add constraint unnomvue unique (nomvue);
alter table cudcms.vue add constraint chkinvariantcardetatvue check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudcms.vue add constraint chkinvariantdatecreaupdavue check (datecrea <= dateupda);

create or replace function cudcms.creationvue(pnom public.nom, pdescr public.libelle)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vnom public.nom;
		vdescr public.libelle;
	begin 
		
		assert(pnom is not null),'Le nom de la vue est vide.';
		assert(not public.existencetuple('cudcms', 'vue', 'nomvue', pnom)),'Le nom <'|| pnom ||'> de la vue existe deja.';
		
		vcode := cudincrement.generationidentifiant('vue');
		vordmax := public.obtentionordremax('cudcms', 'vue', 'ord');
		execute format('insert into cudcms.vue (codevue, nomvue, descrvue, ord) values ($1, $2, $3, $4)')
		using vcode, pnom, pdescr, vordmax;
	
		execute format('select nomvue, descrvue from cudcms.vue where codevue = $1')
		into vnom, vdescr
		using vcode;	
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomvue';
		assert((vdescr is null) or (vdescr = pdescr)),'Incoherence sur les donnees inserees. descrvue';
		
		return vcode;
	end;
	$$;

create or replace function cudcms.aftercreationvue()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		
		call srcms.ajoutervue(new.codevue, new.nomvue, new.descrvue, new.etat, new.ord, new.datecrea);	
		return null;
	
	end;
	$$;	

create trigger ajoutvue after insert on cudcms.vue for each row execute function cudcms.aftercreationvue();

create or replace procedure cudcms.modifiervue(pcode public.identifiant, pnom public.nom, pdescr public.libelle)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vdescr public.libelle;
	begin 
		
		assert(pcode is not null),'Le code de la vue est vide.';
		assert(public.existencetuple('cudcms', 'vue', 'codevue', pcode)),'Le code <'|| pcode ||'> de la vue est inconnu.';	
		assert(pnom is not null),'Le nom de la vue est vide.';
		execute format('select nomvue from cudcms.vue where codevue = $1')
		into vnom
		using pcode;
		if (vnom != pnom) then			
			assert(not public.existencetuple('cudcms', 'vue', 'nomvue', pnom)),'Le nom <'|| pnom ||'> de la vue existe deja.';
		end if;
		
		execute format('update cudcms.vue set nomvue = $1, descrvue = $2, dateupda = current_timestamp where codevue = $3')
		using pnom, pdescr, pcode;
	
		execute format('select nomvue, descrvue from cudcms.vue where codevue = $1')
		into vnom, vdescr
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees mises a jour. nomvue';
		assert((vdescr is null) or (vdescr = pdescr)),'Incoherence sur les donnees mises a jour. descrvue';
		
	end;
	$$;

create or replace procedure cudcms.supprimervue(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudcms', 'vue', 'codevue', pcode)),'Le code <'|| pcode ||'> de la vue est inconnu.';	
		
		call public.supprimer('cudcms', 'vue', 'codevue', pcode);
	
		assert(not public.existencetuple('cudcms', 'vue', 'codevue', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudcms.aftermiseajourvue()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srcms', 'vue', 'codevue', old.codevue, new.etat, new.dateupda);
		else
			call srcms.mettreajourvue(old.codevue, new.nomvue, new.descrvue, new.dateupda);
		end if;	
		return null;
	
	end;
	$$;	

create trigger miseajourvue after update on cudcms.vue for each row execute function cudcms.aftermiseajourvue();

create or replace function cudcms.aftersuppressionvue()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		return null;
	
	end;
	$$;	

create trigger suppressionvue after delete on cudcms.vue for each row execute function cudcms.aftersuppressionvue();

-- ======== creation de la table vuespacetravail
-- ==========================================================================================================================================
create table cudcms.vuespacetravail(
	codesptrav public.identifiant not null,
	codevue public.identifiant not null,
	statut public.etat not null default 1);

alter table cudcms.vuespacetravail add constraint pkvuespacetravail primary key (codesptrav, codevue);
alter table cudcms.vuespacetravail add constraint fkvuespacetravailespacetravail foreign key (codesptrav) references cudsecurite.espacetravail(codesptrav) on delete cascade;
alter table cudcms.vuespacetravail add constraint fkvuespacetravailvue foreign key (codevue) references cudcms.vue(codevue) on delete cascade;

create or replace procedure cudcms.mettreajourvuespacetravail(pcodesptrav public.identifiant, pcodesvues public.identifiant[])
	language plpgsql
	as $$
	declare
		pcodevue public.identifiant;
		vtrouv boolean;
	begin
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide2.';
		assert(public.existencetuple('cudsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';
		foreach pcodevue in array pcodesvues
		loop
			assert(pcodevue is not null),'Le code de la vue est vide.';
			assert(public.existencetuple('cudcms', 'vue', 'codevue', pcodevue)),'Le code <'|| pcodevue ||'> de la vue est inconnu.';
		end loop;		
	
		delete from cudcms.vuespacetravail where codesptrav = pcodesptrav;
		foreach pcodevue in array pcodesvues
		loop
			insert into cudcms.vuespacetravail(codesptrav, codevue) values (pcodesptrav, pcodevue);
		end loop;
		
		foreach pcodevue in array pcodesvues
		loop
			execute format('select exists (select * from cudcms.vuespacetravail de where de.codesptrav = $1 and de.codevue = $2)')
			into vtrouv
			using pcodesptrav, pcodevue;
			assert(vtrouv),'Incoherences sur les donnees inserees.';
		end loop;
	end;
	$$;

create or replace procedure cudcms.mettreajourvuedefautvuespacetravail(pcodesptrav public.identifiant, pcodevue public.identifiant)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
	begin
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('cudsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';
		assert(pcodevue is not null),'Le code de la vue est vide.';
		assert(public.existencetuple('cudcms', 'vue', 'codevue', pcodevue)),'Le code <'|| pcodevue ||'> de la vue est inconnu.';		
	
		execute format('update cudcms.vuespacetravail set statut = 2 where codesptrav = $1 and codevue = $2')
		using pcodesptrav, pcodevue;
		execute format('update cudcms.vuespacetravail set statut = 1 where codesptrav = $1 and codevue <> $2')
		using pcodesptrav, pcodevue;
		
		execute format('select statut from cudcms.vuespacetravail where codesptrav = $1 and codevue = $2')
		into vstatut
		using pcodesptrav, pcodevue;
		assert(vstatut = 2),'Incoherence sur les donnees mise a jour. statut';
		for vstatut in select vp.statut from cudcms.vuespacetravail vp where vp.codesptrav = pcodesptrav and vp.codevue <> pcodevue
		loop
			assert(vstatut = 1),'Incoherence sur les donnees mise a jour. statut';
		end loop;
	end;
	$$;

create or replace function cudcms.aftermettreajourvuedefautvuespacetravail()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srcms.mettreajourvuedefautvuespacetravail(old.codesptrav, old.codevue, new.statut);
		return null;
	end;
	$$;	

create trigger miseajourdefautvuespacetravail after update on cudcms.vuespacetravail for each row execute function cudcms.aftermettreajourvuedefautvuespacetravail();

create or replace function cudcms.aftersupprimervuespacetravail()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srcms.retirervuespacetravail(old.codesptrav, old.codevue);
		call public.detacher('cudsecurite', 'espacetravail', 'codesptrav', old.codesptrav);
		call public.detacher('cudcms', 'vue', 'codevue', old.codevue);
		return null;
	end;
	$$;	

create trigger retraitvuespacetravail after delete on cudcms.vuespacetravail for each row execute function cudcms.aftersupprimervuespacetravail();

create or replace function cudcms.aftercreervuespacetravail()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srcms.ajoutervuespacetravail(new.codesptrav, new.codevue, new.statut);
		call public.attacher('cudsecurite', 'espacetravail', 'codesptrav', new.codesptrav);
		call public.attacher('cudcms', 'vue', 'codevue', new.codevue);
		return null;
	end;
	$$;	

create trigger ajoutvuespacetravail after insert on cudcms.vuespacetravail for each row execute function cudcms.aftercreervuespacetravail();

-- ======== creation de la table composant
-- ==========================================================================================================================================
create table cudcms.composant(
	codecompo public.identifiant not null,
	nomcompo public.nom not null,
	descrcompo public.libelle null,
	parent public.identifiant null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudcms.composant add constraint pkcomposant primary key (codecompo);
alter table cudcms.composant add constraint unnomcompo unique (nomcompo);
alter table cudcms.composant add constraint chkinvariantcardetatcomposant check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudcms.composant add constraint chkinvariantdatecreaupdacomposant check (datecrea <= dateupda);
alter table cudcms.composant add constraint fkcomposantcomposant foreign key (parent) references cudcms.composant(codecompo) on delete cascade;

create or replace function cudcms.creationcomposant(pnom public.nom, pdescr public.libelle, pparent public.identifiant)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vnom public.nom;
		vdescr public.libelle;
		vparent public.identifiant;
	begin 
		
		assert(pnom is not null),'Le nom du composant est vide.';
		assert(not public.existencetuple('cudcms', 'composant', 'nomcompo', pnom)),'Le nom <'|| pnom ||'> du composant existe deja.';
		if (pparent is not null) then
			assert(public.existencetuple('cudcms', 'composant', 'codecompo', pparent)),'Le code <'|| pparent ||'> du composant parent est inconnu.';
		end if;
		
		vcode := cudincrement.generationidentifiant('composant');
		vordmax := public.obtentionordremax('cudcms', 'composant', 'ord');
		execute format('insert into cudcms.composant (codecompo, nomcompo, descrcompo, parent, ord) values ($1, $2, $3, $4, $5)')
		using vcode, pnom, pdescr, pparent, vordmax;
	
		execute format('select nomcompo, descrcompo, parent from cudcms.composant where codecompo = $1')
		into vnom, vdescr, vparent
		using vcode;	
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomcompo';
		assert((vdescr is null) or (vdescr = pdescr)),'Incoherence sur les donnees inserees. descrcompo';
		assert((vparent is null) or (vparent = pparent)),'Incoherence sur les donnees inserees. parent';
		
		return vcode;
	end;
	$$;

create or replace function cudcms.aftercreationcomposant()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		
		call srcms.ajoutercomposant(new.codecompo, new.nomcompo, new.descrcompo, new.parent, new.etat, new.ord, new.datecrea);	
		if (new.parent is not null) then
			call public.attacher('cudcms', 'composant', 'codecompo', new.parent);
		end if;
		return null;
	
	end;
	$$;	

create trigger ajoutcomposant after insert on cudcms.composant for each row execute function cudcms.aftercreationcomposant();

create or replace procedure cudcms.modifiercomposant(pcode public.identifiant, pnom public.nom, pdescr public.libelle)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vdescr public.libelle;
	begin 
		
		assert(pcode is not null),'Le code du composant est vide.';
		assert(public.existencetuple('cudcms', 'composant', 'codecompo', pcode)),'Le code <'|| pcode ||'> du composant est inconnu.';	
		assert(pnom is not null),'Le nom du composant est vide.';
		execute format('select nomcompo from cudcms.composant where codecompo = $1')
		into vnom
		using pcode;
		if (vnom != pnom) then			
			assert(not public.existencetuple('cudcms', 'composant', 'nomcompo', pnom)),'Le nom <'|| pnom ||'> du composant existe deja.';
		end if;
		
		execute format('update cudcms.composant set nomcompo = $1, descrcompo = $2, dateupda = current_timestamp where codecompo = $3')
		using pnom, pdescr, pcode;
	
		execute format('select nomcompo, descrcompo from cudcms.composant where codecompo = $1')
		into vnom, vdescr
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees mises a jour. nomcompo';
		assert((vdescr is null) or (vdescr = pdescr)),'Incoherence sur les donnees mises a jour. descrcompo';
		
	end;
	$$;

create or replace procedure cudcms.supprimercomposant(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudcms', 'composant', 'codecompo', pcode)),'Le code <'|| pcode ||'> du composant est inconnu.';	
		
		call public.supprimer('cudcms', 'composant', 'codecompo', pcode);
	
		assert(not public.existencetuple('cudcms', 'composant', 'codecompo', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudcms.aftermiseajourcomposant()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srcms', 'composant', 'codecompo', old.codecompo, new.etat, new.dateupda);
		else
			call srcms.mettreajourcomposant(old.codecompo, new.nomcompo, new.descrcompo, new.dateupda);
		end if;	
		return null;
	
	end;
	$$;	

create trigger miseajourcomposant after update on cudcms.composant for each row execute function cudcms.aftermiseajourcomposant();

create or replace function cudcms.aftersuppressioncomposant()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		if (old.parent is not null) then
			call public.detacher('cudcms', 'composant', 'codecompo', old.parent);
		end if;
		return null;
	
	end;
	$$;	

create trigger suppressioncomposant after delete on cudcms.composant for each row execute function cudcms.aftersuppressioncomposant();

-- ======== creation de la table composantsvue
-- ==========================================================================================================================================
create table cudcms.composantsvue(
	codevue public.identifiant not null,
	codecompo public.identifiant not null);

alter table cudcms.composantsvue add constraint pkcomposantsvue primary key (codevue, codecompo);
alter table cudcms.composantsvue add constraint fkcomposantsvuevue foreign key (codevue) references cudcms.vue(codevue) on delete cascade;
alter table cudcms.composantsvue add constraint fkcomposantsvuecomposant foreign key (codecompo) references cudcms.composant(codecompo) on delete cascade;

create or replace procedure cudcms.mettreajourcomposantsvue(pcodevue public.identifiant, pcodescompos public.identifiant[])
	language plpgsql
	as $$
	declare
		pcodecompo public.identifiant;
		vtrouv boolean;
	begin
		assert(pcodevue is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('cudcms', 'vue', 'codevue', pcodevue)),'Le code <'|| pcodevue ||'> de l''espace de travail est inconnu.';
		foreach pcodecompo in array pcodescompos
		loop
			assert(pcodecompo is not null),'Le code du composant est vide.';
			assert(public.existencetuple('cudcms', 'composant', 'codecompo', pcodecompo)),'Le code <'|| pcodecompo ||'> du composant est inconnu.';
		end loop;		
	
		delete from cudcms.composantsvue where codevue = pcodevue;
		foreach pcodecompo in array pcodescompos
		loop
			insert into cudcms.composantsvue(codevue, codecompo) values (pcodevue, pcodecompo);
		end loop;
		
		foreach pcodecompo in array pcodescompos
		loop
			execute format('select exists (select * from cudcms.composantsvue de where de.codevue = $1 and de.codecompo = $2)')
			into vtrouv
			using pcodevue, pcodecompo;
			assert(vtrouv),'Incoherences sur les donnees inserees.';
		end loop;
	end;
	$$;

create or replace function cudcms.aftersupprimercomposantsvue()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srcms.retirercomposantsvue(old.codevue, old.codecompo);
		call public.detacher('cudcms', 'vue', 'codevue', old.codevue);
		call public.detacher('cudcms', 'composant', 'codecompo', old.codecompo);
		return null;
	end;
	$$;	

create trigger retraitcomposantsvue after delete on cudcms.composantsvue for each row execute function cudcms.aftersupprimercomposantsvue();

create or replace function cudcms.aftercreercomposantsvue()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srcms.ajoutercomposantsvue(new.codevue, new.codecompo);
		call public.attacher('cudcms', 'vue', 'codevue', new.codevue);
		call public.attacher('cudcms', 'composant', 'codecompo', new.codecompo);
		return null;
	end;
	$$;	

create trigger ajoutcomposantsvue after insert on cudcms.composantsvue for each row execute function cudcms.aftercreercomposantsvue();

-- ======== creation de la table contenu
-- ==========================================================================================================================================
create table cudcms.contenu(
	codeconten public.identifiant not null,
	nomconten public.nom not null,
	descrconten public.libelle null,
	codecompo public.identifiant not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudcms.contenu add constraint pkcontenu primary key (codeconten);
alter table cudcms.contenu add constraint unnomcontencodecompo unique (nomconten, codecompo);
alter table cudcms.contenu add constraint chkinvariantcardetatcontenu check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudcms.contenu add constraint chkinvariantdatecreaupdacontenu check (datecrea <= dateupda);
alter table cudcms.contenu add constraint fkcontenucomposant foreign key (codecompo) references cudcms.composant(codecompo) on delete cascade;

create or replace function cudcms.creationcontenu(pnom public.nom, pdescr public.libelle, pcodecompo public.identifiant)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vnom public.nom;
		vdescr public.libelle;
		vcodecompo public.identifiant;
		vtrouv boolean; 
	begin 
		
		assert(pnom is not null),'Le nom du contenu est vide.';
		assert(pcodecompo is not null),'Le code du composant est vide.';
		assert(public.existencetuple('cudcms', 'composant', 'codecompo', pcodecompo)),'Le code <'|| pcodecompo ||'> du composant est inconnu.';	
		execute format('select exists (select codeconten from cudcms.contenu where codecompo = $1 and nomconten = $2)')
		into vtrouv
		using pcodecompo, pnom;
		assert(not vtrouv),'Ce contenu est deja present dans ce composant.';
		
		vcode := cudincrement.generationidentifiant('contenu');
		vordmax := public.obtentionordremax('cudcms', 'contenu', 'ord');
		execute format('insert into cudcms.contenu (codeconten, nomconten, descrconten, codecompo, ord) values ($1, $2, $3, $4, $5)')
		using vcode, pnom, pdescr, pcodecompo, vordmax;
	
		execute format('select nomconten, descrconten, codecompo from cudcms.contenu where codeconten = $1')
		into vnom, vdescr, vcodecompo
		using vcode;	
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomcompo';
		assert((vdescr is null) or (vdescr = pdescr)),'Incoherence sur les donnees inserees. descrcompo';
		assert(vcodecompo = pcodecompo),'Incoherence sur les donnees inserees. codecompo';
		
		return vcode;
	end;
	$$;

create or replace function cudcms.aftercreationcontenu()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		
		call srcms.ajoutercontenu(new.codeconten, new.nomconten, new.descrconten, new.codecompo, new.etat, new.ord, new.datecrea);	
		call public.attacher('cudcms', 'composant', 'codecompo', new.codecompo);
		return null;
	
	end;
	$$;	

create trigger ajoutcontenu after insert on cudcms.contenu for each row execute function cudcms.aftercreationcontenu();

create or replace procedure cudcms.modifiercontenu(pcode public.identifiant, pnom public.nom, pdescr public.libelle)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vdescr public.libelle;
		vcodecompo public.identifiant;
		vtrouv boolean;
	begin 
		
		assert(pcode is not null),'Le code du contenu est vide.';
		assert(public.existencetuple('cudcms', 'contenu', 'codeconten', pcode)),'Le code <'|| pcode ||'> du contenu est inconnu.';	
		assert(pnom is not null),'Le nom du contenu est vide.';
		execute format('select nomconten, codecompo from cudcms.contenu where codeconten = $1')
		into vnom, vcodecompo
		using pcode;
		if (vnom != pnom) then			
			execute format('select exists (select codeconten from cudcms.contenu where codecompo = $1 and nomconten = $2)')
			into vtrouv
			using vcodecompo, pnom;
			assert(not vtrouv),'Ce contenu est deja present dans ce composant.';
		end if;
		
		execute format('update cudcms.contenu set nomconten = $1, descrconten = $2, dateupda = current_timestamp where codeconten = $3')
		using pnom, pdescr, pcode;
	
		execute format('select nomconten, descrconten from cudcms.contenu where codeconten = $1')
		into vnom, vdescr
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees mises a jour. nomconten';
		assert((vdescr is null) or (vdescr = pdescr)),'Incoherence sur les donnees mises a jour. descrconten';
		
	end;
	$$;

create or replace procedure cudcms.supprimercontenu(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudcms', 'contenu', 'codeconten', pcode)),'Le code <'|| pcode ||'> du contenu est inconnu.';	
		
		call public.supprimer('cudcms', 'contenu', 'codeconten', pcode);
	
		assert(not public.existencetuple('cudcms', 'contenu', 'codeconten', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudcms.aftermiseajourcontenu()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srcms', 'contenu', 'codeconten', old.codeconten, new.etat, new.dateupda);
		else
			call srcms.mettreajourcontenu(old.codeconten, new.nomconten, new.descrconten, new.dateupda);
		end if;	
		return null;
	
	end;
	$$;	

create trigger miseajourcontenu after update on cudcms.contenu for each row execute function cudcms.aftermiseajourcontenu();

create or replace function cudcms.aftersuppressioncontenu()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		call public.detacher('cudcms', 'composant', 'codecompo', old.codecompo);
		return null;
	
	end;
	$$;	

create trigger suppressioncontenu after delete on cudcms.contenu for each row execute function cudcms.aftersuppressioncontenu();

-- ======== creation de la table valeurcontenu
-- ==========================================================================================================================================
create table cudcms.valeurcontenu(
	codevalconten public.identifiant not null,
	lang public.isolangue not null,
	lib text not null,
	statut public.etat not null default 1,
	codeconten public.identifiant not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudcms.valeurcontenu add constraint pkvaleurcontenu primary key (codevalconten);
alter table cudcms.valeurcontenu add constraint unlangcodeconten unique (lang, codeconten);
alter table cudcms.valeurcontenu add constraint chkinvariantcardetatvaleurcontenu check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudcms.valeurcontenu add constraint chkinvariantdatecreaupdavaleurcontenu check (datecrea <= dateupda);
alter table cudcms.valeurcontenu add constraint fkvaleurcontenucontenu foreign key (codeconten) references cudcms.contenu(codeconten) on delete cascade;

create or replace function cudcms.creationvaleurcontenu(plang public.isolangue, plib text, pcodeconten public.identifiant)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vlang public.isolangue;
		vlib text;
		vcodeconten public.identifiant;
		vtrouv boolean;
	begin 
		
		assert(plang is not null),'La langue de la valeur du contenu est vide.';
		assert(plib is not null),'Le libelle de la valeur du contenu est vide.';
		assert(pcodeconten is not null),'Le code du composant est vide.';
		assert(public.existencetuple('cudcms', 'contenu', 'codeconten', pcodeconten)),'Le code <'|| pcodeconten ||'> du contenu est inconnu.';		
		execute format('select exists (select codevalconten from cudcms.valeurcontenu where lang = $1 and codeconten = $2)')
		into vtrouv
		using plang, pcodeconten;
		assert(not vtrouv),'La valeur du contenu en cette langue est deja presente.';
		
		vcode := cudincrement.generationidentifiant('valeurcontenu');
		vordmax := public.obtentionordremax('cudcms', 'valeurcontenu', 'ord');
		execute format('insert into cudcms.valeurcontenu (codevalconten, lang, lib, codeconten, ord) values ($1, $2, $3, $4, $5)')
		using vcode, plang, plib, pcodeconten, vordmax;
	
		execute format('select lang, lib, codeconten from cudcms.valeurcontenu where codevalconten = $1')
		into vlang, vlib, vcodeconten
		using vcode;	
		assert(vlang = plang),'Incoherence sur les donnees inserees. lang';
		assert(vlib = plib),'Incoherence sur les donnees inserees. lib';
		assert(vcodeconten = pcodeconten),'Incoherence sur les donnees inserees. codeconten';
		
		return vcode;
	end;
	$$;

create or replace function cudcms.aftercreationvaleurcontenu()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		
		call srcms.ajoutervaleurcontenu(new.codevalconten, new.lang, new.lib, new.statut, new.codeconten, new.etat, new.ord, new.datecrea);	
		call public.attacher('cudcms', 'contenu', 'codeconten', new.codeconten);
		return null;
	
	end;
	$$;	

create trigger ajoutvaleurcontenu after insert on cudcms.valeurcontenu for each row execute function cudcms.aftercreationvaleurcontenu();

create or replace procedure cudcms.modifiervaleurcontenu(pcode public.identifiant, plib text)
	language plpgsql
	as $$
	declare
		vlib text;
	begin 
		
		assert(pcode is not null),'Le code de la valeur du contenu est vide.';
		assert(public.existencetuple('cudcms', 'valeurcontenu', 'codevalconten', pcode)),'Le code <'|| pcode ||'> de la valeur du contenu est inconnu.';	
		assert(plib is not null),'Le libelle de la valeur du contenu est vide.';
		
		execute format('update cudcms.valeurcontenu set lib = $1, dateupda = current_timestamp where codevalconten = $2')
		using plib, pcode;
	
		execute format('select lib from cudcms.valeurcontenu where codevalconten = $1')
		into vlib
		using pcode;	
		assert(vlib = plib),'Incoherence sur les donnees mises a jour. lib';
		
	end;
	$$;

create or replace procedure cudcms.validervaleurcontenu(pcode public.identifiant)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
	begin 
		
		assert(pcode is not null),'Le code de la valeur du contenu est vide.';
		assert(public.existencetuple('cudcms', 'valeurcontenu', 'codevalconten', pcode)),'Le code <'|| pcode ||'> de la valeur du contenu est inconnu.';
		execute format('select statut from cudcms.valeurcontenu where codevalconten = $1')
		into vstatut
		using pcode;	
		assert(vstatut = 1),'Incoherence sur le statut de la valeur du contenu.';
		
		execute format('update cudcms.valeurcontenu set statut = 2, dateupda = current_timestamp where codevalconten = $1')
		using pcode;
	
		execute format('select statut from cudcms.valeurcontenu where codevalconten = $1')
		into vstatut
		using pcode;	
		assert(vstatut = 2),'Incoherence sur les donnees mises a jour. statut';
		
	end;
	$$;

create or replace procedure cudcms.publiervaleurcontenu(pcode public.identifiant)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
	begin 
		
		assert(pcode is not null),'Le code de la valeur du contenu est vide.';
		assert(public.existencetuple('cudcms', 'valeurcontenu', 'codevalconten', pcode)),'Le code <'|| pcode ||'> de la valeur du contenu est inconnu.';
		execute format('select statut from cudcms.valeurcontenu where codevalconten = $1')
		into vstatut
		using pcode;	
		assert(vstatut = 2),'Incoherence sur le statut de la valeur du contenu.';
		
		execute format('update cudcms.valeurcontenu set statut = 3, dateupda = current_timestamp where codevalconten = $1')
		using pcode;
	
		execute format('select statut from cudcms.valeurcontenu where codevalconten = $1')
		into vstatut
		using pcode;	
		assert(vstatut = 3),'Incoherence sur les donnees mises a jour. statut';
		
	end;
	$$;

create or replace procedure cudcms.archivervaleurcontenu(pcode public.identifiant)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
	begin 
		
		assert(pcode is not null),'Le code de la valeur du contenu est vide.';
		assert(public.existencetuple('cudcms', 'valeurcontenu', 'codevalconten', pcode)),'Le code <'|| pcode ||'> de la valeur du contenu est inconnu.';
		execute format('select statut from cudcms.valeurcontenu where codevalconten = $1')
		into vstatut
		using pcode;	
		assert(vstatut = 3),'Incoherence sur le statut de la valeur du contenu.';
		
		execute format('update cudcms.valeurcontenu set statut = 4, dateupda = current_timestamp where codevalconten = $1')
		using pcode;
	
		execute format('select statut from cudcms.valeurcontenu where codevalconten = $1')
		into vstatut
		using pcode;	
		assert(vstatut = 4),'Incoherence sur les donnees mises a jour. statut';
		
	end;
	$$;

create or replace procedure cudcms.supprimervaleurcontenu(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudcms', 'valeurcontenu', 'codevalconten', pcode)),'Le code <'|| pcode ||'> de la valeur du contenu est inconnu.';	
		
		call public.supprimer('cudcms', 'valeurcontenu', 'codevalconten', pcode);
	
		assert(not public.existencetuple('cudcms', 'valeurcontenu', 'codevalconten', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudcms.aftermiseajourvaleurcontenu()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srcms', 'valeurcontenu', 'codevalconten', old.codevalconten, new.etat, new.dateupda);
		else
			if (old.statut != new.statut) then
				call srcms.mettreajourstatutvaleurcontenu(old.codevalconten, new.statut, new.dateupda);
			else
				call srcms.mettreajourvaleurcontenu(old.codevalconten, new.lib, new.dateupda);
			end if;
		end if;	
		return null;
	
	end;
	$$;	

create trigger miseajourvaleurcontenu after update on cudcms.valeurcontenu for each row execute function cudcms.aftermiseajourvaleurcontenu();

create or replace function cudcms.aftersuppressionvaleurcontenu()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		call public.detacher('cudcms', 'contenu', 'codeconten', old.codeconten);
		return null;
	
	end;
	$$;	

create trigger suppressionvaleurcontenu after delete on cudcms.valeurcontenu for each row execute function cudcms.aftersuppressionvaleurcontenu();

-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== creation du schema srcms
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create schema srcms;
alter schema srcms owner to akamsrdbservey;

-- ======== creation de la table vue
-- ==========================================================================================================================================
create table srcms.vue(
	codevue public.identifiant not null,
	nomvue public.nom not null,
	descrvue public.libelle null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srcms.vue add constraint pkvue primary key (codevue);
alter table srcms.vue add constraint chkinvariantdatecreaupdavue check (datecrea <= dateupda);

create or replace procedure srcms.ajoutervue(pcode public.identifiant, pnom public.nom, pdescr public.libelle, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vdescr public.libelle;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code de la vue est vide.';
		assert(not public.existencetuple('srcms', 'vue', 'codevue', pcode)),'Le code <'|| pcode ||'> de la vue existe deja.';
		assert(pnom is not null),'Le nom de la vue est vide.';
		assert(petat = 1),'L''etat de la vue est incoherent.';
		assert(pord > 0),'L''ordre de la vue est incoherent.';
		assert(pdatecrea is not null),'La date de creation de la vue est vide.';
		
		execute format('insert into srcms.vue (codevue, nomvue, descrvue, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6)')
		using pcode, pnom, pdescr, petat, pord, pdatecrea;
	
		execute format('select nomvue, descrvue, etat, ord, datecrea from srcms.vue where codevue = $1')
		into vnom, vdescr, vetat, vord, vdatecrea
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomvue';
		assert((vdescr is null) or (vdescr = pdescr)),'Incoherence sur les donnees inserees. descrvue';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srcms.mettreajourvue(pcode public.identifiant, pnom public.nom, pdescr public.libelle, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vdescr public.libelle;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code de la vue est vide.';
		assert(public.existencetuple('srcms', 'vue', 'codevue', pcode)),'Le code <'|| pcode ||'> de la vue est inconnu.';
		assert(pdateupda is not null),'La date de mise a jour de la vue est vide.';
		assert(pnom is not null),'Le nom de la vue est vide.';
		execute format('select dateupda from srcms.vue where codevue = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour de la vue est incoherente.';
	
		execute format('update srcms.vue set nomvue = $1, descrvue = $2, dateupda = $3 where codevue = $4')
		using pnom, pdescr, pdateupda, pcode;
	
		execute format('select nomvue, descrvue, dateupda from srcms.vue where codevue = $1')
		into vnom, vdescr, vdateupda
		using pcode;
		assert(vnom = pnom),'Les donnees mises a jour sont incoherentes. nomvue';
		assert((vdescr is null) or (vdescr = pdescr)),'Les donnees mises a jour sont incoherentes. descrvue';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srcms.aftermiseajourvue()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		execute format('update srcms.vuespacetravail set nomvue = $1, descrvue = $2 where codevue = $3')
		using new.nomvue, new.descrvue, old.codevue;
		return null;
	
	end;
	$$;	

create trigger miseajourvue after update on srcms.vue for each row execute function srcms.aftermiseajourvue();

create or replace function srcms.obtentionvue(pcode public.identifiant)
	returns table(codevue public.identifiant, nomvue public.nom, descrvue public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code de la vue est vide.';
		assert(public.existencetuple('srcms', 'vue', 'codevue', pcode)),'Le code <'|| pcode ||'> de la vue est inconnu.';
		
		return query select d.codevue, d.nomvue, d.descrvue from srcms.vue d where d.codevue = pcode;
	
	end;
	$$;

create or replace function srcms.obtentionvuenom(pnom public.nom)
	returns table(codevue public.identifiant, nomvue public.nom, descrvue public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pnom is not null),'Le nom de la vue est vide.';
		assert(public.existencetuple('srcms', 'vue', 'nomvue', pnom)),'Le nom <'|| pnom ||'> de la vue est inconnu.';
		
		return query select d.codevue, d.nomvue, d.descrvue from srcms.vue d where d.nomvue = pnom;
	
	end;
	$$;

create or replace function srcms.recherchevue(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codevue public.identifiant, nomvue public.nom, descrvue public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select d.codevue, d.nomvue, d.descrvue from srcms.vue d where d.etat <> 3 order by d.ord desc limit plimit offset pdebut;
		else
			return query select d.codevue, d.nomvue, d.descrvue from srcms.vue d where d.etat <> 3 and (d.nomvue ilike '%'|| pcritere ||'%' or d.descrvue ilike '%'|| pcritere ||'%') order by d.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== creation de la table vuespacetravail
-- ==========================================================================================================================================
create table srcms.vuespacetravail(
	codesptrav public.identifiant not null,
	codevue public.identifiant not null,
	nomvue public.nom not null,
	descrvue public.libelle null,
	statut public.etat not null
	);

alter table srcms.vuespacetravail add constraint pkvuespacetravail primary key (codesptrav, codevue);

create or replace procedure srcms.ajoutervuespacetravail(pcodesptrav public.identifiant, pcodevue public.identifiant, pstatut public.etat)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
		vnomvue public.nom;
		vdescrvue public.libelle;
		vstatut public.etat;
	begin
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';
		assert(pcodevue is not null),'Le code de la vue est vide.';	
		assert(public.existencetuple('srcms', 'vue', 'codevue', pcodevue)),'Le code <'|| pcodevue ||'> de la vue est inconnu.';		
		assert(pstatut = 1),'Le statut de la vue est incoherent.';	
		execute format('select exists (select * from srcms.vuespacetravail where codesptrav = $1 and codevue = $2)')
		into vtrouv
		using pcodesptrav, pcodevue;
		assert(not vtrouv),'L''espace de travail <'|| pcodesptrav ||'> possede deja cette vue <'|| pcodevue ||'>.';
	
		execute format('select nomvue, descrvue from srcms.vue where codevue = $1;')
		into vnomvue, vdescrvue
		using pcodevue;
		execute format('insert into srcms.vuespacetravail(codesptrav, codevue, nomvue, descrvue, statut) values ($1, $2, $3, $4, $5);')
		using pcodesptrav, pcodevue, vnomvue, vdescrvue, pstatut;
	
		execute format('select exists (select * from srcms.vuespacetravail where codesptrav = $1 and codevue = $2)')
		into vtrouv
		using pcodesptrav, pcodevue;
		assert(vtrouv),'Incoherence sur les donnees inserees.';
	end;
	$$;

create or replace procedure srcms.retirervuespacetravail(pcodesptrav public.identifiant, pcodevue public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
	begin
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';
		assert(pcodevue is not null),'Le code de la vue est vide.';	
		assert(public.existencetuple('srcms', 'vue', 'codevue', pcodevue)),'Le code <'|| pcodevue ||'> de la vue est inconnu.';
		execute format('select exists (select * from srcms.vuespacetravail where codesptrav = $1 and codevue = $2)')
		into vtrouv
		using pcodesptrav, pcodevue;
		assert(vtrouv),'L''espace de travail <'|| pcodesptrav ||'> ne possede pas cette vue <'|| pcodevue ||'>.';
	
		execute format('delete from srcms.vuespacetravail where codesptrav = $1 and codevue = $2;')
		using pcodesptrav, pcodevue;
	
		execute format('select exists (select * from srcms.vuespacetravail where codesptrav = $1 and codevue = $2)')
		into vtrouv
		using pcodesptrav, pcodevue;
		assert(not vtrouv),'Incoherence sur les donnees supprimees.';
	end;
	$$;

create or replace procedure srcms.mettreajourvuedefautvuespacetravail(pcodesptrav public.identifiant, pcodevue public.identifiant, pstatut public.etat)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
	begin
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';
		assert(pcodevue is not null),'Le code de la vue est vide.';	
		assert(public.existencetuple('srcms', 'vue', 'codevue', pcodevue)),'Le code <'|| pcodevue ||'> de la vue est inconnu.';
		assert(pstatut = 1 or pstatut = 2),'Le statut de la vue est incoherent.';	
		
		execute format('update srcms.vuespacetravail set statut = $1 where codesptrav = $2 and codevue = $3;')
		using pstatut, pcodesptrav, pcodevue;
	
		execute format('select statut from srcms.vuespacetravail where codesptrav = $1 and codevue = $2')
		into vstatut
		using pcodesptrav, pcodevue;
		assert(vstatut = pstatut),'Incoherence sur les donnees mises a jour. statut';
	end;
	$$;

create or replace function srcms.obtentionvuespacetravail(pcodesptrav public.identifiant)
	returns table(codevue public.identifiant, nomvue public.nom, descrvue public.libelle, statut public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodesptrav is not null),'Le code de l''espace de travail est vide.';
		assert(public.existencetuple('srsecurite', 'espacetravail', 'codesptrav', pcodesptrav)),'Le code <'|| pcodesptrav ||'> de l''espace de travail est inconnu.';
		
		return query select de.codevue, de.nomvue, de.descrvue, de.statut from srcms.vuespacetravail de where de.codesptrav = pcodesptrav;
	
	end;
	$$;

-- ======== creation de la table composant
-- ==========================================================================================================================================
create table srcms.composant(
	codecompo public.identifiant not null,
	nomcompo public.nom not null,
	descrcompo public.libelle null,
	parent public.identifiant null,
	nomparent public.nom null,
	descrparent public.libelle null,
	parentparent public.identifiant null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srcms.composant add constraint pkcomposant primary key (codecompo);
alter table srcms.composant add constraint chkinvariantdatecreaupdacomposant check (datecrea <= dateupda);

create or replace procedure srcms.ajoutercomposant(pcode public.identifiant, pnom public.nom, pdescr public.libelle, pparent public.identifiant, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vdescr public.libelle;
		vparent public.identifiant;
		vnomparent public.nom;
		vdescrparent public.libelle;
		vparentparent public.identifiant;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code du composant est vide.';
		assert(not public.existencetuple('srcms', 'composant', 'codecompo', pcode)),'Le code <'|| pcode ||'> du composant existe deja.';
		assert(pnom is not null),'Le nom du composant est vide.';		
		if (pparent is not null) then
			assert(public.existencetuple('srcms', 'composant', 'codecompo', pparent)),'Le code <'|| pparent ||'> du composant parent est inconnu.';
		end if;
		assert(petat = 1),'L''etat du composant est incoherent.';
		assert(pord > 0),'L''ordre du composant est incoherent.';
		assert(pdatecrea is not null),'La date de creation du composant est vide.';
		
		execute format('select nomcompo, descrcompo, parent from srcms.composant where codecompo = $1')
		into vnomparent, vdescrparent, vparentparent
		using pparent;
		execute format('insert into srcms.composant (codecompo, nomcompo, descrcompo, parent, nomparent, descrparent, parentparent, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)')
		using pcode, pnom, pdescr, pparent, vnomparent, vdescrparent, vparentparent, petat, pord, pdatecrea;
	
		execute format('select nomcompo, descrcompo, parent, etat, ord, datecrea from srcms.composant where codecompo = $1')
		into vnom, vdescr, vparent, vetat, vord, vdatecrea
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomcompo';
		assert((vdescr is null) or (vdescr = pdescr)),'Incoherence sur les donnees inserees. descrcompo';
		assert((vparent is null) or (vparent = pparent)),'Incoherence sur les donnees inserees. parent';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srcms.mettreajourcomposant(pcode public.identifiant, pnom public.nom, pdescr public.libelle, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vdescr public.libelle;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du composant est vide.';
		assert(public.existencetuple('srcms', 'composant', 'codecompo', pcode)),'Le code <'|| pcode ||'> du composant est inconnu.';
		assert(pdateupda is not null),'La date de mise a jour du composant est vide.';
		assert(pnom is not null),'Le nom du composant est vide.';
		execute format('select dateupda from srcms.composant where codecompo = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour du composant est incoherente.';
	
		execute format('update srcms.composant set nomcompo = $1, descrcompo = $2, dateupda = $3 where codecompo = $4')
		using pnom, pdescr, pdateupda, pcode;
	
		execute format('select nomcompo, descrcompo, dateupda from srcms.composant where codecompo = $1')
		into vnom, vdescr, vdateupda
		using pcode;
		assert(vnom = pnom),'Les donnees mises a jour sont incoherentes. nomcompo';
		assert((vdescr is null) or (vdescr = pdescr)),'Les donnees mises a jour sont incoherentes. descrcompo';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srcms.aftermiseajourcomposant()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		execute format('update srcms.composant set nomparent = $1, descrparent = $2 where parent = $3')
		using new.nomcompo, new.descrcompo, old.codecompo;		
		execute format('update srcms.composantsvue set nomcompo = $1, descrcompo = $2 where codecompo = $3')
		using new.nomcompo, new.descrcompo, old.codecompo;	
		execute format('update srcms.contenu set nomcompo = $1, descrcompo = $2 where codecompo = $3')
		using new.nomcompo, new.descrcompo, old.codecompo;
		return null;
	
	end;
	$$;	

create trigger miseajourcomposant after update on srcms.composant for each row execute function srcms.aftermiseajourcomposant();

create or replace function srcms.obtentioncomposant(pcode public.identifiant)
	returns table(codecompo public.identifiant, nomcompo public.nom, descrcompo public.libelle, parent public.identifiant, nomparent public.nom, descrparent public.libelle, parentparent public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code du composant est vide.';
		assert(public.existencetuple('srcms', 'composant', 'codecompo', pcode)),'Le code <'|| pcode ||'> du composant est inconnu.';
		
		return query select c.codecompo, c.nomcompo, c.descrcompo, c.parent, c.nomparent, c.descrparent, c.parentparent from srcms.composant c where c.codecompo = pcode;
	
	end;
	$$;

create or replace function srcms.obtentioncomposantnom(pnom public.nom)
	returns table(codecompo public.identifiant, nomcompo public.nom, descrcompo public.libelle, parent public.identifiant, nomparent public.nom, descrparent public.libelle, parentparent public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pnom is not null),'Le nom du composant est vide.';
		assert(public.existencetuple('srcms', 'composant', 'nomcompo', pnom)),'Le nom <'|| pnom ||'> du composant est inconnu.';
		
		return query select c.codecompo, c.nomcompo, c.descrcompo, c.parent, c.nomparent, c.descrparent, c.parentparent from srcms.composant c where c.nomvue = pnom;
	
	end;
	$$;

create or replace function srcms.obtentioncomposantsenfants(pparent public.identifiant)
	returns table(codecompo public.identifiant, nomcompo public.nom, descrcompo public.libelle, parent public.identifiant, nomparent public.nom, descrparent public.libelle, parentparent public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pparent is not null),'Le code du composant est vide.';
		assert(public.existencetuple('srcms', 'composant', 'codecompo', pparent)),'Le code <'|| pparent ||'> du composant est inconnu.';
		
		return query select c.codecompo, c.nomcompo, c.descrcompo, c.parent, c.nomparent, c.descrparent, c.parentparent from srcms.composant c where c.parent = pparent and c.etat <> 3;
	
	end;
	$$;

create or replace function srcms.recherchecomposant(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codecompo public.identifiant, nomcompo public.nom, descrcompo public.libelle, parent public.identifiant, nomparent public.nom, descrparent public.libelle, parentparent public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select c.codecompo, c.nomcompo, c.descrcompo, c.parent, c.nomparent, c.descrparent, c.parentparent from srcms.composant c where c.etat <> 3 order by c.ord desc limit plimit offset pdebut;
		else
			return query select c.codecompo, c.nomcompo, c.descrcompo, c.parent, c.nomparent, c.descrparent, c.parentparent from srcms.composant c where c.etat <> 3 and (c.nomcompo ilike '%'|| pcritere ||'%' or c.descrcompo ilike '%'|| pcritere ||'%') order by c.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== creation de la table composantsvue
-- ==========================================================================================================================================
create table srcms.composantsvue(
	codevue public.identifiant not null,
	codecompo public.identifiant not null,
	nomcompo public.nom not null,
	descrcompo public.libelle null,
	parentcompo public.identifiant null
	);

alter table srcms.composantsvue add constraint pkcomposantsvue primary key (codevue, codecompo);

create or replace procedure srcms.ajoutercomposantsvue(pcodevue public.identifiant, pcodecompo public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
		vnomcompo public.nom;
		vdescrcompo public.libelle;
		vparentcompo public.identifiant;
	begin
		assert(pcodevue is not null),'Le code de la vue est vide.';
		assert(public.existencetuple('srcms', 'vue', 'codevue', pcodevue)),'Le code <'|| pcodevue ||'> de la vue est inconnu.';
		assert(pcodecompo is not null),'Le code du composant est vide.';	
		assert(public.existencetuple('srcms', 'composant', 'codecompo', pcodecompo)),'Le code <'|| pcodecompo ||'> du composant est inconnu.';
		execute format('select exists (select * from srcms.composantsvue where codevue = $1 and codecompo = $2)')
		into vtrouv
		using pcodevue, pcodecompo;
		assert(not vtrouv),'La vue <'|| pcodevue ||'> possede deja ce composant <'|| pcodecompo ||'>.';
	
		execute format('select nomcompo, descrcompo, parent from srcms.composant where codecompo = $1;')
		into vnomcompo, vdescrcompo, vparentcompo
		using pcodecompo;
		execute format('insert into srcms.composantsvue(codevue, codecompo, nomcompo, descrcompo, parentcompo) values ($1, $2, $3, $4, $5);')
		using pcodevue, pcodecompo, vnomcompo, vdescrcompo, vparentcompo;
	
		execute format('select exists (select * from srcms.composantsvue where codevue = $1 and codecompo = $2)')
		into vtrouv
		using pcodevue, pcodecompo;
		assert(vtrouv),'Incoherence sur les donnees inserees.';
	end;
	$$;

create or replace procedure srcms.retirercomposantsvue(pcodevue public.identifiant, pcodecompo public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
	begin
		assert(pcodevue is not null),'Le code de la vue est vide.';
		assert(public.existencetuple('srcms', 'vue', 'codevue', pcodevue)),'Le code <'|| pcodevue ||'> de la vue est inconnu.';
		assert(pcodecompo is not null),'Le code du composant est vide.';	
		assert(public.existencetuple('srcms', 'composant', 'codecompo', pcodecompo)),'Le code <'|| pcodecompo ||'> du composant est inconnu.';
		execute format('select exists (select * from srcms.composantsvue where codevue = $1 and codecompo = $2)')
		into vtrouv
		using pcodevue, pcodecompo;
		assert(vtrouv),'La vue <'|| pcodevue ||'> ne possede pas ce composant <'|| pcodecompo ||'>.';
	
		execute format('delete from srcms.composantsvue where codevue = $1 and codecompo = $2;')
		using pcodevue, pcodecompo;
	
		execute format('select exists (select * from srcms.composantsvue where codevue = $1 and codecompo = $2)')
		into vtrouv
		using pcodevue, pcodecompo;
		assert(not vtrouv),'Incoherence sur les donnees supprimees.';
	end;
	$$;

create or replace function srcms.obtentioncomposantsvue(pcodevue public.identifiant)
	returns table(codecompo public.identifiant, nomcompo public.nom, descrcompo public.libelle, parentcompo public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodevue is not null),'Le code de la vue est vide.';
		assert(public.existencetuple('srcms', 'vue', 'codevue', pcodevue)),'Le code <'|| pcodevue ||'> de la vue est inconnu.';
		
		return query select cv.codecompo, cv.nomcompo, cv.descrcompo, cv.parentcompo from srcms.composantsvue cv where cv.codevue = pcodevue;
	
	end;
	$$;

-- ======== creation de la table contenu
-- ==========================================================================================================================================
create table srcms.contenu(
	codeconten public.identifiant not null,
	nomconten public.nom not null,
	descrconten public.libelle null,
	codecompo public.identifiant not null,
	nomcompo public.nom not null,
	descrcompo public.libelle null,
	parentcompo public.identifiant null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srcms.contenu add constraint pkcontenu primary key (codeconten);
alter table srcms.contenu add constraint chkinvariantdatecreaupdacontenu check (datecrea <= dateupda);

create or replace procedure srcms.ajoutercontenu(pcode public.identifiant, pnom public.nom, pdescr public.libelle, pcodecompo public.identifiant, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vdescr public.libelle;
		vcodecompo public.identifiant;
		vnomcompo public.nom;
		vdescrcompo public.libelle;
		vparentcompo public.identifiant;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code du contenu est vide.';
		assert(not public.existencetuple('srcms', 'contenu', 'codeconten', pcode)),'Le code <'|| pcode ||'> du contenu existe deja.';
		assert(pnom is not null),'Le nom du contenu est vide.';		
		assert(pcodecompo is not null),'Le code du composant parent est vide.';
		assert(public.existencetuple('srcms', 'composant', 'codecompo', pcodecompo)),'Le code <'|| pcodecompo ||'> du composant parent est inconnu.';
		assert(petat = 1),'L''etat du contenu est incoherent.';
		assert(pord > 0),'L''ordre du contenu est incoherent.';
		assert(pdatecrea is not null),'La date de creation du contenu est vide.';
		
		execute format('select nomcompo, descrcompo, parent from srcms.composant where codecompo = $1')
		into vnomcompo, vdescrcompo, vparentcompo
		using pcodecompo;
		execute format('insert into srcms.contenu (codeconten, nomconten, descrconten, codecompo, nomcompo, descrcompo, parentcompo, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)')
		using pcode, pnom, pdescr, pcodecompo, vnomcompo, vdescrcompo, vparentcompo, petat, pord, pdatecrea;
	
		execute format('select nomconten, descrconten, codecompo, etat, ord, datecrea from srcms.contenu where codeconten = $1')
		into vnom, vdescr, vcodecompo, vetat, vord, vdatecrea
		using pcode;	
		assert(vnom = pnom),'Incoherence sur les donnees inserees. nomconten';
		assert((vdescr is null) or (vdescr = pdescr)),'Incoherence sur les donnees inserees. descrconten';
		assert(vcodecompo = pcodecompo),'Incoherence sur les donnees inserees. codecompo';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srcms.mettreajourcontenu(pcode public.identifiant, pnom public.nom, pdescr public.libelle, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vnom public.nom;
		vdescr public.libelle;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du contenu est vide.';
		assert(public.existencetuple('srcms', 'contenu', 'codeconten', pcode)),'Le code <'|| pcode ||'> du contenu est inconnu.';
		assert(pdateupda is not null),'La date de mise a jour du contenu est vide.';
		assert(pnom is not null),'Le nom du contenu est vide.';
		execute format('select dateupda from srcms.contenu where codecompo = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour du contenu est incoherente.';
	
		execute format('update srcms.contenu set nomconten = $1, descrconten = $2, dateupda = $3 where codeconten = $4')
		using pnom, pdescr, pdateupda, pcode;
	
		execute format('select nomconten, descrconten, dateupda from srcms.contenu where codeconten = $1')
		into vnom, vdescr, vdateupda
		using pcode;
		assert(vnom = pnom),'Les donnees mises a jour sont incoherentes. nomconten';
		assert((vdescr is null) or (vdescr = pdescr)),'Les donnees mises a jour sont incoherentes. descrconten';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srcms.aftermiseajourcontenu()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		execute format('update srcms.valeurcontenu set nomconten = $1, descrconten = $2 where codeconten = $3')
		using new.nomconten, new.descrconten, old.codeconten;
		return null;
	
	end;
	$$;	

create trigger miseajourcontenu after update on srcms.contenu for each row execute function srcms.aftermiseajourcontenu();

create or replace function srcms.obtentioncontenu(pcode public.identifiant)
	returns table(codeconten public.identifiant, nomconten public.nom, descrconten public.libelle, codecompo public.identifiant, nomcompo public.nom, descrcompo public.libelle, parentcompo public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code du contenu est vide.';
		assert(public.existencetuple('srcms', 'contenu', 'codeconten', pcode)),'Le code <'|| pcode ||'> du contenu est inconnu.';
		
		return query select c.codeconten, c.nomconten, c.descrconten, c.codecompo, c.nomcompo, c.descrcompo, c.parentcompo from srcms.contenu c where c.codeconten = pcode;
	
	end;
	$$;

create or replace function srcms.obtentioncontenunom(pnom public.nom)
	returns table(codeconten public.identifiant, nomconten public.nom, descrconten public.libelle, codecompo public.identifiant, nomcompo public.nom, descrcompo public.libelle, parentcompo public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pnom is not null),'Le nom du contenu est vide.';
		assert(public.existencetuple('srcms', 'contenu', 'nomconten', pnom)),'Le nom <'|| pnom ||'> du contenu est inconnu.';
		
		return query select c.codeconten, c.nomconten, c.descrconten, c.codecompo, c.nomcompo, c.descrcompo, c.parentcompo from srcms.contenu c where c.nomconten = pnom;
	
	end;
	$$;

create or replace function srcms.obtentioncontenuscomposant(pcodecompo public.identifiant)
	returns table(codeconten public.identifiant, nomconten public.nom, descrconten public.libelle, codecompo public.identifiant, nomcompo public.nom, descrcompo public.libelle, parentcompo public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodecompo is not null),'Le code du composant est vide.';
		assert(public.existencetuple('srcms', 'composant', 'codecompo', pcodecompo)),'Le code <'|| pcodecompo ||'> du composant est inconnu.';
		
		return query select c.codeconten, c.nomconten, c.descrconten, c.codecompo, c.nomcompo, c.descrcompo, c.parentcompo from srcms.contenu c where c.codecompo = pcodecompo and  c.etat <> 3;
	
	end;
	$$;

create or replace function srcms.recherchecontenu(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codeconten public.identifiant, nomconten public.nom, descrconten public.libelle, codecompo public.identifiant, nomcompo public.nom, descrcompo public.libelle, parentcompo public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select c.codeconten, c.nomconten, c.descrconten, c.codecompo, c.nomcompo, c.descrcompo, c.parentcompo from srcms.contenu c where c.etat <> 3 order by c.ord desc limit plimit offset pdebut;
		else
			return query select c.codeconten, c.nomconten, c.descrconten, c.codecompo, c.nomcompo, c.descrcompo, c.parentcompo from srcms.contenu c where c.etat <> 3 and (c.nomconten ilike '%'|| pcritere ||'%' or c.descrconten ilike '%'|| pcritere ||'%') order by c.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== creation de la table valeurcontenu
-- ==========================================================================================================================================
create table srcms.valeurcontenu(
	codevalconten public.identifiant not null,
	lang public.isolangue not null,
	lib text not null,
	statut public.etat not null,
	codeconten public.identifiant not null,
	nomconten public.nom not null,
	descrconten public.libelle null,
	codecompo public.identifiant not null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srcms.valeurcontenu add constraint pkvaleurcontenu primary key (codevalconten);
alter table srcms.valeurcontenu add constraint chkinvariantdatecreaupdavaleurcontenu check (datecrea <= dateupda);

create or replace procedure srcms.ajoutervaleurcontenu(pcode public.identifiant, plang public.isolangue, plib text, pstatut public.etat, pcodeconten public.identifiant, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vlang public.isolangue;
		vlib text;
		vstatut public.etat;
		vcodeconten public.identifiant;
		vnomconten public.nom;
		vdescrconten public.libelle;
		vcodecompo public.identifiant;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code de la valeur du contenu est vide.';
		assert(not public.existencetuple('srcms', 'valeurcontenu', 'codevalconten', pcode)),'Le code <'|| pcode ||'> de la valeur du contenu existe deja.';
		assert(plang is not null),'La langue de la valeur du contenu est vide.';
		assert(plib is not null),'Le libelle de la valeur du contenu est vide.';
		assert(pstatut = 1),'Le statut de la valeur du contenu est incoherent.';
		assert(pcodeconten is not null),'Le code du contenu est vide.';
		assert(public.existencetuple('srcms', 'contenu', 'codeconten', pcodeconten)),'Le code <'|| pcodeconten ||'> du contenu est inconnu.';
		assert(petat = 1),'L''etat de la valeur du contenu est incoherent.';
		assert(pord > 0),'L''ordre de la valeur du contenu est incoherent.';
		assert(pdatecrea is not null),'La date de creation de la valeur du contenu est vide.';
		
		execute format('select nomconten, descrconten, codecompo from srcms.contenu where codeconten = $1')
		into vnomconten, vdescrconten, vcodecompo
		using pcodeconten;
		execute format('insert into srcms.valeurcontenu (codevalconten, lang, lib, statut, codeconten, nomconten, descrconten, codecompo, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)')
		using pcode, plang, plib, pstatut, pcodeconten, vnomconten, vdescrconten, vcodecompo, petat, pord, pdatecrea;
	
		execute format('select lang, lib, statut, codeconten, etat, ord, datecrea from srcms.valeurcontenu where codevalconten = $1')
		into vlang, vlib, vstatut, vcodeconten, vetat, vord, vdatecrea
		using pcode;	
		assert(vlang = plang),'Incoherence sur les donnees inserees. lang';
		assert(vlib = plib),'Incoherence sur les donnees inserees. lib';
		assert(vstatut = pstatut),'Incoherence sur les donnees inserees. statut';
		assert(vcodeconten = pcodeconten),'Incoherence sur les donnees inserees. codeconten';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srcms.mettreajourvaleurcontenu(pcode public.identifiant, plib text, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vlib text;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code de la valeur du contenu est vide.';
		assert(public.existencetuple('srcms', 'valeurcontenu', 'codevalconten', pcode)),'Le code <'|| pcode ||'> de la valeur du contenu est inconnu.';
		assert(plib is not null),'Le libelle de la valeur du contenu est vide.';
		assert(pdateupda is not null),'La date de mise a jour de la valeur du contenu est vide.';
		execute format('select dateupda from srcms.contenu where codecompo = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour de la valeur du contenu est incoherente.';
	
		execute format('update srcms.valeurcontenu set lib = $1, dateupda = $2 where codevalconten = $3')
		using plib, pdateupda, pcode;
	
		execute format('select lib, dateupda from srcms.valeurcontenu where codevalconten = $1')
		into vlib, vdateupda
		using pcode;
		assert(vlib = plib),'Les donnees mises a jour sont incoherentes. lib';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace procedure srcms.mettreajourstatutvaleurcontenu(pcode public.identifiant, pstatut public.etat, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code de la valeur du contenu est vide.';
		assert(public.existencetuple('srcms', 'valeurcontenu', 'codevalconten', pcode)),'Le code <'|| pcode ||'> de la valeur du contenu est inconnu.';
		assert(pstatut = 2 or pstatut = 3 or pstatut = 4),'Le statut de la valeur du contenu est incoherent.';
		assert(pdateupda is not null),'La date de mise a jour de la valeur du contenu est vide.';
		execute format('select dateupda from srcms.contenu where codecompo = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour de la valeur du contenu est incoherente.';
	
		execute format('update srcms.valeurcontenu set statut = $1, dateupda = $2 where codevalconten = $3')
		using pstatut, pdateupda, pcode;
	
		execute format('select statut, dateupda from srcms.valeurcontenu where codevalconten = $1')
		into vstatut, vdateupda
		using pcode;
		assert(vstatut = pstatut),'Les donnees mises a jour sont incoherentes. statut';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srcms.aftermiseajourvaleurcontenu()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		return null;
	
	end;
	$$;	

create trigger miseajourvaleurcontenu after update on srcms.valeurcontenu for each row execute function srcms.aftermiseajourvaleurcontenu();

create or replace function srcms.obtentionvaleurcontenu(pcode public.identifiant)
	returns table(codevalconten public.identifiant, lang public.isolangue, lib text, statut public.etat, codeconten public.identifiant, nomconten public.nom, descrconten public.libelle, codecompo public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code de la valeur du contenu est vide.';
		assert(public.existencetuple('srcms', 'valeurcontenu', 'codevalconten', pcode)),'Le code <'|| pcode ||'> de la valeur du contenu est inconnu.';
		
		return query select vc.codevalconten, vc.lang, vc.lib, vc.statut, vc.codeconten, vc.nomconten, vc.descrconten, vc.codecompo from srcms.valeurcontenu vc where vc.codevalconten = pcode;
	
	end;
	$$;

create or replace function srcms.obtentionvaleurscontenu(pcodeconten public.identifiant)
	returns table(codevalconten public.identifiant, lang public.isolangue, lib text, statut public.etat, codeconten public.identifiant, nomconten public.nom, descrconten public.libelle, codecompo public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodecompo is not null),'Le code du contenu est vide.';
		assert(public.existencetuple('srcms', 'contenu', 'codeconten', pcodeconten)),'Le code <'|| pcodeconten ||'> du contenu est inconnu.';
		
		return query select vc.codevalconten, vc.lang, vc.lib, vc.statut, vc.codeconten, vc.nomconten, vc.descrconten, vc.codecompo from srcms.valeurcontenu vc where vc.codeconten = pcodeconten and  vc.etat <> 3;
	
	end;
	$$;

create or replace function srcms.obtentionvaleurscontenuscomposantlangue(pcodecompo public.identifiant, plang public.isolangue)
	returns table(codevalconten public.identifiant, lang public.isolangue, lib text, statut public.etat, codeconten public.identifiant, nomconten public.nom, descrconten public.libelle, codecompo public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodecompo is not null),'Le code du composant est vide.';
		assert(public.existencetuple('srcms', 'composant', 'codecompo', pcodecompo)),'Le code <'|| pcodecompo ||'> du composant est inconnu.';
		assert(plang is not null),'La langue de la valeur du contenu est vide.';
		
		return query select vc.codevalconten, vc.lang, vc.lib, vc.statut, vc.codeconten, vc.nomconten, vc.descrconten, vc.codecompo from srcms.valeurcontenu vc where vc.codecompo = pcodecompo and vc.lang = plang and  vc.etat <> 3;
	
	end;
	$$;

create or replace function srcms.recherchevaleurcontenu(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codevalconten public.identifiant, lang public.isolangue, lib text, statut public.etat, codeconten public.identifiant, nomconten public.nom, descrconten public.libelle, codecompo public.identifiant)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select vc.codevalconten, vc.lang, vc.lib, vc.statut, vc.codeconten, vc.nomconten, vc.descrconten, vc.codecompo from srcms.valeurcontenu vc where vc.etat <> 3 order by vc.ord desc limit plimit offset pdebut;
		else
			return query select vc.codevalconten, vc.lang, vc.lib, vc.statut, vc.codeconten, vc.nomconten, vc.descrconten, vc.codecompo from srcms.valeurcontenu vc where vc.etat <> 3 and (vc.lib ilike '%'|| pcritere ||'%') order by vc.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;
	
-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== Creation du schema cudutilisateur
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create schema cudutilisateur;
alter schema cudutilisateur owner to akamcuddbservey;

-- ======== Creation de la table enregistrement
-- ==========================================================================================================================================
create table cudutilisateur.enregistrement(
	codenreg public.identifiant not null,
	otpenreg public.nom not null,
	statutenreg public.etat not null default 1,
	datexpirenreg timestamp null,
	nomsenreg public.libelle not null,
	prenomsenreg public.libelle null,
	numtelenreg public.numtel not null,
	emailenreg public.email not null,
	mdpenreg public.nom not null,
	pinenreg public.codepin not null,
	typeutilis public.typeutilisateur not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudutilisateur.enregistrement add constraint pkenregistrement primary key (codenreg);
alter table cudutilisateur.enregistrement add constraint chkinvariantcardetatenregistrement check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudutilisateur.enregistrement add constraint chkinvariantdatecreaupdaenregistrement check (datecrea <= dateupda);

create or replace function cudutilisateur.creationenregistrement(ptype public.typeutilisateur, pnoms public.libelle, pprenoms public.libelle, pnumtel public.numtel, pemail public.email, pmdp public.nom, ppin public.codepin)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		votp public.nom;
		vdatexpir timestamp;
		vnoms public.libelle;
		vprenoms public.libelle;
		vnumtel public.numtel;
		vemail public.email;
		vmdp public.nom;
		vpin public.codepin;
		vtype public.typeutilisateur;
	begin 
		
		assert(ptype is not null),'Le type utilisateur est vide.';
		assert(pnoms is not null),'Les noms est vide.';
		assert(pnumtel is not null),'Le numero de telephone est vide.';
		assert(pemail is not null),'L''email est vide.';
		assert(pmdp is not null),'Le mot de passe est vide.';
		assert(ppin is not null),'Le pin est vide.';
		
		vcode := cudincrement.generationidentifiant('enregistrement');
		vordmax := public.obtentionordremax('cudutilisateur', 'enregistrement', 'ord');
		votp = (floor(random()*(899999)+100000))::VARCHAR(6);
		vdatexpir = current_timestamp + interval '1 hours';
		execute format('insert into cudutilisateur.enregistrement (codenreg, otpenreg, datexpirenreg, nomsenreg, prenomsenreg, numtelenreg, emailenreg, mdpenreg, pinenreg, typeutilis, ord) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)')
		using vcode, votp, vdatexpir, pnoms, pprenoms, pnumtel, pemail, pmdp, ppin, ptype, vordmax;
	
		execute format('select nomsenreg, prenomsenreg, numtelenreg, emailenreg, mdpenreg, pinenreg, typeutilis from cudutilisateur.enregistrement where codenreg = $1')
		into vnoms, vprenoms, vnumtel, vemail, vmdp, vpin, vtype
		using vcode;	
		assert(vnoms = pnoms),'Incoherence sur les donnees inserees. nomsenreg';
		assert((vprenoms = pprenoms or vprenoms is null)),'Incoherence sur les donnees inserees. prenomsenreg';
		assert(vnumtel = pnumtel),'Incoherence sur les donnees inserees. numtelenreg';
		assert(vemail = pemail),'Incoherence sur les donnees inserees. emailenreg';
		assert(vmdp = pmdp),'Incoherence sur les donnees inserees. mdpenreg';
		assert(vpin = ppin),'Incoherence sur les donnees inserees. pinenreg';
		assert(vtype = ptype),'Incoherence sur les donnees inserees. typeutilis';
		
		return vcode;
	end;
	$$;

create or replace function cudutilisateur.aftercreationenregistrement()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srutilisateur.ajouterenregistrement(new.codenreg, new.otpenreg, new.statutenreg, new.datexpirenreg, new.nomsenreg, new.prenomsenreg, new.numtelenreg, new.emailenreg, new.mdpenreg, new.pinenreg, new.typeutilis, new.etat, new.ord, new.datecrea);
		return null;
	end;
	$$;	

create trigger ajoutenregistrement after insert on cudutilisateur.enregistrement for each row execute function cudutilisateur.aftercreationenregistrement();

create or replace procedure cudutilisateur.validerenregistrement(pcode public.identifiant, potp public.nom)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
		vdatexpir timestamp;
		votp public.nom;
		vnoms public.libelle;
		vprenoms public.libelle;
		vnumtel public.numtel;
		vemail public.email;
		vmdp public.nom;
		vpin public.codepin;
		vtype public.typeutilisateur;
		vcodecompte public.identifiant;
		vcodeutilis public.identifiant;
		vcoderesposerv public.identifiant;
		vcoderespo public.identifiant;
		vcodeadmin public.identifiant;
		vcodexploit public.identifiant;
		vcodeprofils public.identifiant array[1];
		vcodewallet public.identifiant;
		vcode public.identifiant;
	begin 
		
		assert(pcode is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('cudutilisateur', 'enregistrement', 'codenreg', pcode)),'Le code <'|| pcode ||'> de l''enregistrement est inconnu.';
		assert(potp is not null),'Le code de l''enregistrement est vide.';
		execute format('select statutenreg, datexpirenreg, otpenreg from cudutilisateur.enregistrement where codenreg = $1')
		into vstatut, vdatexpir, votp
		using pcode;
		assert(vstatut = 1),'Le statut de l''enregistrement est incoherent.';
		assert(votp = potp),'L''OTP fourni est incorrect.';
		assert(vdatexpir > current_timestamp),'L''OTP genere par l''enregistrement n''est plus valide.';
				
		execute format('select nomsenreg, numtelenreg, emailenreg, mdpenreg, pinenreg, typeutilis from cudutilisateur.enregistrement where codenreg = $1')
		into vnoms, vnumtel, vemail, vmdp, vpin, vtype
		using pcode;
		vcodecompte := cudsecurite.creationcompte(vnoms, vemail, vmdp, 1);
		vcodeutilis := cudutilisateur.creationutilisateur(pcode, vcodecompte);
		if (vtype = 'resposervey') then
			vcoderesposerv := cudutilisateur.creationresposervey(vcodeutilis, vpin);
			vcodeprofils[0] := srsecurite.obtenircodeprofil('resposervey');
			call cudsecurite.mettreajourprofilscompte(vcodecompte, vcodeprofils);
		end if;
		if (vtype = 'responsable') then
			vcoderespo := cudutilisateur.creationresponsable(vcodeutilis, vpin);
			vcodeprofils[0] := srsecurite.obtenircodeprofil('responsable');
			call cudsecurite.mettreajourprofilscompte(vcodecompte, vcodeprofils);
		end if;
		if (vtype = 'exploitant') then
			vcodexploit := cudutilisateur.creationexploitant(vcodeutilis);
			vcodeprofils[0] := srsecurite.obtentioncodeprofil('exploitant');
			call cudsecurite.mettreajourprofilscompte(vcodecompte, vcodeprofils);
		end if;
		if (vtype = 'administrateur') then
			vcodeadmin := cudutilisateur.creationadministrateur(vcodeutilis);
			vcodeprofils[0] := srsecurite.obtentioncodeprofil('administrateur');
			call cudsecurite.mettreajourprofilscompte(vcodecompte, vcodeprofils);
		end if;
		execute format('update cudutilisateur.enregistrement set statutenreg = 2, dateupda = current_timestamp where codenreg = $1')
		using pcode;
		
		execute format('select statutenreg from cudutilisateur.enregistrement where codenreg = $1')
		into vstatut
		using pcode;
		assert(vstatut = 2),'Le statut de l''enregistrement est incoherent.';
	
	end;
	$$;

create or replace procedure cudutilisateur.annulerenregistrement(pcode public.identifiant)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
	begin 
		
		assert(pcode is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('cudutilisateur', 'enregistrement', 'codenreg', pcode)),'Le code <'|| pcode ||'> de l''enregistrement est inconnu.';
		execute format('select statutenreg from cudutilisateur.enregistrement where codenreg = $1')
		into vstatut
		using pcode;
		assert(vstatut = 1),'Le statut de l''enregistrement est incoherent.';
		
		execute format('update cudutilisateur.enregistrement set statutenreg = 3, dateupda = current_timestamp where codenreg = $1')
		using pcode;
		
		execute format('select statutenreg from cudutilisateur.enregistrement where codenreg = $1')
		into vstatut
		using pcode;
		assert(vstatut = 3),'Le statut de l''enregistrement est incoherent.';
	
	end;
	$$;

create or replace procedure cudutilisateur.supprimerenregistrement(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudutilisateur', 'enregistrement', 'codenreg', pcode)),'Le code <'|| pcode ||'> de l''enregistrement est inconnu.';	
		
		call public.supprimer('cudutilisateur', 'enregistrement', 'codenreg', pcode);
	
		assert(not public.existencetuple('cudutilisateur', 'enregistrement', 'codenreg', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudutilisateur.aftermiseajourenregistrement()
	returns trigger 
	language plpgsql
	as $$
	begin 
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srutilisateur', 'enregistrement', 'codenreg', old.codenreg, new.etat, new.dateupda);
		end if;
		if (old.statutenreg = 1 and new.statutenreg = 2) then 
			call srutilisateur.mettreajourvalidationenregistrement(new.codenreg, new.statutenreg, new.dateupda);
		end if;
		if (old.statutenreg = 1 and new.statutenreg = 3) then 
			call srutilisateur.mettreajourannulationenregistrement(new.codenreg, new.statutenreg, new.dateupda);
		end if;
		return null;
	end;
	$$;	

create trigger miseajourenregistrement after update on cudutilisateur.enregistrement for each row execute function cudutilisateur.aftermiseajourenregistrement();

create or replace function cudutilisateur.aftersuppressionenregistrement()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		return null;
	
	end;
	$$;	

create trigger suppressionenregistrement after delete on cudutilisateur.enregistrement for each row execute function cudutilisateur.aftersuppressionenregistrement();

-- ======== Creation de la table utilisateur
-- ==========================================================================================================================================
create table cudutilisateur.utilisateur(
	codeutilis public.identifiant not null,
	nomsutilis public.libelle not null,
	prenomsutilis public.libelle null,
	numtelutilis public.numtel not null,
	emailutilis public.email not null,
	codenreg public.identifiant not null,
	codecompte public.identifiant not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudutilisateur.utilisateur add constraint pkutilisateur primary key (codeutilis);
alter table cudutilisateur.utilisateur add constraint unnumtelutilis unique (numtelutilis);
alter table cudutilisateur.utilisateur add constraint unemailutilis unique (emailutilis);
alter table cudutilisateur.utilisateur add constraint chkinvariantcardetatutilisateur check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudutilisateur.utilisateur add constraint chkinvariantdatecreaupdautilisateur check (datecrea <= dateupda);
alter table cudutilisateur.utilisateur add constraint fkutilisateurenregistrement foreign key (codenreg) references cudutilisateur.enregistrement(codenreg) on delete cascade;
alter table cudutilisateur.utilisateur add constraint fkutilisateurcompte foreign key (codecompte) references cudsecurite.compte(codecompte) on delete cascade;

create or replace function cudutilisateur.creationutilisateur(pcodenreg public.identifiant, pcodecompte public.identifiant)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vnoms public.libelle;
		vprenoms public.libelle;
		vnumtel public.numtel;
		vemail public.email;
		vcodenreg public.identifiant;
		vcodecompte public.identifiant;
	begin 
		
		assert(pcodenreg is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('cudutilisateur', 'enregistrement', 'codenreg', pcodenreg)),'Le code <'|| pcodenreg ||'> de l''enregistrement est inconnu.';
		assert(pcodecompte is not null),'Le code du compte est vide.';
		assert(public.existencetuple('cudsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		
		execute format('select nomsenreg, prenomsenreg, numtelenreg, emailenreg from cudutilisateur.enregistrement where codenreg = $1')
		into vnoms, vprenoms, vnumtel, vemail
		using pcodenreg;	
		vcode := cudincrement.generationidentifiant('utilisateur');
		vordmax := public.obtentionordremax('cudutilisateur', 'utilisateur', 'ord');
		execute format('insert into cudutilisateur.utilisateur (codeutilis, nomsutilis, prenomsutilis, numtelutilis, emailutilis, codenreg, codecompte, ord) values ($1, $2, $3, $4, $5, $6, $7, $8)')
		using vcode, vnoms, vprenoms, vnumtel, vemail, pcodenreg, pcodecompte, vordmax;
	
		execute format('select codenreg, codecompte from cudutilisateur.utilisateur where codeutilis = $1')
		into vcodenreg, vcodecompte
		using vcode;	
		assert(vcodenreg = pcodenreg),'Incoherence sur les donnees inserees. codenreg';
		assert(vcodecompte = pcodecompte),'Incoherence sur les donnees inserees. codecompte';
		
		return vcode;
	end;
	$$;

create or replace function cudutilisateur.aftercreationutilisateur()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		call srutilisateur.ajouterutilisateur(new.codeutilis, new.nomsutilis, new.prenomsutilis, new.numtelutilis, new.emailutilis, new.codenreg, new.codecompte, new.etat, new.ord, new.datecrea);
		call public.attacher('cudutilisateur', 'enregistrement', 'codenreg', new.codenreg);
		call public.attacher('cudsecurite', 'compte', 'codecompte', new.codecompte);
	
		return null;
	end;
	$$;	

create trigger ajoututilisateur after insert on cudutilisateur.utilisateur for each row execute function cudutilisateur.aftercreationutilisateur();

create or replace procedure cudutilisateur.supprimerutilisateur(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudutilisateur', 'utilisateur', 'codeutilis', pcode)),'Le code <'|| pcode ||'> de l''utilisateur est inconnu.';	
		
		call public.supprimer('cudutilisateur', 'utilisateur', 'codeutilis', pcode);
	
		assert(not public.existencetuple('cudutilisateur', 'utilisateur', 'codeutilis', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudutilisateur.aftermiseajourutilisateur()
	returns trigger 
	language plpgsql
	as $$
	begin 
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srutilisateur', 'utilisateur', 'codeutilis', old.codeutilis, new.etat, new.dateupda);
		end if;
		return null;
	end;
	$$;	

create trigger miseajourutilisateur after update on cudutilisateur.utilisateur for each row execute function cudutilisateur.aftermiseajourutilisateur();

create or replace function cudutilisateur.aftersuppressionutilisateur()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		call public.detacher('cudutilisateur', 'enregistrement', 'codenreg', old.codenreg);
		call public.detacher('cudsecurite', 'compte', 'codecompte', old.codecompte);
		return null;
	
	end;
	$$;	

create trigger suppressionutilisateur after delete on cudutilisateur.utilisateur for each row execute function cudutilisateur.aftersuppressionutilisateur();

-- ======== creation de la table exploitant
-- ==========================================================================================================================================
create table cudutilisateur.exploitant(
	codexploit public.identifiant not null,
	codeutilis public.identifiant not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudutilisateur.exploitant add constraint pkexploitant primary key (codexploit);
alter table cudutilisateur.exploitant add constraint chkinvariantcardetatexploitant check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudutilisateur.exploitant add constraint chkinvariantdatecreaupdaexploitant check (datecrea <= dateupda);
alter table cudutilisateur.exploitant add constraint fkutilisateurexploitant foreign key (codeutilis) references cudutilisateur.utilisateur(codeutilis) on delete restrict;

create or replace function cudutilisateur.creationexploitant(pcodeutilis public.identifiant)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vcodeutilis public.identifiant;
	begin 
		
		assert(pcodeutilis is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('cudutilisateur', 'utilisateur', 'codeutilis', pcodeutilis)),'Le code <'|| pcodeutilis ||'> de l''utilisateur est inconnu.';
		
		vcode = cudincrement.generationidentifiant('exploitant');
		vordmax = public.obtentionordremax('cudutilisateur', 'exploitant', 'ord');
		execute format('insert into cudutilisateur.exploitant (codexploit, codeutilis, ord) values ($1, $2, $3)')
		using vcode, pcodeutilis, vordmax;
	
		execute format('select codeutilis from cudutilisateur.exploitant where codexploit = $1')
		into vcodeutilis
		using vcode;	
		assert(vcodeutilis = pcodeutilis),'Incoherence 1 sur les donnees inserees.';
		
		return vcode;
	end;
	$$;

create or replace function cudutilisateur.aftercreationexploitant()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		call srutilisateur.ajouterexploitant(new.codexploit, new.codeutilis, new.etat, new.ord, new.datecrea);
		call public.attacher('cudutilisateur', 'utilisateur', 'codeutilis', new.codeutilis);
	
		return null;
	end;
	$$;	

create trigger ajoutexploitant after insert on cudutilisateur.exploitant for each row execute function cudutilisateur.aftercreationexploitant();

create or replace procedure cudutilisateur.supprimerexploitant(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudutilisateur', 'exploitant', 'codexploit', pcode)),'Le code <'|| pcode ||'> de l''exploitant est inconnu.';	
		
		call public.supprimer('cudutilisateur', 'exploitant', 'codexploit', pcode);
	
		assert(not public.existencetuple('cudutilisateur', 'exploitant', 'codexploit', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudutilisateur.aftermiseajourexploitant()
	returns trigger 
	language plpgsql
	as $$
	begin 
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srutilisateur', 'exploitant', 'codexploit', old.codexploit, new.etat, new.dateupda);
		end if;
		return null;
	end;
	$$;	

create trigger miseajourexploitant after update on cudutilisateur.exploitant for each row execute function cudutilisateur.aftermiseajourexploitant();

create or replace function cudutilisateur.aftersuppressionexploitant()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		call public.detacher('cudutilisateur', 'utilisateur', 'codeutilis', old.codeutilis);
		return null;
	
	end;
	$$;	

create trigger suppressionexploitant after delete on cudutilisateur.exploitant for each row execute function cudutilisateur.aftersuppressionexploitant();

-- ======== creation de la table administrateur
-- ==========================================================================================================================================
create table cudutilisateur.administrateur(
	codeadmin public.identifiant not null,
	codeutilis public.identifiant not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudutilisateur.administrateur add constraint pkadministrateur primary key (codeadmin);
alter table cudutilisateur.administrateur add constraint chkinvariantcardetatadministrateur check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudutilisateur.administrateur add constraint chkinvariantdatecreaupdaadministrateur check (datecrea <= dateupda);
alter table cudutilisateur.administrateur add constraint fkutilisateuradministrateur foreign key (codeutilis) references cudutilisateur.utilisateur(codeutilis) on delete restrict;

create or replace function cudutilisateur.creationadministrateur(pcodeutilis public.identifiant)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vcodeutilis public.identifiant;
	begin 
		
		assert(pcodeutilis is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('cudutilisateur', 'utilisateur', 'codeutilis', pcodeutilis)),'Le code <'|| pcodeutilis ||'> de l''utilisateur est inconnu.';
		
		vcode = cudincrement.generationidentifiant('administrateur');
		vordmax = public.obtentionordremax('cudutilisateur', 'administrateur', 'ord');
		execute format('insert into cudutilisateur.administrateur (codeadmin, codeutilis, ord) values ($1, $2, $3)')
		using vcode, pcodeutilis, vordmax;
	
		execute format('select codeutilis from cudutilisateur.administrateur where codeadmin = $1')
		into vcodeutilis
		using vcode;	
		assert(vcodeutilis = pcodeutilis),'Incoherence 1 sur les donnees inserees.';
		
		return vcode;
	end;
	$$;

create or replace function cudutilisateur.aftercreationadministrateur()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		call srutilisateur.ajouteradministrateur(new.codeadmin, new.codeutilis, new.etat, new.ord, new.datecrea);
		call public.attacher('cudutilisateur', 'utilisateur', 'codeutilis', new.codeutilis);
	
		return null;
	end;
	$$;	

create trigger ajoutadministrateur after insert on cudutilisateur.administrateur for each row execute function cudutilisateur.aftercreationadministrateur();

create or replace procedure cudutilisateur.supprimeradministrateur(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudutilisateur', 'administrateur', 'codeadmin', pcode)),'Le code <'|| pcode ||'> de l''administrateur est inconnu.';	
		
		call public.supprimer('cudutilisateur', 'administrateur', 'codeadmin', pcode);
	
		assert(not public.existencetuple('cudutilisateur', 'administrateur', 'codeadmin', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudutilisateur.aftermiseajouradministrateur()
	returns trigger 
	language plpgsql
	as $$
	begin 
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srutilisateur', 'administrateur', 'codeadmin', old.codeadmin, new.etat, new.dateupda);
		end if;
		return null;
	end;
	$$;	

create trigger miseajouradministrateur after update on cudutilisateur.administrateur for each row execute function cudutilisateur.aftermiseajouradministrateur();

create or replace function cudutilisateur.aftersuppressionadministrateur()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		call public.detacher('cudutilisateur', 'utilisateur', 'codeutilis', old.codeutilis);
		return null;
	
	end;
	$$;	

create trigger suppressionadministrateur after delete on cudutilisateur.administrateur for each row execute function cudutilisateur.aftersuppressionadministrateur();


-- ======== Creation de la table resposervey
-- ==========================================================================================================================================
create table cudutilisateur.resposervey(
	coderesposerv public.identifiant not null,
	pinresposervey public.codepin not null,
	codeutilis public.identifiant not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudutilisateur.resposervey add constraint pkresposervey primary key (coderesposerv);
alter table cudutilisateur.resposervey add constraint chkinvariantcardetatresposervey check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudutilisateur.resposervey add constraint chkinvariantdatecreaupdaresposervey check (datecrea <= dateupda);
alter table cudutilisateur.resposervey add constraint fkutilisateurresposervey foreign key (codeutilis) references cudutilisateur.utilisateur(codeutilis) on delete restrict;

create or replace function cudutilisateur.creationresposervey(pcodeutilis public.identifiant, ppin public.codepin)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vcodeutilis public.identifiant;
		vpin public.codepin;
	begin 
		
		assert(pcodeutilis is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('cudutilisateur', 'utilisateur', 'codeutilis', pcodeutilis)),'Le code <'|| pcodeutilis ||'> de l''utilisateur est inconnu.';
		assert(ppin is not null),'Le pin du responsable servey est vide.';
	
		vcode = cudincrement.generationidentifiant('resposervey');
		vordmax = public.obtentionordremax('cudutilisateur', 'resposervey', 'ord');
		execute format('insert into cudutilisateur.resposervey (coderesposerv, codeutilis, pinresposervey, ord) values ($1, $2, $3, $4)')
		using vcode, pcodeutilis, ppin, vordmax;
	
		execute format('select codeutilis from cudutilisateur.resposervey where coderesposerv = $1')
		into vcodeutilis
		using vcode;	
		assert(vcodeutilis = pcodeutilis),'Incoherence 1 sur les donnees inserees.';
		
		return vcode;
	end;
	$$;

create or replace function cudutilisateur.aftercreationresposervey()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		call srutilisateur.ajouteresposervey(new.coderesposerv, new.pinresposervey, new.codeutilis, new.etat, new.ord, new.datecrea);
		call public.attacher('cudutilisateur', 'utilisateur', 'codeutilis', new.codeutilis);
	
		return null;
	end;
	$$;	

create trigger ajoutresposervey after insert on cudutilisateur.resposervey for each row execute function cudutilisateur.aftercreationresposervey();

create or replace procedure cudutilisateur.supprimerresposervey(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudutilisateur', 'resposervey', 'coderesposerv', pcode)),'Le code <'|| pcode ||'> du responsable servey est inconnu.';	
		
		call public.supprimer('cudutilisateur', 'resposervey', 'coderesposerv', pcode);
	
		assert(not public.existencetuple('cudutilisateur', 'resposervey', 'coderesposerv', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudutilisateur.aftermiseajourresposervey()
	returns trigger 
	language plpgsql
	as $$
	begin 
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srutilisateur', 'resposervey', 'coderesposerv', old.coderesposerv, new.etat, new.dateupda);
		end if;
		return null;
	end;
	$$;	

create trigger miseajourresposervey after update on cudutilisateur.resposervey for each row execute function cudutilisateur.aftermiseajourresposervey();

create or replace function cudutilisateur.aftersuppressionresposervey()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		call public.detacher('cudutilisateur', 'utilisateur', 'codeutilis', old.codeutilis);
		return null;
	
	end;
	$$;	

create trigger suppressionresposervey after delete on cudutilisateur.resposervey for each row execute function cudutilisateur.aftersuppressionresposervey();

-- ======== Creation de la table responsable
-- ==========================================================================================================================================
create table cudutilisateur.responsable(
	coderespo public.identifiant not null,
	pinrespo public.codepin not null,
	codeutilis public.identifiant not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudutilisateur.responsable add constraint pkresponsable primary key (coderespo);
alter table cudutilisateur.responsable add constraint chkinvariantcardetatresponsable check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudutilisateur.responsable add constraint chkinvariantdatecreaupdaresponsable check (datecrea <= dateupda);
alter table cudutilisateur.responsable add constraint fkutilisateurresponsable foreign key (codeutilis) references cudutilisateur.utilisateur(codeutilis) on delete restrict;

create or replace function cudutilisateur.creationresponsable(pcodeutilis public.identifiant, ppin public.codepin)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vcodeutilis public.identifiant;
		vpin public.codepin;
	begin 
		
		assert(pcodeutilis is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('cudutilisateur', 'utilisateur', 'codeutilis', pcodeutilis)),'Le code <'|| pcodeutilis ||'> de l''utilisateur est inconnu.';
		assert(ppin is not null),'Le pin du responsable est vide.';
	
		vcode = cudincrement.generationidentifiant('responsable');
		vordmax = public.obtentionordremax('cudutilisateur', 'responsable', 'ord');
		execute format('insert into cudutilisateur.responsable (coderespo, codeutilis, pinrespo, ord) values ($1, $2, $3, $4)')
		using vcode, pcodeutilis, ppin, vordmax;
	
		execute format('select codeutilis from cudutilisateur.responsable where coderespo = $1')
		into vcodeutilis
		using vcode;	
		assert(vcodeutilis = pcodeutilis),'Incoherence 1 sur les donnees inserees.';
		
		return vcode;
	end;
	$$;

create or replace function cudutilisateur.aftercreationresponsable()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		call srutilisateur.ajouterresponsable(new.coderespo, new.pinrespo, new.codeutilis, new.etat, new.ord, new.datecrea);
		call public.attacher('cudutilisateur', 'utilisateur', 'codeutilis', new.codeutilis);
	
		return null;
	end;
	$$;	

create trigger ajoutresponsable after insert on cudutilisateur.responsable for each row execute function cudutilisateur.aftercreationresponsable();

create or replace procedure cudutilisateur.supprimerresponsable(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudutilisateur', 'responsable', 'coderespo', pcode)),'Le code <'|| pcode ||'> du responsable est inconnu.';	
		
		call public.supprimer('cudutilisateur', 'responsable', 'coderespo', pcode);
	
		assert(not public.existencetuple('cudutilisateur', 'responsable', 'coderespo', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudutilisateur.aftermiseajourresponsable()
	returns trigger 
	language plpgsql
	as $$
	begin 
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srutilisateur', 'responsable', 'coderespo', old.coderespo, new.etat, new.dateupda);
		end if;
		return null;
	end;
	$$;	

create trigger miseajourresponsable after update on cudutilisateur.responsable for each row execute function cudutilisateur.aftermiseajourresponsable();

create or replace function cudutilisateur.aftersuppressionresponsable()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		call public.detacher('cudutilisateur', 'utilisateur', 'codeutilis', old.codeutilis);
		return null;
	
	end;
	$$;	

create trigger suppressionresponsable after delete on cudutilisateur.responsable for each row execute function cudutilisateur.aftersuppressionresponsable();

-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== Creation du schema srutilisateur
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create schema srutilisateur;
alter schema srutilisateur owner to akamsrdbservey;

-- ======== Creation de la table enregistrement
-- ==========================================================================================================================================
create table srutilisateur.enregistrement(
	codenreg public.identifiant not null,
	otpenreg public.nom not null,
	statutenreg public.etat not null,
	datexpirenreg timestamp null,
	nomsenreg public.libelle not null,
	prenomsenreg public.libelle null,
	numtelenreg public.numtel not null,
	emailenreg public.email not null,
	mdpenreg public.nom not null,
	pinenreg public.codepin not null,
	typeutilis public.typeutilisateur not null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srutilisateur.enregistrement add constraint pkenregistrement primary key (codenreg);
alter table srutilisateur.enregistrement add constraint chkinvariantdatecreaupdaenregistrement check (datecrea <= dateupda);

create or replace procedure srutilisateur.ajouterenregistrement(pcode public.identifiant, potp public.nom, pstatut public.etat, pdatexpir timestamp, pnoms public.libelle, pprenoms public.libelle, pnumtel public.numtel, pemail public.email, pmdp public.nom, ppin public.codepin, ptype public.typeutilisateur, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		votp public.nom;
		vstatut public.etat;
		vdatexpir timestamp;
		vnoms public.libelle;
		vprenoms public.libelle;
		vnumtel public.numtel;
		vemail public.email;
		vmdp public.nom;
		vpin public.codepin;
		vtype public.typeutilisateur;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code de l''enregistrement est vide.';
		assert(not public.existencetuple('srutilisateur', 'enregistrement', 'codenreg', pcode)),'Le code <'|| pcode ||'> existe deja.';
		assert(potp is not null),'Le code de confirmation de l''enregistrement est vide.';
		assert(pstatut is not null),'Le statut de l''enregistrement est vide.';
		assert(pnoms is not null),'Les noms de l''enregistrement sont vides.';
		assert(pnumtel is not null),'Le numero de telephone de l''enregistrement est vide.';
		assert(pemail is not null),'L''email de l''enregistrement est vide.';
		assert(pmdp is not null),'Le mot de passe de l''enregistrement est vide.';
		assert(ppin is not null),'Le pin de l''enregistrement est vide.';
		assert(ptype is not null),'Le type utilisateur de l''enregistrement est vide.';
		assert(petat = 1),'L''etat de l''enregistrement est incoherent.';
		assert(pord > 0),'L''ordre de l''enregistrement est incoherent.';
		assert(pdatecrea is not null),'La date de creation de l''enregistrement est vide.';	
		
		execute format('insert into srutilisateur.enregistrement (codenreg, otpenreg, statutenreg, datexpirenreg, nomsenreg, prenomsenreg, numtelenreg, emailenreg, mdpenreg, pinenreg, typeutilis, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)')
		using pcode, potp, pstatut, pdatexpir, pnoms, pprenoms, pnumtel, pemail, pmdp, ppin, ptype, petat, pord, pdatecrea;
	
		execute format('select otpenreg, statutenreg, datexpirenreg, nomsenreg, prenomsenreg, numtelenreg, emailenreg, mdpenreg, pinenreg, typeutilis, etat, ord, datecrea from srutilisateur.enregistrement where codenreg = $1')
		into votp, vstatut, vdatexpir, vnoms, vprenoms, vnumtel, vemail, vmdp, vpin, vtype, vetat, vord, vdatecrea
		using pcode;	
		assert(votp = potp),'Incoherence 1 sur les donnees inserees. otpenreg';
		assert(vstatut = pstatut),'Incoherence 1 sur les donnees inserees. statutenreg';
		assert((vdatexpir = pdatexpir or vdatexpir is null)),'Incoherence 1 sur les donnees inserees. datexpirenreg';
		assert(vnoms = pnoms),'Incoherence 1 sur les donnees inserees. nomsenreg';
		assert((vprenoms = pprenoms or vprenoms is null)),'Incoherence 1 sur les donnees inserees. prenomsenreg';
		assert(vnumtel = pnumtel),'Incoherence 1 sur les donnees inserees. numtelenreg';
		assert(vemail = pemail),'Incoherence 1 sur les donnees inserees. emailenreg';
		assert(vmdp = pmdp),'Incoherence 1 sur les donnees inserees. mdpenreg';
		assert(vpin = ppin),'Incoherence 1 sur les donnees inserees. pinenreg';
		assert(vtype = ptype),'Incoherence 1 sur les donnees inserees. typeutilis';
		assert(vetat = petat),'Incoherence 1 sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence 1 sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence 1 sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srutilisateur.mettreajourvalidationenregistrement(pcode public.identifiant, pstatut public.etat, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('srutilisateur', 'enregistrement', 'codenreg', pcode)),'Le code <'|| pcode ||'> est inconnu.';
		assert(pstatut is not null),'Le statut de l''enregistrement est vide.';
		assert(pstatut = 2),'Le statut de l''enregistrement est incorrect.';
		assert(pdateupda is not null),'La date de creation de l''enregistrement est vide.';	
		execute format('select dateupda from srutilisateur.enregistrement where codenreg = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour est incoherente.';
	
		execute format('update srutilisateur.enregistrement set statutenreg = $1, dateupda = $2 where codenreg = $3')
		using pstatut, pdateupda, pcode;
	
		execute format('select statutenreg, dateupda from srutilisateur.enregistrement where codenreg = $1')
		into vstatut, vdateupda
		using pcode;
		assert(vstatut = pstatut),'Les donnees mises a jour sont incoherentes. statutenreg';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace procedure srutilisateur.mettreajourannulationenregistrement(pcode public.identifiant, pstatut public.etat, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('srutilisateur', 'enregistrement', 'codenreg', pcode)),'Le code <'|| pcode ||'> est inconnu.';
		assert(pstatut is not null),'Le statut de l''enregistrement est vide.';
		assert(pstatut = 3),'Le statut de l''enregistrement est incorrect.';
		assert(pdateupda is not null),'La date de creation de l''enregistrement est vide.';	
		execute format('select dateupda from srutilisateur.enregistrement where codenreg = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour est incoherente.';
	
		execute format('update srutilisateur.enregistrement set statutenreg = $1, dateupda = $2 where codenreg = $3')
		using pstatut, pdateupda, pcode;
	
		execute format('select statutenreg, dateupda from srutilisateur.enregistrement where codenreg = $1')
		into vstatut, vdateupda
		using pcode;
		assert(vstatut = pstatut),'Les donnees mises a jour sont incoherentes. statutenreg';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srutilisateur.obtentionenregistrement(pcode public.identifiant)
	returns table(codenreg public.identifiant, otpenreg public.nom, statutenreg public.etat, datexpirenreg timestamp, nomsenreg public.libelle, prenomsenreg public.libelle, numtelenreg public.numtel, emailenreg public.email, mdpenreg public.nom, pinenreg public.codepin, typeutilis public.typeutilisateur)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
	begin 
		
		assert(pcode is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('srutilisateur', 'enregistrement', 'codenreg', pcode)),'Le code <'|| pcode ||'> de l''enregistrement est inconnu.';
	
		return query select e.codenreg, e.otpenreg, e.statutenreg, e.datexpirenreg, e.nomsenreg, e.prenomsenreg, e.numtelenreg, e.emailenreg, e.mdpenreg, e.pinenreg, e.typeutilis from srutilisateur.enregistrement e where e.codenreg = pcode;
		
	end;
	$$;


create or replace function srutilisateur.recherchenregistrement(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codenreg public.identifiant, otpenreg public.nom, statutenreg public.etat, datexpirenreg timestamp, nomsenreg public.libelle, prenomsenreg public.libelle, numtelenreg public.numtel, emailenreg public.email, mdpenreg public.nom, pinenreg public.codepin, typeutilis public.typeutilisateur)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select e.codenreg, e.otpenreg, e.statutenreg, e.datexpirenreg, e.nomsenreg, e.prenomsenreg, e.numtelenreg, e.emailenreg, e.mdpenreg, e.pinenreg, e.typeutilis from srutilisateur.enregistrement e where e.etat <> 3 order by e.ord desc limit plimit offset pdebut;
		else
			return query select e.codenreg, e.otpenreg, e.statutenreg, e.datexpirenreg, e.nomsenreg, e.prenomsenreg, e.numtelenreg, e.emailenreg, e.mdpenreg, e.pinenreg, e.typeutilis from srutilisateur.enregistrement e where e.etat <> 3 and (e.nomsenreg ilike '%'|| pcritere ||'%' or e.prenomsenreg ilike '%'|| pcritere ||'%' or e.numtelenreg ilike '%'|| pcritere ||'%' or e.emailenreg ilike '%'|| pcritere ||'%') order by e.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== Creation de la table utilisateur
-- ==========================================================================================================================================
create table srutilisateur.utilisateur(	
	codeutilis public.identifiant not null,
	nomsutilis public.libelle not null,
	prenomsutilis public.libelle null,
	numtelutilis public.numtel not null,
	emailutilis public.email not null,
	codenreg public.identifiant not null,
	otpenreg public.nom not null,
	statutenreg public.etat not null,
	datexpirenreg timestamp null,
	nomsenreg public.libelle not null,
	prenomsenreg public.libelle null,
	numtelenreg public.numtel not null,
	emailenreg public.email not null,
	mdpenreg public.nom not null,
	typeutilis public.typeutilisateur not null,
	codecompte public.identifiant not null,
	nomcompte public.libelle null,
	logincompte public.nom not null,
	statutcompte public.etat not null,	
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srutilisateur.utilisateur add constraint pkutilisateur primary key (codeutilis);
alter table srutilisateur.utilisateur add constraint chkinvariantdatecreaupdautilisateur check (datecrea <= dateupda);

create or replace procedure srutilisateur.ajouterutilisateur(pcode public.identifiant, pnomsutilis public.libelle, pprenomsutilis public.libelle, pnumtelutilis public.numtel, pemailutilis public.email, pcodenreg public.identifiant, pcodecompte public.identifiant, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vnomsutilis public.libelle;
		vprenomsutilis public.libelle;
		vnumtelutilis public.numtel;
		vemailutilis public.email;
		vcodenreg public.identifiant;
		votpenreg public.nom;
		vstatutenreg public.etat;
		vdatexpirenreg timestamp;
		vnomsenreg public.libelle;
		vprenomsenreg public.libelle;
		vnumtelenreg public.numtel;
		vemailenreg public.email;
		vmdpenreg public.nom;
		vtypeutilis public.typeutilisateur;
		vcodecompte public.identifiant;
		vnomcompte public.libelle;
		vlogincompte public.nom;
		vstatutcompte public.etat;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code de l''utilisateur est vide.';
		assert(not public.existencetuple('srutilisateur', 'utilisateur', 'codeutilis', pcode)),'Le code <'|| pcode ||'> est existant.';
		assert(pnomsutilis is not null),'Les noms de l''utilisateur sont vides.';
		assert(pnumtelutilis is not null),'Le numero de telephone de l''utilisateur est vide.';
		assert(pemailutilis is not null),'L''email de l''utilisateur est vide.';
		assert(pcodenreg is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('srutilisateur', 'enregistrement', 'codenreg', pcodenreg)),'Le code <'|| pcodenreg ||'> de l''enregistrement est inconnu.';
		assert(pcodecompte is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		assert(petat is not null),'L''etat de l''utilisateur est vide.';
		assert(pord is not null),'L''ordre de l''utilisateur est vide.';
		assert(pdatecrea is not null),'La date de creation de l''utilisateur est vide.';
	
		execute format('select otpenreg, statutenreg, datexpirenreg, nomsenreg, prenomsenreg, numtelenreg, emailenreg, mdpenreg, typeutilis from srutilisateur.enregistrement where codenreg = $1')
		into votpenreg, vstatutenreg, vdatexpirenreg, vnomsenreg, vprenomsenreg, vnumtelenreg, vemailenreg, vmdpenreg, vtypeutilis
		using pcodenreg;	
		execute format('select nomcompte, logincompte, statutcompte from srsecurite.compte where codecompte = $1')
		into vnomcompte, vlogincompte, vstatutcompte
		using pcodecompte;	
		execute format('insert into srutilisateur.utilisateur (codeutilis, nomsutilis, prenomsutilis, numtelutilis, emailutilis, codenreg, otpenreg, statutenreg, datexpirenreg, nomsenreg, prenomsenreg, numtelenreg, emailenreg, mdpenreg, typeutilis, codecompte, nomcompte, logincompte, statutcompte, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22)')
		using pcode, pnomsutilis, pprenomsutilis, pnumtelutilis, pemailutilis, pcodenreg, votpenreg, vstatutenreg, vdatexpirenreg, vnomsenreg, vprenomsenreg, vnumtelenreg, vemailenreg, vmdpenreg, vtypeutilis, pcodecompte, vnomcompte, vlogincompte, vstatutcompte, petat, pord, pdatecrea;
	
		execute format('select nomsutilis, prenomsutilis, numtelutilis, emailutilis, codenreg, codecompte, etat, ord, datecrea from srutilisateur.utilisateur where codeutilis = $1')
		into vnomsutilis, vprenomsutilis, vnumtelutilis, vemailutilis, vcodenreg, vcodecompte, vetat, vord, vdatecrea
		using pcode;	
		assert(vnomsutilis = pnomsutilis ),'Incoherence sur les donnees inserees. nomsutilis';
		assert((vprenomsutilis = pprenomsutilis or vprenomsutilis is null)),'Incoherence sur les donnees inserees. prenomsutilis';
		assert(vnumtelutilis = pnumtelutilis),'Incoherence sur les donnees inserees. numtelutilis';
		assert(vemailutilis = pemailutilis),'Incoherence sur les donnees inserees. emailutilis';
		assert(vcodenreg = pcodenreg),'Incoherence sur les donnees inserees. codenreg';
		assert(vcodecompte = pcodecompte),'Incoherence sur les donnees inserees. codecompte';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. vdatecrea';
		
	end;
	$$;

create or replace function srutilisateur.aftermiseajourutilisateur()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		if (new.typeutilis = 'resposervey') then
			execute format('update srutilisateur.resposervey set nomsutilis = $1, prenomsutilis = $2, numtelutilis = $3, emailutilis = $4, nomcompte = $5, logincompte = $6, statutcompte = $7 where codeutilis = $8')
		using new.nomsutilis, new.prenomsutilis, new.numtelutilis, new.emailutilis, new.nomcompte, new.logincompte, new.statutcompte, old.codeutilis;
		end if;
		if (new.typeutilis = 'responsable') then
			execute format('update srutilisateur.responsable set nomsutilis = $1, prenomsutilis = $2, numtelutilis = $3, emailutilis = $4, nomcompte = $5, logincompte = $6, statutcompte = $7 where codeutilis = $8')
		using new.nomsutilis, new.prenomsutilis, new.numtelutilis, new.emailutilis, new.nomcompte, new.logincompte, new.statutcompte, old.codeutilis;
		end if;
		if (new.typeutilis = 'exploitant') then
			execute format('update srutilisateur.exploitant set nomsutilis = $1, prenomsutilis = $2, numtelutilis = $3, emailutilis = $4, nomcompte = $5, logincompte = $6, statutcompte = $7 where codeutilis = $8')
		using new.nomsutilis, new.prenomsutilis, new.numtelutilis, new.emailutilis, new.nomcompte, new.logincompte, new.statutcompte, old.codeutilis;
		end if;
		if (new.typeutilis = 'administrateur') then
			execute format('update srutilisateur.administrateur set nomsutilis = $1, prenomsutilis = $2, numtelutilis = $3, emailutilis = $4, nomcompte = $5, logincompte = $6, statutcompte = $7 where codeutilis = $8')
		using new.nomsutilis, new.prenomsutilis, new.numtelutilis, new.emailutilis, new.nomcompte, new.logincompte, new.statutcompte, old.codeutilis;
		end if;
		
		return null;
	
	end;
	$$;	

create trigger miseajourutilisateur after update on srutilisateur.utilisateur for each row execute function srutilisateur.aftermiseajourutilisateur();

create or replace function srutilisateur.verifierunicitemail(pemail public.email)
	returns boolean
	language plpgsql
	as $$
	begin 
		
		assert(pemail is not null),'L''email est vide.';
	
		return public.existencetuple('srutilisateur', 'utilisateur', 'emailutilis', pemail);
		
	end;
	$$;

create or replace function srutilisateur.verifierunicitenumtel(pnumtel public.numtel)
	returns boolean
	language plpgsql
	as $$
	begin 
		
		assert(pnumtel is not null),'Le numero de telephone est vide.';	
	
		return public.existencetuple('srutilisateur', 'utilisateur', 'numtelutilis', pnumtel);
		
	end;
	$$;

create or replace function srutilisateur.obtentionutilisateur(pcode public.identifiant)
	returns table(codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, otpenreg public.nom, statutenreg public.etat, datexpirenreg timestamp, nomsenreg public.libelle, prenomsenreg public.libelle, numtelenreg public.numtel, emailenreg public.email, mdpenreg public.nom, typeutilis public.typeutilisateur, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
	begin 
		
		assert(pcode is not null),'Le code de l''utilisateur est vide.';
		assert(public.existencetuple('srutilisateur', 'utilisateur', 'codeutilis', pcode)),'Le code <'|| pcode ||'> de l''utilisateur est inconnu.';
	
		return query select u.codeutilis, u.nomsutilis, u.prenomsutilis, u.numtelutilis, u.emailutilis, u.codenreg, u.otpenreg, u.statutenreg, u.datexpirenreg, u.nomsenreg, u.prenomsenreg, u.numtelenreg, u.emailenreg, u.mdpenreg, u.typeutilis, u.codecompte, u.nomcompte, u.logincompte, u.statutcompte from srutilisateur.utilisateur u where u.codeutilis = pcode;
		
	end;
	$$;

create or replace function srutilisateur.obtentionutilisateurenregistrement(pcodenreg public.identifiant)
	returns table(codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, otpenreg public.nom, statutenreg public.etat, datexpirenreg timestamp, nomsenreg public.libelle, prenomsenreg public.libelle, numtelenreg public.numtel, emailenreg public.email, mdpenreg public.nom, typeutilis public.typeutilisateur, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)
	language plpgsql
	as $$
	declare
		vstatut public.etat;
	begin 
		
		assert(pcodenreg is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('srutilisateur', 'enregistrement', 'codenreg', pcodenreg)),'Le code <'|| pcodenreg ||'> de l''enregistrement est inconnu.';
	
		return query select u.codeutilis, u.nomsutilis, u.prenomsutilis, u.numtelutilis, u.emailutilis, u.codenreg, u.otpenreg, u.statutenreg, u.datexpirenreg, u.nomsenreg, u.prenomsenreg, u.numtelenreg, u.emailenreg, u.mdpenreg, u.typeutilis, u.codecompte, u.nomcompte, u.logincompte, u.statutcompte from srutilisateur.utilisateur u where u.codenreg = pcodenreg;
		
	end;
	$$;

-- ======== creation de la table exploitant
-- ==========================================================================================================================================
create table srutilisateur.exploitant(	
	codexploit public.identifiant not null,
	codeutilis public.identifiant not null,
	nomsutilis public.libelle not null,
	prenomsutilis public.libelle null,
	numtelutilis public.numtel not null,
	emailutilis public.email not null,
	codenreg public.identifiant not null,	
	codecompte public.identifiant not null,
	nomcompte public.libelle null,
	logincompte public.nom not null,
	statutcompte public.etat not null,		
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srutilisateur.exploitant add constraint pkexploitant primary key (codexploit);
alter table srutilisateur.exploitant add constraint chkinvariantdatecreaupdaexploitant check (datecrea <= dateupda);

create or replace procedure srutilisateur.ajouterexploitant(pcode public.identifiant, pcodeutilis public.identifiant, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vcodeutilis public.identifiant;
		vnomsutilis public.libelle;
		vprenomsutilis public.libelle;
		vnumtelutilis public.numtel;
		vemailutilis public.email;
		vcodenreg public.identifiant;
		vcodecompte public.identifiant;
		vnomcompte public.libelle;
		vlogincompte public.nom;
		vstatutcompte public.etat;	
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code de l''exploitant est vide.';
		assert(not public.existencetuple('srutilisateur', 'exploitant', 'codexploit', pcode)),'Le code <'|| pcode ||'> de l''exploitant est existant.';
		assert(pcodeutilis is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srutilisateur', 'utilisateur', 'codeutilis', pcodeutilis)),'Le code <'|| pcodeutilis ||'> de l''utilisateur est inconnu.';
		assert(petat = 1),'L''etat de l''exploitant est vide.';
		assert(pord > 0),'L''ordre de l''exploitant est vide.';
		assert(pdatecrea is not null),'La date de creation de l''exploitant est vide.';
	
		execute format('select nomsutilis, prenomsutilis, numtelutilis, emailutilis, codenreg, codecompte, nomcompte, logincompte, statutcompte from srutilisateur.utilisateur where codeutilis = $1')
		into vnomsutilis, vprenomsutilis, vnumtelutilis, vemailutilis, vcodenreg, vcodecompte, vnomcompte, vlogincompte, vstatutcompte
		using pcodeutilis;
		
		execute format('insert into srutilisateur.exploitant (codexploit, codeutilis, nomsutilis, prenomsutilis, numtelutilis, emailutilis, codenreg, codecompte, nomcompte, logincompte, statutcompte, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)')
		using pcode, pcodeutilis, vnomsutilis, vprenomsutilis, vnumtelutilis, vemailutilis, vcodenreg, vcodecompte, vnomcompte, vlogincompte, vstatutcompte, petat, pord, pdatecrea;
	
		execute format('select codeutilis, etat, ord, datecrea from srutilisateur.exploitant where codexploit = $1')
		into vcodeutilis, vetat, vord, vdatecrea
		using pcode;	
		assert(vcodeutilis = pcodeutilis),'Incoherence sur les donnees inserees. codeutilis';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace function srutilisateur.obtentionexploitant(pcode public.identifiant)
	returns table(codexploit public.identifiant, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code de l''exploitant est vide.';
		assert(public.existencetuple('srutilisateur', 'exploitant', 'codexploit', pcode)),'Le code <'|| pcode ||'> de l''exploitant est inconnu.';
		
		return query select e.codexploit, e.codeutilis, e.nomsutilis, e.prenomsutilis, e.numtelutilis, e.emailutilis, e.codenreg, e.codecompte, e.nomcompte, e.logincompte, e.statutcompte from srutilisateur.exploitant e where e.codexploit = pcode;
	end;
	$$;

create or replace function srutilisateur.obtentionexploitantutilisateur(pcodeutilis public.identifiant)
	returns table(codexploit public.identifiant, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodeutilis is not null),'Le code de l''utilisateur est vide.';
		assert(public.existencetuple('srutilisateur', 'utilisateur', 'codeutilis', pcodeutilis)),'Le code <'|| pcodeutilis ||'> de l''utilisateur est inconnu.';
		
		return query select e.codexploit, e.codeutilis, e.nomsutilis, e.prenomsutilis, e.numtelutilis, e.emailutilis, e.codenreg, e.codecompte, e.nomcompte, e.logincompte, e.statutcompte from srutilisateur.exploitant e where e.codeutilis = pcodeutilis;
	end;
	$$;

create or replace function srutilisateur.obtentionexploitantcompte(pcodecompte public.identifiant)
	returns table(codexploit public.identifiant, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodecompte is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		
		return query select e.codexploit, e.codeutilis, e.nomsutilis, e.prenomsutilis, e.numtelutilis, e.emailutilis, e.codenreg, e.codecompte, e.nomcompte, e.logincompte, e.statutcompte from srutilisateur.exploitant e where e.codecompte = pcodecompte;
	end;
	$$;

create or replace function srutilisateur.obtentionexploitantenregistrement(pcodenreg public.identifiant)
	returns table(codeadmin public.identifiant, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodenreg is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('srutilisateur', 'enregistrement', 'codenreg', pcodenreg)),'Le code <'|| pcodenreg ||'> de l''enregistrement est inconnu.';
		
		return query select e.codexploit, e.codeutilis, e.nomsutilis, e.prenomsutilis, e.numtelutilis, e.emailutilis, e.codenreg, e.codecompte, e.nomcompte, e.logincompte, e.statutcompte from srutilisateur.exploitant e where e.codenreg = pcodenreg;
	end;
	$$;

create or replace function srutilisateur.recherchexploitant(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codexploit public.identifiant, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select e.codexploit, e.codeutilis, e.nomsutilis, e.prenomsutilis, e.numtelutilis, e.emailutilis, e.codenreg, e.codecompte, e.nomcompte, e.logincompte, e.statutcompte from srutilisateur.exploitant e where e.etat <> 3 order by e.ord desc limit plimit offset pdebut;
		else
			return query select e.codexploit, e.codeutilis, e.nomsutilis, e.prenomsutilis, e.numtelutilis, e.emailutilis, e.codenreg, e.codecompte, e.nomcompte, e.logincompte, e.statutcompte from srutilisateur.exploitant e where e.etat <> 3 and (e.nomsutilis ilike '%'|| pcritere ||'%' or e.prenomsutilis ilike '%'|| pcritere ||'%' or e.numtelutilis ilike '%'|| pcritere ||'%' or c.emailutilis ilike '%'|| pcritere ||'%') order by e.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== creation de la table administrateur
-- ==========================================================================================================================================
create table srutilisateur.administrateur(	
	codeadmin public.identifiant not null,
	codeutilis public.identifiant not null,
	nomsutilis public.libelle not null,
	prenomsutilis public.libelle null,
	numtelutilis public.numtel not null,
	emailutilis public.email not null,
	codenreg public.identifiant not null,	
	codecompte public.identifiant not null,
	nomcompte public.libelle null,
	logincompte public.nom not null,
	statutcompte public.etat not null,		
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srutilisateur.administrateur add constraint pkadministrateur primary key (codeadmin);
alter table srutilisateur.administrateur add constraint chkinvariantdatecreaupdaadministrateur check (datecrea <= dateupda);

create or replace procedure srutilisateur.ajouteradministrateur(pcode public.identifiant, pcodeutilis public.identifiant, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vcodeutilis public.identifiant;
		vnomsutilis public.libelle;
		vprenomsutilis public.libelle;
		vnumtelutilis public.numtel;
		vemailutilis public.email;
		vcodenreg public.identifiant;
		vcodecompte public.identifiant;
		vnomcompte public.libelle;
		vlogincompte public.nom;
		vstatutcompte public.etat;	
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code de l''administrateur est vide.';
		assert(not public.existencetuple('srutilisateur', 'administrateur', 'codeadmin', pcode)),'Le code <'|| pcode ||'> de l''administrateur est existant.';
		assert(pcodeutilis is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srutilisateur', 'utilisateur', 'codeutilis', pcodeutilis)),'Le code <'|| pcodeutilis ||'> de l''utilisateur est inconnu.';
		assert(petat = 1),'L''etat de l''administrateur est vide.';
		assert(pord > 0),'L''ordre de l''administrateur est vide.';
		assert(pdatecrea is not null),'La date de creation de l''administrateur est vide.';
	
		execute format('select nomsutilis, prenomsutilis, numtelutilis, emailutilis, codenreg, codecompte, nomcompte, logincompte, statutcompte from srutilisateur.utilisateur where codeutilis = $1')
		into vnomsutilis, vprenomsutilis, vnumtelutilis, vemailutilis, vcodenreg, vcodecompte, vnomcompte, vlogincompte, vstatutcompte
		using pcodeutilis;
		
		execute format('insert into srutilisateur.administrateur (codeadmin, codeutilis, nomsutilis, prenomsutilis, numtelutilis, emailutilis, codenreg, codecompte, nomcompte, logincompte, statutcompte, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)')
		using pcode, pcodeutilis, vnomsutilis, vprenomsutilis, vnumtelutilis, vemailutilis, vcodenreg, vcodecompte, vnomcompte, vlogincompte, vstatutcompte, petat, pord, pdatecrea;
	
		execute format('select codeutilis, etat, ord, datecrea from srutilisateur.administrateur where codeadmin = $1')
		into vcodeutilis, vetat, vord, vdatecrea
		using pcode;	
		assert(vcodeutilis = pcodeutilis),'Incoherence sur les donnees inserees. codeutilis';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace function srutilisateur.obtentionadministrateur(pcode public.identifiant)
	returns table(codeadmin public.identifiant, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code de l''administrateur est vide.';
		assert(public.existencetuple('srutilisateur', 'administrateur', 'codeadmin', pcode)),'Le code <'|| pcode ||'> de l''administrateur est inconnu.';
		
		return query select c.codeadmin, c.codeutilis, c.nomsutilis, c.prenomsutilis, c.numtelutilis, c.emailutilis, c.codenreg, c.codecompte, c.nomcompte, c.logincompte, c.statutcompte from srutilisateur.administrateur c where c.codeadmin = pcode;
	end;
	$$;

create or replace function srutilisateur.obtentionadministrateurutilisateur(pcodeutilis public.identifiant)
	returns table(codeadmin public.identifiant, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodeutilis is not null),'Le code de l''utilisateur est vide.';
		assert(public.existencetuple('srutilisateur', 'utilisateur', 'codeutilis', pcodeutilis)),'Le code <'|| pcodeutilis ||'> de l''utilisateur est inconnu.';
		
		return query select c.codeadmin, c.codeutilis, c.nomsutilis, c.prenomsutilis, c.numtelutilis, c.emailutilis, c.codenreg, c.codecompte, c.nomcompte, c.logincompte, c.statutcompte from srutilisateur.administrateur c where c.codeutilis = pcodeutilis;
	end;
	$$;

create or replace function srutilisateur.obtentionadministrateurcompte(pcodecompte public.identifiant)
	returns table(codeadmin public.identifiant, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodecompte is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		
		return query select c.codeadmin, c.codeutilis, c.nomsutilis, c.prenomsutilis, c.numtelutilis, c.emailutilis, c.codenreg, c.codecompte, c.nomcompte, c.logincompte, c.statutcompte from srutilisateur.administrateur c where c.codecompte = pcodecompte;
	end;
	$$;

create or replace function srutilisateur.obtentionadministrateurenregistrement(pcodenreg public.identifiant)
	returns table(codeadmin public.identifiant, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodenreg is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('srutilisateur', 'enregistrement', 'codenreg', pcodenreg)),'Le code <'|| pcodenreg ||'> de l''enregistrement est inconnu.';
		
		return query select c.codeadmin, c.codeutilis, c.nomsutilis, c.prenomsutilis, c.numtelutilis, c.emailutilis, c.codenreg, c.codecompte, c.nomcompte, c.logincompte, c.statutcompte from srutilisateur.administrateur c where c.codenreg = pcodenreg;
	end;
	$$;

create or replace function srutilisateur.rechercheadministrateur(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codeadmin public.identifiant, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select c.codeadmin, c.codeutilis, c.nomsutilis, c.prenomsutilis, c.numtelutilis, c.emailutilis, c.codenreg, c.codecompte, c.nomcompte, c.logincompte, c.statutcompte from srutilisateur.administrateur c where c.etat <> 3 order by c.ord desc limit plimit offset pdebut;
		else
			return query select c.codeadmin, c.codeutilis, c.nomsutilis, c.prenomsutilis, c.numtelutilis, c.emailutilis, c.codenreg, c.codecompte, c.nomcompte, c.logincompte, c.statutcompte from srutilisateur.administrateur c where c.etat <> 3 and (c.nomsutilis ilike '%'|| pcritere ||'%' or c.prenomsutilis ilike '%'|| pcritere ||'%' or c.numtelutilis ilike '%'|| pcritere ||'%' or c.emailutilis ilike '%'|| pcritere ||'%') order by c.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== Creation de la table resposervey
-- ==========================================================================================================================================
create table srutilisateur.resposervey(	
	coderesposerv public.identifiant not null,
	pinresposervey public.codepin not null,
	codeutilis public.identifiant not null,
	nomsutilis public.libelle not null,
	prenomsutilis public.libelle null,
	numtelutilis public.numtel not null,
	emailutilis public.email not null,
	codenreg public.identifiant not null,	
	codecompte public.identifiant not null,
	nomcompte public.libelle null,
	logincompte public.nom not null,
	statutcompte public.etat not null,		
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srutilisateur.resposervey add constraint pkresposervey primary key (coderesposerv);
alter table srutilisateur.resposervey add constraint chkinvariantdatecreaupdaresposervey check (datecrea <= dateupda);

create or replace procedure srutilisateur.ajouteresposervey(pcode public.identifiant, ppin public.codepin, pcodeutilis public.identifiant, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vpin public.codepin;
		vcodeutilis public.identifiant;
		vnomsutilis public.libelle;
		vprenomsutilis public.libelle;
		vnumtelutilis public.numtel;
		vemailutilis public.email;
		vcodenreg public.identifiant;
		vcodecompte public.identifiant;
		vnomcompte public.libelle;
		vlogincompte public.nom;
		vstatutcompte public.etat;	
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code du responsable servey est vide.';
		assert(not public.existencetuple('srutilisateur', 'resposervey', 'coderesposerv', pcode)),'Le code <'|| pcode ||'> du responsable servey est existant.';
		assert(ppin is not null),'Le pin du responsable servey est vide.';
		assert(pcodeutilis is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srutilisateur', 'utilisateur', 'codeutilis', pcodeutilis)),'Le code <'|| pcodeutilis ||'> de l''utilisateur est inconnu.';
		assert(petat = 1),'L''etat du responsable servey est vide.';
		assert(pord > 0),'L''ordre du responsable servey est vide.';
		assert(pdatecrea is not null),'La date de creation du responsable servey est vide.';
	
		execute format('select nomsutilis, prenomsutilis, numtelutilis, emailutilis, codenreg, codecompte, nomcompte, logincompte, statutcompte from srutilisateur.utilisateur where codeutilis = $1')
		into vnomsutilis, vprenomsutilis, vnumtelutilis, vemailutilis, vcodenreg, vcodecompte, vnomcompte, vlogincompte, vstatutcompte
		using pcodeutilis;
		
		execute format('insert into srutilisateur.resposervey (coderesposerv, pinresposervey, codeutilis, nomsutilis, prenomsutilis, numtelutilis, emailutilis, codenreg, codecompte, nomcompte, logincompte, statutcompte, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)')
		using pcode, ppin, pcodeutilis, vnomsutilis, vprenomsutilis, vnumtelutilis, vemailutilis, vcodenreg, vcodecompte, vnomcompte, vlogincompte, vstatutcompte, petat, pord, pdatecrea;
	
		execute format('select pinresposervey, codeutilis, etat, ord, datecrea from srutilisateur.resposervey where coderesposerv = $1')
		into vpin, vcodeutilis, vetat, vord, vdatecrea
		using pcode;	
		assert(vpin = ppin),'Incoherence sur les donnees inserees. pinresposervey';
		assert(vcodeutilis = pcodeutilis),'Incoherence sur les donnees inserees. codeutilis';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace function srutilisateur.obtentionresposervey(pcode public.identifiant)
	returns table(coderesposerv public.identifiant, pinresposervey public.codepin, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat, typeutilis public.typeutilisateur)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code du responsable servey est vide.';
		assert(public.existencetuple('srutilisateur', 'resposervey', 'coderesposerv', pcode)),'Le code <'|| pcode ||'> du responsable servey est inconnu.';
		
		return query select r.coderesposerv, r.pinresposervey, r.codeutilis, r.nomsutilis, r.prenomsutilis, r.numtelutilis, r.emailutilis, r.codenreg, r.codecompte, r.nomcompte, r.logincompte, r.statutcompte, u.typeutilis  
						from srutilisateur.resposervey r 
							inner join srutilisateur.utilisateur u on(u.codenreg = r.codenreg)
						where r.coderesposerv = pcode;
	end;
	$$;

create or replace function srutilisateur.obtentionresposerveyutilisateur(pcodeutilis public.identifiant)
	returns table(coderesposerv public.identifiant, pinresposervey public.codepin, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodeutilis is not null),'Le code de l''utilisateur est vide.';
		assert(public.existencetuple('srutilisateur', 'utilisateur', 'codeutilis', pcodeutilis)),'Le code <'|| pcodeutilis ||'> de l''utilisateur est inconnu.';
		
		return query select r.coderesposerv, r.pinresposervey, r.codeutilis, r.nomsutilis, r.prenomsutilis, r.numtelutilis, r.emailutilis, r.codenreg, r.codecompte, r.nomcompte, r.logincompte, r.statutcompte from srutilisateur.resposervey r where r.codeutilis = pcodeutilis;
	end;
	$$;

create or replace function srutilisateur.obtentionresposerveycompte(pcodecompte public.identifiant)
	returns table(coderesposerv public.identifiant, pinresposervey public.codepin, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodecompte is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		
		return query select r.coderesposerv, r.pinresposervey, r.codeutilis, r.nomsutilis, r.prenomsutilis, r.numtelutilis, r.emailutilis, r.codenreg, r.codecompte, r.nomcompte, r.logincompte, r.statutcompte from srutilisateur.resposervey r where r.codecompte = pcodecompte;
	end;
	$$;

create or replace function srutilisateur.obtentionresposerveyenregistrement(pcodenreg public.identifiant)
	returns table(coderesposerv public.identifiant, pinresposervey public.codepin, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodenreg is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('srutilisateur', 'enregistrement', 'codenreg', pcodenreg)),'Le code <'|| pcodenreg ||'> de l''enregistrement est inconnu.';
		
		return query select r.coderesposerv, r.pinresposervey, r.codeutilis, r.nomsutilis, r.prenomsutilis, r.numtelutilis, r.emailutilis, r.codenreg, r.codecompte, r.nomcompte, r.logincompte, r.statutcompte from srutilisateur.resposervey r where r.codenreg = pcodenreg;
	end;
	$$;

create or replace function srutilisateur.rechercheresposervey(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(coderesposerv public.identifiant, pinresposervey public.codepin, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select r.coderesposerv, r.pinresposervey, r.codeutilis, r.nomsutilis, r.prenomsutilis, r.numtelutilis, r.emailutilis, r.codenreg, r.codecompte, r.nomcompte, r.logincompte, r.statutcompte 
							from srutilisateur.resposervey r 
								inner join srutilisateur.enregistrement e on (e.codenreg = r.codenreg and e.typeutilis = 'resposervey')
							where r.etat <> 3 
							order by r.ord desc 
							limit plimit offset pdebut;
		else
			return query select r.coderesposerv, cr.pinresposervey, r.codeutilis, r.nomsutilis, r.prenomsutilis, r.numtelutilis, r.emailutilis, r.codenreg, r.codecompte, r.nomcompte, r.logincompte, r.statutcompte 
							from srutilisateur.resposervey r 
								inner join srutilisateur.enregistrement e on (e.codenreg = c.codenreg and e.typeutilis = 'resposervey')
							where r.etat <> 3 and (r.nomsutilis ilike '%'|| pcritere ||'%' or r.prenomsutilis ilike '%'|| pcritere ||'%' or r.numtelutilis ilike '%'|| pcritere ||'%' or r.emailutilis ilike '%'|| pcritere ||'%') 
							order by r.ord desc 
							limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== Creation de la table responsable
-- ==========================================================================================================================================
create table srutilisateur.responsable(	
	coderespo public.identifiant not null,
	pinrespo public.codepin not null,
	codeutilis public.identifiant not null,
	nomsutilis public.libelle not null,
	prenomsutilis public.libelle null,
	numtelutilis public.numtel not null,
	emailutilis public.email not null,
	codenreg public.identifiant not null,	
	codecompte public.identifiant not null,
	nomcompte public.libelle null,
	logincompte public.nom not null,
	statutcompte public.etat not null,		
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srutilisateur.responsable add constraint pkresponsable primary key (coderespo);
alter table srutilisateur.responsable add constraint chkinvariantdatecreaupdaresponsable check (datecrea <= dateupda);

create or replace procedure srutilisateur.ajouterresponsable(pcode public.identifiant, ppin public.codepin, pcodeutilis public.identifiant, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vpin public.codepin;
		vcodeutilis public.identifiant;
		vnomsutilis public.libelle;
		vprenomsutilis public.libelle;
		vnumtelutilis public.numtel;
		vemailutilis public.email;
		vcodenreg public.identifiant;
		vcodecompte public.identifiant;
		vnomcompte public.libelle;
		vlogincompte public.nom;
		vstatutcompte public.etat;	
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code du responsable est vide.';
		assert(not public.existencetuple('srutilisateur', 'responsable', 'coderespo', pcode)),'Le code <'|| pcode ||'> du responsable est existant.';
		assert(ppin is not null),'Le pin du responsable est vide.';
		assert(pcodeutilis is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srutilisateur', 'utilisateur', 'codeutilis', pcodeutilis)),'Le code <'|| pcodeutilis ||'> de l''utilisateur est inconnu.';
		assert(petat = 1),'L''etat du responsable est vide.';
		assert(pord > 0),'L''ordre du responsable est vide.';
		assert(pdatecrea is not null),'La date de creation du responsable est vide.';
	
		execute format('select nomsutilis, prenomsutilis, numtelutilis, emailutilis, codenreg, codecompte, nomcompte, logincompte, statutcompte from srutilisateur.utilisateur where codeutilis = $1')
		into vnomsutilis, vprenomsutilis, vnumtelutilis, vemailutilis, vcodenreg, vcodecompte, vnomcompte, vlogincompte, vstatutcompte
		using pcodeutilis;
		
		execute format('insert into srutilisateur.responsable (coderespo, pinrespo, codeutilis, nomsutilis, prenomsutilis, numtelutilis, emailutilis, codenreg, codecompte, nomcompte, logincompte, statutcompte, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)')
		using pcode, ppin, pcodeutilis, vnomsutilis, vprenomsutilis, vnumtelutilis, vemailutilis, vcodenreg, vcodecompte, vnomcompte, vlogincompte, vstatutcompte, petat, pord, pdatecrea;
	
		execute format('select pinrespo, codeutilis, etat, ord, datecrea from srutilisateur.responsable where coderespo = $1')
		into vpin, vcodeutilis, vetat, vord, vdatecrea
		using pcode;	
		assert(vpin = ppin),'Incoherence sur les donnees inserees. pinrespo';
		assert(vcodeutilis = pcodeutilis),'Incoherence sur les donnees inserees. codeutilis';
		assert(vetat = petat),'Incoherence sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace function srutilisateur.obtentionresponsable(pcode public.identifiant)
	returns table(coderespo public.identifiant, pinrespo public.codepin, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat, typeutilis public.typeutilisateur)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcode is not null),'Le code du responsable est vide.';
		assert(public.existencetuple('srutilisateur', 'responsable', 'coderespo', pcode)),'Le code <'|| pcode ||'> du responsable est inconnu.';
		
		return query select r.coderespo, r.pinrespo, r.codeutilis, r.nomsutilis, r.prenomsutilis, r.numtelutilis, r.emailutilis, r.codenreg, r.codecompte, r.nomcompte, r.logincompte, r.statutcompte, u.typeutilis  
						from srutilisateur.responsable r 
							inner join srutilisateur.utilisateur u on(u.codenreg = r.codenreg)
						where r.coderespo = pcode;
	end;
	$$;

create or replace function srutilisateur.obtentionresponsableutilisateur(pcodeutilis public.identifiant)
	returns table(coderespo public.identifiant, pinrespo public.codepin, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodeutilis is not null),'Le code de l''utilisateur est vide.';
		assert(public.existencetuple('srutilisateur', 'utilisateur', 'codeutilis', pcodeutilis)),'Le code <'|| pcodeutilis ||'> de l''utilisateur est inconnu.';
		
		return query select r.coderespo, r.pinrespo, r.codeutilis, r.nomsutilis, r.prenomsutilis, r.numtelutilis, r.emailutilis, r.codenreg, r.codecompte, r.nomcompte, r.logincompte, r.statutcompte from srutilisateur.responsable r where r.codeutilis = pcodeutilis;
	end;
	$$;

create or replace function srutilisateur.obtentionresponsablecompte(pcodecompte public.identifiant)
	returns table(coderespo public.identifiant, pinrespo public.codepin, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodecompte is not null),'Le code du compte est vide.';
		assert(public.existencetuple('srsecurite', 'compte', 'codecompte', pcodecompte)),'Le code <'|| pcodecompte ||'> du compte est inconnu.';
		
		return query select r.coderespo, r.pinrespo, r.codeutilis, r.nomsutilis, r.prenomsutilis, r.numtelutilis, r.emailutilis, r.codenreg, r.codecompte, r.nomcompte, r.logincompte, r.statutcompte from srutilisateur.responsable r where r.codecompte = pcodecompte;
	end;
	$$;

create or replace function srutilisateur.obtentionresponsableenregistrement(pcodenreg public.identifiant)
	returns table(coderespo public.identifiant, pinrespo public.codepin, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodenreg is not null),'Le code de l''enregistrement est vide.';
		assert(public.existencetuple('srutilisateur', 'enregistrement', 'codenreg', pcodenreg)),'Le code <'|| pcodenreg ||'> de l''enregistrement est inconnu.';
		
		return query select r.coderespo, r.pinrespo, r.codeutilis, r.nomsutilis, r.prenomsutilis, r.numtelutilis, r.emailutilis, r.codenreg, r.codecompte, r.nomcompte, r.logincompte, r.statutcompte from srutilisateur.responsable r where r.codenreg = pcodenreg;
	end;
	$$;

create or replace function srutilisateur.rechercheresponsable(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(coderespo public.identifiant, pinrespo public.codepin, codeutilis public.identifiant, nomsutilis public.libelle, prenomsutilis public.libelle, numtelutilis public.numtel, emailutilis public.email, codenreg public.identifiant, codecompte public.identifiant, nomcompte public.libelle, logincompte public.nom, statutcompte public.etat)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select r.coderespo, r.pinrespo, r.codeutilis, r.nomsutilis, r.prenomsutilis, r.numtelutilis, r.emailutilis, r.codenreg, r.codecompte, r.nomcompte, r.logincompte, r.statutcompte 
							from srutilisateur.responsable r 
								inner join srutilisateur.enregistrement e on (e.codenreg = r.codenreg and e.typeutilis = 'responsable')
							where r.etat <> 3 
							order by r.ord desc 
							limit plimit offset pdebut;
		else
			return query select r.coderespo, cr.pinrespo, r.codeutilis, r.nomsutilis, r.prenomsutilis, r.numtelutilis, r.emailutilis, r.codenreg, r.codecompte, r.nomcompte, r.logincompte, r.statutcompte 
							from srutilisateur.responsable r 
								inner join srutilisateur.enregistrement e on (e.codenreg = c.codenreg and e.typeutilis = 'responsable')
							where r.etat <> 3 and (r.nomsutilis ilike '%'|| pcritere ||'%' or r.prenomsutilis ilike '%'|| pcritere ||'%' or r.numtelutilis ilike '%'|| pcritere ||'%' or r.emailutilis ilike '%'|| pcritere ||'%') 
							order by r.ord desc 
							limit plimit offset pdebut;
		end if;
	
	end;
	$$;
	
-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== Creation du schema cudservey
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create schema cudservey;
alter schema cudservey owner to akamcuddbservey;

-- ======== creation de la table wifi
-- ==========================================================================================================================================
create table cudservey.wifi(
	codewifi public.identifiant not null,
	nomwifi public.libelle not null,
	frequence public.nom not null,
	canal public.nom not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudservey.wifi add constraint pkwifi primary key (codewifi);
alter table cudservey.wifi add constraint chkinvariantcardetatwifi check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudservey.wifi add constraint chkinvariantdatecreaupdawifi check (datecrea <= dateupda);

create or replace function cudservey.creationwifi(pnomwifi public.libelle, pfrequence public.nom, pcanal public.nom)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vnomwifi public.libelle;
		vfrequence public.nom;
		vcanal public.nom;
	begin 
		
		assert(pnomwifi is not null),'Le nom du wifi est vide.';
		assert(pfrequence is not null),'La frequence du wifi est vide.';
		assert(pcanal is not null),'Le canal du wifi est vide.';
	
		vcode = cudincrement.generationidentifiant('wifi');
		vordmax = public.obtentionordremax('cudservey', 'wifi', 'ord');
		execute format('insert into cudservey.wifi (codewifi, nomwifi, frequence, canal, ord) values ($1, $2, $3, $4, $5)')
		using vcode, pnomwifi, pfrequence, pcanal, vordmax;
	
		execute format('select nomwifi, frequence, canal from cudservey.wifi where codewifi = $1')
		into vnomwifi, vfrequence, vcanal 
		using vcode;	
		assert(vnomwifi = pnomwifi),'Incoherence 1 sur les donnees inserees. nomwifi';
		assert(vfrequence = pfrequence),'Incoherence 1 sur les donnees inserees. frequence';
		assert(vcanal = pcanal),'Incoherence 1 sur les donnees inserees. canal';		
		
		return vcode;
	end;
	$$;

create or replace function cudservey.aftercreationwifi()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		call srservey.ajouterwifi(new.codewifi, new.nomwifi, new.frequence, new.canal, new.etat, new.ord, new.datecrea);
	
		return null;
	end;
	$$;	

create trigger ajoutwifi after insert on cudservey.wifi for each row execute function cudservey.aftercreationwifi();

create or replace procedure cudservey.modifierwifi(pcode public.identifiant, pnomwifi public.libelle, pfrequence public.nom, pcanal public.nom)
	language plpgsql
	as $$
	declare
		vnomwifi public.libelle;
		vfrequence public.nom;
		vcanal public.nom;
	begin 
		
		assert(pcode is not null),'Le code du wifi est vide.';
		assert(public.existencetuple('cudservey', 'wifi', 'codewifi', pcode)),'Le code <'|| pcode ||'> du wifi est inconnu.';
		assert(pnomwifi is not null),'Le nom du wifi est vide.';
		assert(pfrequence is not null),'La frequence du wifi est vide.';
		assert(pcanal is not null),'Le canal du wifi est vide.';
		
		execute format('update cudservey.wifi set nomwifi = $1, frequence = $2, canal = $3, dateupda = current_timestamp where codewifi = $4')
		using padresse, pcode;
	
		execute format('select nomwifi, frequence, canal from cudservey.wifi where codewifi = $1')
		into vnomwifi, vfrequence, vcanal
		using pcode;	
		assert(vnomwifi = pnomwifi),'Incoherence 1 sur les donnees inserees. nomwifi';
		assert(vfrequence = pfrequence),'Incoherence 1 sur les donnees inserees. frequence';
		assert(vcanal = pcanal),'Incoherence 1 sur les donnees inserees. canal';
		
	end;
	$$;

create or replace procedure cudservey.supprimerwifi(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudservey', 'wifi', 'codewifi', pcode)),'Le code <'|| pcode ||'> du wifi est inconnu.';	
		
		call public.supprimer('cudservey', 'wifi', 'codewifi', pcode);
	
		assert(not public.existencetuple('cudservey', 'wifi', 'codewifi', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudservey.aftermiseajourwifi()
	returns trigger 
	language plpgsql
	as $$
	begin 
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srservey', 'wifi', 'codewifi', old.codewifi, new.etat, new.dateupda);
		else
			call public.mettreajourwifi(old.codewifi, new.nomwifi, new.frequence, new.canal, new.dateupda);
		end if;
		return null;
	end;
	$$;	

create trigger miseajourwifi after update on cudservey.wifi for each row execute function cudservey.aftermiseajourwifi();

create or replace function cudservey.aftersuppressionwifi()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		return null;
	
	end;
	$$;	

create trigger suppressionwifi after delete on cudservey.wifi for each row execute function cudservey.aftersuppressionwifi();

-- ======== creation de la table photo
-- ==========================================================================================================================================
create table cudservey.photo(
	codephoto public.identifiant not null,
	descrphoto public.libelle not null,
	codefic public.identifiant not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudservey.photo add constraint pkphoto primary key (codephoto);
alter table cudservey.photo add constraint chkinvariantcardetatphoto check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudservey.photo add constraint chkinvariantdatecreaupdaphoto check (datecrea <= dateupda);
alter table cudservey.photo add constraint fkfichierphoto foreign key (codefic) references cudfichier.fichier(codefic) on delete restrict;

create or replace function cudservey.creationphoto(pcodesite public.identifiant, pdescrphoto public.libelle, pnomfic public.nom, pmime public.nom, ptaille numeric, pconten bytea)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vdescrphoto public.libelle;
		pcodefic public.identifiant;
		vcodefic public.identifiant;
	begin 
		
		assert(pcodesite is not null),'Le code du site est vide.';
		assert(public.existencetuple('cudservey', 'site', 'codesite', pcodesite)),'Le code <'|| pcodesite ||'> du site est inconnu.';
		assert(pdescrphoto is not null),'La description de la photo est vide.';
		assert(pnomfic is not null),'Le nom du fichier est vide.';
		assert(pmime is not null),'Le mime du fichier est vide.';
		assert(ptaille is not null),'La taille du fichier est vide.';
		assert(pconten is not null),'Le contenu du fichier est vide.';
	
		vcode = cudincrement.generationidentifiant('photo');
		vordmax := public.obtentionordremax('cudservey', 'photo', 'ord');
		pcodefic := cudfichier.creationfichier(pnomfic, pmime, ptaille, pconten);
		execute format('insert into cudservey.photo (codephoto, descrphoto, codefic, ord) values ($1, $2, $3, $4)')
		using vcode, pdescrphoto, pcodefic, vordmax;
	
		execute format('select descrphoto, codefic from cudservey.photo where codephoto = $1')
		into vdescrphoto, vcodefic 
		using vcode;	
		assert(vdescrphoto = pdescrphoto),'Incoherence 1 sur les donnees inserees. descrphoto';
		assert(vcodefic = pcodefic),'Incoherence 1 sur les donnees inserees. codefic';	
	
		call cudservey.creerphotosite(pcodesite, vcode);		
		return vcode;
	end;
	$$;

create or replace function cudservey.aftercreationphoto()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		call srservey.ajouterphoto(new.codephoto, new.descrphoto, new.codefic, new.etat, new.ord, new.datecrea);
		call public.attacher('cudfichier', 'fichier', 'codefic', new.codefic);
		return null;
	end;
	$$;	

create trigger ajoutphoto after insert on cudservey.photo for each row execute function cudservey.aftercreationphoto();

create or replace procedure cudservey.modifierphoto(pcode public.identifiant, pdescrphoto public.libelle)
	language plpgsql
	as $$
	declare
		vdescrphoto public.libelle;
	begin 
		
		assert(pcode is not null),'Le code de la photo est vide.';
		assert(public.existencetuple('cudservey', 'photo', 'codephoto', pcode)),'Le code <'|| pcode ||'> de la photo est inconnu.';
		assert(pdescrphoto is not null),'La description de la photo est vide.';
		
		execute format('update cudservey.photo set descrphoto = $1, dateupda = current_timestamp where codephoto = $2')
		using pdescrphoto, pcode;
	
		execute format('select descrphoto from cudservey.photo where codephoto = $1')
		into vdescrphoto
		using pcode;	
		assert(vdescrphoto = pdescrphoto),'Incoherence 1 sur les donnees inserees. descrphoto';
		
	end;
	$$;

create or replace procedure cudservey.modifierfichierphoto(pcode public.identifiant, pnomfic public.nom, pmime public.nom, ptaille numeric, pconten bytea)
	language plpgsql
	as $$
	declare
		pcodefic public.identifiant;
	begin 
		
		assert(pcode is not null),'Le code de la photo est vide.';
		assert(public.existencetuple('cudservey', 'photo', 'codephoto', pcode)),'Le code <'|| pcode ||'> de la photo est inconnu.';
		assert(pnomfic is not null),'Le nom du fichier est vide.';
		assert(pmime is not null),'Le mime du fichier est vide.';
		assert(ptaille is not null),'La taille du fichier est vide.';
		assert(pconten is not null),'Le contenu du fichier est vide.';
	
		execute format('select codefic from cudservey.photo where codephoto = $1')
		into pcodefic
		using pcode;
		call cudfichier.modifierfichier(pcodefic, pnomfic, pmime, ptaille, pconten);
		execute format('update cudservey.photo set dateupda = current_timestamp where codephoto = $1')
		using pcode;
		
	end;
	$$;

create or replace procedure cudservey.supprimerphoto(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudservey', 'photo', 'codephoto', pcode)),'Le code <'|| pcode ||'> de la photo est inconnu.';	
		
		call cudservey.supprimerphotosite(pcode);
		call public.supprimer('cudservey', 'photo', 'codephoto', pcode);
	
		assert(not public.existencetuple('cudservey', 'photo', 'codephoto', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudservey.aftermiseajourphoto()
	returns trigger 
	language plpgsql
	as $$
	begin 
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srservey', 'photo', 'codephoto', old.codephoto, new.etat, new.dateupda);
		end if;
		if (old.descrphoto != new.descrphoto) then
			call srservey.mettreajourphoto(old.codephoto, new.descrphoto, new.dateupda);
		end if;
		return null;
	end;
	$$;	

create trigger miseajourphoto after update on cudservey.photo for each row execute function cudservey.aftermiseajourphoto();

create or replace function cudservey.aftersuppressionphoto()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call public.detacher('cudfichier', 'fichier', 'codefic', old.codefic); 
		call public.supprimer('cudfichier', 'fichier', 'codefic', old.codefic);
		return null;
	
	end;
	$$;	

create trigger suppressionphoto after delete on cudservey.photo for each row execute function cudservey.aftersuppressionphoto();

-- ======== creation de la table site
-- ==========================================================================================================================================
create table cudservey.site(
	codesite public.identifiant not null,
	nomsite public.libelle not null,
	immeuble boolean not null,
	hauteur numeric null,
	dalle boolean null,
	descrdalle public.libelle null,
	sourcelectrique boolean not null,
	priseterre boolean not null,
	operateurs boolean not null,
	longitude numeric(25,20) not null,
	latitude numeric(25,20) not null,
	adresse public.libelle null,
	descrenviron public.libelle null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudservey.site add constraint pksite primary key (codesite);
alter table cudservey.site add constraint chkinvariantcardetatsite check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudservey.site add constraint chkinvariantdatecreaupdasite check (datecrea <= dateupda);

create or replace function cudservey.creationsite(pnomsite public.libelle, pimmeuble boolean, phauteur numeric, pdalle boolean, pdescrdalle public.libelle, psourcelectrique boolean, ppriseterre boolean, poperateurs boolean, pcodesoperateurs public.identifiant[], plongitude numeric(25,20), platitude numeric(25,20), padresse public.libelle, pdescrenviron public.libelle)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vnomsite public.libelle;
		vimmeuble boolean;
		vhauteur numeric;
		vdalle boolean;
		vdescrdalle public.libelle;
		vsourcelectrique boolean;
		vpriseterre boolean;
		voperateurs boolean;
		vcodeoperateur public.identifiant;
		vlongitude numeric(25,20);
		vlatitude numeric(25,20);
		vadresse public.libelle;
		vdescrenviron public.libelle;
	begin 
		
		assert(pnomsite is not null),'Le nom du site est vide.';
		assert(pimmeuble is not null),'L''attribut immeuble est vide.';
		if (pimmeuble) then
			assert(phauteur is not null),'La hauteur de l''immeuble est vide.';
			assert(pdalle is not null),'L''attribut dalles est vide.';
		end if;		
		if (pdalle) then
			assert(pdescrdalle is not null),'La description des dalles est vide.';
		end if;
		assert(psourcelectrique is not null),'L''attribut source electrique est vide.';
		assert(ppriseterre is not null),'L''attribut prise terre est vide.';
		assert(poperateurs is not null),'L''attribut operateur de telecom est vide.';
		if (poperateurs) then
			assert(pcodesoperateurs is not null),'Les identifiants des operateurs de telecom sont vides.';
			if (pcodesoperateurs is not null) then
				foreach vcodeoperateur in array pcodesoperateurs
				loop
					assert(vcodeoperateur is not null),'Le code de l''operateur de telecom est vide.';
					assert(public.existencetuple('cuddomaine', 'nomenclature', 'codenomen', vcodeoperateur)),'Le code <'|| vcodeoperateur ||'> de l''operateur de telecom est inconnu.';
				end loop;
			end if;
		end if;
		assert(plongitude is not null),'La longitude des coordonnees GPS est vide.';
		assert(platitude is not null),'La latitude des coordonnees GPS est vide.';
	
		vcode := cudincrement.generationidentifiant('site');
		vordmax := public.obtentionordremax('cudservey', 'site', 'ord');		
		execute format('insert into cudservey.site (codesite, nomsite, immeuble, hauteur, dalle, descrdalle, sourcelectrique, priseterre, operateurs, longitude, latitude, adresse, descrenviron, ord) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)')
		using vcode, pnomsite, pimmeuble, phauteur, pdalle, pdescrdalle, psourcelectrique, ppriseterre, poperateurs, plongitude, platitude, padresse, pdescrenviron, vordmax;
		
		execute format('select nomsite, immeuble, hauteur, dalle, descrdalle, sourcelectrique, priseterre, operateurs, longitude, latitude, adresse, descrenviron from cudservey.site where codesite = $1')
		into vnomsite, vimmeuble, vhauteur, vdalle, vdescrdalle, vsourcelectrique, vpriseterre, voperateurs, vlongitude, vlatitude, vadresse, vdescrenviron 
		using vcode;	
		assert(vnomsite = pnomsite),'Incoherence 1 sur les donnees inserees. nomsite';
		assert(vimmeuble = pimmeuble),'Incoherence 1 sur les donnees inserees. immeuble';
		assert((vhauteur is null) or (vhauteur = phauteur)),'Incoherence 1 sur les donnees inserees. hauteur';
		assert((vdalle is null) or (vdalle = pdalle)),'Incoherence 1 sur les donnees inserees. dalle';
		assert((vdescrdalle is null) or (vdescrdalle = pdescrdalle)),'Incoherence 1 sur les donnees inserees. descrdalle';
		assert(vsourcelectrique = psourcelectrique),'Incoherence 1 sur les donnees inserees. sourcelectrique';
		assert(vpriseterre = ppriseterre),'Incoherence 1 sur les donnees inserees. priseterre';
		assert(voperateurs = poperateurs),'Incoherence 1 sur les donnees inserees. operateurs';
		assert(vlongitude = plongitude),'Incoherence 1 sur les donnees inserees. longitude';
		assert(vlatitude = platitude),'Incoherence 1 sur les donnees inserees. latitude';
		assert((vadresse is null) or (vadresse = padresse)),'Incoherence 1 sur les donnees inserees. adresse';
		assert((vdescrenviron is null) or (vdescrenviron = pdescrenviron)),'Incoherence 1 sur les donnees inserees. descrenviron';
		
		if (pcodesoperateurs is not null) then
			call cudservey.mettreajouroperateursite(vcode, pcodesoperateurs);
		end if;
	
		return vcode;
	end;
	$$;

create or replace function cudservey.aftercreationsite()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		call srservey.ajoutersite(new.codesite, new.nomsite, new.immeuble, new.hauteur, new.dalle, new.descrdalle, new.sourcelectrique, new.priseterre, new.operateurs, new.longitude, new.latitude, new.adresse, new.descrenviron, new.etat, new.ord, new.datecrea);
		return null;
	end;
	$$;	

create trigger ajoutsite after insert on cudservey.site for each row execute function cudservey.aftercreationsite();

create or replace procedure cudservey.modifiersite(pcode public.identifiant, pnomsite public.libelle, pimmeuble boolean, phauteur numeric, pdalle boolean, pdescrdalle public.libelle, psourcelectrique boolean, ppriseterre boolean, poperateurs boolean, pcodesoperateurs public.identifiant[], plongitude numeric(25,20), platitude numeric(25,20), padresse public.libelle, pdescrenviron public.libelle)
	language plpgsql
	as $$
	declare
		vnomsite public.libelle;
		vimmeuble boolean;
		vhauteur numeric;
		vdalle boolean;
		vdescrdalle public.libelle;
		vsourcelectrique boolean;
		vpriseterre boolean;
		voperateurs boolean;
		vcodeoperateur public.identifiant;
		vlongitude numeric(25,20);
		vlatitude numeric(25,20);
		vadresse public.libelle;
		vdescrenviron public.libelle;
	begin 
		
		assert(pcode is not null),'Le code du site est vide.';
		assert(public.existencetuple('cudservey', 'site', 'codesite', pcode)),'Le code <'|| pcode ||'> du site est inconnu.';
		assert(pnomsite is not null),'Le nom du site est vide.';
		assert(pimmeuble is not null),'L''attribut immeuble est vide.';
		if (pimmeuble) then
			assert(phauteur is not null),'La hauteur de l''immeuble est vide.';
			assert(pdalle is not null),'L''attribut dalles est vide.';
		end if;		
		if (pdalle) then
			assert(pdescrdalle is not null),'La description des dalles est vide.';
		end if;
		assert(psourcelectrique is not null),'L''attribut source electrique est vide.';
		assert(ppriseterre is not null),'L''attribut prise terre est vide.';
		assert(poperateurs is not null),'L''attribut operateur de telecom est vide.';
		if (poperateurs) then
			foreach vcodeoperateur in array pcodesoperateurs
			loop
				assert(vcodeoperateur is not null),'Le code de l''operateur de telecom est vide.';
				assert(public.existencetuple('cuddomaine', 'nomenclature', 'codenomen', vcodeoperateur)),'Le code <'|| vcodeoperateur ||'> de l''operateur de telecom est inconnu.';
			end loop;
		end if;
		assert(plongitude is not null),'La longitude des coordonnees GPS est vide.';
		assert(platitude is not null),'La latitude des coordonnees GPS est vide.';
		
		execute format('update cudservey.site set nomsite = $1, immeuble = $2, hauteur = $3, dalle = $4, descrdalle = $5, sourcelectrique = $6, priseterre = $7, operateurs = $8, longitude = $9, latitude = $10, adresse = $11, descrenviron = $12, dateupda = current_timestamp where codesite = $13')
		using pnomsite, pimmeuble, phauteur, pdalle, pdescrdalle, psourcelectrique, ppriseterre, poperateurs, plongitude, platitude, padresse, pdescrenviron, pcode;
	
		execute format('select nomsite, immeuble, hauteur, dalle, descrdalle, sourcelectrique, priseterre, operateurs, longitude, latitude, adresse, descrenviron from cudservey.site where codesite = $1')
		into vnomsite, vimmeuble, vhauteur, vdalle, vdescrdalle, vsourcelectrique, vpriseterre, voperateurs, vlongitude, vlatitude, vadresse, vdescrenviron 
		using pcode;	
		assert(vnomsite = pnomsite),'Incoherence 1 sur les donnees mises a jour. nomsite';
		assert(vimmeuble = pimmeuble),'Incoherence 1 sur les donnees mises a jour. immeuble';
		assert((vhauteur is null) or (vhauteur = phauteur)),'Incoherence 1 sur les donnees mises a jour. hauteur';
		assert((vdalle is null) or (vdalle = pdalle)),'Incoherence 1 sur les donnees mises a jour. dalle';
		assert((vdescrdalle is null) or (vdescrdalle = pdescrdalle)),'Incoherence 1 sur les donnees mises a jour. descrdalle';
		assert(vsourcelectrique = psourcelectrique),'Incoherence 1 sur les donnees mises a jour. sourcelectrique';
		assert(vpriseterre = ppriseterre),'Incoherence 1 sur les donnees mises a jour. priseterre';
		assert(voperateurs = poperateurs),'Incoherence 1 sur les donnees mises a jour. operateurs';
		assert(vlongitude = plongitude),'Incoherence 1 sur les donnees mises a jour. longitude';
		assert(vlatitude = platitude),'Incoherence 1 sur les donnees mises a jour. latitude';
		assert((vadresse is null) or (vadresse = padresse)),'Incoherence 1 sur les donnees mises a jour. adresse';
		assert((vdescrenviron is null) or (vdescrenviron = pdescrenviron)),'Incoherence 1 sur les donnees mises a jour. descrenviron';
		
		if (pcodesoperateurs is not null) then
			call cudservey.mettreajouroperateursite(pcode, pcodesoperateurs);
		end if;
		
	end;
	$$;

create or replace procedure cudservey.supprimersite(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudservey', 'site', 'codesite', pcode)),'Le code <'|| pcode ||'> du site est inconnu.';	
		
		call public.supprimer('cudservey', 'site', 'codesite', pcode);
	
		assert(not public.existencetuple('cudservey', 'site', 'codesite', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudservey.aftermiseajoursite()
	returns trigger 
	language plpgsql
	as $$
	begin 
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srservey', 'site', 'codesite', old.codesite, new.etat, new.dateupda);
		else
			call srservey.mettreajoursite(old.codesite, new.nomsite, new.immeuble, new.hauteur, new.dalle, new.descrdalle, new.sourcelectrique, new.priseterre, new.operateurs, new.longitude, new.latitude, new.adresse, new.descrenviron, new.dateupda);
		end if;
		return null;
	end;
	$$;	

create trigger miseajoursite after update on cudservey.site for each row execute function cudservey.aftermiseajoursite();

create or replace function cudservey.aftersuppressionsite()
	returns trigger 
	language plpgsql
	as $$
	begin 
		
		return null;
	
	end;
	$$;	

create trigger suppressionsite after delete on cudservey.site for each row execute function cudservey.aftersuppressionsite();

-- ======== Creation de la table photosite
-- ==========================================================================================================================================
create table cudservey.photosite(
	codesite public.identifiant not null,
	codephoto public.identifiant not null);

alter table cudservey.photosite add constraint pkphotosite primary key (codesite, codephoto);
alter table cudservey.photosite add constraint fkphotositesite foreign key (codesite) references cudservey.site(codesite) on delete cascade;
alter table cudservey.photosite add constraint fkphotositephoto foreign key (codephoto) references cudservey.photo(codephoto) on delete cascade;

create or replace procedure cudservey.creerphotosite(pcodesite public.identifiant, pcodephoto public.identifiant)
	language plpgsql
	as $$
	declare
		vcodesite public.identifiant;
		vcodephoto public.identifiant;
		vtrouv boolean;
	begin
		assert(pcodesite is not null),'Le code du site est vide.';
		assert(public.existencetuple('cudservey', 'site', 'codesite', pcodesite)),'Le code <'|| pcodesite ||'> du site est inconnu.';
		assert(pcodephoto is not null),'Le code de la photo est vide.';
		assert(public.existencetuple('cudservey', 'photo', 'codephoto', pcodephoto)),'Le code <'|| pcodephoto ||'> de la photo est inconnu.';
		execute format('select exists (select * from cudservey.photosite ps where ps.codesite = $1 and ps.codephoto = $2)')
		into vtrouv
		using pcodesite, pcodephoto;
		assert(not vtrouv),'Ce site contient deja cette photo.';
	
		execute format('insert into cudservey.photosite(codesite, codephoto) values ($1, $2)')
		using pcodesite, pcodephoto;
			
		execute format('select exists (select * from cudservey.photosite ps where ps.codesite = $1 and ps.codephoto = $2)')
		into vtrouv
		using pcodesite, pcodephoto;
		assert(vtrouv),'Incoherences sur les donnees inserees.';
	end;
	$$;

create or replace function cudservey.aftercreerphotosite()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srservey.ajouterphotosite(new.codesite, new.codephoto);
		call public.attacher('cudservey', 'site', 'codesite', new.codesite);
		call public.attacher('cudservey', 'photo', 'codephoto', new.codephoto);
		return null;
	end;
	$$;	

create trigger ajoutphotosite after insert on cudservey.photosite for each row execute function cudservey.aftercreerphotosite();

create or replace procedure cudservey.supprimerphotosite(pcodephoto public.identifiant)
	language plpgsql
	as $$
	declare
		vcodephoto public.identifiant;
		vtrouv boolean;
	begin
		
		assert(pcodephoto is not null),'Le code de la photo est vide.';
		assert(public.existencetuple('cudservey', 'photo', 'codephoto', pcodephoto)),'Le code <'|| pcodephoto ||'> de la photo est inconnu.';
		execute format('select exists (select * from cudservey.photosite where codephoto = $1)')
		into vtrouv
		using pcodephoto;
		assert(vtrouv),'Cette photo n''est associee a aucun site.';
	
		execute format('delete from cudservey.photosite where codephoto = $1;')
		using pcodephoto;
			
		execute format('select exists (select * from cudservey.photosite where codephoto = $1)')
		into vtrouv
		using pcodephoto;
		assert(not vtrouv),'Incoherences sur les donnees mises a jour.';
	
	end;
	$$;

create or replace function cudservey.aftersupprimerphotosite()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srservey.retirerphotosite(old.codesite, old.codephoto);
		call public.detacher('cudservey', 'site', 'codesite', old.codesite);
		call public.detacher('cudservey', 'photo', 'codephoto', old.codephoto);
		return null;
	end;
	$$;	

create trigger retraitphotosite after delete on cudservey.photosite for each row execute function cudservey.aftersupprimerphotosite();

-- ======== Creation de la table operateursite
-- ==========================================================================================================================================
create table cudservey.operateursite(
	codesite public.identifiant not null,
	codeoperateur public.identifiant not null);

alter table cudservey.operateursite add constraint pkoperateursite primary key (codesite, codeoperateur);
alter table cudservey.operateursite add constraint fkoperateursitesite foreign key (codesite) references cudservey.site(codesite) on delete cascade;
alter table cudservey.operateursite add constraint fkoperateursiteoperateur foreign key (codeoperateur) references cuddomaine.nomenclature(codenomen) on delete cascade;

create or replace procedure cudservey.mettreajouroperateursite(pcodesite public.identifiant, pcodesoperateurs public.identifiant[])
	language plpgsql
	as $$
	declare
		pcodeoperateur public.identifiant;
		vtrouv boolean;
	begin
		assert(pcodesite is not null),'Le code du site est vide.';
		assert(public.existencetuple('cudservey', 'site', 'codesite', pcodesite)),'Le code <'|| pcodesite ||'> du site est inconnu.';
		foreach pcodeoperateur in array pcodesoperateurs
		loop
			assert(pcodeoperateur is not null),'Le code de l''operateur est vide.';
			assert(public.existencetuple('cuddomaine', 'nomenclature', 'codenomen', pcodeoperateur)),'Le code <'|| pcodeoperateur ||'> de l''operateur est inconnu.';
		end loop;		
	
		delete from cudservey.operateursite where codesite = pcodesite;
		foreach pcodeoperateur in array pcodesoperateurs
		loop
			insert into cudservey.operateursite(codesite, codeoperateur) values (pcodesite, pcodeoperateur);
		end loop;
		
		foreach pcodeoperateur in array pcodesoperateurs
		loop
			execute format('select exists (select * from cudservey.operateursite os where os.codesite = $1 and os.codeoperateur = $2)')
			into vtrouv
			using pcodesite, pcodeoperateur;
			assert(vtrouv),'Incoherences sur les donnees inserees.';
		end loop;
	end;
	$$;

create or replace function cudservey.aftersupprimeroperateursite()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srservey.retireroperateursite(old.codesite, old.codeoperateur);
		call public.detacher('cudservey', 'site', 'codesite', old.codesite);
		call public.detacher('cuddomaine', 'nomenclature', 'codenomen', old.codeoperateur);
		return null;
	end;
	$$;	

create trigger retraitoperateursite after delete on cudservey.operateursite for each row execute function cudservey.aftersupprimeroperateursite();

create or replace function cudservey.aftercreeroperateursite()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srservey.ajouteroperateursite(new.codesite, new.codeoperateur);
		call public.attacher('cudservey', 'site', 'codesite', new.codesite);
		call public.attacher('cuddomaine', 'nomenclature', 'codenomen', new.codeoperateur);
		return null;
	end;
	$$;	

create trigger ajoutoperateursite after insert on cudservey.operateursite for each row execute function cudservey.aftercreeroperateursite();

-- ======== creation de la table servey
-- ==========================================================================================================================================
create table cudservey.servey(
	codeservey public.identifiant not null,
	nomreseau public.libelle not null,
	dateservey date not null,
	codepays public.identifiant not null,
	codeville public.identifiant not null,
	clientmobile numeric not null default 0,
	clientbtob numeric not null default 0,
	statutservey public.etat not null default 1,
	codesite public.identifiant not null,
	coderesposerv public.identifiant not null,
	etat public.etat not null default 1,
	card public.enaturel not null default 0,
	ord public.enaturelnn not null,
	datecrea timestamp not null default current_timestamp,
	dateupda timestamp null);

alter table cudservey.servey add constraint pkservey primary key (codeservey);
alter table cudservey.servey add constraint chkinvariantcardetatservey check (((card > 0 or etat = 1 or etat = 3) and (etat <> 1 or card = 0) and (etat <> 3 or card = 0)) or ((card = 0 or etat = 2) and (etat <> 2 or card > 0)));
alter table cudservey.servey add constraint chkinvariantdatecreaupdaservey check (datecrea <= dateupda);
alter table cudservey.servey add constraint fkserveypays foreign key (codepays) references cuddomaine.nomenclature(codenomen) on delete cascade;
alter table cudservey.servey add constraint fkserveyville foreign key (codeville) references cuddomaine.nomenclature(codenomen) on delete cascade;
alter table cudservey.servey add constraint fkserveysite foreign key (codesite) references cudservey.site(codesite) on delete cascade;
alter table cudservey.servey add constraint fkserveyresposervey foreign key (coderesposerv) references cudutilisateur.resposervey(coderesposerv) on delete cascade;

create or replace function cudservey.creationservey(pnomreseau public.libelle, pdateservey date, pcodepays public.identifiant, pcodeville public.identifiant, pclientmobile numeric, pclientbtob numeric, pnomsite public.libelle, pimmeuble boolean, phauteur numeric, pdalle boolean, pdescrdalle public.libelle, psourcelectrique boolean, ppriseterre boolean, poperateurs boolean, pcodesoperateurs public.identifiant[], plongitude numeric(25,20), platitude numeric(25,20), padresse public.libelle, pdescrenviron public.libelle, pcoderesposerv public.identifiant)
	returns public.identifiant 
	language plpgsql
	as $$
	declare
		vcode public.identifiant;
		vordmax public.enaturelnn;
		vnomreseau public.libelle;
		vdateservey date;
		vcodepays public.identifiant;	
		vcodeville public.identifiant;
		vclientmobile numeric;
		vclientbtob numeric;
		pcodesite public.identifiant;
		vcodesite public.identifiant;
		vcoderesposerv public.identifiant;
		vnomsite public.libelle;
		vimmeuble boolean;
		vhauteur numeric;
		vdalle boolean;
		vdescrdalle public.libelle;
		vsourcelectrique boolean;
		vpriseterre boolean;
		voperateurs boolean;
		vcodeoperateur public.identifiant;
		vlongitude numeric(25,20);
		vlatitude numeric(25,20);
		vadresse public.libelle;
		vdescrenviron public.libelle;
	begin 
		
		assert(pnomreseau is not null),'Le nom du reseau du servey est vide.';
		assert(pdateservey is not null),'La date du servey est vide.';
		assert(pcodepays is not null),'Le code du pays est vide.';
		assert(pcodeville is not null),'Le code de la ville est vide.';
		assert(pclientmobile is not null),'La quantite de clients mobiles est vide.';
		assert(pclientbtob is not null),'La quantite de clients BtoB est vide.';
		assert(pcoderesposerv is not null),'Le code du responsable du servey est vide.';
		assert(public.existencetuple('cudutilisateur', 'resposervey', 'coderesposerv', pcoderesposerv)),'Le code <'|| pcoderesposerv ||'> du responsable du servey est inconnu.';
		assert(pnomsite is not null),'Le nom du site est vide.';
		assert(pimmeuble is not null),'L''attribut immeuble est vide.';
		if (pimmeuble) then
			assert(phauteur is not null),'La hauteur de l''immeuble est vide.';
			assert(pdalle is not null),'L''attribut dalles est vide.';
		end if;		
		if (pdalle) then
			assert(pdescrdalle is not null),'La description des dalles est vide.';
		end if;
		assert(psourcelectrique is not null),'L''attribut source electrique est vide.';
		assert(ppriseterre is not null),'L''attribut prise terre est vide.';
		assert(poperateurs is not null),'L''attribut operateur de telecom est vide.';
		if (poperateurs) then
			assert(pcodesoperateurs is not null),'Les identifiants des operateurs de telecom sont vides.';
			if (pcodesoperateurs is not null) then
				foreach vcodeoperateur in array pcodesoperateurs
				loop
					assert(vcodeoperateur is not null),'Le code de l''operateur de telecom est vide.';
					assert(public.existencetuple('cuddomaine', 'nomenclature', 'codenomen', vcodeoperateur)),'Le code <'|| vcodeoperateur ||'> de l''operateur de telecom est inconnu.';
				end loop;
			end if;
		end if;
		assert(plongitude is not null),'La longitude des coordonnees GPS est vide.';
		assert(platitude is not null),'La latitude des coordonnees GPS est vide.';
			
		vcode := cudincrement.generationidentifiant('servey');
		vordmax := public.obtentionordremax('cudservey', 'servey', 'ord');	
		pcodesite := cudservey.creationsite(pnomsite, pimmeuble, phauteur, pdalle, pdescrdalle, psourcelectrique, ppriseterre, poperateurs, pcodesoperateurs, plongitude, platitude, padresse, pdescrenviron);
		execute format('insert into cudservey.servey (codeservey, nomreseau, dateservey, codepays, codeville, clientmobile, clientbtob, codesite, coderesposerv, ord) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)')
		using vcode, pnomreseau, pdateservey, pcodepays, pcodeville, pclientmobile, pclientbtob, pcodesite, pcoderesposerv, vordmax;
		
		execute format('select nomreseau, dateservey, codepays, codeville, clientmobile, clientbtob, codesite, coderesposerv from cudservey.servey where codeservey = $1')
		into vnomreseau, vdateservey, vcodepays, vcodeville, vclientmobile, vclientbtob, vcodesite, vcoderesposerv 
		using vcode;	
		assert(vnomreseau = pnomreseau),'Incoherence 1 sur les donnees inserees. nomreseau';
		assert(vdateservey = pdateservey),'Incoherence 1 sur les donnees inserees. dateservey';
		assert(vcodepays = pcodepays),'Incoherence 1 sur les donnees inserees. codepays';
		assert(vcodeville = pcodeville),'Incoherence 1 sur les donnees inserees. codeville';
		assert(vclientmobile = pclientmobile),'Incoherence 1 sur les donnees inserees. clientmobile';
		assert(vclientbtob = pclientbtob),'Incoherence 1 sur les donnees inserees. clientbtob';
		assert(vcodesite = pcodesite),'Incoherence 1 sur les donnees inserees. codesite';
		assert(vcoderesposerv = pcoderesposerv),'Incoherence 1 sur les donnees inserees. coderesposerv';
			
		return vcode;
	end;
	$$;

create or replace function cudservey.aftercreationservey()
	returns trigger 
	language plpgsql
	as $$
	declare
	begin 
		call srservey.ajouterservey(new.codeservey, new.statutservey, new.nomreseau, new.dateservey, new.codepays, new.codeville, new.clientmobile, new.clientbtob, new.codesite, new.coderesposerv, new.etat, new.ord, new.datecrea);
		call public.attacher('cuddomaine', 'nomenclature', 'codenomen', new.codepays);
		call public.attacher('cuddomaine', 'nomenclature', 'codenomen', new.codeville);
		call public.attacher('cudservey', 'site', 'codesite', new.codesite);
		call public.attacher('cudutilisateur', 'resposervey', 'coderesposerv', new.coderesposerv);
		return null;
	end;
	$$;	

create trigger ajoutservey after insert on cudservey.servey for each row execute function cudservey.aftercreationservey();

create or replace procedure cudservey.modifierservey(pcode public.identifiant, pnomreseau public.libelle, pdateservey date, pcodepays public.identifiant, pcodeville public.identifiant, pclientmobile numeric, pclientbtob numeric, pnomsite public.libelle, pimmeuble boolean, phauteur numeric, pdalle boolean, pdescrdalle public.libelle, psourcelectrique boolean, ppriseterre boolean, poperateurs boolean, pcodesoperateurs public.identifiant[], plongitude numeric(25,20), platitude numeric(25,20), padresse public.libelle, pdescrenviron public.libelle)
	language plpgsql
	as $$
	declare
		vnomreseau public.libelle;
		vdateservey date;
		vcodepays public.identifiant;	
		vcodeville public.identifiant;
		vclientmobile numeric;
		vclientbtob numeric;
		pcodesite public.identifiant;
		vcodesite public.identifiant;
		vimmeuble boolean;
		vhauteur numeric;
		vdalle boolean;
		vdescrdalle public.libelle;
		vsourcelectrique boolean;
		vpriseterre boolean;
		voperateurs boolean;
		vcodeoperateur public.identifiant;
		vlongitude numeric(25,20);
		vlatitude numeric(25,20);
		vadresse public.libelle;
		vdescrenviron public.libelle;
	begin 
		
		assert(pcode is not null),'Le code du servey est vide.';
		assert(public.existencetuple('cudservey', 'servey', 'codeservey', pcode)),'Le code <'|| pcode ||'> du servey est inconnu.';
		assert(pnomreseau is not null),'Le nom du reseau du servey est vide.';
		assert(pdateservey is not null),'La date du servey est vide.';
		assert(pcodepays is not null),'Le code du pays est vide.';
		assert(pcodeville is not null),'Le code de la ville est vide.';
		assert(pclientmobile is not null),'La quantite de clients mobiles est vide.';
		assert(pclientbtob is not null),'La quantite de clients BtoB est vide.';
		assert(pnomsite is not null),'Le nom du site est vide.';
		assert(pimmeuble is not null),'L''attribut immeuble est vide.';
		if (pimmeuble) then
			assert(phauteur is not null),'La hauteur de l''immeuble est vide.';
			assert(pdalle is not null),'L''attribut dalles est vide.';
		end if;		
		if (pdalle) then
			assert(pdescrdalle is not null),'La description des dalles est vide.';
		end if;
		assert(psourcelectrique is not null),'L''attribut source electrique est vide.';
		assert(ppriseterre is not null),'L''attribut prise terre est vide.';
		assert(poperateurs is not null),'L''attribut operateur de telecom est vide.';
		if (poperateurs) then
			foreach vcodeoperateur in array pcodesoperateurs
			loop
				assert(vcodeoperateur is not null),'Le code de l''operateur de telecom est vide.';
				assert(public.existencetuple('cuddomaine', 'nomenclature', 'codenomen', vcodeoperateur)),'Le code <'|| vcodeoperateur ||'> de l''operateur de telecom est inconnu.';
			end loop;
		end if;
		assert(plongitude is not null),'La longitude des coordonnees GPS est vide.';
		assert(platitude is not null),'La latitude des coordonnees GPS est vide.';
		
		execute format('select codesite from cudservey.servey where codeservey = $1')
		into pcodesite 
		using pcode;
		call cudservey.modifiersite(pcodesite, pnomsite, pimmeuble, phauteur, pdalle, pdescrdalle, psourcelectrique, ppriseterre, poperateurs, pcodesoperateurs, plongitude, platitude, padresse, pdescrenviron);
		execute format('update cudservey.servey set nomreseau = $1, dateservey = $2, codepays = $3, codeville = $4, clientmobile = $5, clientbtob = $6, dateupda = current_timestamp where codeservey = $7')
		using pnomreseau, pdateservey, pcodepays, pcodeville, pclientmobile, pclientbtob, pcode;
		
		execute format('select nomreseau, dateservey, codepays, codeville, clientmobile, clientbtob from cudservey.servey where codeservey = $1')
		into vnomreseau, vdateservey, vcodepays, vcodeville, vclientmobile, vclientbtob 
		using pcode;	
		assert(vnomreseau = pnomreseau),'Incoherence 1 sur les donnees mises a jour. nomreseau';
		assert(vdateservey = pdateservey),'Incoherence 1 sur les donnees mises a jour. dateservey';
		assert(vcodepays = pcodepays),'Incoherence 1 sur les donnees mises a jour. codepays';
		assert(vcodeville = pcodeville),'Incoherence 1 sur les donnees mises a jour. codeville';
		assert(vclientmobile = pclientmobile),'Incoherence 1 sur les donnees mises a jour. clientmobile';
		assert(vclientbtob = pclientbtob),'Incoherence 1 sur les donnees mises a jour. clientbtob';
				
	end;
	$$;

create or replace procedure cudservey.soumettreservey(pcode public.identifiant)
	language plpgsql
	as $$
	declare
		pstatutservey public.etat;
		vstatutservey public.etat;
	begin 
		
		assert(pcode is not null),'Le code du servey est vide.';
		assert(public.existencetuple('cudservey', 'servey', 'codeservey', pcode)),'Le code <'|| pcode ||'> du servey est inconnu.';
		execute format('select statutservey from cudservey.servey where codeservey = $1')
		into pstatutservey 
		using pcode;
		assert(pstatutservey = 1 or pstatutservey = 4),'Le statut du servey est incoherent.';
		
		call cudservey.creersoumissionservey(pcode);
		execute format('update cudservey.servey set statutservey = 2, dateupda = current_timestamp where codeservey = $1')
		using pcode;
	
		execute format('select statutservey from cudservey.servey where codeservey = $1')
		into vstatutservey 
		using pcode;	
		assert(vstatutservey = 2),'Incoherence 1 sur les donnees mises a jour. statutservey';
		
	end;
	$$;

create or replace procedure cudservey.accepterservey(pcode public.identifiant)
	language plpgsql
	as $$
	declare
		pstatutservey public.etat;
		vstatutservey public.etat;
	begin 
		
		assert(pcode is not null),'Le code du servey est vide.';
		assert(public.existencetuple('cudservey', 'servey', 'codeservey', pcode)),'Le code <'|| pcode ||'> du servey est inconnu.';
		execute format('select statutservey from cudservey.servey where codeservey = $1')
		into pstatutservey 
		using pcode;
		assert(pstatutservey = 2),'Le statut du servey est incoherent.';
		
		call cudservey.creeracceptationservey(pcode);
		execute format('update cudservey.servey set statutservey = 3, dateupda = current_timestamp where codeservey = $1')
		using pcode;
	
		execute format('select statutservey from cudservey.servey where codeservey = $1')
		into vstatutservey 
		using pcode;	
		assert(vstatutservey = 3),'Incoherence 1 sur les donnees mises a jour. statutservey';
		
	end;
	$$;

create or replace procedure cudservey.rejeterservey(pcode public.identifiant)
	language plpgsql
	as $$
	declare
		pstatutservey public.etat;
		vstatutservey public.etat;
	begin 
		
		assert(pcode is not null),'Le code du servey est vide.';
		assert(public.existencetuple('cudservey', 'servey', 'codeservey', pcode)),'Le code <'|| pcode ||'> du servey est inconnu.';
		execute format('select statutservey from cudservey.servey where codeservey = $1')
		into pstatutservey 
		using pcode;
		assert(pstatutservey = 2),'Le statut du servey est incoherent.';
		
		call cudservey.creerejetservey(pcode);
		execute format('update cudservey.servey set statutservey = 4, dateupda = current_timestamp where codeservey = $1')
		using pcode;
	
		execute format('select statutservey from cudservey.servey where codeservey = $1')
		into vstatutservey 
		using pcode;	
		assert(vstatutservey = 4),'Incoherence 1 sur les donnees mises a jour. statutservey';
		
	end;
	$$;

create or replace procedure cudservey.supprimerservey(pcode public.identifiant)
	language plpgsql
	as $$
	declare
	begin 
		
		assert(public.existencetuple('cudservey', 'servey', 'codeservey', pcode)),'Le code <'|| pcode ||'> du servey est inconnu.';	
		
		call public.supprimer('cudservey', 'servey', 'codeservey', pcode);
	
		assert(not public.existencetuple('cudservey', 'servey', 'codeservey', pcode)),'Incoherence sur le tuple supprime.';
		
	end;
	$$;

create or replace function cudservey.aftermiseajourservey()
	returns trigger 
	language plpgsql
	as $$
	begin 
		if (old.etat != new.etat) then 
			call public.mettreajouretatuple('srservey', 'servey', 'codeservey', old.codeservey, new.etat, new.dateupda);
		else
			if (old.statutservey != new.statutservey) then
				if ((old.statutservey = 1 and new.statutservey = 2) or (old.statutservey = 4 and new.statutservey = 2)) then
					call srservey.mettreajoursoumissionservey(old.codeservey, new.statutservey, new.dateupda);
				end if;				
				if (old.statutservey = 2 and new.statutservey = 3) then
					call srservey.mettreajouracceptationservey(old.codeservey, new.statutservey, new.dateupda);
				end if;				
				if (old.statutservey = 2 and new.statutservey = 4) then
					call srservey.mettreajourejetservey(old.codeservey, new.statutservey, new.dateupda);
				end if;
			else
				call srservey.mettreajourservey(old.codeservey, new.nomreseau, new.dateservey, new.codepays, new.codeville, new.clientmobile, new.clientbtob, new.codesite, new.dateupda);
			end if;			
		end if;
		return null;
	end;
	$$;	

create trigger miseajourservey after update on cudservey.servey for each row execute function cudservey.aftermiseajourservey();

create or replace function cudservey.aftersuppressionservey()
	returns trigger 
	language plpgsql
	as $$
	begin 		
		
		call public.detacher('cuddomaine', 'nomenclature', 'codenomen', old.codepays);
		call public.detacher('cuddomaine', 'nomenclature', 'codenomen', old.codeville);
		call public.detacher('cudservey', 'site', 'codesite', old.codesite);
		call public.detacher('cudutilisateur', 'resposervey', 'coderesposerv', old.coderesposerv);
		return null;
	
	end;
	$$;	

create trigger suppressionservey after delete on cudservey.servey for each row execute function cudservey.aftersuppressionservey();

-- ======== Creation de la table wifiservey
-- ==========================================================================================================================================
create table cudservey.wifiservey(
	codeservey public.identifiant not null,
	codewifi public.identifiant not null);

alter table cudservey.wifiservey add constraint pkwifiservey primary key (codeservey, codewifi);
alter table cudservey.wifiservey add constraint fkwifiserveyservey foreign key (codeservey) references cudservey.servey(codeservey) on delete cascade;
alter table cudservey.wifiservey add constraint fkwifiserveysite foreign key (codewifi) references cudservey.wifi(codewifi) on delete cascade;

create or replace procedure cudservey.mettreajourwifiservey(pcodeservey public.identifiant, pcodeswifis public.identifiant[])
	language plpgsql
	as $$
	declare
		pcodewifi public.identifiant;
		vtrouv boolean;
	begin
		assert(pcodeservey is not null),'Le code du servey est vide.';
		assert(public.existencetuple('cudservey', 'servey', 'codeservey', pcodeservey)),'Le code <'|| pcodeservey ||'> du servey est inconnu.';
		foreach pcodewifi in array pcodeswifis
		loop
			assert(pcodewifi is not null),'Le code du wifi est vide.';
			assert(public.existencetuple('cudservey', 'wifi', 'codewifi', pcodewifi)),'Le code <'|| pcodewifi ||'> du wifi est inconnu.';
		end loop;		
	
		delete from cudservey.wifiservey where codeservey = pcodeservey;
		foreach pcodewifi in array pcodeswifis
		loop
			insert into cudservey.wifiservey(codeservey, pcodewifi) values (pcodeservey, pcodewifi);
		end loop;
		
		foreach pcodewifi in array pcodeswifis
		loop
			execute format('select exists (select * from cudservey.wifiservey ws where ws.codeservey = $1 and ws.pcodewifi = $2)')
			into vtrouv
			using pcodeservey, pcodewifi;
			assert(vtrouv),'Incoherences sur les donnees inserees.';
		end loop;
	end;
	$$;

create or replace function cudservey.aftersupprimerwifiservey()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call cudservey.retirerwifiservey(old.codeservey, old.codewifi);
		call public.detacher('cudservey', 'servey', 'codeservey', old.codeservey);
		call public.detacher('cudservey', 'wifi', 'codewifi', old.codewifi);
		return null;
	end;
	$$;	

create trigger retraitwifiservey after delete on cudservey.wifiservey for each row execute function cudservey.aftersupprimerwifiservey();

create or replace function cudservey.aftercreerwifiservey()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call cudservey.ajouterwifiservey(new.codeservey, new.codewifi);
		call public.attacher('cudservey', 'servey', 'codeservey', new.codeservey);
		call public.attacher('cudservey', 'wifi', 'codewifi', new.codewifi);
		return null;
	end;
	$$;	

create trigger ajoutwifiservey after insert on cudservey.wifiservey for each row execute function cudservey.aftercreerwifiservey();

-- ======== Creation de la table soumissionservey
-- ==========================================================================================================================================
create table cudservey.soumissionservey(
	codeservey public.identifiant not null,
	datesoumis timestamp not null);

alter table cudservey.soumissionservey add constraint pksoumissionservey primary key (codeservey, datesoumis);
alter table cudservey.soumissionservey add constraint fksoumissionserveyservey foreign key (codeservey) references cudservey.servey(codeservey) on delete cascade;

create or replace procedure cudservey.creersoumissionservey(pcodeservey public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
		pdatesoumis timestamp;
	begin
		
		assert(pcodeservey is not null),'Le code du servey est vide.';
		assert(public.existencetuple('cudservey', 'servey', 'codeservey', pcodeservey)),'Le code <'|| pcodeservey ||'> du servey est inconnu.';			
	
		pdatesoumis := current_timestamp;
		execute format('insert into cudservey.soumissionservey (codeservey, datesoumis) values ($1, $2)')
		using pcodeservey, pdatesoumis;
		
		execute format('select exists (select * from cudservey.soumissionservey ws where ss.codeservey = $1 and ss.datesoumis = $2)')
		into vtrouv
		using pcodeservey, pdatesoumis;
		assert(vtrouv),'Incoherences sur les donnees inserees.';
	
	end;
	$$;

create or replace function cudservey.aftercreersoumissionservey()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srservey.ajoutersoumissionservey(new.codeservey, new.datesoumis);
		call public.attacher('cudservey', 'servey', 'codeservey', new.codeservey);
		return null;
	end;
	$$;	

create trigger ajoutsoumissionservey after insert on cudservey.soumissionservey for each row execute function cudservey.aftercreersoumissionservey();

-- ======== Creation de la table acceptationservey
-- ==========================================================================================================================================
create table cudservey.acceptationservey(
	codeservey public.identifiant not null,
	dateaccept timestamp not null);

alter table cudservey.acceptationservey add constraint pkacceptationservey primary key (codeservey, dateaccept);
alter table cudservey.acceptationservey add constraint fkacceptationserveyservey foreign key (codeservey) references cudservey.servey(codeservey) on delete cascade;

create or replace procedure cudservey.creeracceptationservey(pcodeservey public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
		pdateaccept timestamp;
	begin
		
		assert(pcodeservey is not null),'Le code du servey est vide.';
		assert(public.existencetuple('cudservey', 'servey', 'codeservey', pcodeservey)),'Le code <'|| pcodeservey ||'> du servey est inconnu.';			
	
		pdateaccept := current_timestamp;
		execute format('insert into cudservey.acceptationservey (codeservey, dateaccept) values ($1, $2)')
		using pcodeservey, pdateaccept;
		
		execute format('select exists (select * from cudservey.acceptationservey acs where acs.codeservey = $1 and acs.dateaccept = $2)')
		into vtrouv
		using pcodeservey, pdateaccept;
		assert(vtrouv),'Incoherences sur les donnees inserees.';
	
	end;
	$$;

create or replace function cudservey.aftercreeracceptationservey()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srservey.ajouteracceptationservey(new.codeservey, new.dateaccept);
		call public.attacher('cudservey', 'servey', 'codeservey', new.codeservey);
		return null;
	end;
	$$;	

create trigger ajoutacceptationservey after insert on cudservey.acceptationservey for each row execute function cudservey.aftercreeracceptationservey();

-- ======== Creation de la table rejetservey
-- ==========================================================================================================================================
create table cudservey.rejetservey(
	codeservey public.identifiant not null,
	daterejet timestamp not null);

alter table cudservey.rejetservey add constraint pkrejetservey primary key (codeservey, daterejet);
alter table cudservey.rejetservey add constraint fkrejetserveyservey foreign key (codeservey) references cudservey.servey(codeservey) on delete cascade;

create or replace procedure cudservey.creerejetservey(pcodeservey public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
		pdaterejet timestamp;
	begin
		
		assert(pcodeservey is not null),'Le code du servey est vide.';
		assert(public.existencetuple('cudservey', 'servey', 'codeservey', pcodeservey)),'Le code <'|| pcodeservey ||'> du servey est inconnu.';			
	
		pdaterejet := current_timestamp;
		execute format('insert into cudservey.rejetservey (codeservey, daterejet) values ($1, $2)')
		using pcodeservey, pdaterejet;
		
		execute format('select exists (select * from cudservey.rejetservey ws where rs.codeservey = $1 and rs.daterejet = $2)')
		into vtrouv
		using pcodeservey, pdaterejet;
		assert(vtrouv),'Incoherences sur les donnees inserees.';
	
	end;
	$$;

create or replace function cudservey.aftercreerejetservey()
	returns trigger 
	language plpgsql
	as $$
	begin 
		call srservey.ajouterejetservey(new.codeservey, new.daterejet);
		call public.attacher('cudservey', 'servey', 'codeservey', new.codeservey);
		return null;
	end;
	$$;	

create trigger ajoutrejetservey after insert on cudservey.rejetservey for each row execute function cudservey.aftercreerejetservey();

-- ==========================================================================================================================================
-- ==========================================================================================================================================
-- ======== Creation du schema srsurvey
-- ==========================================================================================================================================
-- ==========================================================================================================================================
create schema srservey;
alter schema srservey owner to akamsrdbservey;

-- ======== Creation de la table wifi
-- ==========================================================================================================================================
create table srservey.wifi(
	codewifi public.identifiant not null,
	nomwifi public.libelle not null,
	frequence public.nom not null,
	canal public.nom not null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srservey.wifi add constraint pkwifi primary key (codewifi);
alter table srservey.wifi add constraint chkinvariantdatecreaupdawifi check (datecrea <= dateupda);

create or replace procedure srservey.ajouterwifi(pcode public.identifiant, pnomwifi public.libelle, pfrequence public.nom, pcanal public.nom, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vnomwifi public.libelle;
		vfrequence public.nom;
		vcanal public.nom;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code du wifi est vide.';
		assert(not public.existencetuple('srservey', 'wifi', 'codewifi', pcode)),'Le code <'|| pcode ||'> du wifi existe deja.';
		assert(pnomwifi is not null),'Le nom du wifi est vide.';
		assert(pfrequence is not null),'La frequence du wifi est vide.';
		assert(pcanal is not null),'Le canal du wifi est vide.';
		assert(petat = 1),'L''etat du wifi est incoherent.';
		assert(pord > 0),'L''ordre du wifi est incoherent.';
		assert(pdatecrea is not null),'La date de creation du wifi est vide.';	
		
		execute format('insert into srservey.wifi (codewifi, nomwifi, frequence, canal, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7)')
		using pcode, pnomwifi, pfrequence, pcanal, petat, pord, pdatecrea;
	
		execute format('select nomwifi, frequence, canal, etat, ord, datecrea from srservey.wifi where codewifi = $1')
		into vnomwifi, vfrequence, vcanal, vetat, vord, vdatecrea
		using pcode;	
		assert(vnomwifi = pnomwifi),'Incoherence 1 sur les donnees inserees. nomwifi';
		assert(vfrequence = pfrequence),'Incoherence 1 sur les donnees inserees. frequence';
		assert(vcanal = pcanal),'Incoherence 1 sur les donnees inserees. canal';
		assert(vetat = petat),'Incoherence 1 sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence 1 sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence 1 sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srservey.mettreajourwifi(pcode public.identifiant, pnomwifi public.libelle, pfrequence public.nom, pcanal public.nom, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vnomwifi public.libelle;
		vfrequence public.nom;
		vcanal public.nom;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du wifi est vide.';
		assert(public.existencetuple('srservey', 'wifi', 'codewifi', pcode)),'Le code <'|| pcode ||'> du wifi est inconnu.';
		assert(pnomwifi is not null),'Le nom du wifi est vide.';
		assert(pfrequence is not null),'La frequence du wifi est vide.';
		assert(pcanal is not null),'Le canal du wifi est vide.';
		assert(pdateupda is not null),'La date de creation du wifi est vide.';	
		execute format('select dateupda from srservey.wifi where codewifi = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour est incoherente.';
	
		execute format('update srservey.wifi set nomwifi = $1, frequence = $2, canal = $3, dateupda = $4 where codewifi = $5')
		using pnomwifi, pfrequence, pcanal, pdateupda, pcode;
	
		execute format('select nomwifi, frequence, canal, dateupda from srservey.wifi where codewifi = $1')
		into vnomwifi, vfrequence, vcanal, vdateupda
		using pcode;
		assert(vnomwifi = pnomwifi),'Incoherence 1 sur les donnees inserees. nomwifi';
		assert(vfrequence = pfrequence),'Incoherence 1 sur les donnees inserees. frequence';
		assert(vcanal = pcanal),'Incoherence 1 sur les donnees inserees. canal';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srservey.obtentionwifi(pcode public.identifiant)
	returns table(codewifi public.identifiant, nomwifi public.libelle, frequence public.nom, canal public.nom)
	language plpgsql
	as $$
	begin 
		
		assert(pcode is not null),'Le code du wifi est vide.';
		assert(public.existencetuple('srservey', 'wifi', 'codewifi', pcode)),'Le code <'|| pcode ||'> du wifi est inconnu.';
	
		return query select w.codewifi, w.nomwifi, w.frequence, w.canal from srservey.wifi w where w.codewifi = pcode;
		
	end;
	$$;


create or replace function srservey.recherchewifis(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codewifi public.identifiant, nomwifi public.libelle, frequence public.nom, canal public.nom)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select w.codewifi, w.nomwifi, w.frequence, w.canal from srservey.wifi w where w.etat <> 3 order by w.ord desc limit plimit offset pdebut;
		else
			return query select w.codewifi, w.nomwifi, w.frequence, w.canal from srservey.wifi w where w.etat <> 3 and (w.nomwifi ilike '%'|| pcritere ||'%') order by w.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== Creation de la table photo
-- ==========================================================================================================================================
create table srservey.photo(
	codephoto public.identifiant not null,
	descrphoto public.libelle not null,
	codefic public.identifiant not null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srservey.photo add constraint pkphoto primary key (codephoto);
alter table srservey.photo add constraint chkinvariantdatecreaupdaphoto check (datecrea <= dateupda);

create or replace procedure srservey.ajouterphoto(pcode public.identifiant, pdescrphoto public.libelle, pcodefic public.identifiant, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vdescrphoto public.libelle;
		vcodefic public.identifiant;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code de la photo est vide.';
		assert(not public.existencetuple('srservey', 'photo', 'codephoto', pcode)),'Le code <'|| pcode ||'> de la photo existe deja.';
		assert(pdescrphoto is not null),'La description de la photo est vide.';
		assert(pcodefic is not null),'Le code du fichier de la photo est vide.';
		assert(public.existencetuple('srfichier', 'fichier', 'codefic', pcodefic)),'Le code <'|| pcodefic ||'> du fichier de la photo est inconnu.';
		assert(petat = 1),'L''etat de la photo est incoherent.';
		assert(pord > 0),'L''ordre de la photo est incoherent.';
		assert(pdatecrea is not null),'La date de creation de la photo est vide.';	
		
		execute format('insert into srservey.photo (codephoto, descrphoto, codefic, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6)')
		using pcode, pdescrphoto, pcodefic, petat, pord, pdatecrea;
	
		execute format('select descrphoto, codefic, etat, ord, datecrea from srservey.photo where codephoto = $1')
		into vdescrphoto, vcodefic, vetat, vord, vdatecrea
		using pcode;	
		assert(vdescrphoto = pdescrphoto),'Incoherence 1 sur les donnees inserees. descrphoto';
		assert(vcodefic = pcodefic),'Incoherence 1 sur les donnees inserees. codefic';
		assert(vetat = petat),'Incoherence 1 sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence 1 sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence 1 sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srservey.mettreajourphoto(pcode public.identifiant, pdescrphoto public.libelle, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vdescrphoto public.libelle;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code de la photo est vide.';
		assert(public.existencetuple('srservey', 'photo', 'codephoto', pcode)),'Le code <'|| pcode ||'> de la photo est inconnu.';
		assert(pdescrphoto is not null),'La description de la photo est vide.';
		assert(pdateupda is not null),'La date de creation de la photo est vide.';	
		execute format('select dateupda from srservey.photo where codephoto = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour est incoherente.';
	
		execute format('update srservey.photo set descrphoto = $1, dateupda = $2 where codephoto = $3')
		using pdescrphoto, pdateupda, pcode;
	
		execute format('select descrphoto, dateupda from srservey.photo where codephoto = $1')
		into vdescrphoto, vdateupda
		using pcode;
		assert(vdescrphoto = pdescrphoto),'Incoherence 1 sur les donnees inserees. descrphoto';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srservey.obtentionphoto(pcode public.identifiant)
	returns table(codephoto public.identifiant, descrphoto public.libelle, codefic public.identifiant, nomfic public.nom, mimefic public.nom, taillefic numeric)
	language plpgsql
	as $$
	begin 
		
		assert(pcode is not null),'Le code de la photo est vide.';
		assert(public.existencetuple('srservey', 'photo', 'codephoto', pcode)),'Le code <'|| pcode ||'> de la photo est inconnu.';
	
		return query select p.codephoto, p.descrphoto, p.codefic, f.nomfic, f.mimefic, f.taillefic 
						from srservey.photo p 
							inner join srfichier.fichier f on (f.codefic = p.codefic)
						where p.codephoto = pcode;
		
	end;
	$$;


create or replace function srservey.recherchephotos(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codephoto public.identifiant, descrphoto public.libelle, codefic public.identifiant, nomfic public.nom, mimefic public.nom, taillefic numeric)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select p.codephoto, p.descrphoto, p.codefic, f.nomfic, f.mimefic, f.taillefic 
							from srservey.photo p 
								inner join srfichier.fichier f on (f.codefic = p.codefic)
							where p.etat <> 3 order by p.ord desc limit plimit offset pdebut;
		else
			return query select p.codephoto, p.descrphoto, p.codefic, f.nomfic, f.mimefic, f.taillefic 
							from srservey.photo p 
								inner join srfichier.fichier f on (f.codefic = p.codefic)
							where p.etat <> 3 and (p.descrphoto ilike '%'|| pcritere ||'%') order by p.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== Creation de la table site
-- ==========================================================================================================================================
create table srservey.site(
	codesite public.identifiant not null,
	nomsite public.libelle not null,
	immeuble boolean not null,
	hauteur numeric null,
	dalle boolean null,
	descrdalle public.libelle null,
	sourcelectrique boolean not null,
	priseterre boolean not null,
	operateurs boolean not null,
	longitude numeric(25,20) not null,
	latitude numeric(25,20) not null,
	adresse public.libelle null,
	descrenviron public.libelle null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srservey.site add constraint pksite primary key (codesite);
alter table srservey.site add constraint chkinvariantdatecreaupdasite check (datecrea <= dateupda);

create or replace procedure srservey.ajoutersite(pcode public.identifiant, pnomsite public.libelle, pimmeuble boolean, phauteur numeric, pdalle boolean, pdescrdalle public.libelle, psourcelectrique boolean, ppriseterre boolean, poperateurs boolean, plongitude numeric(25,20), platitude numeric(25,20), padresse public.libelle, pdescrenviron public.libelle, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vnomsite public.libelle;
		vimmeuble boolean;
		vhauteur numeric;
		vdalle boolean;
		vdescrdalle public.libelle;
		vsourcelectrique boolean;
		vpriseterre boolean;
		voperateurs boolean;
		vlongitude numeric(25,20);
		vlatitude numeric(25,20);
		vadresse public.libelle;
		vdescrenviron public.libelle;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code du site est vide.';
		assert(not public.existencetuple('srservey', 'site', 'codesite', pcode)),'Le code <'|| pcode ||'> du site existe deja.';
		assert(pnomsite is not null),'Le nom du site est vide.';
		assert(pimmeuble is not null),'L''attribut immeuble est vide.';
		if (pimmeuble) then
			assert(phauteur is not null),'La hauteur de l''immeuble est vide.';
			assert(pdalle is not null),'L''attribut dalles est vide.';
		end if;		
		if (pdalle) then
			assert(pdescrdalle is not null),'La description des dalles est vide.';
		end if;
		assert(psourcelectrique is not null),'L''attribut source electrique est vide.';
		assert(ppriseterre is not null),'L''attribut prise terre est vide.';
		assert(poperateurs is not null),'L''attribut operateur de telecom est vide.';
		assert(plongitude is not null),'La longitude des coordonnees GPS est vide.';
		assert(platitude is not null),'La latitude des coordonnees GPS est vide.';	
		assert(petat = 1),'L''etat du site est incoherent.';
		assert(pord > 0),'L''ordre du site est incoherent.';
		assert(pdatecrea is not null),'La date de creation du site est vide.';
	
		execute format('insert into srservey.site (codesite, nomsite, immeuble, hauteur, dalle, descrdalle, sourcelectrique, priseterre, operateurs, longitude, latitude, adresse, descrenviron, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)')
		using pcode, pnomsite, pimmeuble, phauteur, pdalle, pdescrdalle, psourcelectrique, ppriseterre, poperateurs, plongitude, platitude, padresse, pdescrenviron, petat, pord, pdatecrea;
	
		execute format('select nomsite, immeuble, hauteur, dalle, descrdalle, sourcelectrique, priseterre, operateurs, longitude, latitude, adresse, descrenviron, etat, ord, datecrea from srservey.site where codesite = $1')
		into vnomsite, vimmeuble, vhauteur, vdalle, vdescrdalle, vsourcelectrique, vpriseterre, voperateurs, vlongitude, vlatitude, vadresse, vdescrenviron, vetat, vord, vdatecrea
		using pcode;	
		assert(vnomsite = pnomsite),'Incoherence 1 sur les donnees inserees. nomsite';
		assert(vimmeuble = pimmeuble),'Incoherence 1 sur les donnees inserees. immeuble';
		assert((vhauteur is null) or (vhauteur = phauteur)),'Incoherence 1 sur les donnees inserees. hauteur';
		assert((vdalle is null) or (vdalle = pdalle)),'Incoherence 1 sur les donnees inserees. dalle';
		assert((vdescrdalle is null) or (vdescrdalle = pdescrdalle)),'Incoherence 1 sur les donnees inserees. descrdalle';
		assert(vsourcelectrique = psourcelectrique),'Incoherence 1 sur les donnees inserees. sourcelectrique';
		assert(vpriseterre = ppriseterre),'Incoherence 1 sur les donnees inserees. priseterre';
		assert(voperateurs = poperateurs),'Incoherence 1 sur les donnees inserees. operateurs';
		assert(vlongitude = plongitude),'Incoherence 1 sur les donnees inserees. longitude';
		assert(vlatitude = platitude),'Incoherence 1 sur les donnees inserees. latitude';
		assert((vadresse is null) or (vadresse = padresse)),'Incoherence 1 sur les donnees inserees. adresse';
		assert((vdescrenviron is null) or (vdescrenviron = pdescrenviron)),'Incoherence 1 sur les donnees inserees. descrenviron';
		assert(vetat = petat),'Incoherence 1 sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence 1 sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence 1 sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srservey.mettreajoursite(pcode public.identifiant, pnomsite public.libelle, pimmeuble boolean, phauteur numeric, pdalle boolean, pdescrdalle public.libelle, psourcelectrique boolean, ppriseterre boolean, poperateurs boolean, plongitude numeric(25,20), platitude numeric(25,20), padresse public.libelle, pdescrenviron public.libelle, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vnomsite public.libelle;
		vimmeuble boolean;
		vhauteur numeric;
		vdalle boolean;
		vdescrdalle public.libelle;
		vsourcelectrique boolean;
		vpriseterre boolean;
		voperateurs boolean;
		vlongitude numeric(25,20);
		vlatitude numeric(25,20);
		vadresse public.libelle;
		vdescrenviron public.libelle;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du site est vide.';
		assert(public.existencetuple('srservey', 'site', 'codesite', pcode)),'Le code <'|| pcode ||'> du site est inconnu.';
		assert(pnomsite is not null),'Le nom du site est vide.';
		assert(pimmeuble is not null),'L''attribut immeuble est vide.';
		if (pimmeuble) then
			assert(phauteur is not null),'La hauteur de l''immeuble est vide.';
			assert(pdalle is not null),'L''attribut dalles est vide.';
		end if;		
		if (pdalle) then
			assert(pdescrdalle is not null),'La description des dalles est vide.';
		end if;
		assert(psourcelectrique is not null),'L''attribut source electrique est vide.';
		assert(ppriseterre is not null),'L''attribut prise terre est vide.';
		assert(poperateurs is not null),'L''attribut operateur de telecom est vide.';
		assert(plongitude is not null),'La longitude des coordonnees GPS est vide.';
		assert(platitude is not null),'La latitude des coordonnees GPS est vide.';	
		execute format('select dateupda from srservey.site where codesite = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour est incoherente.';
	
		execute format('update srservey.site set nomsite = $1, immeuble = $2, hauteur = $3, dalle = $4, descrdalle = $5, sourcelectrique = $6, priseterre = $7, operateurs = $8, longitude = $9, latitude = $10, adresse = $11, descrenviron = $12, dateupda = $13 where codesite = $14')
		using pnomsite, pimmeuble, phauteur, pdalle, pdescrdalle, psourcelectrique, ppriseterre, poperateurs, plongitude, platitude, padresse, pdescrenviron, pdateupda, pcode;
	
		execute format('select nomsite, immeuble, hauteur, dalle, descrdalle, sourcelectrique, priseterre, operateurs, longitude, latitude, adresse, descrenviron, dateupda from srservey.site where codesite = $1')
		into vnomsite, vimmeuble, vhauteur, vdalle, vdescrdalle, vsourcelectrique, vpriseterre, voperateurs, vlongitude, vlatitude, vadresse, vdescrenviron, vdateupda
		using pcode;
		assert(vnomsite = pnomsite),'Incoherence 1 sur les donnees mises a jour. nomsite';
		assert(vimmeuble = pimmeuble),'Incoherence 1 sur les donnees mises a jour. immeuble';
		assert((vhauteur is null) or (vhauteur = phauteur)),'Incoherence 1 sur les donnees mises a jour. hauteur';
		assert((vdalle is null) or (vdalle = pdalle)),'Incoherence 1 sur les donnees mises a jour. dalle';
		assert((vdescrdalle is null) or (vdescrdalle = pdescrdalle)),'Incoherence 1 sur les donnees mises a jour. descrdalle';
		assert(vsourcelectrique = psourcelectrique),'Incoherence 1 sur les donnees mises a jour. sourcelectrique';
		assert(vpriseterre = ppriseterre),'Incoherence 1 sur les donnees mises a jour. priseterre';
		assert(voperateurs = poperateurs),'Incoherence 1 sur les donnees mises a jour. operateurs';
		assert(vlongitude = plongitude),'Incoherence 1 sur les donnees mises a jour. longitude';
		assert(vlatitude = platitude),'Incoherence 1 sur les donnees mises a jour. latitude';
		assert((vadresse is null) or (vadresse = padresse)),'Incoherence 1 sur les donnees mises a jour. adresse';
		assert((vdescrenviron is null) or (vdescrenviron = pdescrenviron)),'Incoherence 1 sur les donnees mises a jour. descrenviron';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srservey.obtentionsite(pcode public.identifiant)
	returns table(codesite public.identifiant, nomsite public.libelle, immeuble boolean, hauteur numeric, dalle boolean, descrdalle public.libelle, sourcelectrique boolean, priseterre boolean, operateurs boolean, longitude numeric(25,20), latitude numeric(25,20), adresse public.libelle, descrenviron public.libelle)
	language plpgsql
	as $$
	begin 
		
		assert(pcode is not null),'Le code du site est vide.';
		assert(public.existencetuple('srservey', 'site', 'codesite', pcode)),'Le code <'|| pcode ||'> du site est inconnu.';
	
		return query select s.codesite, s.nomsite, s.immeuble, s.hauteur, s.dalle, s.descrdalle, s.sourcelectrique, s.priseterre, s.operateurs, s.longitude, s.latitude, s.adresse, s.descrenviron from srservey.site s where s.codesite = pcode;
		
	end;
	$$;

create or replace function srservey.recherchesites(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codesite public.identifiant, nomsite public.libelle, immeuble boolean, hauteur numeric, dalle boolean, descrdalle public.libelle, sourcelectrique boolean, priseterre boolean, operateurs boolean, longitude numeric(25,20), latitude numeric(25,20), adresse public.libelle, descrenviron public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select s.codesite, s.nomsite, s.immeuble, s.hauteur, s.dalle, s.descrdalle, s.sourcelectrique, s.priseterre, s.operateurs, s.longitude, s.latitude, s.adresse, s.descrenviron from srservey.site s where s.etat <> 3 order by s.ord desc limit plimit offset pdebut;
		else
			return query select s.codesite, s.nomsite, s.immeuble, s.hauteur, s.dalle, s.descrdalle, s.sourcelectrique, s.priseterre, s.operateurs, s.longitude, s.latitude, s.adresse, s.descrenviron from srservey.site s where s.etat <> 3 and (s.nomsite ilike '%'|| pcritere ||'%') order by s.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== Creation de la table photosite
-- ==========================================================================================================================================
create table srservey.photosite(
	codesite public.identifiant not null,
	codephoto public.identifiant not null,
	descrphoto public.libelle not null,
	codefic public.identifiant not null,
	nomfic public.nom not null,
	mimefic public.nom not null,
	taillefic numeric not null
	);

alter table srservey.photosite add constraint pkphotosite primary key (codesite, codephoto);

create or replace procedure srservey.ajouterphotosite(pcodesite public.identifiant, pcodephoto public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
		vdescrphoto public.libelle;
		vcodefic public.identifiant;
		vnomfic public.nom;
		vmimefic public.nom;
		vtaillefic numeric;
	begin
		assert(pcodesite is not null),'Le code du site est vide.';
		assert(public.existencetuple('srservey', 'site', 'codesite', pcodesite)),'Le code <'|| pcodesite ||'> du site est inconnu.';
		assert(pcodephoto is not null),'Le code de la photo est vide.';	
		assert(public.existencetuple('srservey', 'photo', 'codephoto', pcodephoto)),'Le code <'|| pcodephoto ||'> de la photo est inconnu.';
		execute format('select exists (select * from srservey.photosite where codesite = $1 and codephoto = $2)')
		into vtrouv
		using pcodesite, pcodephoto;
		assert(not vtrouv),'Le site <'|| pcodesite ||'> possede deja cette photo <'|| pcodephoto ||'>.';
	
		execute format('select descrphoto, codefic from srservey.photo where codephoto = $1;')
		into vdescrphoto, vcodefic
		using pcodephoto;
		execute format('select nomfic, mimefic, taillefic from srfichier.fichier where codefic = $1;')
		into vnomfic, vmimefic, vtaillefic
		using vcodefic;
		execute format('insert into srservey.photosite(codesite, codephoto, descrphoto, codefic, nomfic, mimefic, taillefic) values ($1, $2, $3, $4, $5, $6, $7);')
		using pcodesite, pcodephoto, vdescrphoto, vcodefic, vnomfic, vmimefic, vtaillefic;
	
		execute format('select exists (select * from srservey.photosite where codesite = $1 and codephoto = $2)')
		into vtrouv
		using pcodesite, pcodephoto;
		assert(vtrouv),'Incoherence sur les donnees inserees.';
	end;
	$$;

create or replace procedure srservey.retirerphotosite(pcodesite public.identifiant, pcodephoto public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
	begin
		assert(pcodesite is not null),'Le code du site est vide.';
		assert(public.existencetuple('srservey', 'site', 'codesite', pcodesite)),'Le code <'|| pcodesite ||'> du site est inconnu.';
		assert(pcodephoto is not null),'Le code de la photo est vide.';	
		assert(public.existencetuple('srservey', 'photo', 'codephoto', pcodephoto)),'Le code <'|| pcodephoto ||'> de la photo est inconnu.';
		execute format('select exists (select * from srservey.photosite where codesite = $1 and codephoto = $2)')
		into vtrouv
		using pcodesite, pcodephoto;
		assert(vtrouv),'Le site <'|| pcodesite ||'> ne possede pas cette photo <'|| pcodephoto ||'>.';
	
		execute format('delete from srservey.photosite where codesite = $1 and codephoto = $2;')
		using pcodesite, pcodephoto;
	
		execute format('select exists (select * from srservey.photosite where codesite = $1 and codephoto = $2)')
		into vtrouv
		using pcodesite, pcodephoto;
		assert(not vtrouv),'Incoherence sur les donnees supprimees.';
	end;
	$$;

create or replace function srservey.obtentionphotosite(pcodesite public.identifiant, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codesite public.identifiant, codephoto public.identifiant, descrphoto public.libelle, codefic public.identifiant, nomfic public.nom, mimefic public.nom, taillefic numeric)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodesite is not null),'Le code du site est vide.';
		assert(public.existencetuple('srservey', 'site', 'codesite', pcodesite)),'Le code <'|| pcodesite ||'> du site est inconnu.';
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		return query select ps.codesite, ps.codephoto, ps.descrphoto, ps.codefic, ps.nomfic, ps.mimefic, ps.taillefic from srservey.photosite ps where ps.codesite = pcodesite limit plimit offset pdebut;	
	
	end;
	$$;

-- ======== Creation de la table operateursite
-- ==========================================================================================================================================
create table srservey.operateursite(
	codesite public.identifiant not null,
	codeoperateur public.identifiant not null,
	enumoperateur public.enumnomenclature not null
	);

alter table srservey.operateursite add constraint pkoperateursite primary key (codesite, codeoperateur);

create or replace procedure srservey.ajouteroperateursite(pcodesite public.identifiant, pcodeoperateur public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
		venumoperateur public.enumnomenclature;
	begin
		assert(pcodesite is not null),'Le code du site est vide.';
		assert(public.existencetuple('srservey', 'site', 'codesite', pcodesite)),'Le code <'|| pcodesite ||'> du site est inconnu.';
		assert(pcodeoperateur is not null),'Le code de l''operateur est vide.';	
		assert(public.existencetuple('srdomaine', 'nomenclature', 'codenomen', pcodeoperateur)),'Le code <'|| pcodeoperateur ||'> de l''operateur est inconnu.';
		execute format('select exists (select * from srservey.operateursite where codesite = $1 and codeoperateur = $2)')
		into vtrouv
		using pcodesite, pcodeoperateur;
		assert(not vtrouv),'Le site <'|| pcodesite ||'> possede deja cet operateur <'|| pcodeoperateur ||'>.';
	
		execute format('select enumnomen from srdomaine.nomenclature where codenomen = $1;')
		into venumoperateur
		using pcodeoperateur;
		execute format('insert into srservey.operateursite(codesite, codeoperateur, enumoperateur) values ($1, $2, $3);')
		using pcodesite, pcodeoperateur, venumoperateur;
	
		execute format('select exists (select * from srservey.operateursite where codesite = $1 and codeoperateur = $2)')
		into vtrouv
		using pcodesite, pcodeoperateur;
		assert(vtrouv),'Incoherence sur les donnees inserees.';
	end;
	$$;

create or replace procedure srservey.retireroperateursite(pcodesite public.identifiant, pcodeoperateur public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
	begin
		assert(pcodesite is not null),'Le code du site est vide.';
		assert(public.existencetuple('srservey', 'site', 'codesite', pcodesite)),'Le code <'|| pcodesite ||'> du site est inconnu.';
		assert(pcodeoperateur is not null),'Le code de l''operateur est vide.';	
		assert(public.existencetuple('srdomaine', 'nomenclature', 'codenomen', pcodeoperateur)),'Le code <'|| pcodeoperateur ||'> de l''operateur est inconnu.';
		execute format('select exists (select * from srservey.operateursite where codesite = $1 and codeoperateur = $2)')
		into vtrouv
		using pcodesite, pcodeoperateur;
		assert(vtrouv),'Le site <'|| pcodesite ||'> ne possede pas cet operateur <'|| pcodeoperateur ||'>.';
	
		execute format('delete from srservey.operateursite where codesite = $1 and codeoperateur = $2;')
		using pcodesite, pcodeoperateur;
	
		execute format('select exists (select * from srservey.operateursite where codesite = $1 and codeoperateur = $2)')
		into vtrouv
		using pcodesite, pcodeoperateur;
		assert(not vtrouv),'Incoherence sur les donnees supprimees.';
	end;
	$$;

create or replace function srservey.obtentionoperateursite(pcodesite public.identifiant)
	returns table(codesite public.identifiant, codeoperateur public.identifiant, enumoperateur public.enumnomenclature)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodesite is not null),'Le code du site est vide.';
		assert(public.existencetuple('srservey', 'site', 'codesite', pcodesite)),'Le code <'|| pcodesite ||'> du site est inconnu.';
		
		return query select os.codesite, os.codeoperateur, os.enumoperateur from srservey.operateursite os where os.codesite = pcodesite;
	
	end;
	$$;

-- ======== Creation de la table servey
-- ==========================================================================================================================================
create table srservey.servey(
	codeservey public.identifiant not null,
	statutservey public.etat not null,
	nomreseau public.libelle not null,
	dateservey date not null,
	codepays public.identifiant not null,
	enumpays public.enumnomenclature not null,
	codeville public.identifiant not null,
	enumville public.enumnomenclature not null,
	clientmobile numeric not null,
	clientbtob numeric not null,
	coderesposerv public.identifiant not null,
	pinresposervey public.codepin not null,
	codeutilis public.identifiant not null,
	codesite public.identifiant not null,
	nomsite public.libelle not null,
	immeuble boolean not null,
	hauteur numeric null,
	dalle boolean null,
	descrdalle public.libelle null,
	sourcelectrique boolean not null,
	priseterre boolean not null,
	operateurs boolean not null,
	longitude numeric(25,20) not null,
	latitude numeric(25,20) not null,
	adresse public.libelle null,
	descrenviron public.libelle null,
	etat public.etat not null,
	ord public.enaturelnn not null,
	datecrea timestamp not null,
	dateupda timestamp null);

alter table srservey.servey add constraint pkservey primary key (codeservey);
alter table srservey.servey add constraint chkinvariantdatecreaupdaservey check (datecrea <= dateupda);

create or replace procedure srservey.ajouterservey(pcode public.identifiant, pstatutservey public.etat, pnomreseau public.libelle, pdateservey date, pcodepays public.identifiant, pcodeville public.identifiant, pclientmobile numeric, pclientbtob numeric, pcodesite public.identifiant, pcoderesposerv public.identifiant, petat public.etat, pord public.enaturelnn, pdatecrea timestamp)
	language plpgsql
	as $$
	declare
		vstatutservey public.etat;
		vnomreseau public.libelle;
		vdateservey date;
		vcodepays public.identifiant;
		venumpays public.enumnomenclature;
		vcodeville public.identifiant;
		venumville public.enumnomenclature;
		vclientmobile numeric;
		vclientbtob numeric;
		vcodesite public.identifiant;
		vcoderesposerv public.identifiant;
		vpinresposervey public.codepin;
		vcodeutilis public.identifiant;
		vnomsite public.libelle;
		vimmeuble boolean;
		vhauteur numeric;
		vdalle boolean;
		vdescrdalle public.libelle;
		vsourcelectrique boolean;
		vpriseterre boolean;
		voperateurs boolean;
		vlongitude numeric(25,20);
		vlatitude numeric(25,20);
		vadresse public.libelle;
		vdescrenviron public.libelle;
		vetat public.etat;
		vord public.enaturelnn;
		vdatecrea timestamp;
	begin 
		
		assert(pcode is not null),'Le code du servey est vide.';
		assert(not public.existencetuple('srservey', 'servey', 'codeservey', pcode)),'Le code <'|| pcode ||'> du servey existe deja.';
		assert(pstatutservey = 1),'Le statut du servey est incoherent.';
		assert(pnomreseau is not null),'Le nom du reseau est vide.';
		assert(pdateservey is not null),'La date du servey est vide.';
		assert(pcodepays is not null),'Le code du pays est vide.';
		assert(pcodeville is not null),'Le code de la ville est vide.';
		assert(pclientmobile is not null),'L''attribut client mobile est vide.';
		assert(pclientbtob is not null),'L''attribut client btob est vide.';
		assert(pcodesite is not null),'Le code du site est vide.';
		assert(public.existencetuple('srservey', 'site', 'codesite', pcodesite)),'Le code <'|| pcodesite ||'> du site est inconnu.';
		assert(pcoderesposerv is not null),'Le code du responsable du servey est vide.';
		assert(public.existencetuple('srutilisateur', 'resposervey', 'coderesposerv', pcoderesposerv)),'Le code <'|| pcoderesposerv ||'> du responsable du servey est inconnu.';
		assert(petat = 1),'L''etat du servey est incoherent.';
		assert(pord > 0),'L''ordre du servey est incoherent.';
		assert(pdatecrea is not null),'La date de creation du servey est vide.';
	
		execute format('select enumnomen from srdomaine.nomenclature where codenomen = $1')
		into venumpays
		using pcodepays;
		execute format('select enumnomen from srdomaine.nomenclature where codenomen = $1')
		into venumville
		using pcodeville;
		execute format('select nomsite, immeuble, hauteur, dalle, descrdalle, sourcelectrique, priseterre, operateurs, longitude, latitude, adresse, descrenviron from srservey.site where codesite = $1')
		into vnomsite, vimmeuble, vhauteur, vdalle, vdescrdalle, vsourcelectrique, vpriseterre, voperateurs, vlongitude, vlatitude, vadresse, vdescrenviron
		using pcodesite;
		execute format('select pinresposervey, codeutilis from srutilisateur.resposervey where coderesposerv = $1')
		into vpinresposervey, vcodeutilis
		using pcoderesposerv;
		execute format('insert into srservey.servey (codeservey, statutservey, nomreseau, dateservey, codepays, enumpays, codeville, enumville, clientmobile, clientbtob, coderesposerv, pinresposervey, codeutilis, codesite, nomsite, immeuble, hauteur, dalle, descrdalle, sourcelectrique, priseterre, operateurs, longitude, latitude, adresse, descrenviron, etat, ord, datecrea) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29)')
		using pcode, pstatutservey, pnomreseau, pdateservey, pcodepays, venumpays, pcodeville, venumville, pclientmobile, pclientbtob, pcoderesposerv, vpinresposervey, vcodeutilis, pcodesite, vnomsite, vimmeuble, vhauteur, vdalle, vdescrdalle, vsourcelectrique, vpriseterre, voperateurs, vlongitude, vlatitude, vadresse, vdescrenviron, petat, pord, pdatecrea;
	
		execute format('select statutservey, nomreseau, dateservey, codepays, codeville, clientmobile, clientbtob, coderesposerv, codesite, etat, ord, datecrea from srservey.servey where codeservey = $1')
		into vstatutservey, vnomreseau, vdateservey, vcodepays, vcodeville, vclientmobile, vclientbtob, vcoderesposerv, vcodesite, vetat, vord, vdatecrea
		using pcode;	
		assert(vstatutservey = pstatutservey),'Incoherence 1 sur les donnees inserees. statutservey';
		assert(vnomreseau = pnomreseau),'Incoherence 1 sur les donnees inserees. nomreseau';
		assert(vdateservey = pdateservey),'Incoherence 1 sur les donnees inserees. dateservey';
		assert(vcodepays = pcodepays),'Incoherence 1 sur les donnees inserees. codepays';
		assert(vcodeville = pcodeville),'Incoherence 1 sur les donnees inserees. codeville';
		assert(vclientmobile = pclientmobile),'Incoherence 1 sur les donnees inserees. clientmobile';
		assert(vclientbtob = pclientbtob),'Incoherence 1 sur les donnees inserees. clientbtob';
		assert(vcoderesposerv = pcoderesposerv),'Incoherence 1 sur les donnees inserees. coderesposerv';
		assert(vcodesite = pcodesite),'Incoherence 1 sur les donnees inserees. codesite';
		assert(vetat = petat),'Incoherence 1 sur les donnees inserees. etat';
		assert(vord = pord),'Incoherence 1 sur les donnees inserees. ord';
		assert(vdatecrea = pdatecrea),'Incoherence 1 sur les donnees inserees. datecrea';
		
	end;
	$$;

create or replace procedure srservey.mettreajourservey(pcode public.identifiant, pnomreseau public.libelle, pdateservey date, pcodepays public.identifiant, pcodeville public.identifiant, pclientmobile numeric, pclientbtob numeric, pcodesite public.identifiant, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vnomreseau public.libelle;
		vdateservey date;
		vcodepays public.identifiant;
		venumpays public.enumnomenclature;
		vcodeville public.identifiant;
		venumville public.enumnomenclature;
		vclientmobile numeric;
		vclientbtob numeric;
		vcodesite public.identifiant;
		vnomsite public.libelle;
		vimmeuble boolean;
		vhauteur numeric;
		vdalle boolean;
		vdescrdalle public.libelle;
		vsourcelectrique boolean;
		vpriseterre boolean;
		voperateurs boolean;
		vlongitude numeric(25,20);
		vlatitude numeric(25,20);
		vadresse public.libelle;
		vdescrenviron public.libelle;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du servey est vide.';
		assert(public.existencetuple('srservey', 'servey', 'codeservey', pcode)),'Le code <'|| pcode ||'> du servey  est inconnu.';
		assert(pnomreseau is not null),'Le nom du reseau est vide.';
		assert(pdateservey is not null),'La date du servey est vide.';
		assert(pcodepays is not null),'Le code du pays est vide.';
		assert(pcodeville is not null),'Le code de la ville est vide.';
		assert(pclientmobile is not null),'L''attribut client mobile est vide.';
		assert(pclientbtob is not null),'L''attribut client btob est vide.';
		assert(pcodesite is not null),'Le code du site est vide.';
		assert(public.existencetuple('srservey', 'site', 'codesite', pcodesite)),'Le code <'|| pcodesite ||'> du site est inconnu.';
		execute format('select dateupda from srservey.servey where codeservey = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour est incoherente.';
	
		execute format('select enumnomen from srdomaine.nomenclature where codenomen = $1')
		into venumpays
		using pcodepays;
		execute format('select enumnomen from srdomaine.nomenclature where codenomen = $1')
		into venumville
		using pcodeville;
		execute format('select nomsite, immeuble, hauteur, dalle, descrdalle, sourcelectrique, priseterre, operateurs, longitude, latitude, adresse, descrenviron from srservey.site where codesite = $1')
		into vnomsite, vimmeuble, vhauteur, vdalle, vdescrdalle, vsourcelectrique, vpriseterre, voperateurs, vlongitude, vlatitude, vadresse, vdescrenviron
		using pcodesite;
		execute format('update srservey.servey set nomreseau = $1, dateservey = $2, codepays = $3, enumpays = $4, codeville = $5, enumville = $6, clientmobile = $7, clientbtob = $8, codesite = $9, nomsite = $10, immeuble = $11, hauteur = $12, dalle = $13, descrdalle = $14, sourcelectrique = $15, priseterre = $16, operateurs = $17, longitude = $18, latitude = $19, adresse = $20, descrenviron = $21, dateupda = $22 where codeservey = $23')
		using pnomreseau, pdateservey, pcodepays, venumpays, pcodeville, venumville, pclientmobile, pclientbtob, pcodesite, vnomsite, vimmeuble, vhauteur, vdalle, vdescrdalle, vsourcelectrique, vpriseterre, voperateurs, vlongitude, vlatitude, vadresse, vdescrenviron, pdateupda, pcode;
	
		execute format('select nomreseau, dateservey, codepays, codeville, clientmobile, clientbtob, codesite, dateupda from srservey.servey where codeservey = $1')
		into vnomreseau, vdateservey, vcodepays, vcodeville, vclientmobile, vclientbtob, vcodesite, vdateupda
		using pcode;	
		assert(vnomreseau = pnomreseau),'Incoherence 1 sur les donnees mises a jour. nomreseau';
		assert(vdateservey = pdateservey),'Incoherence 1 sur les donnees mises a jour. dateservey';
		assert(vcodepays = pcodepays),'Incoherence 1 sur les donnees mises a jour. codepays';
		assert(vcodeville = pcodeville),'Incoherence 1 sur les donnees mises a jour. codeville';
		assert(vclientmobile = pclientmobile),'Incoherence 1 sur les donnees mises a jour. clientmobile';
		assert(vclientbtob = pclientbtob),'Incoherence 1 sur les donnees mises a jour. clientbtob';
		assert(vcodesite = pcodesite),'Incoherence 1 sur les donnees mises a jour. codesite';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace procedure srservey.mettreajoursoumissionservey(pcode public.identifiant, pstatutservey public.etat, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vstatutservey public.etat;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du servey est vide.';
		assert(public.existencetuple('srservey', 'servey', 'codeservey', pcode)),'Le code <'|| pcode ||'> du servey est inconnu.';
		assert(pstatutservey = 2),'Le statut du servey est incoherent.';	
		execute format('select dateupda from srservey.servey where codeservey = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour est incoherente.';
	
		execute format('update srservey.servey set statutservey = $1, dateupda = $2 where codeservey = $3')
		using pstatutservey, pdateupda, pcode;
	
		execute format('select statutservey, datecrea from srservey.servey where codeservey = $1')
		into vstatutservey, vdateupda
		using pcode;	
		assert(vstatutservey = pstatutservey),'Incoherence 1 sur les donnees mises a jour. statutservey';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace procedure srservey.mettreajouracceptationservey(pcode public.identifiant, pstatutservey public.etat, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vstatutservey public.etat;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du servey est vide.';
		assert(public.existencetuple('srservey', 'servey', 'codeservey', pcode)),'Le code <'|| pcode ||'> du servey est inconnu.';
		assert(pstatutservey = 2),'Le statut du servey est incoherent.';	
		execute format('select dateupda from srservey.servey where codeservey = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour est incoherente.';
	
		execute format('update srservey.servey set statutservey = $1, dateupda = $2 where codeservey = $3')
		using pstatutservey, pdateupda, pcode;
	
		execute format('select statutservey, datecrea from srservey.servey where codeservey = $1')
		into vstatutservey, vdateupda
		using pcode;	
		assert(vstatutservey = pstatutservey),'Incoherence 1 sur les donnees mises a jour. statutservey';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace procedure srservey.mettreajourejetservey(pcode public.identifiant, pstatutservey public.etat, pdateupda timestamp)
	language plpgsql
	as $$
	declare
		vstatutservey public.etat;
		vdateupda timestamp;
	begin 
		
		assert(pcode is not null),'Le code du servey est vide.';
		assert(public.existencetuple('srservey', 'servey', 'codeservey', pcode)),'Le code <'|| pcode ||'> du servey  est inconnu.';
		assert(pstatutservey = 2),'Le statut du servey est incoherent.';	
		execute format('select dateupda from srservey.servey where codeservey = $1')
		into vdateupda
		using pcode;
		assert((pdateupda >= vdateupda) or (vdateupda is null)),'La date de mise a jour est incoherente.';
	
		execute format('update srservey.servey set statutservey = $1, dateupda = $2 where codeservey = $3')
		using pstatutservey, pdateupda, pcode;
	
		execute format('select statutservey, datecrea from srservey.servey where codeservey = $1')
		into vstatutservey, vdateupda
		using pcode;	
		assert(vstatutservey = pstatutservey),'Incoherence 1 sur les donnees mises a jour. statutservey';
		assert(vdateupda = pdateupda),'Les donnees mises a jour sont incoherentes. dateupda';
		
	end;
	$$;

create or replace function srservey.obtentionservey(pcode public.identifiant)
	returns table(codeservey public.identifiant, statutservey public.etat, nomreseau public.libelle, dateservey date, codepays public.identifiant, enumpays public.enumnomenclature, codeville public.identifiant, enumville public.enumnomenclature, clientmobile numeric, clientbtob numeric, coderesposerv public.identifiant, pinresposervey public.codepin, codeutilis public.identifiant, codesite public.identifiant, nomsite public.libelle, immeuble boolean, hauteur numeric, dalle boolean, descrdalle public.libelle, sourcelectrique boolean, priseterre boolean, operateurs boolean, longitude numeric(25,20), latitude numeric(25,20), adresse public.libelle, descrenviron public.libelle)
	language plpgsql
	as $$
	begin 
		
		assert(pcode is not null),'Le code du servey est vide.';
		assert(public.existencetuple('srservey', 'servey', 'codeservey', pcode)),'Le code <'|| pcode ||'> du servey est inconnu.';
	
		return query select s.codeservey, s.statutservey, s.nomreseau, s.dateservey, s.codepays, s.enumpays, s.codeville, s.enumville, s.clientmobile, s.clientbtob, s.coderesposerv, s.pinresposervey, s.codeutilis, s.codesite, s.nomsite, s.immeuble, s.hauteur, s.dalle, s.descrdalle, s.sourcelectrique, s.priseterre, s.operateurs, s.longitude, s.latitude, s.adresse, s.descrenviron from srservey.servey s where s.codeservey = pcode;
		
	end;
	$$;

create or replace function srservey.obtentionserveyresposervey(pcoderesposerv public.identifiant, pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codeservey public.identifiant, statutservey public.etat, nomreseau public.libelle, dateservey date, codepays public.identifiant, enumpays public.enumnomenclature, codeville public.identifiant, enumville public.enumnomenclature, clientmobile numeric, clientbtob numeric, coderesposerv public.identifiant, pinresposervey public.codepin, codeutilis public.identifiant, codesite public.identifiant, nomsite public.libelle, immeuble boolean, hauteur numeric, dalle boolean, descrdalle public.libelle, sourcelectrique boolean, priseterre boolean, operateurs boolean, longitude numeric(25,20), latitude numeric(25,20), adresse public.libelle, descrenviron public.libelle)
	language plpgsql
	as $$
	begin 
		
		assert(pcoderesposerv is not null),'Le code du responsable du servey est vide.';
		assert(public.existencetuple('srutilisateur', 'resposervey', 'coderesposerv', pcoderesposerv)),'Le code <'|| pcoderesposerv ||'> du responsable du servey est inconnu.';	
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select s.codeservey, s.statutservey, s.nomreseau, s.dateservey, s.codepays, s.enumpays, s.codeville, s.enumville, s.clientmobile, s.clientbtob, s.coderesposerv, s.pinresposervey, s.codeutilis, s.codesite, s.nomsite, s.immeuble, s.hauteur, s.dalle, s.descrdalle, s.sourcelectrique, s.priseterre, s.operateurs, s.longitude, s.latitude, s.adresse, s.descrenviron from srservey.servey s where s.etat <> 3 and s.coderesposerv = pcoderesposerv order by s.ord desc limit plimit offset pdebut;
		else
			return query select s.codeservey, s.statutservey, s.nomreseau, s.dateservey, s.codepays, s.enumpays, s.codeville, s.enumville, s.clientmobile, s.clientbtob, s.coderesposerv, s.pinresposervey, s.codeutilis, s.codesite, s.nomsite, s.immeuble, s.hauteur, s.dalle, s.descrdalle, s.sourcelectrique, s.priseterre, s.operateurs, s.longitude, s.latitude, s.adresse, s.descrenviron from srservey.servey s where s.etat <> 3 and s.coderesposerv = pcoderesposerv and (s.nomsite ilike '%'|| pcritere ||'%') order by s.ord desc limit plimit offset pdebut;
		end if;		
		
	end;
	$$;

create or replace function srservey.rechercheserveys(pcritere public.libelle, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codeservey public.identifiant, statutservey public.etat, nomreseau public.libelle, dateservey date, codepays public.identifiant, enumpays public.enumnomenclature, codeville public.identifiant, enumville public.enumnomenclature, clientmobile numeric, clientbtob numeric, coderesposerv public.identifiant, pinresposervey public.codepin, codeutilis public.identifiant, codesite public.identifiant, nomsite public.libelle, immeuble boolean, hauteur numeric, dalle boolean, descrdalle public.libelle, sourcelectrique boolean, priseterre boolean, operateurs boolean, longitude numeric(25,20), latitude numeric(25,20), adresse public.libelle, descrenviron public.libelle)  
	language plpgsql
	as $$
	declare
	begin 
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select s.codeservey, s.statutservey, s.nomreseau, s.dateservey, s.codepays, s.enumpays, s.codeville, s.enumville, s.clientmobile, s.clientbtob, s.coderesposerv, s.pinresposervey, s.codeutilis, s.codesite, s.nomsite, s.immeuble, s.hauteur, s.dalle, s.descrdalle, s.sourcelectrique, s.priseterre, s.operateurs, s.longitude, s.latitude, s.adresse, s.descrenviron from srservey.servey s where s.etat <> 3 order by s.ord desc limit plimit offset pdebut;
		else
			return query select s.codeservey, s.statutservey, s.nomreseau, s.dateservey, s.codepays, s.enumpays, s.codeville, s.enumville, s.clientmobile, s.clientbtob, s.coderesposerv, s.pinresposervey, s.codeutilis, s.codesite, s.nomsite, s.immeuble, s.hauteur, s.dalle, s.descrdalle, s.sourcelectrique, s.priseterre, s.operateurs, s.longitude, s.latitude, s.adresse, s.descrenviron from srservey.servey s where s.etat <> 3 and (s.nomsite ilike '%'|| pcritere ||'%') order by s.ord desc limit plimit offset pdebut;
		end if;
	
	end;
	$$;

-- ======== Creation de la table wifiservey
-- ==========================================================================================================================================
create table srservey.wifiservey(
	codeservey public.identifiant not null,
	codewifi public.identifiant not null,
	nomwifi public.libelle not null,
	frequence public.nom not null,
	canal public.nom not null
	);

alter table srservey.wifiservey add constraint pkwifiservey primary key (codeservey, codewifi);

create or replace procedure srservey.ajouterwifiservey(pcodeservey public.identifiant, pcodewifi public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
		vnomwifi public.libelle;
		vfrequence public.nom;
		vcanal public.nom;
	begin
		assert(pcodeservey is not null),'Le code du servey est vide.';
		assert(public.existencetuple('srservey', 'servey', 'codeservey', pcodeservey)),'Le code <'|| pcodeservey ||'> du servey est inconnu.';
		assert(pcodewifi is not null),'Le code du wifi est vide.';	
		assert(public.existencetuple('srservey', 'wifi', 'codewifi', pcodewifi)),'Le code <'|| pcodewifi ||'> du wifi est inconnu.';
		execute format('select exists (select * from srservey.wifiservey where codeservey = $1 and codewifi = $2)')
		into vtrouv
		using pcodeservey, pcodewifi;
		assert(not vtrouv),'Le servey <'|| pcodeservey ||'> possede deja cette wifi <'|| pcodewifi ||'>.';
	
		execute format('select nomwifi, frequence, canal from srservey.wifi where codewifi = $1;')
		into vnomwifi, vfrequence, vcanal
		using pcodewifi;
		execute format('insert into srservey.wifiservey(codeservey, codewifi, nomwifi, frequence, canal) values ($1, $2, $3, $4, $5);')
		using pcodeservey, pcodewifi, vnomwifi, vfrequence, vcanal;
	
		execute format('select exists (select * from srservey.wifiservey where codeservey = $1 and codewifi = $2)')
		into vtrouv
		using pcodeservey, pcodewifi;
		assert(vtrouv),'Incoherence sur les donnees inserees.';
	end;
	$$;

create or replace procedure srservey.retirerwifiservey(pcodeservey public.identifiant, pcodewifi public.identifiant)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
	begin
		assert(pcodeservey is not null),'Le code du servey est vide.';
		assert(public.existencetuple('srservey', 'servey', 'codeservey', pcodeservey)),'Le code <'|| pcodeservey ||'> du servey est inconnu.';
		assert(pcodewifi is not null),'Le code du wifi est vide.';	
		assert(public.existencetuple('srservey', 'wifi', 'codewifi', pcodewifi)),'Le code <'|| pcodewifi ||'> du wifi est inconnu.';
		execute format('select exists (select * from srservey.wifiservey where codeservey = $1 and codewifi = $2)')
		into vtrouv
		using pcodeservey, pcodewifi;
		assert(vtrouv),'Le servey <'|| pcodeservey ||'> ne possede pas cette wifi <'|| pcodewifi ||'>.';
	
		execute format('delete from srservey.wifiservey where codeservey = $1 and codewifi = $2;')
		using pcodeservey, pcodewifi;
	
		execute format('select exists (select * from srservey.wifiservey where codeservey = $1 and codewifi = $2)')
		into vtrouv
		using pcodeservey, pcodewifi;
		assert(not vtrouv),'Incoherence sur les donnees supprimees.';
	end;
	$$;

create or replace function srservey.obtentionwifiservey(pcodeservey public.identifiant, pdebut public.enaturel, plimit public.enaturelnn)
	returns table(codeservey public.identifiant, codewifi public.identifiant, nomwifi public.libelle, frequence public.nom, canal public.nom)  
	language plpgsql
	as $$
	declare
	begin 
		
		assert(pcodeservey is not null),'Le code du servey est vide.';
		assert(public.existencetuple('srservey', 'servey', 'codeservey', pcodeservey)),'Le code <'|| pcodeservey ||'> du servey est inconnu.';
		assert(pdebut is not null),'Le nombre de ligne a passer est vide.';
		assert(plimit is not null),'Le nombre de ligne a renvoyer est vide.';
		
		if (pcritere is null) then
			return query select ws.codeservey, ws.codewifi, ws.nomwifi, ws.frequence, ws.canal from srservey.wifiservey ws where ws.codeservey = pcodeservey order by ws.ord desc limit plimit offset pdebut;
		else
			return query select ws.codeservey, ws.codewifi, ws.nomwifi, ws.frequence, ws.canal from srservey.wifiservey ws where ws.codeservey = pcodeservey and (ws.nomsite ilike '%'|| pcritere ||'%') order by ws.ord desc limit plimit offset pdebut;
		end if;	
	
	end;
	$$;

-- ======== Creation de la table soumissionservey
-- ==========================================================================================================================================
create table srservey.soumissionservey(
	codeservey public.identifiant not null,
	datesoumis timestamp not null);

alter table srservey.soumissionservey add constraint pksoumissionservey primary key (codeservey, datesoumis);

create or replace procedure srservey.ajoutersoumissionservey(pcodeservey public.identifiant, pdatesoumis timestamp)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
	begin
		
		assert(pcodeservey is not null),'Le code du servey est vide.';
		assert(public.existencetuple('srservey', 'servey', 'codeservey', pcodeservey)),'Le code <'|| pcodeservey ||'> du servey est inconnu.';	
		assert(pdatesoumis is not null),'La date de soumission du servey est vide.';		
	
		execute format('insert into srservey.soumissionservey (codeservey, datesoumis) values ($1, $2)')
		using pcodeservey, pdatesoumis;
		
		execute format('select exists (select * from srservey.soumissionservey ws where ss.codeservey = $1 and ss.datesoumis = $2)')
		into vtrouv
		using pcodeservey, pdatesoumis;
		assert(vtrouv),'Incoherences sur les donnees inserees.';
	
	end;
	$$;

-- ======== Creation de la table acceptationservey
-- ==========================================================================================================================================
create table srservey.acceptationservey(
	codeservey public.identifiant not null,
	dateaccept timestamp not null);

alter table srservey.acceptationservey add constraint pkacceptationservey primary key (codeservey, dateaccept);

create or replace procedure srservey.ajouteracceptationservey(pcodeservey public.identifiant, pdateaccept timestamp)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
	begin
		
		assert(pcodeservey is not null),'Le code du servey est vide.';
		assert(public.existencetuple('srservey', 'servey', 'codeservey', pcodeservey)),'Le code <'|| pcodeservey ||'> du servey est inconnu.';	
		assert(pdateaccept is not null),'La date d''acceptation du servey est vide.';
	
		execute format('insert into srservey.acceptationservey (codeservey, dateaccept) values ($1, $2)')
		using pcodeservey, pdateaccept;
		
		execute format('select exists (select * from srservey.acceptationservey acs where acs.codeservey = $1 and acs.dateaccept = $2)')
		into vtrouv
		using pcodeservey, pdateaccept;
		assert(vtrouv),'Incoherences sur les donnees inserees.';
	
	end;
	$$;

-- ======== Creation de la table rejetservey
-- ==========================================================================================================================================
create table srservey.rejetservey(
	codeservey public.identifiant not null,
	daterejet timestamp not null);

alter table srservey.rejetservey add constraint pkrejetservey primary key (codeservey, daterejet);

create or replace procedure srservey.creerejetservey(pcodeservey public.identifiant, pdaterejet timestamp)
	language plpgsql
	as $$
	declare
		vtrouv boolean;
	begin
		
		assert(pcodeservey is not null),'Le code du servey est vide.';
		assert(public.existencetuple('srservey', 'servey', 'codeservey', pcodeservey)),'Le code <'|| pcodeservey ||'> du servey est inconnu.';
		assert(pdaterejet is not null),'La date de rejet du servey est vide.';			
	
		execute format('insert into srservey.rejetservey (codeservey, daterejet) values ($1, $2)')
		using pcodeservey, pdaterejet;
		
		execute format('select exists (select * from srservey.rejetservey ws where rs.codeservey = $1 and rs.daterejet = $2)')
		into vtrouv
		using pcodeservey, pdaterejet;
		assert(vtrouv),'Incoherences sur les donnees inserees.';
	
	end;
	$$;






























