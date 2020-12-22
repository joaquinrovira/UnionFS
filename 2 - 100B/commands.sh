#!/bin/bash
N=10

test_speed() {
    AVG=0
    i=1
    while [ "$i" -le "$N" ]; do
        RESULT=$(eval $CMD |& awk '/copied/ {print $(NF-1) " "  $NF}')
        AMOUNT=$(echo $RESULT | awk '{print $1}')
        UNITS=$(echo $RESULT | awk '{print $2}')
        AVG=$(echo $AVG+$AMOUNT | bc)
        echo -e "\t$AMOUNT $UNITS"
        i=$((i + 1))
    done

    AVG=$(echo "scale=2;$AVG/$N" | bc)
    echo -e "\e[2K\r\tAVG = $AVG $UNITS"
}

# READ SPEEDS
echo -e "\e[36m# \e[33mRead speeds:"
echo -e "\e[33m-- \e[35mHost\e[0m"
CMD="dd if=data of=/dev/null conv=sync"
test_speed
echo -e "\e[33m-- \e[35mVolume\e[0m"
CMD='docker run --rm --mount source=volume_byte,target=/mount layers_byte dd if=/mount/data of=/dev/null conv=sync'
test_speed
echo -e "\e[33m-- \e[35mBind\e[0m"
CMD='docker run --rm --mount type=bind,source="$(pwd)",target=/mount layers_byte dd if=/mount/data of=/dev/null conv=sync'
test_speed
echo -e "\e[33m-- \e[35mLow layer\e[0m"
CMD='docker run --rm layers_byte dd if=/layers/0/data of=/dev/null conv=sync'
test_speed
echo -e "\e[33m-- \e[35mHigh layer\e[0m"
CMD='docker run --rm layers_byte dd if=/layers/9/data of=/dev/null conv=sync'
test_speed

# WRITE SPEEDS
echo -e "\e[36m# \e[33mWrite speeds:"
echo -e "\e[33m-- \e[35mHost\e[0m"
CMD="dd if=/dev/zero of=data bs=1 count=100 conv=sync"
test_speed
echo -e "\e[33m-- \e[35mVolume\e[0m"
CMD='docker run --rm --mount type=volume,source=volume,target=/mount layers_byte dd if=/dev/zero of=/mount/data bs=1 count=100 conv=sync'
test_speed
echo -e "\e[33m-- \e[35mBind\e[0m"
CMD='docker run --rm --mount type=bind,source="$(pwd)",target=/mount layers_byte dd if=/dev/zero of=/mount/data bs=1 count=100 conv=sync'
test_speed
echo -e "\e[33m-- \e[35mLow layer (preexisting file)\e[0m"
CMD='docker run --rm layers_byte dd if=/dev/zero of=/layers/0/data bs=1 count=100 conv=sync'
test_speed
echo -e "\e[33m-- \e[35mHigh layer (preexisting file)\e[0m"
CMD='docker run --rm layers_byte dd if=/dev/zero of=/layers/9/data bs=1 count=100 conv=sync'
test_speed
echo -e "\e[33m-- \e[35mLow layer\e[0m"
CMD='docker run --rm layers_byte dd if=/dev/zero of=/tmp/new_data bs=1 count=100 conv=sync'
test_speed
echo -e "\e[33m-- \e[35mHigh layer\e[0m"
CMD='docker run --rm layers_byte dd if=/dev/zero of=/tmp/new_data bs=1 count=100 conv=sync'
test_speed
