INRES="1680x1050" # input resolution
OUTRES="1280x720" # output resolution
FPS="60" # target FPS
GOP="120" # i-frame interval, should be double of FPS, 
GOPMIN="60" # min i-frame interval, should be equal to fps, 
THREADS="0" # max 6
CBR="3000k" # constant bitrate (should be between 1000k - 3000k)
QUALITY="medium"  # one of the many FFMPEG preset
AUDIO_RATE="44100"

SINK_GRAB_ID=$(pactl load-module module-null-sink sink_name="grab" rate=$AUDIO_RATE sink_properties=device.description="INgrabOUT")
SINK_DUPLEX_ID=$(pactl load-module module-null-sink sink_name="duplex_out" rate=$AUDIO_RATE sink_properties=device.description="duplexOUT")

MODULE2=$(pactl load-module module-loopback rate=${AUDIO_RATE} latency_msec=1 adjust_time=1 source=${DEFAULT_SOURCE} sink="duplex_out")
MODULE3=$(pactl load-module module-loopback rate=${AUDIO_RATE} latency_msec=1 adjust_time=1 source="grab.monitor" sink="duplex_out")
MODULE1=$(pactl load-module module-loopback latency_msec=1 source="grab.monitor")

./ffmpeg_g -f alsa -i pulse -filter_complex aresample=44100 -framerate $FPS -f x11grab -s "$INRES" -i :0.0 -vsync 1 -f mp4 -ac 2 \
  -vcodec libx264 -g $GOP -keyint_min $GOPMIN
  -s $OUTRES -preset $QUALITY -acodec libmp3lame -threads $THREADS -strict normal ./test.mp4

pactl unload-module ${SINKASSOURCE}
pactl unload-module ${MODULE3}
pactl unload-module ${MODULE2}
pactl unload-module ${MODULE1}
pactl unload-module ${SINK_DUPLEX_ID}
pactl unload-module ${SINK_GRAB_ID}
