## Composant Dev_it

NB: le formatage de ce wiki est basique dans cette première version (car le markdown est généré à partir d'un script...), mais il sera amélioré dans les prochaines version => toutes mes confuses : pb de bande passante vs contraintes etc...

Il permet notament de gérer des développement de bundles en local, afin de faire des itération de développement/test de changement de code, à la fois dans une app et dans ces bundles.

Pour cela il permet de scripter les modifications nécéssaires des fichier pré-cités pour executer un bundle clonés en local, via le cycle suivant:

1. Cloner l'app et le(s) bundles à modifier;



  
2. configurer et lancer le script dev_it qui configure la version locale de ce(s) bundle(s) dans l'app;



  
3. lancer les container, puis lancer "make docker/cmds" pour exécuter dedans les "composer update" du/de(s) bundle(s) en local;



  
4. développer/tester les changement de code à la fois dans l'app et le(s) bundle(s);



  
5. pusher et releaser le(s) bundle(s) une fois les dev/test terminés;



  
6. configurer et lancer le script dev_it qui restore la version de l'app avec le(s) bundle(s) releasé(s);



  
7. lancer "make docker/cmds" pour exécuter les "composer update" du/de(s) bundle(s) releasé(s);



  
8. tester cette nouvelle version de l'app et si ok commiter/pusher cette version.



  




Ces script de configuration et restauration sont potentiellement spécifiques à chaque app, mais modifient les mêmes fichier en base : Dockerfile, docker-compose.yml, composer.json ...

Le composant dev_it expose pour cela des api permettant de modifier ces fichier:

* charger ces fichier sous forme de liste ou map manipulables: peu importe le format : json, Dockerfile ou yaml : le fichier est chargé en array/map (multi-dimensionel) ou objet spécifique et modifiable via une api identique quelquesoit le format d'origine:

    * un fichier json est chargé en base en array ou map selon son type de contenu,



  
    * un fichier yaml est chargé en map, 



  
    * un fichier Dockerfile est chargé en array de map contenant, un champ "cmd" indiquant la commande docker (RUN, COPY, FROM, VOLUME...), sa value ( = ce qu'il y a après la commande, ex : RUN "composer install ..." ou VOLUME "/srv/app...") et diverses autres infos...



  
    * il est possible de paraméter des types d'objet dédiés: par exemple, un fichier composer.json peut être paramétré comme un objet ayant:

        * une propriété "require" contenant la map bundle/versionConstraint,



  
        * une propriété "repositories" contenant un array d'objet de type Repository, un objet Repostory ayant une propriété "type" valant soit "vcs", soit "path", et une propriété url de type string;



  






  






  
* l'api propose une syntax d'accès classique à ces données et un langage de requete: exemple: 

    * maDockerComposeMap["version"] référence la valeur de l'entrée "version" de la map représentant un fichier docker-compose.yml,



  
    * monComposerObject.require référence la map bundle/versionConstraint de l'objet représentant un fichier composer,



  
    * monComposerObject.repositories[0].url = "/srv/app/mon_bundle.git" met à jour l'url du premier repository du fichier composer;



  
    * exemple de requete sur un Dockerfile array qui retourne la commande qui match via regexp un composer install:

        * return from var statment in statments



  
        *  where !(statment.cmd.includesMatch(re `(?i:run)`) && statment.original.includesMatch(re `(?i:composer\s+install)`))



  
        *  select statment;



  






  






  
* api de génération commune de ces fichier :

    * toDocker(maDockerfileMap, "./Dockerfile"): génère la maDockerfileMap au format "Dockerfile" dans le fichier ./Dockerfile,



  
    * toComposer(monComposerObject, "./composer.json") : génère monComposerObject au format "composer" dans le fichier ./composer.json.

        * NB: on a dit plus haut que monComposerObject est un paramétrage sous forme objet du fichier composer.json, avec seulement les deux propriétés ce fichier json: "require" et "repositories";  
donc on pourrait croire que cette fonction toComposer(monComposerObject, "./composer.json") ne va générer que ces deux propriétés dans le fichier, mais que neni: par défaut la totalité du contenu est générée (sauf si on spécifie explicitement de ne générer que les propriétés de l'objet);  
donc le principe en gros est de ne paramétrer sous forme d'objet typé que les propriétés du contenu json qu'on manipule par programme.



  






  






  




### Installation

To Be Completed ...







### Evolutions

Cette section décrit les évolutions prévues de ce composant.  
Les évolutions flaguées [refacto] décrivent des améliorations du code par rapport au guidelines de qualité de code.

* structurer le code par app: déplacer le code spécifique à une app dans un repertoire du nom de l'app;



  
* [refacto] définit un type pour les fichier json: le code de manipulation du fichier composer.json n'est pas basé sur une définition de type pour ce fichier;  
cela est du au fait que le champ json "type" d'un repository bugait lorsqu'on le définissait comme champ de type car "type" est un mot clé du langage, mais la doc dit de précéder les identifier correspondant à des mot clé du lanage par un '; il faut donc définir ce type de fichier avec une champ 'type et refactorer en conséquence le code de manupulation de ce type de fichier;  


