function backup
    load_backups_credentials
    restic -r s3:(r2b_endpoint) backup --verbose ~/Calibre\ Library/ ~/Desktop/ ~/Developer/ ~/Documents/ ~/Downloads/ ~/Movies/Personal/ ~/Music/Personal/ ~/Pictures/Personal/
end
