function ona_add_ssh_host --description "Append zmx config to ona's ssh config"
    if test (count $argv) -ne 1
        echo "Usage: ona_add_ssh_host <hostname>"
        return 1
    end
    begin
        echo ""
        echo "Host ona.*"
        echo "    HostName $argv[1]"
        echo "    User gitpod_devcontainer"
        echo "    ProxyCommand \"/usr/local/bin/gitpod\" environment ssh %h --proxy-connect --user %r --ona-config-dir \"/Users/russellblickhan/.ssh/ona\""
        echo "    StrictHostKeyChecking no"
        echo "    IdentityFile \"/Users/russellblickhan/.ssh/ona/id_ed25519\""
        echo "    IdentitiesOnly yes"
        echo "    ControlMaster auto"
        echo "    RemoteCommand /home/linuxbrew/.linuxbrew/bin/zmx attach %k"
        echo "    RequestTTY yes"
    end >> ~/.ssh/ona/config
end
