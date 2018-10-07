#!/bin/bash
# --------------------------------------------------
# audio.sh - modify pulseaudio state from commandline
#
# Usage (simple)
#    vup           Turn volume up 5%
#    vdown         Turn volume down 5%
#    vstate        Toggle mute state
#    vstate        Show audio state
#
# Usage (complicated, unnecessary but fun)
#    audio.sh +    Turn volume up 5%
#    audio.sh ++   Turn volume up 10%
#    audio.sh m+   Toggle mute state, then turn volume up 5%
#    audio.sh ---  Turn volume down 15%
#
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
ME=$(basename $0)
REAL_ME=$(readlink -f $0)

max_volume="0x10000"
inc=$(($max_volume / 20))

# --------------------------------------------------
# FUNCTIONS

# short usage
usage() {
  cat<<-EOF
	A command-line tool for manupulating pulseaudio sound state
    
	audio.sh, vup, vdown, vmute, vstate
	Usage: audio.sh [-h|--help] [ma-+]+ [=]
	
	Run audio.sh without arguments and get current sink volume and mute
	state.
	
	Run audio.sh with an arbritrary number of commands, each command
	represented by a symbol:
	  -  Turn the volume down by 5%
	  +  Turn the volume up by 5%
	  m  Toggle mute state
	  a  Show source, sink, sink volume and sink mute state
	  =  Show i3bar-friendly volume and mute state
	
	Examples:
	  audio.sh         Show volume and mute state
	  audio.sh m       Toggle mute state
	  audio.sh +++     Turn volume up 15%
	  audio.sh m----   Toggle mute, then turn volume down 20%
	
	Aliases
	  vup is an alias for 'audio.sh +'
	  vdown is an alias for 'audio.sh -'
	  vmute is an alias for 'audio.sh m'
	  vstate is an alias for 'audio.sh a'
	
	Aliases also support all arguments supported by audio.sh. So:
	'vup ++' increases volume 15% (5% for each +, and 5% because it 
	was called as vup.) Though meaningless, this means that you can
	run 'vmute m', which will mute then unmute immediately.
	EOF
  exit 0
}

# Returns volume 0-100
_getratio() {
  ratio=$(( 1 + ( volstate * 100 ) / max_volume ))
  [[ $(( $ratio % 5 )) == '1' ]] && ratio=$(( ratio - 1 ))
  echo $ratio
}

# Returns volume expressed as a string, useful for i3bar in i3wm
print_bar() {
  ratio=$(_getratio)
  volume=$(( ratio / 10 ))
  floor=$(( volume - 10 ))
  while [[ $volume -ge $floor ]] ; do
    [[ $volume -ge 0 ]] && echo -n "♪" || echo -n "."
    volume=$(( volume - 1 ))
  done
}

# Print audio state
getstate() {
  ratio=$(_getratio)
  cat <<-EOF
	volstate:  $ratio/100
	mutestate: $mutestate
	EOF
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

# If this script is called via symlink
command='default'
case $ME in
  'vup')    command='+' ;;   
  'vdown')  command='-' ;; 
  'vmute')  command='m' ;;
  'vstate') command='a' ;;
esac
[[ "$command" != 'default' ]] && $REAL_ME $@ $command && exit 0


# If this script is called as audio.sh
[[ "$1" == '-h' || "$1" == '--help' ]] && usage
set -- $(echo "$@" | perl -pe 's// /g') # expand all args so there are
                                        # whitespaces between each char
case "$1" in
  '-' ) down        ; shift ; $0 $@ ;;
  '+' ) up          ; shift ; $0 $@ ;;
  'm' ) toggle_mute ; shift ; $0 $@ ;;
  'a' ) getall      ; shift ; $0 $@ ;;
  '=' ) print_bar   ;;
  *   ) getstate    ;;
esac

exit 0
