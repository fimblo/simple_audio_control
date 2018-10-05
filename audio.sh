# > pacmd dump | grep -v load-module| unc | sort | tr " " \\t
#set-card-profile    alsa_card.pci-0000_00_1f.3                         output:analog-stereo+input:analog-stereo
#
#set-default-source  alsa_input.pci-0000_00_1f.3.analog-stereo
#set-source-mute     alsa_input.pci-0000_00_1f.3.analog-stereo          no
#set-source-volume   alsa_input.pci-0000_00_1f.3.analog-stereo          0xe1e1
#suspend-source      alsa_input.pci-0000_00_1f.3.analog-stereo          yes
#
#set-default-sink    alsa_output.pci-0000_00_1f.3.analog-stereo
#set-sink-mute       alsa_output.pci-0000_00_1f.3.analog-stereo         yes
#set-sink-volume     alsa_output.pci-0000_00_1f.3.analog-stereo         0x5000
#suspend-sink        alsa_output.pci-0000_00_1f.3.analog-stereo         yes

#set-source-mute     alsa_output.pci-0000_00_1f.3.analog-stereo.monitor no
#set-source-volume   alsa_output.pci-0000_00_1f.3.analog-stereo.monitor 0x10000
#suspend-source      alsa_output.pci-0000_00_1f.3.analog-stereo.monitor yes

state=$(mktemp); trap 'rm -f $state' 0
pacmd dump > $state

sink=$(cat $state   | grep set-default-sink   | cut -d" " -f2)
source=$(cat $state | grep set-default-source | cut -d" " -f2)

volstate=$(cat $state  | grep set-sink-volume | cut -d" " -f3)
mutestate=$(cat $state | grep set-sink-mute   | cut -d" " -f3)

max_volume="0x10000"
inc=$(($max_volume / 20))

getratio() {
  ratio=$(( 1 + ( volstate * 100 ) / max_volume ))
  [[ $(( $ratio % 5 )) == '1' ]] && ratio=$(( ratio - 1 ))
  echo $ratio
}


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

getstate() {
  ratio=$(getratio)
  cat <<-EOF
	volstate:  $ratio/100
	mutestate: $mutestate
	EOF
  exit 0
}

getall() {
  cat <<-EOF
	sink:      $sink
	source:    $source
	EOF
  getstate
}


up() {
  new=$((volstate + inc))
  [[ $new -gt $max_volume ]] && new=$max_volume
  pactl set-sink-volume $sink $(printf "0x%X" $new)
}
down() {
  new=$((volstate - inc))
  [[ $new -lt $((0x00000)) ]] && new="0x00000"
  pactl set-sink-volume $sink $(printf "0x%X" $new)
}

toggle_mute() {
  pactl set-sink-mute $sink toggle
}


# deal with user's wishes

[[ $# == '0' ]] && getstate             # if no args, show state
set -- $(echo "$@" | perl -pe 's// /g') # expand all args so there are
                                        # whitespaces between each char
case "$1" in
  '-' ) down        ; shift ; $0 $@ ;;
  '+' ) up          ; shift ; $0 $@ ;;
  'm' ) toggle_mute ; shift ; $0 $@ ;;
  '=' ) print_bar   ;;
  'a' ) getall      ;;
  
esac


