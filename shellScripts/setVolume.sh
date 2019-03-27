#/bin/sh

set newVol = `echo $1 / 100 | bc -l`

osascript -e " set volume($newVol )"


