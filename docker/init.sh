#!/bin/bash
# ======================================================================
#
# DOCKER PHP DEV ENVIRONMENT :: INIT
# (work in progress)
#
# ----------------------------------------------------------------------
# 2021-11-nn  <axel.hahn@iml.unibe.ch>
# ======================================================================

cd $( dirname $0 )
. $( basename $0 ).cfg

# git@git-repo.iml.unibe.ch:iml-open-source/docker-php-starterkit.git
selfgitrepo="docker-php-starterkit.git"

# ----------------------------------------------------------------------
# FUNCTIONS
# ----------------------------------------------------------------------

# draw a headline 2
function h2(){
    echo
    echo -e "\e[33m>>>>> $*\e[0m"
}

# draw a headline 3
function h3(){
    echo
    echo -e "\e[34m----- $*\e[0m"
}

# function _gitinstall(){
#     h2 "install/ update app from git repo ${gitrepo} in ${gittarget} ..."
#     test -d ${gittarget} && ( cd ${gittarget}  && git pull )
#     test -d ${gittarget} || git clone -b ${gitbranch} ${gitrepo} ${gittarget} 
# }

# set acl on local directory
function _setWritepermissions(){
    h2 "set write permissions on ${gittarget} ..."

    local _user=$( id -gn )
    typeset -i local _user_uid=0
    test -f /etc/subuid && _user_uid=$( grep $_user /etc/subuid 2>/dev/null | cut -f 2 -d ':' )-1
    typeset -i local DOCKER_USER_OUTSIDE=$_user_uid+$DOCKER_USER_UID

    set -vx
    # remove current acl
    sudo setfacl -bR "${WRITABLEDIR}"

    # default permissions: both the host user and the user with UID 33 (www-data on many systems) are owners with rwx perms
    sudo setfacl -dRm u:${DOCKER_USER_OUTSIDE}:rwx,${_user}:rwx "${WRITABLEDIR}"

    # permissions: make both the host user and the user with UID 33 owner with rwx perms for all existing files/directories
    sudo setfacl -Rm u:${DOCKER_USER_OUTSIDE}:rwx,${_user}:rwx "${WRITABLEDIR}"
    set +vx
}

# cleanup starterkit git data
function _removeGitdata(){
    h2 "Remove git data of starterkit"
    echo -n "Current git remote url: "
    git config --get remote.origin.url
    git config --get remote.origin.url 2>/dev/null | grep $selfgitrepo >/dev/null
    if [ $? -eq 0 ]; then
        echo
        echo -n "Delete local .git and .gitignore? [y/N] > "
        read answer
        test "$answer" = "y" && ( echo "Deleting ... " && rm -rf ../.git ../.gitignore )
    else
        echo "It was done already - $selfgitrepo was not found."
    fi

}

# helper function: cut a text file starting from database start marker
# see _generateFiles()
function _fix_no-db(){
    local _file=$1
    if [ $DB_ADD = false ]; then
        typeset -i local iStart=$( cat ${_file} | fgrep -n "$CUTTER_NO_DATABASE" | cut -f 1 -d ':' )-1
        if [ $iStart -gt 0 ]; then
            sed -ni "1,${iStart}p" ${_file}
        fi
    fi
}

# loop over all files in templates subdir make replacements and generate
# a target file.
# It skips if 
#   - 1st line is not starting with "# TARGET: filename"
#   - target file has no updated lines
function _generateFiles(){

    # re-read config vars
    . $( basename $0 ).cfg

    local _tmpfile=/tmp/newfilecontent$$.tmp
    h2 "generate files from templates..."
    for mytpl in $( ls -1 ./templates/* )
    do
        # h3 $mytpl
        local _doReplace=1

        # fetch traget file from first line
        target=$( head -1 $mytpl | grep "^# TARGET:" | cut -f 2- -d ":" | awk '{ print $1 }' )

        if [ -z "$target" ]; then
            echo SKIP: $mytpl - target was not found in 1st line
            _doReplace=0
        fi

        # write generated files to target
        if [ $_doReplace -eq 1 ]; then

            # write file from line 2 to a tmp file
            sed -n '2,$p' $mytpl >$_tmpfile

            # add generator
            # sed -i "s#{{generator}}#generated by $0 - template: $mytpl - $( date )#g" $_tmpfile
            local _md5=$( md5sum $_tmpfile | awk '{ print $1 }' )
            sed -i "s#{{generator}}#GENERATED BY $0 - template: $mytpl - $_md5#g" $_tmpfile

            # loop over vars to make the replacement
            grep "^[a-zA-Z]" $( basename $0 ).cfg | while read line
            do
                # echo replacement: $line
                mykey=$( echo $line | cut -f 1 -d '=' )
                myvalue="$( eval echo \"\${$mykey}\" )"
                # grep "{{$mykey}}" $_tmpfile

                # TODO: multiline values fail here in replacement with sed 
                sed -i "s#{{$mykey}}#${myvalue}#g" $_tmpfile
            done
            _fix_no-db $_tmpfile

            # echo "changes for $target:"
            diff  "../$target"  "$_tmpfile" | grep -v "$_md5" | grep -v "^---" | grep .
            if [ $? -eq 0 -o ! -f "../$target" ]; then
                echo -n "$mytpl - changes detected - writing [$target] ... "
                mkdir -p $( dirname  "../$target" ) || exit 2
                mv "$_tmpfile" "../$target" || exit 2
                echo OK
            else
                rm -f $_tmpfile
                echo "SKIP: $mytpl - Nothing to do."
            fi
        fi
        echo
    done

}

# loop over all files in templates subdir make replacements and generate
# a traget file.
function _removeGeneratedFiles(){
    h2 "remove generated files..."
    for mytpl in $( ls -1 ./templates/* )
    do
        h3 $mytpl

        # fetch traget file from first line
        target=$( head -1 $mytpl | grep "^# TARGET:" | cut -f 2- -d ":" | awk '{ print $1 }' )

        if [ ! -z "$target" -a -f "../$target" ]; then
            echo -n "REMOVING "
            ls -l "../$target" || exit 2
            rm -f "../$target" || exit 2
            echo OK
        else
            echo SKIP: $target
        fi
        
    done
}

function _showContainers(){
    local bLong=$1
    h2 CONTAINERS
    if [ -z "$bLong" ]; then
        docker-compose ps
    else
        docker ps | grep $APP_NAME
    fi
}


# a bit stupid ... i think I need to delete it.
function _showInfos(){
    _showContainers long
    h2 INFO

    h3 "processes"
    docker-compose top

    h3 "Check app port"
    >/dev/tcp/localhost/${APP_PORT} 2>/dev/null && (
        echo "OK, app port ${APP_PORT} is reachable"
        echo
        echo "In a web browser open:"
        echo "  $frontendurl"
    )
    h3 "Check database port"
    >/dev/tcp/localhost/${DB_PORT} 2>/dev/null && (
        echo "OK, db port ${DB_PORT} is reachable"
        echo
        echo "In a local DB admin tool:"
        echo "  host    : localhost"
        echo "  port    : ${DB_PORT}"
        echo "  user    : root"
        echo "  password: ${MYSQL_ROOT_PASS}"
    )
    echo
}

function _wait(){
    echo -n "... press RETURN > "; read dummy
}

# ----------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------

action=$1

while true; do
    echo
    echo -e "\e[32m===== INITIALIZER FOR APP [$APP_NAME] ===== \e[0m"

    if [ -z "$action" ]; then

        _showContainers

        h2 MENU
        echo "  g - remove git data of starterkit"
        echo
        echo "  i - init application: set permissions"
        echo "  t - generate files from templates"
        echo "  T - remove generated files"
        echo
        echo "  u - startup containers    docker-compose up -d"
        echo "  s - shutdown containers   docker-compose stop"
        echo "  r - remove containers     docker-compose rm -f"
        echo
        echo "  m - more infos"
        echo "  c - console (bash)"
        echo
        echo -n "  select >"
        read action 
    fi

    case "$action" in
        g)
            _removeGitdata
            ;;
        i)
            # _gitinstall
            _setWritepermissions
            ;;
        t)
            _generateFiles
            ;;
        T)
            _removeGeneratedFiles
            rm -rf containers
            ;;
        f)
            _removeGeneratedFiles
            _generateFiles
            _wait
            ;;
        m)
            _showInfos
            _wait
            ;;
        u)
            docker-compose up -d --remove-orphans
            test ! -z "${APP_ONSTARTUP}" && sleep 2 && docker exec -it appmonitor-server /bin/bash -c "${APP_ONSTARTUP}" 
            echo "In a web browser:"
            echo "  $frontendurl"
            echo
            _wait
            ;;
        s)
            docker-compose stop
            ;;
        r)
            docker-compose rm -f
            ;;
        c)
            docker ps
            echo -n "id or name >"
            read dockerid
            test -z "$dockerid" || docker exec -it $dockerid /bin/bash
            ;;
        *) echo "ACTION [$action] NOT IMPLEMENTED."
    esac
    action=
done


# ----------------------------------------------------------------------
