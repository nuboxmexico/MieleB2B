role :app, %w{ubuntu@3.140.91.212}

set :user, "ubuntu"
server "3.140.91.212", roles: %w{web}

set :ssh_options, {
  forward_agent: true,
  keys: ["~/.ssh/test-miele.pem"],
  user: 'ubuntu'
}