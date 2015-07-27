#!/bin/bash
smartctl -l scttempsts /dev/sdb | tr -s ' ' | awk -F'[ \t]' '$1$2 ~ /CurrentTemperature:/ {print($3);}'
