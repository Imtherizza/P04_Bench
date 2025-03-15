#!/bin/bash

# FORCE CLEAN EVERYTHING

# Remove all the files
docker exec dla-2 /bin/bash -c "cd WORKSPACE_DLA_TESTED && ./clean.sh"
docker exec dla-3-14 /bin/bash -c "cd WORKSPACE_DLA_TESTED && ./clean.sh"

# PRESS 
echo "Appuyez sur une touche pour continuer"
read -n 1 -s
exit 0