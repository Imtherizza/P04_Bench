#!/bin/bash

./1_build_engines_dla.sh

timeout 4 tegrastats

./2_launch_measure_power.sh

python3 3_calculate_energy.py