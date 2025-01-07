# Composant Dev_it

Ce composant permet de créer des scripts de manipulation des fichiers `Dockerfile`, `docker-compose.yml`, `composer.json`, etc., afin de les adapter à son environnement de développement.  

Il permet notamment de gérer des développements bundles en local pour effectuer des itérations de développement et de tests sur une application et ses bundles.  

## Fonctionnalités principales

Le composant facilite les étapes suivantes :
1. **Cloner l'application et les bundles à modifier.**
2. **Lancer le script `dev_it`** pour configurer les versions locales des bundles dans l'application.
3. **Démarrer les conteneurs et exécuter les commandes comme `composer update`** pour les bundles locaux.
4. **Développer et tester simultanément dans l'application et les bundles.**
5. **Publier et relâcher les bundles une fois les tests terminés.**
6. **Exécuter le script `dev_it`** pour restaurer l'application avec les bundles relâchés.
7. **Tester la nouvelle version de l'application, puis la valider en commitant et en poussant les changements.**

## Gestion des fichiers

Les scripts de configuration et de restauration modifient les mêmes fichiers de base : 
`Dockerfile`, `docker-compose.yml`, et `composer.json`.  

Le composant `dev_it` expose des API permettant de manipuler ces fichiers.  

### API de chargement des fichiers

L'API permet de charger ces fichiers sous forme de liste, de map, ou d'objet dédié. Le format d'origine du fichier est automatiquement géré :
- **Fichiers JSON :** chargés en array ou map selon leur contenu.
- **Fichiers YAML :** chargés en map.
- **Fichiers Dockerfile :** chargés en array de maps, chaque map contenant :
  - Un champ `cmd` (la commande Docker, ex. `RUN`, `COPY`, `FROM`, etc.).
  - Un champ `value` (le contenu après la commande, ex. `RUN "composer install..."`).
  - D'autres informations utiles.

Des types d'objet personnalisés peuvent être paramétrés, par exemple :
- Pour un fichier `composer.json` :
  - Une propriété `require` contenant une map `bundle/versionConstraint`.
  - Une propriété `repositories` contenant un array d'objets `Repository`.  
    - Un objet `Repository` a :
      - Une propriété `type` (`vcs` ou `path`).
      - Une propriété `url` (type string).

### Exemples d'accès et de requêtes

L'API propose une syntaxe classique pour accéder aux données et un langage de requêtes :
- Accès direct :
  ```ballerina
  maDockerComposeMap["version"]```
- Mise à jour :
  ```ballerina
  monComposerObject.repositories[0].url = "/srv/app/mon_bundle.git";```
- Requête sur un Dockerfile :
```ballerinareturn from var statment in statments
       where !(statment.cmd.includesMatch(re `(?i:run)`) && 
              statment.original.includesMatch(re `(?i:composer\s+install)`))
       select statment;
```

### API de génération des fichiers

Les fichiers modifiés peuvent être générés dans leur format d'origine :
- Générer un Dockerfile :
  ```ballerina
  toDocker(maDockerfileMap, "./Dockerfile");```
- Générer un fichier composer.json :
 ```ballerina
  toComposer(monComposerObject, "./composer.json");
```

## Installation

To Be Completed...
