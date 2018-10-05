# simple_audio_control

	A command-line tool for manupulating pulseaudio sound state
    
	audio.sh, vup, vdown, vmute, vstate
	Usage: audio.sh [-+ma]+ [=|h]
	
	Run audio.sh without arguments and get current sink volume and mute
	state.
	
	Run audio.sh with an arbritrary number of commands, each command
	represented by a symbol:
	h  Show usage 
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
