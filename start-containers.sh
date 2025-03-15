#!/bin/bash

# CE PROGRAMME SERA REMPLACE A L'AVENIR PAR rien pck ca le fait tout seul shrug
# IL EST LA JUSTE POUR FACILITER LE TRAVAIL

# Si les containers existent, les supprimer
docker rm -f dla-2 dla-3-14

# Verbose
echo "Demarrage des containers..."
echo

# Démarrer les containers
# docker run -d -it --privileged --runtime nvidia -v /usr/bin/tegrastats:/usr/bin/tegrastats --name "dla-1-3-7" "nvcr.io/nvidia/l4t-tensorrt:r8.2.1-runtime" sleep infinity
docker run -d -it \
  --privileged \
  --runtime nvidia \
  --name "dla-3-14" \
  -v /usr/lib/aarch64-linux-gnu/tegra:/usr/lib/aarch64-linux-gnu/tegra \
  -v /usr/share/glvnd/egl_vendor.d:/usr/share/glvnd/egl_vendor.d \
  -v /usr/bin/tegrastats:/usr/bin/tegrastats \
  "nvcr.io/nvidia/l4t-jetpack:r35.4.1" \
  sleep infinity
docker run -d -it \
  --privileged \
  --runtime nvidia \
  --name "dla-2" \
  -v /usr/lib/aarch64-linux-gnu/tegra:/usr/lib/aarch64-linux-gnu/tegra \
  -v /usr/share/glvnd/egl_vendor.d:/usr/share/glvnd/egl_vendor.d \
  -v /usr/bin/tegrastats:/usr/bin/tegrastats \
  "nvcr.io/nvidia/l4t-jetpack:r35.1.0" \
  sleep infinity

# Obsolete
#docker cp WORKSPACE_DLA_TESTED "dla-1-3-7:/"
#docker cp WORKSPACE_DLA_TESTED "dla-2:/"
#docker cp WORKSPACE_DLA_TESTED "dla-3-14:/"

# Wait for input
echo "Appuyez sur une touche pour continuer"
read -n 1 -s
exit 0