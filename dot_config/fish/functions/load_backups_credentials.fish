function load_backups_credentials
    set -gx AWS_ACCESS_KEY_ID (op read "op://Private/Cloudflare Backups/access_key_id")
    set -gx AWS_SECRET_ACCESS_KEY (op read "op://Private/Cloudflare Backups/secret_access_key")
end
