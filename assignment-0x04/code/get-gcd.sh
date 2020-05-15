#!/usr/bin/env bash

function gcd {
        local gcd_result
        if [[ $2 == 0 ]];then
                gcd_result="$1"
                echo "$gcd_result"
        else
                gcd_result=$(gcd "$2" "$(($1 % $2))")
                echo "$gcd_result"
        fi
}

flag=0  # 记录是否出错
if [[ $# != 2 ]];then
        echo 'ArgumentError: The number of the arguments must be two.'
        flag=$((flag + 1))
fi
re='^[0-9]+$'
if [[ $1 && ! $1 =~ $re ]];then
        # =~: 正则匹配
        echo "TypeError: $1 is not an integer."
        flag=$((flag + 1))
fi
if [[ $2 && ! $2 =~ $re ]];then
        echo "TypeError: $2 is not an integer."
        flag=$((flag + 1))
fi
if [[ $flag != 0 ]];then
        echo -e '\nget-gcd.sh - get the Greatest Common Divisor of two integers\nUsage: bash get-gcd.sh <Integer1> <Integer2>' && exit 1
fi

gcd_result="$(gcd "$1" "$2")"
echo "$gcd_result"