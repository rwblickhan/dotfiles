sync:
    ./dotbot.sh

download-yt-audio url:
  yt-dlp -x --audio-format mp3 -P ~/Documents/yt-dlp -o "%(title)s.%(ext)s" {{url}}

bump_rwb:
  cd ~/Developer/astro-rwblickhan.org && git diff-index --quiet HEAD && echo "No changes!" || (git camp "Log")
