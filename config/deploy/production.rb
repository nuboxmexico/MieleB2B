## apunta a production

role :app, %w{ubuntu@52.90.119.126}
role :web, %w{ubuntu@54.82.240.19}

set :user, "ubuntu"
server "52.90.119.126", roles: %w{app}
server "54.82.240.19", roles: %w{web}

set :ssh_options, {
    forward_agent: true,
    keys: ["~/.ssh/miele-b2b-prod.pem"],
    user: 'ubuntu'
}