#!/bin/bash
################################################################
# file: AndroidBuild.sh
# author: Richard Luo
# date: 2010/04/18 11:15:55
################################################################

## set -ix
## export TARGET_PRODUCT=cyanogen_crespo

## export TARGET_PRODUCT=cyanogen_galaxytab

# export ENABLE_FAST_BUILDING=yes
# export TARGET_BUILD_VARIANT=eng

if [ "$TARGET_PRODUCT" = "" ]
then
    export TARGET_PRODUCT=beagleboneblack
fi

# export TARGET_SIMULATOR=true
# export TARGET_SIMULATOR_WITH_BINDER=true

ADB=${HOME}/projects/android_sdk/platform-tools/adb

function Gettop
{
    local TOPFILE=build/core/envsetup.mk
    if [ -n "$TOP" -a -f "$TOP/$TOPFILE" ] ; then
        echo $TOP
    else
        if [ -f $TOPFILE ] ; then
            echo $PWD
        else
            # We redirect cd to /dev/null in case it's aliased to
            # a command that prints something as a side-effect
            # (like pushd)
            local HERE=$PWD
            T=
            while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ]; do
                cd .. > /dev/null
                T=$PWD
            done
            cd $HERE > /dev/null
            if [ -f "$T/$TOPFILE" ]; then
                echo $T
            fi
        fi
    fi
}

TOP_DIR=$(Gettop)

function Croot()
{
    if [ "$TOP_DIR" ]; then
        cd $TOP_DIR
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

# $1: path to the file that need to be installed into the system/bin
function is_the_system_bin_file()
{
    local dir_bin=`dirname $1`
    local tmp_str=`basename $dir_bin`
    if [ ! $tmp_str = "bin" ];then
        echo "it's not a bin file!"
        return 1
    fi

    tmp_str=`dirname $dir_bin`
    tmp_str=`basename $tmp_str`
    if [ ! $tmp_str = "system" ]; then
        echo "it's not in system dir!"
        return 1
    fi
    return 0
}

# $1: the input file path
function get_push_path()
{
    if echo $1 | grep -qE "/system/";then
        echo $1 | perl -pe 's/.*(\/system\/.*)/\1/'
    fi
}

# $1: the path to AndroidManifest.xml
function get_manifest_package_name()
{
    local package=`ParseAndroidManifest.pl < $1`
    echo $package
}

function is_apk_file()
{
    local apk_file=$1
    if ! echo $apk_file | grep -qE "apk$"; then
#        echo "$apk_file is not apk file!"
        return 1
    fi

    if [ ! -f $apk_file ]; then
        echo "$apk_file doesn't exist!"
        return 1
    fi
    return 0
}

# $1: input file name
function is_exe_or_so_file()
{
    local exe_so_file=$1

    if [ ! -f $exe_so_file ]; then
        echo "$exe_so_file doesn't exist!"
        return 1
    fi

    if echo $exe_so_file | grep -qE "\.so$"; then
#        echo " `basename $exe_so_file` is a .so file!"
        return 0
    else
        if [ -x $exe_so_file ]; then
#            echo "$exe_so_file is a executable file!"
            return 0
        fi
    fi

    echo "$exe_so_file is not a executable or so file"
    return 1
}

# $1: input file name
function is_jar_package()
{
    local jar_file=$1

    if [ ! -f $jar_file ]; then
        echo "$jar_file doesn't exist!"
        return 1
    fi

    if echo $jar_file | grep -qE "\.jar$"; then
#        echo " `basename $jar_file` is a .so file!"
        return 0
    else
        if [ -x $jar_file ]; then
#            echo "$jar_file is a executable file!"
            return 0
        fi
    fi

    echo "$jar_file is not a jar package file"
    return 1
}



# $1: the file need to be installed
function install_droid_apk()
{
    local apk_file=$1
    if ! is_apk_file $apk_file; then
        exit 198
    fi

    local package=$(get_manifest_package_name ./AndroidManifest.xml)

    echo "try uninstall $package"
    $ADB uninstall $package

    if ! $ADB install $apk_file; then
        echo "failed to install $package"
        exit 198
    fi

    echo "adb install $apk_file ok!"
}

function adb_do_remount()
{
    if ! $ADB remount 2>&1>/dev/null; then
        echo "remount /system with RW failed!"
        return 1
    else
        return 0
    fi
}

# $1: the file need to be installed
function install_droid_exe_or_so_file()
{
    local theFile=$1
    if [ "$1X" = "X" ]; then
        echo "null input file!"
        exit 99
    fi

    local dstPushPath=$(get_push_path $theFile)
    if [ "X$dstPushPath" = "X" ]; then
        if echo $theFile | grep -qE "linux-x86"; then
            echo "$theFile is belong to local host on x86"
            exit 0
        else
            echo "$theFile is not a file in system dir!"
            return 0
        fi
    fi
    
    if ! adb_do_remount; then
        exit 100
    fi

    if ! adb_do_install $theFile $dstPushPath; then
        exit 123
    fi 
    return 0
}

# $1: the file to install
# $2: to where it will be installed
function adb_do_install()
{
    local theFile=$1
    local dstPushPath=$2

    if $ADB push $theFile $dstPushPath>/dev/null 2>&1; then
#    if echo "just a test"; then
        printf '[OK] %-40s ==> %-50s\n' "`basename $theFile`" "$dstPushPath"
        if echo "$dstPushPath" | grep -qE '/system/bin/'; then
            local run_cmd="adb shell /system/bin/`basename $theFile`"
            printf "$run_cmd\n"
        fi
        return 0
    fi 
    echo "Failed: adb push $theFile $dstPushPath"
    return 1
}

function install_jar_package()
{
    local theFile=$1
    if [ "$1X" = "X" ]; then
        echo "null input file!"
        exit 99
    fi

    local dstPushPath=$(get_push_path $theFile)
    if [ "X$dstPushPath" = "X" ]; then
        if echo $theFile | grep -qE "linux-x86"; then
            echo "$theFile is belong to local host on x86"
            exit 0
        else
            echo "$theFile is not a file in system dir!"
            return 0
        fi
    fi
    
    if ! adb_do_remount; then
        exit 100
    fi

    if ! adb_do_install $theFile $dstPushPath; then
        exit 100
    fi

    return 0

}

function install_droid_module()
{
    local theFile=$1
    if [ "X$theFile" = "X" ];then
        echo "maybe it's a compile error!"
        exit 100
    fi

    theFile=$TOP_DIR/$theFile
    if [ ! -f $theFile ]; then
        echo "the file $theFile doesn't exist!!"
        exit 100
    fi

    if is_apk_file $theFile;then
        install_droid_apk $theFile;
        return 0
    fi

    if is_exe_or_so_file $theFile; then
        install_droid_exe_or_so_file $theFile
        return 0
    fi

    if is_jar_package $theFile; then
        install_jar_package $theFile
        return 0
    fi

    echo "UNKNOW file: $theFile"
    exit 89
}


function my_mm()
{
    if [ "$TOP_DIR" ]; then
        cd $(Gettop)/build
        source ./envsetup.sh
        cd -
        mm $1
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function start_build()
{
    T=$(Gettop)
    if [ "$TOP_DIR" ]; then
        cd $(Gettop)/build
        source ./envsetup.sh
        cd -
        local exe_name=$1
        shift
        echo "before execute $exe_name PWD:$PWD"
        if ! $exe_name $@ showcommands | tee /tmp/BuildP1000.log; then
            echo "build error, pleas check it!"
            exit 10
        else
            if [ "X$TARGET_SIMULATOR" = "X" ]; then
                echo ""
                echo ""
                cat /tmp/BuildP1000.log | grep Install:|sed -e 's/Install: //'>/tmp/EBuild.txt
                while read line
                do
#                    install_droid_module $line
                    echo $line
                done </tmp/EBuild.txt
            else
                echo "==== SIMULATOR build ok ===="
            fi
        fi
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi

}


function main()
{
    if [ -f AndroidManifest.xml ] && [ -f build.xml ] && [ -f local.properties ]; then
        ant clean && ant debug install
    else
        start_build mmm
    fi
}

echo "================ $0" 

PROG=`basename $0`

case $PROG in
    MMM)
        start_build mmm $@
        ;;
    MM)
        start_build mm
        ;;
    *)
        echo "Usage: MMM | MM"
        exit 3
        ;;
esac
