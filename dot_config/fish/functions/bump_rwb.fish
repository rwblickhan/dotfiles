function bump_rwb
  cd ~/Developer/astro-rwblickhan.org
  if jj log -r "@" --no-graph -T 'description' | string match -qr '.'
    echo "Error: current revision is already described"
    return 1
  end
  if not jj log -r "@- & main" --no-graph -T 'x' 2>/dev/null | string match -q 'x'
    echo "Error: parent of current revision is not the main bookmark"
    return 1
  end
  if jj diff | string match -qr '.'
    jj describe -m "Log"; and jj bookmark set main; and jj git push
  else
    echo "No changes!"
  end
end
