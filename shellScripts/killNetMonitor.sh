#!/bin/sh

ProcID=`top -l1 200 | grep "Net Monito"`
ProcID=`echo $ProcID | cut -f1 -d ' '`
kill $ProcID
