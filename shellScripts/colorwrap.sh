#!/bin/sh

# -----------------------------------------------------------------------------
#  This script will change the text and background colors of a command
#  depending on the command (ssh, sudo, su, ...)
#  or its parameters (ssh someserver, sudo somecommand, ...)
#
#  To do so, it replaces the command itself with an alias, like
#    alias ssh='/usr/local/bin/colorwrap \ssh $*'
#  in .bashrc.
#
#  Colors are either named by their ANSI name (black, white)
#  or as a rgb-tupel with 3 values in hex (00FF33).
#  To get a specific color, start the DigitalColor Meter.app,
#  use "RGB as Decimal, 16-bit"
#  and klick on the desired color on the screen to find its value.
#
#  The currently used colors can be read by using the command
#    colorwrap getcolor
#  Transparencies will *not* be detected!
#
#  Since getting and setting the colors is done via AppleScript,
#  and since AppleScript relies on the current name of the window,
#  this script does sometimes have problems with Visor.
#
#  OS X Terminal from 10.5 onwards:
#  Since *setting* the transparency is not supported anymore 
#  (although it is still possible to do so in the preferences),
#  all transparencies are lost once this script is activated by any commands,
#  until the window is closed and opened again.
#
#  Idea and original Script: JD Smith and Eric Kow
#  Source: http://www.macosxhints.com/article.p0hp?story=20050920183403172
#
#  last edited: 05.06.2009
#  maelcum
# -----------------------------------------------------------------------------



# ----------------------------------------------------------------------
#  Definition of properties
# ----------------------------------------------------------------------

PEACH="{65535, 53713, 41377}"
BLUE="{32382, 40092, 54227}"
RED="{65021, 30840, 28527}"
GREEN="green"
MD_GRAY="{26214, 26214, 26214}"
LIGHT_GRAY="{38024, 38024, 38024}"
BLACK="black"



# ----------------------------------------------------------------------
#  Definition of functions
# ----------------------------------------------------------------------


#  function to get the currently used colors
#
fnc_get_fg_color() {
    echo `osascript -s s -e "tell application \"Terminal\" to tell front window to get its normal text color"`
}
#
fnc_get_bg_color() {
    echo `osascript -s s -e "tell application \"Terminal\" to tell front window to get its background color"`
}


#  function to assign (not set!) the new text and background color,
#  depending on the command that has been passed as a parameter
#
fnc_select_fg_color() {
    case "${1}" in
	*ebdb.webfactional.com)   NEW_FG_COLOR=$BLACK;; 
	*skoczen.webfactional.com)   NEW_FG_COLOR=$BLACK;;
    *quantumimagery.com)       NEW_FG_COLOR=$BLACK;;
    *skoczen.dyndns.org)       NEW_FG_COLOR=$BLACK;;
    *stevenskoczen.com)       NEW_FG_COLOR=$BLACK;;
	*hematite.local)       NEW_FG_COLOR=$BLACK;;
	# *someserver)	NEW_FG_COLOR=$PEACH;;   <<<  CUSTOMIZE THIS
        # *192.168.0.*)   NEW_FG_COLOR=$PEACH;;   <<<  CUSTOMIZE THIS
	*sudo*)		NEW_FG_COLOR=$RED;;
	su*)	    NEW_FG_COLOR=$RED;;
	*)	        NEW_FG_COLOR=$GREEN;;
    esac
    echo ${NEW_FG_COLOR}
}
#
fnc_select_bg_color() {
    case "${1}" in
	*ebdb.webfactional.com)   NEW_BG_COLOR=$GREEN;; 
	*skoczen.webfactional.com)   NEW_BG_COLOR=$BLUE;;
    *quantumimagery.com)       NEW_BG_COLOR=$RED;;  
    *skoczen.dyndns.org)       NEW_BG_COLOR=$LIGHT_GRAY;;   
    *stevenskoczen.com)       NEW_BG_COLOR=$LIGHT_GRAY;;    
	*hematite.local)       NEW_BG_COLOR=$LIGHT_GRAY;;	
	sudo*)		NEW_BG_COLOR=$BLACK;;
	su*)	        NEW_BG_COLOR=$BLACK;;
	*)	        NEW_BG_COLOR=$BLACK;;
    esac
    echo ${NEW_BG_COLOR}
}


#  function to quote the color, if necessary
#
fnc_quote_color() {
    THE_COLOR=$*
    case ${THE_COLOR} in 
	\"*\") ;;
	'{'*'}') ;;
	*) THE_COLOR='"'${THE_COLOR}'"'
	;;
    esac
    echo ${THE_COLOR}
}


#  function to set (activate) the previously assigned colors
#
#  this function will be used to set the new colors as well as to reset the old ones back after the command finished
fnc_set_colors() {
    fg_color=`fnc_quote_color ${1}`
    bg_color=`fnc_quote_color ${2}`

    osascript -s s                                                                                      \
    -e "tell application \"Terminal\" to tell front window to set its normal text color to ${fg_color}" \
    -e "tell application \"Terminal\" to tell front window to set its background color to ${bg_color}"
}


#  function to fall back if any error happened
#
fnc_unset_colors_error() {
  # reset the color to its old value
  fnc_set_colors "${ORIGINAL_FG_COLOR}" "${ORIGINAL_BG_COLOR}"
  exit 1;
}


# -----------------------------------------------------------------------------
#  main()
# -----------------------------------------------------------------------------


#  check if any parameter has been passed, otherwise bail out
[ $# -lt 1 ] &&  { echo "usage: $0 cmd [args...]"; exit 1; }


#  save all parameters in the variable. thats the commands that should be executed once the color has been adjusted
COMMAND=$*


#  if only the current colors should be read and displayed (parameter: "getcolor")
#  then do so and exit.
if [ "${COMMAND}" == "getcolor" ]; then
    echo "Text Color is `fnc_get_fg_color`"
    echo "Background is `fnc_get_bg_color`"
    exit 0
fi


#  read and save current color settings
ORIGINAL_FG_COLOR=`fnc_get_fg_color`
ORIGINAL_BG_COLOR=`fnc_get_bg_color`


#  assign and set the new text and background color, depending on the command that has been passed as a parameter
NEW_FG_COLOR=`fnc_select_fg_color "${COMMAND}"`
NEW_BG_COLOR=`fnc_select_bg_color "${COMMAND}"`
fnc_set_colors "${NEW_FG_COLOR}" "${NEW_BG_COLOR}"


#  if an error occurs, the function to reset the colors to their original state is called.
#  the following signals will be monitored: quit, kill abort, error
trap fnc_unset_colors_error 1 2 3 6


#  execute the saved command with its parameters
#  and remember the exit status (successful or not)
${COMMAND}
EXIT_STATUS=$?


#  reset the colors to their original state
fnc_set_colors "${ORIGINAL_FG_COLOR}" "${ORIGINAL_BG_COLOR}"


# exit with the exit status of the command we ran
exit ${EXIT_STATUS}