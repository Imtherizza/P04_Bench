#!/bin/bash

# Faudra tenter de mettre ca en modulaire pck en oubliant de changer ls repertoires et le mode dla gpu j'ai perdu 1h de ma vie :(

sleeping_ms=0
iter=1000
itime=0
power="MODE_MAXN"
device="gpu" # dla0 or gpu (hahahahahaha)
a=0

# Créer un fichier CSV avec l'en-tête
echo "Engine,StartTimestamp,EndTimestamp" > inference_timestamps.csv

models=("inceptionh3v2" "mobilenetv2" "resnet50v1prep" "mobilenetssdv1prep" "resnet34ssdv1prep" "dlv3" "unetv2")
for nn in "${models[@]}"
#"inceptionh3v2"
    #mobilenetv2" 
   # resnet50v1prep" \
   # mobilenetssdv1prep" \
   # resnet34ssdv1prep" \
   # "dlv3" \
   # "unvetv2"
do
    engine="engines/${nn}_int8_${device}.engine"
    # Extraire le nom du fichier sans extension
    folder_name=$nn

    # Créer le dossier pour les logs si nécessaire
    log_folder="power_${power}_${sleeping_ms}ms_${nn}"
    mkdir -p "$log_folder"

    # Lancer les mesures
    (timeout 15m bash 2a_power_read_agx.sh) &
    
    start_timestamp=$(date +"%Y-%m-%d %H:%M:%S.%3N")
    echo "start inference at $start_timestamp"

    # Récupérer le PID du processus power_read_2.sh
    power_read_pid=$!

     # Lancer l'execution --loadEngine=/home/nvidia/Documents/test-Sean/WORKSPACE_DLA_TESTED/$engine \
    /usr/src/tensorrt/bin/trtexec \
        --loadEngine=/WORKSPACE_DLA_TESTED/$engine \
        --iterations=$iter \
    	--idleTime=$itime \
    	--warmUp=10000 \
    	--duration=10 \
        --useSpinWait >> "${log_folder}/power_${power}_${sleeping_ms}ms_${nn}_iteration_${iter}_idletime_${itime}.log" 2>&1
    end_timestamp=$(date +"%Y-%m-%d %H:%M:%S.%3N")
    echo "end inference at $end_timestamp"
    
    # Écrire les timestamps dans le fichier CSV
    echo "$nn,$start_timestamp,$end_timestamp" >> inference_timestamps.csv
	
    # Tuer le processus de power_read
    kill -TERM $power_read_pid

    a=$((a+1))
    echo $a

    echo "start sleeping "
    sleep 10s
    echo "end sleeping "
    
   
    wait
done
