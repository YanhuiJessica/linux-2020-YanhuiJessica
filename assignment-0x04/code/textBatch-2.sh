#!/usr/bin/env bash

usage() {
    cat << EOF
    Copyright: © 2020 YanhuiJessica
    Usage: bash $1 [OPTION]...
    Simple text batch processor for the data gets from
    https://c4pr1c3.github.io/LinuxSysAdmin/exp/chap0x04/web_log.tsv.7z

    Analysis Options:
    -a          show top 100 access hosts and access frequency
    -p          show top 100 access hosts' IP and access frequency
    -v          show top 100 of the most frequently visited URLs
    -s          show the statistics for status codes
    -f          show the most frequently appear top 10 URLs for
                each status codes 4XX
    -u URL      show top 100 access hosts for specified URL

    Other Options:
    -i          show rough information about web_log.tsv
    -h          display this help and exit
EOF
}

info () {
    cnt=$(sed -n '1p' web_log.tsv | wc -w)
    echo "Count of Fields: $cnt"
    echo "Fields Listing:"
    sed -n '1p' web_log.tsv
    lines=$(grep -c "" web_log.tsv)
    lines=$((lines - 1))
    echo "Total records: $lines"
}

top_100_hosts() {
    echo "TOP 100 for Access Hosts:"
    cut web_log.tsv -f 1 | sort | uniq -c | sort -rn -k 1 | head -n 100
}

top_100_ips() {
    echo "TOP 100 for Access Hosts' IP:"
    cut web_log.tsv -f 1 | grep -v "[a-zA-Z]" | sort | uniq -c | sort -rn -k 1 | head -n 100
}

top_100_urls() {
    echo "The Most Frequently Visited URLS - TOP 100:"
    cut web_log.tsv -f 5 | sort | uniq -c | sort -rn -k 1 | head -n 100
}

status_code() {
    sc=($(cut web_log.tsv -f 6))
    unset "sc[0]"
    total=${#sc[@]}
    codes=($(echo "${sc[*]}" | tr ' ' '\n' | sort -u))
    echo "Status Codes Analysis Result:"
    printf "Status Code\tNum\tNum/Total\n---------------------------------\n"
    for c in "${codes[@]}";do
        num=$(cut web_log.tsv -f 6 | grep "$c" -c)
        pnum=$(echo "scale=6; $num/$total" | bc)
        pnum=$(echo "$pnum*100" | bc)
        printf "%-10s\t%d\t%.4f%%\n" "$c" "$num" "$pnum"
    done
}

scode_4xx() {
    fours=($(cut web_log.tsv -f 6 | grep -P "\b4" | sort -u))
    for four in "${fours[@]}";do
        echo -e "\nTOP 10 URLS for Status Code $four:"
        # "^\S+\s+$four\b" 只匹配第二列的状态码
        cut web_log.tsv -f 5,6 | grep -P "^\S+\s+$four\b" | cut -f 1 | sort | uniq -c | sort -k 1 -rn | head -n 10
    done
}

sp_url_top() {
    echo "TOP 100 Access Hosts for $1:"
    cut web_log.tsv -f 1,5 | grep -P "^\S+\s+$1\b" | cut -f 1 | sort | uniq -c | sort -k 1 -rn | head -n 100
}

while getopts "apvsfu:ih" opt; do
    case $opt in
    a ) top_100_hosts ;;
    p ) top_100_ips ;;
    v ) top_100_urls ;;
    s ) status_code ;;
    f ) scode_4xx ;;
    u ) sp_url_top "$OPTARG" ;;
    i ) info ;;
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