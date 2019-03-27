ve ()
{
    project=$1;
    cd ~/workingCopy/${project}
    workon ${project}
}

_ve_complete ()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "`virtualenvwrapper_show_workon_options`" -- ${cur}) )
}
complete -o default -o nospace -F _ve_complete ve