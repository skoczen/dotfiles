#! /bin/sh

sudo rm -R ~/Library/Caches
sudo rm -R /Library/Caches
sudo rm -R /System/Library/Caches
sudo rm -R /System/Library/Extensions.kextcache
sync
sync
sync
sudo reboot

