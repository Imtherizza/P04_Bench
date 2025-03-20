Scripts de benchmark pour le projet P04
Mesure la latence et la consommation 
Quelques notes sur différents scripts
Les scripts dans le dossier WORKSPACE_DLA_TESTED sont fonctionnels

# Prérequis

Jetpack 5.12 (logique)

Docker avec les images correspondantes

Les reseaux neurones trop volumineux à importer

Environ 10-15Go de Stockage pour les images

Les mesures prennent environ 1h10

# start-containers.sh

Démarre de force les containers
Au cas ou un pépin se produit au démarrage de la carte mais eviter de démarrer

# run.sh

Args : test

Run avec sudo
Script de mesure, a completer

Lance un BATCH de mesure sur dla-2 et dla 3-14, DLA et GPU, on ignorera 1 pour l'instant
Théoriquement les GPU ne varient pas mais les versions de CUDA et autres changent donc les tests redondants sont effectués
Il est advisable de moyenner les 3(2) probablement et si il le faut je retirerai les suites GPU pour en laisser que un
--Aussi il est envisagé de retirer le batch dla 3-14 car déja chargé--

TODO : Réparer la copie dans les sous dossiers output, probablement cassée. Les résultats doivent être copiés directement du container pour l'instant

# clearoutput.sh

Supprime tout le repertoire output, a faire uniquement si c'est trop pollué

# forcecopy.sh

OBSOLETE
Args : "container"

Script temporaire
Run avec sudo
Copie les logs nsight dans output
Copie les logs dans le container dans output, a juger de quoi qui est utile

# forceclean.sh

Vide les containers du répertoire de travail si pollué ou corrompu

# overwrite.sh 

Éviter d'utilser ceci, laissé uniquement comme réference
