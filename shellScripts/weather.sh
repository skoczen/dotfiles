#!/bin/sh
# 
# fuweather
# Copyright (c) 2009 Marcus Carlsson <carlsson.marcus@gmail.com> (http://xintron.se)
# 
# "THE BEER-WARE LICENSE" (Revision 42):
# <carlsson.marcus@gmail.com> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return. Marcus Carlsson
 
VERSION='0.3'
temp='&CELSIUS=yes'
IFS=''
HELP="fuweather
  Usage: `basename $0` [city]
  -c, --config \t\t create a configuration-file
  -h, --help \t\t shows this help information
  -t, --temperature \t 1 for Celsius (default), 0 for Fahrenheit
  -v, --version \t\t output version information and exit\n
  Example: `basename $0` stockholm
  Will give you the current weather in Stockholm and a weather forecast for the upcoming days."
 
 
 
weather () {
  ### Dump the city weather to a variable
  WEATHER=$(links -dump "http://www.thefuckingweather.com/?zipcode=$1$2" | head -n 17 | sed -e '7,11d' | sed 's/DEG/°/')
 
  ### Check if we got a valid output
  if [ `echo $WEATHER | grep -c "WRONG FUCKING ZIP"` -eq 1 ]; then
    echo 'Error!
  It was not possible to fetch the current weather in ['$1']. Please try again or select another city.'
    check=0
  else
    if [ ! $3 ]; then
      echo $WEATHER
    else
      check=1
    fi
  fi
}
 
### We got a configuration-file. Load the settings and use them
if [ -f $HOME/.fuweatherrc ]; then
  . $HOME/.fuweatherrc
  if [ -n $temp ]; then
    case $(echo $temp | tr "[:upper:]" "[:lower:]") in
      fahrenheit|f|0)
        temp=''
      ;;
      *)
        temp='&CELSIUS=yes'
      ;;
    esac
  fi
fi
 
### cHEck the arguments and output the correct command
if [ ! -z $1 ]; then
  ### Cycle through the arguments
  while [ ! -z $1 ]; do
    case "$1" in  
      '--help'|'-h')
      echo -e $HELP
        exit 0
      ;;
      '--version' | '-v') 
        echo -e "fuweather v $VERSION"
        exit 0
      ;;
      '--temperature'|'-t')
        ### Missing temperature-argument
        if [ -z $2 ]; then
          echo 'Temperature missing argument. Example: '`basename $0`' -t 0|1 [city]'
          exit 0
        else
          ### We want fahrenhiet instead of celsius
          if [ $2 == '0' ] || [ $2 == 'fahrenheit' ] || [ $2 == 'f' ]; then
            temp=''
          else
            temp='&CELSIUS=yes'
          fi
          shift
          shift
        fi
      ;;
      ### The user wants to create a config-file
      '--config'|'-c')
        clear
        while [ ! $check ] || [ $check == 0 ]; do
          echo 'Enter desired city:'
          read city
          weather $city '&CELSIUS=yes' 'check'
        done
        
        echo 'Enter desired temperature, Celsius|Fahrenheit [C]:'
        read temp
        if [ $temp == 'fahrenheit' ] || [ $temp == 'f' ] || [ $temp == 'celsius' ] || [ $temp == 'c' ]; then
          temp=$temp
        else
          temp='celsius'
        fi
        echo '# Set default city
city='$city'
 
# Set default temperature, if none given, Celsius will be used as default
temp='$temp > $HOME/.fuweatherrc
        clear
        echo 'The configuration file was successfully created and saved.'
        exit 0
      ;;
      *)
        city=$1
        shift
      ;;
    esac
  done
elif [ ! $city ]; then
  echo -e $HELP
  exit 0
fi
 
weather $city $temp