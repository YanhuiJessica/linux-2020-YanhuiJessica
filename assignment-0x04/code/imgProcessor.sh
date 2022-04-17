#!/usr/bin/env bash

usage() {
    cat << EOF
    Copyright: © 2020 YanhuiJessica
    Usage: bash $1 [OPTION]... <filename|filepath>
    Simple processor for image files.

    Attention:
    If the specified operation not supports the given file's type,
    the operation will be skipped.

    Image Operators:
    -q value    JPEG quality compression, value range from
                1 (lowest image quality and highest compression) to
                100 (best quality but least effective compression)
    -r value    resize image (JPEG/PNG/SVG/GIF) by scale, the value should be
                an integer and will be converted to percentage in operation
    -d string   draw text watermark in image's center (only support JPEG/PNG/GIF)
    -j          convert image format from png/svg to jpg

    Filename Settings:
    -o          overwrite the original file. If option (p | s) not set,
                the original image file will still be possible to be overwritten
                whatever this option set or not
    -c          deal directories and their files recursively
    -i          only deal with image (JPEG/PNG/GIF/SVG) filename(s)
    -p prefix   add prefix to filename(s)
    -s suffix   add suffix to filename(s)

    Other Options:
    -h          display this help and exit
EOF
}

check_env() {
    if ! [[ $(command -v convert) ]]; then
        echo -e "Command 'convert' not found\n\nTry: sudo apt install imagemagick"
        exit 1
    fi
}

path_check() {
    if [[ ! $1 ]];then
        echo -e "The path to the file(s) is required\nUse 'bash $0 -h' for more information."
        exit 1
    fi
    if [[ ! -d $1 && ! -f $1 ]];then
        echo "The given path/file $1 is not valid"
        exit 1
    fi
}

file_deal() {
    files=$(ls "$1")
    dir="${1%/*}/"
    for f in $files
    do
        file="${f##*/}"
        if [[ $file == "$f" ]];then
            f="$dir$f"
        fi
        if [[ -d "$f" ]];then
            if [[ ! $7 ]];then
                continue
            else
                # "$fp" "$quality" "$scale" "$text" "$is_convert" "$is_overwrite"
                # "$is_recursive" "$is_image" "$prefix" "$suffix"
                file_deal "$dir$file/" "$2" "$3" "$4" "$5" "$6" \
                "$7" "$8" "$9" "${10}"
                dir=$(echo "$1" | grep -P '.*(?=/[^/]*$)/' -o)
                continue
            fi
        fi
        args=""
        svgargs=""
        ftype=$(xdg-mime query filetype "$f" | grep -P '(?=[^/]*$).*' -o)
        image_flag=$(if [[ "(jpeg png gif)" =~ $ftype ]];then echo "true";fi)   # svg 不作为 convert 的图片处理
        if [[ ! $image_flag && $8 ]];then continue;fi
        if [[ $2 && 'jpeg' == "$ftype" ]];then args="$args -quality $2";fi
        if [[ $3 ]];then
            if [[ "(jpeg png gif)" =~ $ftype ]];then
                args="$args -resize $3%";
            elif [[ 'svg+xml' == "$ftype" ]];then
                svgargs="rsvg-convert -z 0$(echo "scale=2; $3/100" | bc -l) -f svg";
            fi
        fi
        if [[ $4 && "(jpeg png gif)" =~ $ftype ]];then
            curpath=$(pwd)
            args="$args -fill gray -pointsize 40 -gravity center -font '$curpath/assignment-0x04/font/Deng.ttf' -draw \"text 0,0 '$4'\""
        fi
        # 去除扩展名
        filename="${file%.*}"
        # 原扩展名
        extend="${file##*.}"
        if [[ $9 ]];then filename="$9$filename";fi
        if [[ ${10} ]];then filename="$filename${10}";fi
        if [[ ! $image_flag ]];then
            if [[ $file != "$filename.$extend" ]];then
                if [[ "$svgargs" ]];then
                    cmd="$svgargs $dir$file -o $dir$filename.$extend"
                    if [[ $5 ]];then cmd="$cmd && convert $dir$filename.$extend $dir$filename.jpg";fi
                    if [[ $6 ]];then eval "rm $dir$file";fi
                else
                    if [[ $6 ]];then eval "mv $dir$file $dir$filename.$extend"
                    else eval "cp $dir$file $dir$filename.$extend";fi
                fi
            elif [[ "$svgargs" ]];then
                cmd="$svgargs $dir$file -o $dir$filename.new.$extend"
                if [[ $5 ]];then
                    eval "$cmd && convert $dir$filename.new.$extend $dir$filename.jpg"
                    if [[ $6 ]];then rm "$dir$file";fi
                    rm "$dir$filename.new.$extend"
                else
                    eval "$cmd && mv $dir$filename.new.$extend $dir$file"
                fi
            fi
        else
            cmd="convert $args $dir$file"
            if [[ $6 ]];then
                if [[ $5 && "$ftype" != 'gif' ]];then filename="$filename.jpg"
                else filename="$filename.$extend";fi
                eval "$cmd $dir$filename && rm $dir$file"
            else
                if [[ $5 && "$ftype" != 'gif' ]];then filename="$filename.jpg"
                else filename="$filename.$extend";fi
                eval "$cmd $dir$filename"
            fi
        fi
    done
}

while getopts 'q:r:d:jocip:s:h' opt; do
    case "$opt" in
    q ) quality="$OPTARG" ;;
    r ) scale="$OPTARG" ;;
    d ) text="$OPTARG" ;;
    j ) is_convert=true ;;
    o ) is_overwrite=true ;;
    c ) is_recursive=true ;;
    i ) is_image=true ;;
    p ) prefix="$OPTARG" ;;
    s ) suffix="$OPTARG" ;;
    h | ? )
        usage "$0"
        exit 0
        ;;
    esac
done
shift $((OPTIND-1))

check_env

fp="$1"
path_check "$fp"
if [[ -d $fp && "${fp: -1}" != "/" ]];then fp="$fp/";fi

file_deal "$fp" "$quality" "$scale" "$text" "$is_convert" "$is_overwrite" "$is_recursive" "$is_image" \
"$prefix" "$suffix"