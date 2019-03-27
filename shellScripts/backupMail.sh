#!/bin/sh
cd /backups
cp mailBackup1.zip mailBackup2.zip
zip -r9 mailBackup1.zip ~/Library/Mail/*
