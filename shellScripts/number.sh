#!/bin/sh
echo "$1 is logged in the following number of times:"
who | grep $1 | wc -l