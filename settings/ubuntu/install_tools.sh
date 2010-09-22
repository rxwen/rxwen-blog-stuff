#!/bin/bash

# run this script as root, sudo su -l

# sun-java6-jdk must be the last one in array
array=(wireshark vim-gnome expect sun-java6-jdk)

len=${#array[*]}
i=0
while [ $i -lt $len ]; do
        echo "sudo apt-get install -y ${array[$i]}"
        sudo apt-get install -y "$i: ${array[$i]}"
            let i++
        done

