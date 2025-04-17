function download-yt-audio
  yt-dlp -x --audio-format mp3 -P ~/Documents/yt-dlp -o "%(title)s.%(ext)s" $argv
end
