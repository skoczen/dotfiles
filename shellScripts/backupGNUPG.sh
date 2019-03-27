#!/bin/sh -e
cd /backups
cp gnupgBackup1.zip gnupgBackup-Temp-LastBackupFailed.zip
zip -r9 gnupgBackup1.zip /Volumes/USBKEY/*
mv gnupgBackup-Temp-LastBackupFailed.zip gnupgBackup2.zip
