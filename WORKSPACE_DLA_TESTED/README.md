# Objectifs

- Réaliser des séries de mesures de différentes exécutions sur le DLA.
- Mesures à réaliser : latence, power, énergie
- CNN à tester : Inception, MobileNetV2, ResNet50, UNet, MobileNet-SSD, ResNet34-SSD, DeepLabV3
- Power modes à tester : mode max (MAXN) et min (15W)
- Versions de TensorRT à tester : celle pour le DLA V2 et celle pour le DLA V3 (cf diapo début de projet)
- Attention, il faut reflasher la carte Jetson Orin pour changer de version de TensorRT
 
# Contenu du dossier

- *.sh : scripts généraux
- onnx/ : les CNN en représentations intermédiaires
- engines/ : dossier qui va contenir les binaires de TensorRT
- profiles/ : dossier qui va contenir logs détaillé de TensorRT pour la construction des binaires 
- logs/ : dossier qui va contenir logs généraux de TensorRT pour la construction des binaires 

# Etape 1 : Configurer ou vérifier le power mode de la Jetson Orin

- nvpmodel -q  # Donne le mode actuel
- sudo nvpmodel -m 0  # Fixe le mode à 0 (voir doc Nvidia pour correspondance noms des power modes et chiffre)

# Etape 2 : Générer les binaires de TensorRT pour le DLA

- ./1_build_engines_dla.sh # Génère automatiquement tous les binaires engine des différents CNN
- Vérifier que le script ne renvoie pas d'erreur. Si un CNN ne fonctionne pas, me prévenir

# Etape 3 : Lire la latence pour chaque CNN exécuté sur le DLA

- Lire les dernières lignes des fichiers dans le logs/.
- Lire la latence médiane

# Etape 4 : Mesurer la puissance 

- Vérifier les arguments dans le fichier 2_launch_measure_power.sh, notamment le power mode et le nom du CNN
- Vérifier les chemins des rails d'alimentations dans le fichier 2a_power_read_agx.sh, vérifier avec la doc
- sudo tegrastats # à lancer pendant 2 sec avant chaque mesure pour éviter les problèmes de lectures
- ./2_launch_measure_power.sh pour chaque CNN. Un dossier de log sera généré avec le nom du CNN et le power mode

# Etape 5 : Calculer la puissance et l'énergie moyenne

- ./3_calculate_energy.sh


# Debugs courants
- vérifier les chemins ou les noms de fichier, s'il manque un "/" en début de fichier ou autre
- lancer un "sudo tegrastats" avant les lectures de puissances

# Bonus : à tester pour un CNN uniquement  
- Dans un premier terminal, lancer "sudo tegrastats"
- Dans un deuxième terminal en parallèle, exécuter un des binaires de TensorRT :
    "/usr/src/tensorrt/bin/trtexec --loadEngine=/home/nvidia/workspace/engines/name.engine --iterations=$iter \
     --idleTime=$itime --warmUp=10000 --duration=10 --useSpinWait"
- Vérifier que la puissance indiquée par tegrastats est à peu près la même que celle donnée par le script 3_calculate_energy.sh pour le CNN correspondant
