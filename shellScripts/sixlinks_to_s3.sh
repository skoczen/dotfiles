#!/bin/sh
~/Library/shellScripts/s3sync.rb -r -p -v --progress ~/workingCopy/sixlinks-gae/assets/badges/ SixLinks1:badges
~/Library/shellScripts/s3sync.rb -r -p -v --progress ~/workingCopy/sixlinks-gae/assets/css/ SixLinks1:css
~/Library/shellScripts/s3sync.rb -r -p -v --progress ~/workingCopy/sixlinks-gae/assets/flash/ SixLinks1:flash
~/Library/shellScripts/s3sync.rb -r -p -v --progress ~/workingCopy/sixlinks-gae/assets/fonts/ SixLinks1:fonts
~/Library/shellScripts/s3sync.rb -r -p -v --progress ~/workingCopy/sixlinks-gae/assets/images/ SixLinks1:images
# ~/Library/shellScripts/s3sync.rb  -p -v --progress ~/workingCopy/sixlinks-gae/assets/index.html SixLinks1:index.html
~/Library/shellScripts/s3sync.rb -r -p -v --progress ~/workingCopy/sixlinks-gae/assets/js/ SixLinks1:js
# ~/Library/shellScripts/s3sync.rb -r -p -v --progress ~/workingCopy/sixlinks-gae/assets/page_media/ SixLinks1:page_media