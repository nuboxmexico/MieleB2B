role :web, %w{ubuntu@3.131.176.214}

set :user, "ubuntu"
server "3.131.176.214", roles: %w{web}

set :ssh_options, {
    forward_agent: true,
    keys: ["~/.ssh/test-miele.pem"],
    user: 'ubuntu'
}