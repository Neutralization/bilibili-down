# bilibili-down
Shell script to download bilibili videos

## Requirements

### Linux
- [aria2](https://aria2.github.io/)  download videos
- [awk](http://www.gnu.org/software/gawk/gawk.html)
- [curl](https://curl.haxx.se/)
- [ffmpeg](https://www.ffmpeg.org/)  merge video parts
- [jq](https://stedolan.github.io/jq/)  json support
- [sed](https://www.gnu.org/software/sed/)

### Windows
- [Cygwin](https://www.cygwin.com/)
- [MinGW](http://www.mingw.org/)
- [WSL/WSL2](https://docs.microsoft.com/en-us/windows/wsl/about)

Choose one of three, and install tools mentioned in linux

## Features
- Download any bilibili videos with highest quality(*cookies needed*).
- Only support avid URL for now.

## Install
- Place bilidown.sh where you like.

## Usage
- Add alias:
> alias bilidown='sh /path/to/bilidown.sh'

- Run:
> bilidown av62401803  
> bilidown https://www.bilibili.com/video/av62401803  
> bilidown https://www.bilibili.com/video/av62401803?from=search&seid=15964470553028171854

- VIP only videos
1. Open `http://www.bilibili.com` and login
2. Press <kbd>F12</kbd> in Chrome of Firefox
3. Select `Network`
4. Press <kbd>F5</kbd> to reload the page
5. Selct first line and copy your cookies value
6. Edit `cookies` in file as `DedeUserID=****; DedeUserID__ckMd5=****; SESSDATA=****; bili_jct=****`

## Todo
- [ ] Customize output folder and filename.
- [ ] Support epid/ssid/mediaid URL.
- [ ] Support interaction videos.
- [x] Mulitple pages download.
- [x] Mulitple videos download.
- [x] Support avid URL.