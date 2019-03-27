#! /bin/sh
unison -fastcheck true -contactquietly -auto -batch /Volumes/AV_LYRA/AUDIO/ /Users/skoczen/lyra-sync/audio/
unison -fastcheck true -contactquietly -auto -batch /Volumes/AV_LYRA/FILES/ /Users/skoczen/lyra-sync/files/
unison -fastcheck true -contactquietly -auto -batch /Volumes/AV_LYRA/PHOTOS/ /Users/skoczen/lyra-sync/photos/
unison -fastcheck true -contactquietly -auto -batch /Volumes/AV_LYRA/VIDEO/ /Users/skoczen/lyra-sync/video/
echo "Done with Sync"