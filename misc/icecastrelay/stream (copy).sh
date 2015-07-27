#!/bin/bash
(./php -f server_icecastrelay.php >/dev/null &)
while true
do
 if test -a "/tmp/icecastrelayS.sock"; then break; fi
done
tty=$(tty)
INRES="1680x1050" # input resolution
OUTRES="1280x720" # output resolution
FPS="15" # target FPS
GOP="30" # i-frame interval, should be double of FPS, 
GOPMIN="15" # min i-frame interval, should be equal to fps, 
THREADS="0" # max 6
CBR="2000k" # constant bitrate (should be between 1000k - 3000k)
QUALITY="ultrafast"  # one of the many FFMPEG preset
AUDIO_RATE="44100"
STREAM_KEY="$1" # use the terminal command Streaming streamkeyhere to stream your video to twitch or justin
SERVER="live-fra" # twitch server in frankfurt, see http://bashtech.net/twitch/ingest.php for list
clear

pactl unload-module module-udev-detect
DISABLETIMESCHEDULE=$(pactl load-module module-udev-detect tsched=0)

#SINK_GRAB_ID=$(pactl load-module module-null-sink sink_name="grab" rate=$AUDIO_RATE sink_properties=device.description="INgrabOUT")
#SINK_DUPLEX_ID=$(pactl load-module module-null-sink sink_name="duplex_out" rate=$AUDIO_RATE sink_properties=device.description="duplexOUT")
#MODULE1=$(pactl load-module module-loopback source="grab.monitor" sink="duplex_out")
DEFAULT_SOURCE=`pacmd dump | mawk '/set-default-source/ {print $2}'`
DEFAULT_SINK=`pacmd dump | mawk '/set-default-sink/ {print $2}'`
SINKASSOURCE=$(pactl load-module module-remap-source source_name=sink_source source_properties=device.description="sink_source" master=${DEFAULT_SINK}.monitor)
#MODULE2=$(pactl load-module module-loopback rate=${AUDIO_RATE} latency_msec=1 adjust_time=1 source=${DEFAULT_SOURCE} sink="duplex_out")
#MODULE3=$(pactl load-module module-loopback rate=${AUDIO_RATE} latency_msec=1 adjust_time=1 source="grab.monitor" sink="duplex_out")
#MODULE1=$(pactl load-module module-loopback latency_msec=1 source="grab.monitor")
#DEFAULT_SINK=`pacmd dump | mawk '/set-default-sink/ {print $2}'`
#MODULE3=$(pactl load-module module-loopback source="${DEFAULT_SINK}.monitor" sink="grab")
#SOURCE_DUPLEX_ID=$(pactl list short sources | mawk '$2 ~ "duplex_out" {print $1}')

ffmpegBg (){
 ./ffmpeg -f alsa -i pulse -filter_complex aresample=44100 -framerate $FPS -f x11grab -s "$INRES" -i :0.0 -vsync 1 -f ogg -ac 2 \
  -vcodec libtheora -g $GOP -keyint_min $GOPMIN -b:v $CBR -minrate $CBR -maxrate $CBR -qscale:v 5 -pix_fmt yuv420p\
  -s $OUTRES -preset $QUALITY -acodec libvorbis -qscale:a 5 -threads $THREADS -strict normal \
  -bufsize $CBR "unix:///tmp/icecastrelayS.sock" >$tty 2>&1  &
 echo $!
 #while true;do pactl unload-module ${SINKASSOURCE};SINKASSOURCE=$(pactl load-module module-remap-source source_name=sink_source source_properties=device.description="sink_source" master=${DEFAULT_SINK}.monitor);done >/dev/null 2>&1  &
}
ffmpegPID=$(ffmpegBg)
echo $ffmpegPID

#idea make one ffmpeg mix two inputs and let em pass raw into unix socket and make recording ffmpeg record audio from that socket

read -n 1
kill -s SIGKILL $ffmpegPID
pactl unload-module ${SINKASSOURCE}
pactl unload-module ${DISABLETIMESCHEDULE}
pactl load-module module-udev-detect
#pactl unload-module ${MODULE3}
#pactl unload-module ${MODULE2}
#pactl unload-module ${MODULE1}
#pactl unload-module ${SINK_DUPLEX_ID}
#pactl unload-module ${SINK_GRAB_ID}
clear