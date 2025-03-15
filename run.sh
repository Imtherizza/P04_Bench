#!/bin/bash

# Script principal des mesures
#

nsysmode=$1

if [ "$nsysmode" == "nsys" ]
then
    echo "Mode nsys"
    continue
else
    echo "Mode normal"
    #nsysmode = "none"
fi

# Detect if sudo
#if [ "$EUID" -ne 0 ]; then
#    echo "Please run as root (sudo)"
#    exit 1
#fi

date=`date +%Y-%m-%d_%H-%M-%S`
start_time=$(date +%s)

#declare -a dla_versions=(
#    "nvcr.io/nvidia/l4t-tensorrt:r8.5.2-runtime"
#    "nvcr.io/nvidia/l4t-tensorrt:r8.4.1-runtime"
#    "nvcr.io/nvidia/l4t-tensorrt:r8.2.1-runtime"
#)
declare -a dla_versions=(
    "nvcr.io/nvidia/l4t-jetpack:r35.4.1" # DLA3
    "nvcr.io/nvidia/l4t-jetpack:r35.1.0" # DLA2
)

# verbose
echo "--------------------------------------------------------------------"
echo "Lancement des mesures de performances et d'efficacité sur DLA et GPU"
echo "--------------------------------------------------------------------"
echo 
echo "Date d'execution = $date"
echo
echo "--------------------------------------------------------------------"
echo "Version de DLA testés :"

for version in "${dla_versions[@]}"
do
    echo $version "TensorRT version" $(echo $version | grep -o 'r[0-9.]*' | sed 's/^r//')
done

echo "--------------------------------------------------------------------"
echo

# Execution du reste

# Verification de la presence de docker
if ! [ -x "$(command -v docker)" ]; then
    echo "Erreur: docker n'est pas installé." >&2
    exit 1
fi
# Verification de la presence ds images
for version in "${dla_versions[@]}"
do
    if ! docker image inspect $version > /dev/null 2>&1; then
        echo "Erreur: l'image $version n'est pas présente." >&2
        exit 1
    fi
done


# Execution des scripts de mesurePyToPyTorchrch
# Execution du script test si demandé
#if [ "$testmode" == "test" ]; then
# scrap
# continue
#fi

# Lancement sur DLA 1 2 et 3
# Bon ya que 2 et 3 la tout de suite faudra faire pour les 3 a voir
# TODO : mettre ca en loop

# Get the second DLA version (index 1)
version="${dla_versions[1]}"

#containers=("dla-1-3-7" "dla-2" "dla-3-14")
containers=("dla-2" "dla-3-14")

# Create and start containers
# A mentionner que la version de CUDA change entre les conainers, à comparer peut être
for container_name in "${containers[@]}"
do

    echo 
    echo "Lancement dans le container $container_name"
    echo

    # on assume que docker run a deja ete fait
    # Start container
    docker start "$container_name"

    docker exec "$container_name" dpkg -l | grep TensorRT

    # Copie des fichiers de travail dans le container
    docker cp WORKSPACE_DLA_TESTED "$container_name:/"

    # Run 1 engine building
    if [ "$nsysmode" == "nsys" ]
    then
        nsys profile --trace=cuda,nvtx,cublas,cudnn,tegra-accelerators \
                    --output=profile_container_build_engines \
                    --force-overwrite true\
                    docker exec "$container_name" /bin/bash -c "cd WORKSPACE_DLA_TESTED && chmod +x ./*.sh && ./1_build_engines_dla.sh" # test avec gpu et dla, a faire plutard
    else
        docker exec "$container_name" /bin/bash -c "cd WORKSPACE_DLA_TESTED && chmod +x ./*.sh && ./1_build_engines_dla.sh" # test avec gpu et dla, a faire plutard
    fi

    # Run 2 with power measurements
    docker exec "$container_name" timeout 4 tegrastats # 4 secondes pour etre sur
    if [ "$nsysmode" == "nsys" ]
    then   
        nsys profile --trace=cuda,nvtx,cublas,cudnn,tegra-accelerators \
                --output=profile_container_power_measure \
                --force-overwrite true\
                docker exec "$container_name" /bin/bash -c "cd WORKSPACE_DLA_TESTED && ./2_launch_measure_power.sh"
    else
        docker exec "$container_name" /bin/bash -c "cd WORKSPACE_DLA_TESTED && ./2_launch_measure_power.sh"
    fi
    

    # Run 3 with Python profiling
    docker exec "$container_name" /bin/bash -c "cd WORKSPACE_DLA_TESTED && python3 3_calculate_energy.py"

    # Copie des resultats du container vers le dossier output
    # copy nsight logs into output folder
    if [ "$nsysmode" == "nsys" ]
    then
        mkdir -p output/$container_name-DLA/data-$current_profile/nsight/
        mv -f *.nsys-rep output/$container_name-DLA/data-$current_profile/nsight/
    fi

    # Get current power profile and store in variable
    current_profile=$(nvpmodel -q | grep "Power Mode:" | cut -d ' ' -f 4)

    mkdir -p output/$container_name-DLA/data-$current_profile

    # ouioui docker supporte pas les wildcards c'est ignoble
    # copy from docker log files
    mkdir -p output/$container_name-DLA/data-$current_profile/measurments
    docker cp $container_name:/WORKSPACE_DLA_TESTED/inference_timestamps.csv output/$container_name-DLA/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_data.csv output/$container_name-DLA/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/measurments/. output/$container_name-DLA/data-$current_profile/measurments/

    # Copy log folders
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_MODE_"$current_profile"_0ms_dlv3/. output/$container_name-DLA/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_MODE_"$current_profile"_0ms_inceptionh3v2/. output/$container_name-DLA/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_MODE_"$current_profile"_0ms_mobilenetssdv1prep/. output/$container_name-DLA/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_MODE_"$current_profile"_0ms_mobilenetv2/. output/$container_name-DLA/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_MODE_"$current_profile"_0ms_resnet34ssdv1prep/. output/$container_name-DLA/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_MODE_"$current_profile"_0ms_resnet50v1prep/. output/$container_name-DLA/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_MODE_"$current_profile"_0ms_unetv2/. output/$container_name-DLA/data-$current_profile/

    # copu log folder mail
    docker cp $container_name:/WORKSPACE_DLA_TESTED/logs/. output/$container_name-DLA/data-$current_profile/logs/


    #
    # Fin DLA
    # Debut GPU
    # Copie des fichiers de travail dans le container
    docker cp WORKSPACE_DLA_TESTED "$container_name:/"

    docker exec "$container_name" dpkg -l | grep TensorRT

    # Run 1 engine building
    if [ "$nsysmode" == "nsys" ]
    then
        nsys profile --trace=cuda,nvtx,cublas,cudnn,tegra-accelerators \
                    --output=profile_container_build_engines \
                    --force-overwrite true\
                    docker exec "$container_name" /bin/bash -c "cd WORKSPACE_DLA_TESTED && chmod +x ./*.sh && ./1_build_engines_gpu.sh" # test avec gpu et dla, a faire plutard
    else
        docker exec "$container_name" /bin/bash -c "cd WORKSPACE_DLA_TESTED && chmod +x ./*.sh && ./1_build_engines_gpu.sh" # test avec gpu et dla, a faire plutard
    fi

    # Run 2 with power measurements
    docker exec "$container_name" timeout 4 tegrastats # 4 secondes pour etre sur
    if [ "$nsysmode" == "nsys" ]
    then   
        nsys profile --trace=cuda,nvtx,cublas,cudnn,tegra-accelerators \
                --output=profile_container_power_measure \
                --force-overwrite true\
                docker exec "$container_name" /bin/bash -c "cd WORKSPACE_DLA_TESTED && ./2_launch_measure_power.sh"
    else
        docker exec "$container_name" /bin/bash -c "cd WORKSPACE_DLA_TESTED && ./2_launch_measure_power.sh"
    fi

    # Run 3 with Python profiling
    docker exec "$container_name" /bin/bash -c "cd WORKSPACE_DLA_TESTED && python3 3_calculate_energy.py"

    # Copie des resultats du container vers le dossier output
    # copy nsight logs into output folder
    if [ "$nsysmode" == "nsys" ]
    then
        mkdir -p output/$container_name-GPU/data-$current_profile/nsight/
        mv -f *.nsys-rep output/$container_name-GPU/data-$current_profile/nsight/
    fi

    # Get current power profile and store in variable
    current_profile=$(nvpmodel -q | grep "Power Mode:" | cut -d ' ' -f 4)

    mkdir -p output/$container_name-GPU/data-$current_profile

    # ouioui docker supporte pas les wildcards c'est ignoble
    # copy from docker log files
    mkdir -p output/$container_name-GPU/data-$current_profile/measurments
    docker cp $container_name:/WORKSPACE_DLA_TESTED/inference_timestamps.csv output/$container_name-GPU/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_data.csv output/$container_name-GPU/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/measurments/. output/$container_name-GPU/data-$current_profile/measurments/

    # Copy log folders
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_MODE_"$current_profile"_0ms_dlv3/. output/$container_name-GPU/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_MODE_"$current_profile"_0ms_inceptionh3v2/. output/$container_name-GPU/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_MODE_"$current_profile"_0ms_mobilenetssdv1prep/. output/$container_name-GPU/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_MODE_"$current_profile"_0ms_mobilenetv2/. output/$container_name-GPU/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_MODE_"$current_profile"_0ms_resnet34ssdv1prep/. output/$container_name-GPU/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_MODE_"$current_profile"_0ms_resnet50v1prep/. output/$container_name-GPU/data-$current_profile/
    docker cp $container_name:/WORKSPACE_DLA_TESTED/power_MODE_"$current_profile"_0ms_unetv2/. output/$container_name-GPU/data-$current_profile/

    # copu log folder mail
    docker cp $container_name:/WORKSPACE_DLA_TESTED/logs/. output/$container_name-GPU/data-$current_profile/logs/
done
# Clean up

temps_execution=$(($(date +%s) - start_time))
temps_execution=$(printf '%02d:%02d:%02d' $((temps_execution/3600)) $((temps_execution%3600/60)) $((temps_execution%60)))

echo "--------------------------------------------------------------------"
echo "Fin des mesures"
echo "--------------------------------------------------------------------"
echo
#echo "Date d'execution = $date2" # C'est pas une peine de mort tkt

echo "Temps d'executon = $temps_execution"
echo

# 

exit 0