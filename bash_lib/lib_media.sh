#!/bin/bash

if [ "`type -t ffmpeg_convert_webm_to_mp3`" = "function" ]; then
	echo "Skipping import functions from lib_media.sh, they're already sourced in this shell"
	return 0
fi

# ffmpeg stuff

function ffmpeg_convert_webm_to_mp3() {
	if [ -z "${1}" ]; then
		echo "USAGE: ffmpeg_convert_webm_to_mp3 [DIRECTORY]"
		echo "  This will convert each webm in the given directory to mp3."
		return
	fi
	OLD_IFS=${IFS}
	IFS=$'\n'
	FILES=`find ${1} -type f | grep webm`
	for FILE in ${FILES}; do
	    echo -e "Processing video: ${FILE}";	    
	    ffmpeg -i "${FILE}" -codec:a libmp3lame -b:a 320k -ar 44100 -y "${1}/${FILE%.webm}.mp3";
	done;
	IFS=${OLD_IFS}
}
export -f ffmpeg_convert_webm_to_mp3

# youtube-dl stuff

# NOTE: yt_dlp is available easily via homebrew

# youtube-dl -f bestaudio --restrict-filenames --max-downloads 999 -r 5000K --buffer-size 16K --audio-quality 0 --sleep-interval 60 --max-sleep-interval 300 "https://www.youtube.com/playlist?list=PLVNmxQCckyw5bo9u008T5cZNJ_QwWW5o1"
YT_DLP_FILE_FORMAT="%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s"
alias yt_dlp_mp3='yt-dlp -x --audio-format mp3 --audio-quality 0 -o "${YT_DLP_FILE_FORMAT}" ${1}'

