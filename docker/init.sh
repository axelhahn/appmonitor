#!/bin/bash
# ======================================================================
#
# DOCKER DEV ENVIRONMENT :: INIT
# (work in progress)
#
# ----------------------------------------------------------------------
# 2021-11-nn  <axel.hahn@iml.unibe.ch>
# ======================================================================

. $0.cfg
cd $( dirname $0 )


# ----------------------------------------------------------------------
# FUNCTIONS
# ----------------------------------------------------------------------

function h2(){
    echo
    echo ">>>>> $*"
}
function h3(){
    echo
    echo "----- $*"
}

function _gitinstall(){
    h2 "install/ update app from git repo ${gitrepo} in ${gittarget} ..."
    test -d ${gittarget} && ( cd ${gittarget}  && git pull )
    test -d ${gittarget} || git clone -b ${gitbranch} ${gitrepo} ${gittarget} 
}

# set acl on local directory
function _setWritepermissions(){
    h2 "set write permissions on ${gittarget} ..."

    local _user=$( id -gn )
    typeset -i local _user_uid=0
    test -f /etc/subuid && _user_uid=$( grep $_user /etc/subuid 2>/dev/null | cut -f 2 -d ':' )-1
    typeset -i local DOCKER_USER_OUTSIDE=$_user_uid+$DOCKER_USER_UID
    # echo $DOCKER_USER_OUTSIDE

    set -vx
    # remove current acl
    sudo setfacl -bR "${WRITABLEDIR}"

    # default permissions: both the host user and the user with UID 33 (www-data on many systems) are owners with rwx perms
    sudo setfacl -dRm u:${DOCKER_USER_OUTSIDE}:rwx,${HOST_USER_UID}:rwx "${WRITABLEDIR}"

    # permissions: make both the host user and the user with UID 33 owner with rwx perms for all existing files/directories
    sudo setfacl -Rm u:${DOCKER_USER_OUTSIDE}:rwx,${HOST_USER_UID}:rwx "${WRITABLEDIR}"
    set +vx
}


# loop over all files in templates subdir make replacements and generate
# a target file.
# It skips if 
#   - 1st line is not starting with "# TARGET: filename"
#   - target file has no updated lines
function _generateFiles(){
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
        # if [ -f "../$target" ]; then
        #    echo SKIP: target file already exists: $target
        #    _doReplace=0
        #fi

        # write generated files to target
        if [ $_doReplace -eq 1 ]; then

            # write file from line 2 to a tmp file
            sed -n '2,$p' $mytpl >$_tmpfile

            # add generator
            # sed -i "s#{{generator}}#generated by $0 - template: $mytpl - $( date )#g" $_tmpfile
            local _md5=$( md5sum $_tmpfile | awk '{ print $1 }' )
            sed -i "s#{{generator}}#GENERATED BY $0 - template: $mytpl - $_md5#g" $_tmpfile

            # loop over vars to make the replacement
            grep "^[a-zA-Z]" $0.cfg | while read line
            do
                # echo replacement: $line
                mykey=$( echo $line | cut -f 1 -d '=' )
                myvalue=$( eval echo "\${$mykey}" )
                # grep "{{$mykey}}" $_tmpfile
                sed -i "s#{{$mykey}}#$myvalue#g" $_tmpfile
            done

            # echo "changes for $target:"
            diff  "../$target"  "$_tmpfile" | grep -v "$_md5" | grep -v "^---" | grep .
            if [ $? -eq 0 -o ! -f "../$target" ]; then
                echo -n "$mytpl - changes detected - writing [$target] ... "
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
    local line=
    local bLong=$1
    # typeset -i iCounter=0
    h2 CONTAINERS
    docker ps | grep $APP_NAME | while read line
    do
        # iCounter=$iCounter+1
        if [ -z "$bLong" ]; then
            echo $line | awk '{ print "NAME [" $12 "] "  $7" "$8" "$9 }'
        else
            # echo $line | awk '{ print "IMAGE " $2 " ID " $1 ": " $7" "$8" "$9 " | PORTS: " $10 " " $11 }'
            echo $line | awk '{ print "NAME [" $12 "]" }'
            echo $line | awk '{ print "    STATUS: " $7" "$8" "$9 }'
            echo $line | awk '{ print "    IMAGE : " $2 }'
            echo $line | awk '{ print "    ID    : " $1 }'
            echo $line | awk '{ print "    PORTS : " $10 " " $11 }'
            echo
        fi
    done
    # test $iCounter -eq 0 && echo "NO CONTAINER IS RUNNING"
}


# a bit stupid ... i think I need to delete it.
function _showInfos(){
    _showContainers long
    h2 INFO
    docker-compose top
    echo
    echo "In a web browser:"
    echo -n "  $frontendurl"
    wget -O /dev/null -S $frontendurl 2>/dev/null && echo " ... OK, frontend is reachable"
    echo
    echo "In a local DB admin tool:"
    echo "  host    : localhost"
    echo "  port    : ${DB_PORT}"
    echo "  user    : root"
    echo "  password: ${MYSQL_ROOT_PASS}"
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
    echo ===== INITIALIZER FOR APP [$APP_NAME] =====

    if [ -z "$action" ]; then

        _showContainers

        h2 MENU
        echo "  i - init application; set permissions"
        echo "  t - generate files from templates"
        echo "  T - remove generated files"
        echo
        echo "  m - more infos"
        echo
        echo "  u - startup containers    docker-compose up -d"
        echo "  s - shutdown containers   docker-compose stop"
        echo "  r - remove containers     docker-compose rm -f"
        echo
        echo "  c - console (bash)"
        echo
        echo -n "  select >"
        read action 
    fi

    case "$action" in
        i)
            # _gitinstall
            _setWritepermissions
            ;;
        t)
            _generateFiles
            ;;
        T)
            _removeGeneratedFiles
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
            set -vx
            docker-compose up -d --remove-orphans
            sleep 2
            test ! -z "${ONSTARTUP}" && docker exec -it appmonitor-server /bin/bash -c "${ONSTARTUP}"
            set +vx
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
