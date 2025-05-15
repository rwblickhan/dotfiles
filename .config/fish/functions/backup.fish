function backup
  source ~/utils/source.fish
  restic -r s3:https://d68842214bc7eab6283e7ef8876b12e6.r2.cloudflarestorage.com/backups backup --verbose Movies/ Calibre\ Library/ Developer/ Documents/ Desktop/
end
