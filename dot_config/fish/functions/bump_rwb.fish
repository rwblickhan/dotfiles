function bump_rwb
  cd ~/Developer/astro-rwblickhan.org
  if jj log -r "@" --no-graph -T 'description' | string match -qr '.'
    echo "Error: current revision is already described"
    return 1
  end
  set -l parent_id (jj log -r "@-" --no-graph -T 'commit_id')
  set -l main_id (jj log -r "main" --no-graph -T 'commit_id')
  if test "$parent_id" != "$main_id"
    echo "Error: parent of current revision is not the main bookmark"
    return 1
  end
  if jj diff | string match -qr '.'
    jj describe -m "Log"; and mise run push
  else
    echo "No changes!"
  end
end
