# bash completion for restic                               -*- shell-script -*-

__debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__my_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__handle_reply()
{
    __debug "${FUNCNAME[0]}"
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            COMPREPLY=( $(compgen -W "${allflags[*]}" -- "$cur") )
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%%=*}"
                __index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION}" ]; then
                        # zfs completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi
            return 0;
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions=("${must_have_one_noun[@]}")
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    COMPREPLY=( $(compgen -W "${completions[*]}" -- "$cur") )

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        COMPREPLY=( $(compgen -W "${noun_aliases[*]}" -- "$cur") )
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        declare -F __custom_func >/dev/null && __custom_func
    fi

    # available in bash-completion >= 2, not always present on macOS
    if declare -F __ltrim_colon_completions >/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# The arguments should be in the form "ext1|ext2|extn"
__handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1
}

__handle_flag()
{
    __debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    if [ -n "${flagvalue}" ] ; then
        flaghash[${flagname}]=${flagvalue}
    elif [ -n "${words[ $((c+1)) ]}" ] ; then
        flaghash[${flagname}]=${words[ $((c+1)) ]}
    else
        flaghash[${flagname}]="true" # pad "true" for bool flag
    fi

    # skip the argument to a two word flag
    if __contains_word "${words[c]}" "${two_word_flags[@]}"; then
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__handle_noun()
{
    __debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__handle_command()
{
    __debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_$(basename "${words[c]//:/__}")"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__handle_word()
{
    if [[ $c -ge $cword ]]; then
        __handle_reply
        return
    fi
    __debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __handle_flag
    elif __contains_word "${words[c]}" "${commands[@]}"; then
        __handle_command
    elif [[ $c -eq 0 ]] && __contains_word "$(basename "${words[c]}")" "${commands[@]}"; then
        __handle_command
    else
        __handle_noun
    fi
    __handle_word
}

_restic_autocomplete()
{
    last_command="restic_autocomplete"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--completionfile=")
    flags_with_completion+=("--completionfile")
    flags_completion+=("_filedir")
    local_nonpersistent_flags+=("--completionfile=")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_backup()
{
    last_command="restic_backup"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--exclude=")
    two_word_flags+=("-e")
    local_nonpersistent_flags+=("--exclude=")
    flags+=("--exclude-caches")
    local_nonpersistent_flags+=("--exclude-caches")
    flags+=("--exclude-file=")
    local_nonpersistent_flags+=("--exclude-file=")
    flags+=("--exclude-if-present=")
    local_nonpersistent_flags+=("--exclude-if-present=")
    flags+=("--files-from=")
    local_nonpersistent_flags+=("--files-from=")
    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    flags+=("--hostname=")
    local_nonpersistent_flags+=("--hostname=")
    flags+=("--one-file-system")
    flags+=("-x")
    local_nonpersistent_flags+=("--one-file-system")
    flags+=("--parent=")
    local_nonpersistent_flags+=("--parent=")
    flags+=("--stdin")
    local_nonpersistent_flags+=("--stdin")
    flags+=("--stdin-filename=")
    local_nonpersistent_flags+=("--stdin-filename=")
    flags+=("--tag=")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--time=")
    local_nonpersistent_flags+=("--time=")
    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_cat()
{
    last_command="restic_cat"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_check()
{
    last_command="restic_check"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--check-unused")
    local_nonpersistent_flags+=("--check-unused")
    flags+=("--read-data")
    local_nonpersistent_flags+=("--read-data")
    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_dump()
{
    last_command="restic_dump"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_find()
{
    last_command="restic_find"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--host=")
    two_word_flags+=("-H")
    local_nonpersistent_flags+=("--host=")
    flags+=("--ignore-case")
    flags+=("-i")
    local_nonpersistent_flags+=("--ignore-case")
    flags+=("--long")
    flags+=("-l")
    local_nonpersistent_flags+=("--long")
    flags+=("--newest=")
    two_word_flags+=("-N")
    local_nonpersistent_flags+=("--newest=")
    flags+=("--oldest=")
    two_word_flags+=("-O")
    local_nonpersistent_flags+=("--oldest=")
    flags+=("--path=")
    local_nonpersistent_flags+=("--path=")
    flags+=("--snapshot=")
    two_word_flags+=("-s")
    local_nonpersistent_flags+=("--snapshot=")
    flags+=("--tag=")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_forget()
{
    last_command="restic_forget"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--keep-last=")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--keep-last=")
    flags+=("--keep-hourly=")
    two_word_flags+=("-H")
    local_nonpersistent_flags+=("--keep-hourly=")
    flags+=("--keep-daily=")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--keep-daily=")
    flags+=("--keep-weekly=")
    two_word_flags+=("-w")
    local_nonpersistent_flags+=("--keep-weekly=")
    flags+=("--keep-monthly=")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--keep-monthly=")
    flags+=("--keep-yearly=")
    two_word_flags+=("-y")
    local_nonpersistent_flags+=("--keep-yearly=")
    flags+=("--keep-tag=")
    local_nonpersistent_flags+=("--keep-tag=")
    flags+=("--host=")
    local_nonpersistent_flags+=("--host=")
    flags+=("--hostname=")
    local_nonpersistent_flags+=("--hostname=")
    flags+=("--tag=")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--path=")
    local_nonpersistent_flags+=("--path=")
    flags+=("--group-by=")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--group-by=")
    flags+=("--dry-run")
    flags+=("-n")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--prune")
    local_nonpersistent_flags+=("--prune")
    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_init()
{
    last_command="restic_init"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_key()
{
    last_command="restic_key"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_list()
{
    last_command="restic_list"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_ls()
{
    last_command="restic_ls"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--host=")
    two_word_flags+=("-H")
    local_nonpersistent_flags+=("--host=")
    flags+=("--long")
    flags+=("-l")
    local_nonpersistent_flags+=("--long")
    flags+=("--path=")
    local_nonpersistent_flags+=("--path=")
    flags+=("--tag=")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_manpage()
{
    last_command="restic_manpage"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--output-dir=")
    local_nonpersistent_flags+=("--output-dir=")
    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_migrate()
{
    last_command="restic_migrate"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_mount()
{
    last_command="restic_mount"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--allow-other")
    local_nonpersistent_flags+=("--allow-other")
    flags+=("--allow-root")
    local_nonpersistent_flags+=("--allow-root")
    flags+=("--host=")
    two_word_flags+=("-H")
    local_nonpersistent_flags+=("--host=")
    flags+=("--owner-root")
    local_nonpersistent_flags+=("--owner-root")
    flags+=("--path=")
    local_nonpersistent_flags+=("--path=")
    flags+=("--tag=")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_prune()
{
    last_command="restic_prune"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_rebuild-index()
{
    last_command="restic_rebuild-index"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_restore()
{
    last_command="restic_restore"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--exclude=")
    two_word_flags+=("-e")
    local_nonpersistent_flags+=("--exclude=")
    flags+=("--host=")
    two_word_flags+=("-H")
    local_nonpersistent_flags+=("--host=")
    flags+=("--include=")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--include=")
    flags+=("--path=")
    local_nonpersistent_flags+=("--path=")
    flags+=("--tag=")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--target=")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--target=")
    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_snapshots()
{
    last_command="restic_snapshots"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--compact")
    flags+=("-c")
    local_nonpersistent_flags+=("--compact")
    flags+=("--host=")
    two_word_flags+=("-H")
    local_nonpersistent_flags+=("--host=")
    flags+=("--path=")
    local_nonpersistent_flags+=("--path=")
    flags+=("--tag=")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_tag()
{
    last_command="restic_tag"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add=")
    local_nonpersistent_flags+=("--add=")
    flags+=("--host=")
    two_word_flags+=("-H")
    local_nonpersistent_flags+=("--host=")
    flags+=("--path=")
    local_nonpersistent_flags+=("--path=")
    flags+=("--remove=")
    local_nonpersistent_flags+=("--remove=")
    flags+=("--set=")
    local_nonpersistent_flags+=("--set=")
    flags+=("--tag=")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_unlock()
{
    last_command="restic_unlock"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--remove-all")
    local_nonpersistent_flags+=("--remove-all")
    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic_version()
{
    last_command="restic_version"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_restic()
{
    last_command="restic"
    commands=()
    commands+=("autocomplete")
    commands+=("backup")
    commands+=("cat")
    commands+=("check")
    commands+=("dump")
    commands+=("find")
    commands+=("forget")
    commands+=("init")
    commands+=("key")
    commands+=("list")
    commands+=("ls")
    commands+=("manpage")
    commands+=("migrate")
    commands+=("mount")
    commands+=("prune")
    commands+=("rebuild-index")
    commands+=("restore")
    commands+=("snapshots")
    commands+=("tag")
    commands+=("unlock")
    commands+=("version")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--json")
    flags+=("--no-lock")
    flags+=("--option=")
    two_word_flags+=("-o")
    flags+=("--password-file=")
    two_word_flags+=("-p")
    flags+=("--quiet")
    flags+=("-q")
    flags+=("--repo=")
    two_word_flags+=("-r")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_restic()
{
    local cur prev words cword
    declare -A flaghash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __my_init_completion -n "=" || return
    fi

    local c=0
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("restic")
    local must_have_one_flag=()
    local must_have_one_noun=()
    local last_command
    local nouns=()

    __handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_restic restic
else
    complete -o default -o nospace -F __start_restic restic
fi

# ex: ts=4 sw=4 et filetype=sh
