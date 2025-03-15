#!/bin/bash

# Remplace le répertoire de mesure avec celui de Sean
# Certaines choses sont encore "hardcodés" donc des réajustements a faire apres avoir tourné ceci
# Notamment et surtout sur le 2

echo "This will write/overwrite the WORKSPACE_DLA_TESTED folder in P04_DLA_Bench, proceed? (y/n)"
# Input
read -r input
if 
    [ "$input" = "y" ] || [ "$input" = "Y" ] || [ "$input" = "yes" ] || [ "$input" = "Yes" ] || [ "$input" = "YES" ] || [ "$input" = "1" ]
then
    echo
    echo "Copying..."
elif [ "$input" = "remove" ]; then # Secret command
    echo "Removing..."
    rm -rf ../P04_DLA_Bench/WORKSPACE_DLA_TESTED/
    echo "Done"
    echo "Exiting..."
    exit 0
else
    echo
    echo "Exiting..."
    exit 1
fi

# Remove old folder
rm -rf ../P04_DLA_Bench/WORKSPACE_DLA_TESTED/

cp -R ../Documents/test-Sean/WORKSPACE_DLA_TESTED/ ../P04_DLA_Bench/

# Remove clean.sh in work folder and copy the updated one
#rm -f ../P04_DLA_Bench/WORKSPACE_DLA_TESTED/clean.sh
#cp clean.sh ../P04_DLA_Bench/WORKSPACE_DLA_TESTED/

echo
echo "Done"
echo "Exiting..."
exit 0