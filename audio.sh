#!/bin/bash
# --------------------------------------------------
# audio.sh - modify pulseaudio state from commandline
#
# Some descriptive text here
# fimblo@yanson.org
# --------------------------------------------------



# --------------------------------------------------
# VARIABLES

# Get audio source, sink and state
state=$(mktemp); trap 'rm -f $state' 0
pacmd dump > $state

sink=$(cat $state   | grep set-default-sink   | cut -d" " -f2)
source=$(cat $state | grep set-default-source | cut -d" " -f2)

volstate=$(cat $state  | grep set-sink-volume | cut -d" " -f3)
mutestate=$(cat $state | grep set-sink-mute   | cut -d" " -f3)

# --------------------------------------------------
# useful constants
max_volume="0x10000"
inc=$(($max_volume / 20))

# --------------------------------------------------
# FUNCTIONS

# Returns volume 0-100
getratio() {
  ratio=$(( 1 + ( volstate * 100 ) / max_volume ))
  [[ $(( $ratio % 5 )) == '1' ]] && ratio=$(( ratio - 1 ))
  echo $ratio
}

# Returns volume expressed as a string, useful for i3bar in i3wm
print_bar() {
  ratio=$(getratio)
  volume=$(( ratio / 10 ))
  floor=$(( volume - 10 ))
  while [[ $volume -ge $floor ]] ; do
    [[ $volume -ge 0 ]] && echo -n "|" || echo -n "."
    volume=$(( volume - 1 ))
  done

  echo
  exit 0
}

# Print audio state and exit
getstate() {
  ratio=$(getratio)
  cat <<-EOF
	volstate:  $ratio/100
	mutestate: $mutestate
	EOF
  exit 0
}

# Print source and sink
getall() {
  cat <<-EOF
	sink:      $sink
	source:    $source
	EOF
}

# Turn volume up by $inc
up() {
  new=$((volstate + inc))
  [[ $new -gt $max_volume ]] && new=$max_volume
  pactl set-sink-volume $sink $(printf "0x%X" $new)
}

# Turn volume down by $inc
down() {
  new=$((volstate - inc))
  [[ $new -lt $((0x00000)) ]] && new="0x00000"
  pactl set-sink-volume $sink $(printf "0x%X" $new)
}

# Toggle mute state
toggle_mute() {
  pactl set-sink-mute $sink toggle
}


# --------------------------------------------------
# PARSE COMMANDLINE ARGS
[[ $# == '0' ]] && getstate             # if no args, show state
set -- $(echo "$@" | perl -pe 's// /g') # expand all args so there are
                                        # whitespaces between each char
case "$1" in
  '-' ) down        ; shift ; $0 $@ ;;
  '+' ) up          ; shift ; $0 $@ ;;
  'm' ) toggle_mute ; shift ; $0 $@ ;;
  'a' ) getall      ; shift ; $0 $@ ;;
  '=' ) print_bar   ;;
esac

exit 0
