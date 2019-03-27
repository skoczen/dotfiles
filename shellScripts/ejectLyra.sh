#!/bin/sh

Response="y"
if [ $Response = "y" ]
  then
    MOUNTPOINT=`df | grep AV_LYRA | cut -d ' ' -f 1`
    if [ `echo ""` = $MOUNTPOINT ]
     then 
      echo "  Drive does not appear to be mounted. Aborting."
      Response="N" 
     else 
      echo -n "  Drive is mounted on " 
      echo -n "..."
      echo $MOUNTPOINT
      DRIVENAME=`df | grep AV_LYRA | cut -d ' ' -f 1 | cut -d '/' -f 3`
    fi
fi

if [ $Response = "y" ] && [ `echo ""` = `fstat | grep AV_LYRA` ] && [ `echo ""` = `lsof | grep df | grep AV_LYRA | cut -d ' ' -f 1 | cut -d '/' -f 3` ]
   then
     echo "  Drive not in use..."
  else 
    if [ $Response = "y" ]
     then
      echo "*** Drive IN USE!! *** "
      Response="N"
    fi
fi

#while [ $Response = "y" ]
#  do
#  echo -n "Continue with Eject? (y/n) "
#  read -e Response
#done
#echo $Response

if [ $Response = "y" ] || [ $Response = "Y" ]
  then
    echo "  Ejecting Lyra..."
    echo "_______________________________"
    disktool -e $DRIVENAME
  else
    echo "  Leaving Lyra Mounted."
fi
echo "  Done."
