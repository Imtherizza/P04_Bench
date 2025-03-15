#!/bin/bash

# Script obsolete pour copier les données docker vers un repertoire local

# Input version of dla
if [ -z "$1" ]; then
    echo "No argument supplied"
    exit 1
fi

if [[ "$1" != "dla-1-3-7" && "$1" != "dla-2" && "$1" != "dla-3-14" ]]; then
    echo "Invalid argument. Please use dla-1-3-7, dla-2, or dla-3-14"
    exit 1
fi

# copy nsight logs into output folder
mv -f *.nsys-rep output/$1/data-$current_profile/nsight/

# Get current power profile and store in variable
current_profile=$(nvpmodel -q | grep "Power Mode:" | cut -d ' ' -f 4)

mkdir -p output/$1/data-$current_profile

# ouioui docker supporte pas les wildcards c'est ignoble
# copy from docker log files
mkdir -p output/$1/data-$current_profile/measurments
docker cp $1:/WORKSPACE_DLA_TESTED/inference_timestamps.csv output/$1/data-$current_profile/
docker cp $1:/WORKSPACE_DLA_TESTED/power_data.csv output/$1/data-$current_profile/
docker cp $1:/WORKSPACE_DLA_TESTED/measurments/. output/$1/data-$current_profile/measurments/

# Copy log folders
docker cp $1:/WORKSPACE_DLA_TESTED/power_"$current_profile"_0ms_dlv3 output/$1/data-$current_profile/
docker cp $1:/WORKSPACE_DLA_TESTED/power_"$current_profile"_0ms_inceptionh3v2 output/$1/data-$current_profile/
docker cp $1:/WORKSPACE_DLA_TESTED/power_"$current_profile"_0ms_mobilenetssdv1prep output/$1/data-$current_profile/
docker cp $1:/WORKSPACE_DLA_TESTED/power_"$current_profile"_0ms_mobilenetv2 output/$1/data-$current_profile/
docker cp $1:/WORKSPACE_DLA_TESTED/power_"$current_profile"_0ms_resnet34ssdv1prep output/$1/data-$current_profile/
docker cp $1:/WORKSPACE_DLA_TESTED/power_"$current_profile"_0ms_resnet50v1prep output/$1/data-$current_profile/
docker cp $1:/WORKSPACE_DLA_TESTED/power_"$current_profile"_0ms_unetv2 output/$1/data-$current_profile/