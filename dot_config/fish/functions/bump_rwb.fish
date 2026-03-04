function bump_rwb
  cd ~/Developer/astro-rwblickhan.org
  if jj diff | string match -qr '.'
    jj describe -m "Log"; and jj bookmark set main; and jj git push
  else
    echo "No changes!"
  end
end
