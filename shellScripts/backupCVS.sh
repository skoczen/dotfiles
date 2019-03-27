#!/bin/sh
cd /backups
cp cvsBackup1.zip cvsBackup2.zip
zip -r9 cvsBackup1.zip /fileData/cvs/*
