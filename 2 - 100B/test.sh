#!/bin/bash
N=10
test_speed() {
    AVG=0
    i=1
    #[[ ! -z "$PRE" ]] && echo "Preprocess command: $PRE" || echo "Preprocess command not set"
    #[[ ! -z "$POST" ]] && echo "Postprocess command: $POST" || echo "Postprocess command not set"
    while [ "$i" -le "$N" ]; do
        [[ ! -z "$PRE" ]] && eval $PRE
        RESULT=$(eval $CMD |& awk '/copied/ {print $(NF-1) " "  $NF}')
        AMOUNT=$(echo $RESULT | awk '{print $1}')
        UNITS=$(echo $RESULT | awk '{print $2}')
        AVG=$(echo $AVG+$AMOUNT | bc)
        echo -e "\t$AMOUNT $UNITS"
        [[ ! -z "$POST" ]] && eval $POST
        i=$((i + 1))
    done

    AVG=$(echo "scale=2;$AVG/$N" | bc)
    # echo -e "\e[2K\r\tAVG = $AVG $UNITS"
}

# WRITE SPEEDS
echo -e "\e[36m# \e[33mWrite speeds (new file):"
echo -e "\e[33m-- \e[35mHost\e[0m"
PRE='rm data'
POST=
CMD='dd if=/dev/zero of=data bs=1 count=100 conv=sync'
test_speed
echo -e "\e[33m-- \e[35mVolume\e[0m"
PRE='docker run --rm --mount type=volume,source=volume,target=/mount layers_byte rm /mount/data'
POST=
CMD='docker run --rm --mount type=volume,source=volume,target=/mount layers_byte dd if=/dev/zero of=/mount/data bs=1 count=100 conv=sync'
test_speed
echo -e "\e[33m-- \e[35mBind\e[0m"
PRE='rm data'
POST=
CMD='docker run --rm --mount type=bind,source="$(pwd)",target=/mount layers_byte dd if=/dev/zero of=/mount/data bs=1 count=100 conv=sync'
test_speed
echo -e "\e[33m-- \e[35mLow layer\e[0m"
PRE=
POST=
CMD='docker run --rm layers_byte dd if=/dev/zero of=/tmp/new_data bs=1 count=100 conv=sync'
test_speed
echo -e "\e[33m-- \e[35mHigh layer\e[0m"
PRE=
POST=
CMD='docker run --rm layers_byte dd if=/dev/zero of=/tmp/new_data bs=1 count=100 conv=sync'
test_speed

echo -e "\e[36m# \e[33mWrite speeds (rewrite file):"
echo -e "\e[33m-- \e[35mHost\e[0m"
dd if=/dev/zero of=data bs=1 count=100 conv=sync &>/dev/null
CMD='dd if=/dev/zero of=data bs=1 count=100 conv=sync'
test_speed
echo -e "\e[33m-- \e[35mVolume\e[0m"
docker run --rm --mount type=volume,source=volume,target=/mount layers_byte dd if=/dev/zero of=/mount/data bs=1 count=100 conv=sync &>/dev/null
CMD='docker run --rm --mount type=volume,source=volume,target=/mount layers_byte dd if=/dev/zero of=/mount/data bs=1 count=100 conv=sync'
test_speed
echo -e "\e[33m-- \e[35mBind\e[0m"
dd if=/dev/zero of=data bs=1 count=100 conv=sync &>/dev/null
CMD='docker run --rm --mount type=bind,source="$(pwd)",target=/mount layers_byte dd if=/dev/zero of=/mount/data bs=1 count=100 conv=sync'
test_speed
echo -e "\e[33m-- \e[35mLow layer\e[0m"
CMD='docker run --rm layers_byte dd if=/dev/zero of=/layers/0/data bs=1 count=100 conv=sync'
test_speed
echo -e "\e[33m-- \e[35mHigh layer\e[0m"
CMD='docker run --rm layers_byte dd if=/dev/zero of=/layers/9/data bs=1 count=100 conv=sync'
test_speed

# READ SPEEDS
echo -e "\e[36m# \e[33mRead speeds:"
echo -e "\e[33m-- \e[35mHost\e[0m"
CMD='dd if=data of=/dev/null conv=sync'
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
