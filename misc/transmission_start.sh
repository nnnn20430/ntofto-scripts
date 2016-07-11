#!/bin/bash

export TRANSMISSION_HOME=$PWD/torrents/.config/transmission-daemon

transmission-daemon --utp -o -m -w $PWD/torrents
sleep 1
transmission-remote --lpd
