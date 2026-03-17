function backup
    set -lx AWS_ACCESS_KEY_ID (op read "op://Private/Cloudflare Backups/access_key_id")
    set -lx AWS_SECRET_ACCESS_KEY (op read "op://Private/Cloudflare Backups/secret_access_key")
    restic -r s3:(r2b_endpoint)/backups backup --verbose ~/Movies/ ~/Calibre\ Library/ ~/Developer/ ~/Documents/ ~/Desktop/
end
