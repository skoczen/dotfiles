export EDITOR='subl -w'
export PATH="~/.bin:/usr/local/share/python:/usr/local/bin:/opt/local/bin:/Users/skoczen/Library/shellScripts:/usr/local/sbin:.:/Developer/usr/bin:/Developer/usr/sbin:/opt/local/sbin:/opt/local/lib/postgresql84/bin:/android/sdk/platform-tools:/usr/local/ec2-api-tools/bin:/usr/local/share/npm/lib/node_modules/less/bin:/usr/local/share/npm/lib/node_modules:/usr/local/share/npm/lib/node_modules/karma/bin:/usr/local/opt/ruby/bin:/Users/skoczen/Library/Android/sdk/platform-tools/:${PATH}"
# /Applications/xampp/xamppfiles/bin:

bind "set show-all-if-ambiguous On"
. ~/my/dotfiles/etc/django_bash_completion.sh

export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python
source /usr/local/bin/virtualenvwrapper.sh

# Terminal colours (after installing GNU coreutils)
NM="\[\033[0;38m\]" #means no background and white lines
HI="\[\033[0;37m\]" #change this for letter colors
HII="\[\033[0;31m\]" #change this for letter colors
SI="\[\033[0;33m\]" #this is for the current directory
IN="\[\033[0m\]"

export PS1="$NM[ $HI\u $HII\h $SI\w$NM ] $IN"
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export HISTCONTROL="erasedups"
export ANDROID_HOME='/Applications/android-sdk-macosx'
export JAVA_HOME=$(/usr/libexec/java_home)
export PERL5LIB=$BREWPATH/Cellar/exiftool/9.61/libexec/lib:$HOME/perl5/lib/perl5
export LIBMEMCACHED=/usr/local/Cellar/libmemcached/1.0.18_1

# QI is the server
alias svno='svn checkout svn+ssh://aglzen@quantumimagery.com/home/.baxter/aglzen/svn/$1 $2'
# peregrine is server
alias svi='svn commit $1 -m  $2'
alias svni='svn commit $1 -m  $2'
alias checkin='svn commit $1 -m  $2'
alias svr='svn cleanup $1'
alias svnclean='svn cleanup $1'
alias svnrm='svn delete $1'
alias svna='svn add $1'
alias svnu='svn update $1'
alias svnx='svn export $1'


#SYSTEM ALIASES
alias dir='gls'
alias d='date'
alias g='gulp'
alias cls='clear'
alias cd..='cd ..'
alias kill='sudo kill -9'
alias deltree='sudo rm -R'
alias make='make -j 2'
alias pico='pico -w'
alias ls='gls -AGhl --color=auto'
alias l='ls'
alias grep="grep --color=always"
alias egrep="egrep --color=always"



#PROGRAM ALIASES
alias switch_xcode="sudo xcode-select -switch /Volumes/Aerie/Applications/Xcode.app/Contents/Developer"
alias reset_xcode="sudo xcode-select -reset"

alias tm='mate $1'
alias md='mkdir'
alias fnd='sudo find . -name $1'
alias grepall='grep -r -l $1   .'
alias up='uptime'
alias top='top -o cpu'
alias svnClean="find d . -name .svn -exec rm -rf '{}' \; -print"
alias gs='git status'
alias matebash='mate ~/.bash_profile'
alias ducks='du -cks * | sort -rn|head -11' 
alias profileme="history | awk '{print \$2}' | awk 'BEGIN{FS=\"|\"}{print \$1}' | sort | uniq -c | sort -n | tail -n 20 | sort -nr"
# alias start_pg="postgres -D /Volumes/Aerie/Users/skoczen/.db"
alias start_pg="pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start"
alias start_memcached="/usr/local/bin/memcached"
alias start_rabbitmq="sudo rabbitmq-server -detached"
alias stop_rabbitmq="sudo rabbitmqctl stop"
alias start_celery="python manage.py celeryd -v 2 -B -s /tmp/celery -E --concurrency=3 --logfile=/tmp/celery.log"
alias kill_pyc='find . -iname "*.pyc" -delete'
alias kill_dstore='find . -iname ".DS_Store" -delete'
alias bee_smoke_test='python ~/workingCopy/qi/clients/aquameta/beehive/manage.py test_smoke --settings=env.bh_test'
alias gitbox='open -a /Applications/Gitbox.app .'

#DIRECTORY ALIASES
alias cdsite='cd ~/Sites/'
alias cdsites='cd ~/Sites/'
alias cdwork='cd ~/workingCopy/'
alias cdebdb='cd ~/workingCopy/ebdb2/ebdb'
alias cdsixlinks='cd ~/workingCopy/sixlinks'
alias cdbee='cd ~/workingCopy/qi/clients/aquameta/beehive'

#DJANGO ALIASES
alias syncdb='python manage.py syncdb'
alias runserver='python manage.py runserver 0.0.0.0:8000'
alias rsaquameta='python manage.py --settings=env.dev.settings runserver'
alias rs+='python manage.py runserver_plus'
alias resetdb='cp /Users/skoczen/workingCopy/ebDB/sqlite/dbFile-orig /Users/skoczen/workingCopy/ebDB/sqlite/dbFile; syncdb'

# FTP / SSH ALIASES
alias sshlyon='colorwrap.sh ssh -l lyonserver lyonarboretum.com'
alias sshqi='colorwrap.sh ssh aglzen@quantumimagery.com'
alias sshebdb='colorwrap.sh ssh ebdb@ebdb.webfactional.com'
alias sshlwbk='colorwrap.sh ssh lewisandbark@lewisandbark.webfactional.com'
# alias sshtx='ssh tc_console@techchex.com'
alias sshqul='colorwrap.sh ssh skoczen@192.168.42.5'
alias sshwf='colorwrap.sh ssh skoczen.webfactional.com'
alias sshwf2='colorwrap.sh ssh skoczen@web166.webfaction.com'
alias sshmycelium='colorwrap.sh ssh root@agoodcloud.com'
alias sshmycelium_db='colorwrap.sh ssh root@ext-mysql-master.agoodcloud.com'
alias sshmycelium_staging='colorwrap.sh ssh root@digitalmycelium.com'
alias sshmycelium_staging_db='colorwrap.sh ssh root@ext-mysql-master.digitalmycelium.com'
alias sshmycelium_celery='colorwrap.sh ssh root@ext-mycelium-celery.agoodcloud.com'
alias sshjenkins='colorwrap.sh ssh skoczen@goodcloud.cust.arpnetworks.com'
alias sshnew_qi='colorwrap.sh ssh root@50.19.68.191'
alias sshmagpie='colorwrap.sh ssh magpie.local'
alias sshpi='colorwrap.sh ssh pi@192.168.1.80'
alias sshskypi='colorwrap.sh ssh will@192.168.1.82'

alias sshazure='colorwrap.sh ssh -p 2203 skoczen@warehouse.azurestandard.com'
alias start_redis='/usr/local/Cellar/redis/2.2.12/bin/redis-server /usr/local/etc/redis.conf'
alias start_redis2.4='/usr/local/Cellar/redis/2.4.0-rc6/bin/redis-server /usr/local/etc/redis.conf'
alias start_mailman='sudo /usr/local/mailman/bin/mailmanctl -u -s start'
alias stop_mailman='sudo /usr/local/mailman/bin/mailmanctl -u -s stop'
alias sshrack='colorwrap.sh ssh root@184.106.1elscr51.144'
alias copy_ssh='scp ~/.ssh/id_rsa.pub'
alias checkout_live='git checkout live'
alias checkout_master='git checkout master'
alias merge_master='git merge master'

# UTILITY ALIASES
#programming stuff
alias clearsvn='rm -r `find * -name "*.svn*"`'

# FORTUNE COOKIES!
# fortune | cowsay 
fortune

# misc tab-completes
# pip bash completion start
_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}
complete -o default -F _pip_completion pip
# pip bash completion end
source ~/my/dotfiles/etc/git-completion.bash
source ~/my/dotfiles/etc/git-flow-completion.bash
source ~/my/dotfiles/etc/fab_complete.sh
source ~/my/dotfiles/etc/ve.sh


_fab_completion() {
    COMPREPLY=( $( \
    COMP_LINE=$COMP_LINE  COMP_POINT=$COMP_POINT \
    COMP_WORDS="${COMP_WORDS[*]}"  COMP_CWORD=$COMP_CWORD \
    OPTPARSE_AUTO_COMPLETE=1 $1 ) )
}

complete -o default -F _fab_completion bolt

function parse_git_branch {

        git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \[\1\]/'

}

function proml {

  local        BLUE="\[\033[0;34m\]"

# OPTIONAL - if you want to use any of these other colors:

  local         RED="\[\033[0;31m\]"

  local   LIGHT_RED="\[\033[1;31m\]"

  local       GREEN="\[\033[0;32m\]"

  local LIGHT_GREEN="\[\033[1;32m\]"

  local       WHITE="\[\033[1;37m\]"

  local  LIGHT_GRAY="\[\033[0;37m\]"

# END OPTIONAL

  local     DEFAULT="\[\033[0m\]"

PS1="$NM[ $HI\u $HII\h $SI\w$NM ] $IN$RED\$(parse_git_branch)$DEFAULT\n\$ "

}

proml


### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# source ~/.bash_profile_buddyup
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
ulimit -S -n 2048

eval `gdircolors ~/.dir_colors`