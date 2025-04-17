function bump_rwb
  cd ~/Developer/astro-rwblickhan.org && git diff-index --quiet HEAD && echo "No changes!" || git camp "Log"
end
