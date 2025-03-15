#!/bin/bash

# Script to clear contents of output folder while preserving folder structure
echo "This will clear all contents in the output folder. Proceed? (y/n)"
echo "WARNING: This action is irreversible!"

read -r input

if [ "$input" = "y" ] || [ "$input" = "Y" ] || [ "$input" = "yes" ] || [ "$input" = "Yes" ]; then
    echo "Clearing contents..."
    # Find and remove all files (not directories) recursively in output folder
    find output/ -type f -delete
    echo "Done"
    echo "Exiting..."
    exit 0
else
    echo "Exiting..."
    exit 1
fi