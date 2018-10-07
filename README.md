# simple\_audio\_control

Some simple command-line tools for manipulating PulseAudio sound state.

Installation
==
To get the simple volume control commands in place, symlink audio.sh to some place in your $PATH, for example:

	cd ~/bin
	ln -s path/to/simple_audio_control/audio.sh vup
	ln -s path/to/simple_audio_control/audio.sh vdown
	ln -s path/to/simple_audio_control/audio.sh vmute
	ln -s path/to/simple_audio_control/audio.sh vstate

If you want to use the source script audio.sh, you can safely move it (or symlink it) to your $PATH, it's completely stand-alone.
 
--

	Some command-line tools for manupulating pulseaudio sound state
    
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
