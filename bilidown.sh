#!/bin/sh
IFS=$'\n'
if [ $# -eq 0 ]
then
    echo -e "->Need AVID to download!\n"
    exit 1
fi
until [ $# -eq 0 ]
do
    aid=`echo $1 | sed -e 's/.*av//g' -e 's/[a-zA-Z?/].*//g'`
    cookies='DedeUserID=; DedeUserID__ckMd5=; SESSDATA=; bili_jct=`'

    pagelist='https://api.bilibili.com/x/player/pagelist?aid='$aid'&jsonp=jsonp'
    echo -e "->Getting video list: \n"$pagelist
    cids=`curl -sL -H "Cookie: "$cookies $pagelist | jq -r '.data[].cid'`
    title=`curl -sL -H "Cookie: "$cookies 'https://api.bilibili.com/x/web-interface/view?aid='$aid | jq -r '.data.title' | sed 's/[/?!.*|:]//g'`
    cids_arr=($cids)
    echo -e "->Found video pages: "${#cids_arr[@]}

    part=0
    for cid in $cids
    do
        episode=$(( ++part ))
        echo -e "->Download video page: "$episode
        if [ "${#cids_arr[@]}" == "1" ]
        then
            filename=av$aid.$title.mp4
        else
            filename=av$aid.$title【P$episode】.mp4
        fi
        json_url='https://api.bilibili.com/x/player/playurl?avid='$aid'&cid='$cid'&qn=116&fnver=0&fnval=16&otype=json&type='
        echo -e "->Getting video source: \n"$json_url    
        json=`curl -sL -H "Cookie: "$cookies $json_url`
        dash=`echo $json | jq '.data|has("dash")'`
        durl=`echo $json | jq '.data|has("durl")'`
        
        if [ "$dash" == "true" ]
        then
            vp=`echo $json | jq -r '.data.dash.video[0].baseUrl'`
            ap=`echo $json | jq -r '.data.dash.audio[0].baseUrl'`

            echo -e "->Downloading Video Dash"
            aria2c -x10 -k1M --file-allocation=none --auto-file-renaming=false --allow-overwrite=true $vp\
                --show-console-readout false --quiet \
                --header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:65.0) Gecko/20100101 Firefox/65.0"\
                --header="Accept: */*"\
                --header="Accept-Language: zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2"\
                --header="Referer: https://www.bilibili.com/video/av"$aid\
                --header="Origin: https://www.bilibili.com"\
                --header="DNT: 1"\
                --header="Connection: keep-alive"\
                --header="Pragma: no-cache"\
                --header="Cache-Control: no-cache"\
                --header="Cookie: "$cookies \
                --out ./v_$cid.m4s

            echo -e "->Downloading Audio Dash"
            aria2c -x10 -k1M --file-allocation=none --auto-file-renaming=false --allow-overwrite=true $ap\
                --show-console-readout false --quiet \
                --header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:65.0) Gecko/20100101 Firefox/65.0"\
                --header="Accept: */*"\
                --header="Accept-Language: zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2"\
                --header="Referer: https://www.bilibili.com/video/av"$aid\
                --header="Origin: https://www.bilibili.com"\
                --header="DNT: 1"\
                --header="Connection: keep-alive"\
                --header="Pragma: no-cache"\
                --header="Cache-Control: no-cache"\
                --header="Cookie: "$cookies \
                --out ./a_$cid.m4s

            echo -e "->Merge into file: "$filename
            ffmpeg -i ./v_$cid.m4s -i ./a_$cid.m4s -c:v copy -c:a copy\
                -y -hide_banner -loglevel panic \
                ./$filename
            echo -e "->Removing temp files\n"
            rm *.m4s
        elif [ "$durl" == "true" ]
        then
            flvs=`echo $json | jq -r '.data.durl[].url'`
            for flv in $flvs
            do
                flvname=`echo $flv | sed -e 's/\?.*//g' -e 's/.*\///g'`
                echo "file './"$flvname"'" >> ./merge_$cid.txt
                echo "->Downloading Video Part: "$flvname
                aria2c -x10 -k1M --file-allocation=none --auto-file-renaming=false --allow-overwrite=true $flv\
                    --show-console-readout false --quiet \
                    --header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:65.0) Gecko/20100101 Firefox/65.0"\
                    --header="Accept: */*"\
                    --header="Accept-Language: zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2"\
                    --header="Referer: https://www.bilibili.com/video/av"$aid\
                    --header="Origin: https://www.bilibili.com"\
                    --header="DNT: 1"\
                    --header="Connection: keep-alive"\
                    --header="Pragma: no-cache" --header="Cache-Control: no-cache"\
                    --header="Cookie: "$cookies \
                    --out ./$flvname
            done
            echo "->Merge into file: "$filename
            ffmpeg -safe 0 -f concat -i ./merge_$cid.txt -c copy\
                -y -hide_banner -loglevel panic \
                ./$filename
            echo -e "->Removing temp files\n"
            rm *.flv
            rm ./merge_$cid.txt
        else
            echo -e "->Error: Video not found!\n"
        fi
    done
    shift
done
