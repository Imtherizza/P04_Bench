#!/bin/bash

find . -type d -name 'power_*' -exec sh -c 'rm -f "{}"/*.txt "{}"/*.log' \;
rmdir power_*/
rm -f power_data.csv
rm -f inference_timestamps.csv

#find . -type d -name 'power_*' -exec rm -f {}/*.txt {}/*.log \;
#find . -type d -name 'power_*' -exec rmdir {} \;

#rm -f power_data.csv
#rm -f inference_timestamps.csv

