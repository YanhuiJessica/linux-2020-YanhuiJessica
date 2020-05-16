#!/usr/bin/env bash

usage() {
    cat << EOF
    Copyright: © 2020 YanhuiJessica
    Usage: bash $1 [OPTION]...
    Simple text batch processor for the data gets from
    https://c4pr1c3.github.io/LinuxSysAdmin/exp/chap0x04/worldcupplayerinfo.tsv

    Analysis Options:
    -a          show the statistics for Athletes' ages, the count of people
                and the percentage for different age range
    -p          show the statistics for Athletes' positions
    -l          show the longest and shortest names of the players
    -e          show the youngest player(s) with age and oldest player(s)
                with age

    Other Options:
    -i          show rough information about worldcupplayerinfo.tsv
    -h          display this help and exit
EOF
}

info() {
    cnt=$(sed -n '1p' worldcupplayerinfo.tsv | wc -w)
    echo "Count of Fields: $cnt"
    echo "Fields Listing:"
    sed -n '1p' worldcupplayerinfo.tsv
    lines=$(grep -c "" worldcupplayerinfo.tsv)
    lines=$((lines - 1))
    echo "Total records: $lines"
}

age_num_calc() {
    ages=$(cut worldcupplayerinfo.tsv -f 6 | wc -l)
    # 删除第一行列名
    ages=$((ages - 1))
    # 20 岁以下(\b 表示匹配一个单词边界)
    ltw=$(cut worldcupplayerinfo.tsv -f 6 | grep -P "\b[0-9]\b|1[0-9]" -c)
    pltw=$(echo "scale=6; $ltw/$ages" | bc)
    pltw=$(echo "$pltw*100" | bc)
    # [20 -30] 岁
    mid=$(cut worldcupplayerinfo.tsv -f 6 | grep -P "30|[2][0-9]" -c)
    pmid=$(echo "scale=6; $mid/$ages" | bc)
    pmid=$(echo "$pmid*100" | bc)
    # 30 岁以上
    gth=$((ages - ltw - mid))
    pgth=$(echo "scale=6; $gth/$ages" | bc)
    pgth=$(echo "$pgth*100" | bc)
    echo "Athletes' ages analysis result:"
    printf "Ages\t\tNum\tNum/Total\n----------------------------------\n"
    printf "( 0, 20)\t%d\t%.4f%%\n" "$ltw" "$pltw"
    printf "[20, 30]\t%d\t%.4f%%\n" "$mid" "$pmid"
    printf "(30, ∞)\t%d\t%.4f%%\n" "$gth" "$pgth"
}

pos_analysis() {
    mapfile -t postotal < <(cut worldcupplayerinfo.tsv -f 5)
    unset "postotal[0]"
    total=${#postotal[@]}
    mapfile -t pos < <(echo "${postotal[*]}" | tr ' ' '\n' | sort -u)
    echo "Athletes' positions analysis result:"
    printf "Position\tNum\tNum/Total\n----------------------------------\n"
    for p in "${pos[@]}";do
        num=$(cut worldcupplayerinfo.tsv -f 5 | grep "$p" -c)
        pnum=$(echo "scale=6; $num/$total" | bc)
        pnum=$(echo "$pnum*100" | bc)
        printf "%-10s\t%d\t%.4f%%\n" "$p" "$num" "$pnum"
    done
}

find_name_extreme() {
    mapfile -t names < <(cut worldcupplayerinfo.tsv -f 9)
    # 删除第一行列名
    unset "names[0]"
    mi=10000
    mx=0
    export LC_ALL=C
    for name in "${names[@]}";do
        len=${#name}
        if [[ "$len" -gt "$mx" ]];then mx="$len";fi
        if [[ "$len" -lt "$mi" ]];then mi="$len";fi
    done
    echo "The longest name(s):"
    for name in "${names[@]}";do
        len=${#name}
        if [[ $len == "$mx" ]];then echo "$name";fi
    done
    echo -e "\nThe shortest name(s):"
    for name in "${names[@]}";do
        len=${#name}
        if [[ $len == "$mi" ]];then echo "$name";fi
    done
}

find_age_extreme() {
    # -n 按自然数排序
    mapfile -t ages < <(cut worldcupplayerinfo.tsv -f 6 | sort -nu)
    mi=${ages[1]}
    mx=${ages[${#ages[@]}-1]}
    echo "Smallest age: $mi"
    echo "Youngest player(s):"
    cut worldcupplayerinfo.tsv -f 6,9 | grep "$mi" | cut -f 2

    echo -e "\nBiggest age: $mx"
    echo "Oldest player(s):"
    cut worldcupplayerinfo.tsv -f 6,9 | grep "$mx" | cut -f 2
}

while getopts "iapleh" opt; do
    case $opt in
    i ) info ;;
    a ) age_num_calc ;;
    p ) pos_analysis ;;
    l ) find_name_extreme ;;
    e ) find_age_extreme ;;
    h | ? )
        usage "$0"
        exit 0
        ;;
    esac
done

if [[ $# == 0 ]];then
    usage "$0"
    exit 0
fi