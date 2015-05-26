#!/bin/bash

echo "`date +%H:%M:%S` début de traitement"

# test BAN/RAN
parallel -j 8 sh check_ran.sh {} ::: 01 02 03 04 05 06 07 08 09 `seq 10 19` 2A 2B `seq 21 95` `seq 971 974` 976

echo "`date +%H:%M:%S` Fusion"
# fusion en un fichier unique
for dep in {01..19} 2A 2B {21..95} {971..974} ; do cat check_ran_$1 >> erreurs.csv ; rm check_ran_$1; done

echo "`date +%H:%M:%S` fin de traitement"

