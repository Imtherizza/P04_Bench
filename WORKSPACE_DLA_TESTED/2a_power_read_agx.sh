#!/bin/bash

# Chemin vers le répertoire sysfs des rails d'alimentation
SYSFS_PATH="/sys/bus/i2c/drivers/ina3221/1-0040/hwmon/hwmon3/"

# Fichier CSV pour stocker les données
CSV_FILE="power_data.csv"

# Liste des fichiers contenant les informations des rails d'alimentation
RAIL_FILES_VOLTAGE=($(cat "${SYSFS_PATH}in1_input") $(cat "${SYSFS_PATH}in2_input") $(cat "${SYSFS_PATH}in3_input") )
#RAIL_FILES_VOLTAGE=("in1_input" "in2_input" "in3_input")
RAIL_FILES_CURRENT=("curr1_input" "curr2_input" "curr3_input")

read_power_rails() {
    while true; do
        total_power=0  # Variable pour accumuler la puissance totale
        #timestamp=$(date +"%Y-%m-%d %H:%M:%S.%N")  # Timestamp actuel avec les millisecondes

        for ((i=0; i<${#RAIL_FILES_VOLTAGE[@]}; i++)); do

            current=$(cat "${SYSFS_PATH}${RAIL_FILES_CURRENT[i]}")
            #voltage=$(cat "${SYSFS_PATH}${RAIL_FILES_VOLTAGE[i]}")
            
            total_power=$(echo "scale=3; $total_power + ${RAIL_FILES_VOLTAGE[i]} * $current / 1000" | bc)
            #total_power=$(echo "scale=3; $total_power + $voltage * $current / 1000" | bc)
    	done

        # Stocker les données dans le fichier CSV
        echo "$(date +'%Y-%m-%d %H:%M:%S.%N'),${total_power}" >> "$CSV_FILE"

        ## Afficher la puissance totale avec timestamp et millisecondes
	#echo "${timestamp} - Total Power: ${total_power} mW"

        # Sleep for a short duration before reading again
        sleep 0.3s
    done
}

# Trap the signal to stop the script
trap 'exit' INT TERM

# Vérifier si le répertoire sysfs existe
if [ -d "$SYSFS_PATH" ]; then
    # Lire et stocker les valeurs des rails d'alimentation dans un fichier CSV
    read_power_rails
else
    echo "Erreur : Le répertoire sysfs n'existe pas. Veuillez vérifier si la Jetson Orin est correctement connectée."
fi
