# Miele B2B CL

- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Installation](#installation)
- [Development](#development)
  - [Commits and pushing](#commits-and-pushing)
  - [How to run the app](#how-to-run-the-app)
  - [Troubleshooting](#troubleshooting)
- [Deploy](#deploy)

## Getting Started

### Requirements

1. [Docker](https://www.docker.com/products/docker-desktop/)

   - **Installation on [Ubuntu](https://docs.docker.com/desktop/install/ubuntu/)**
   - **Installation on MacOs**
     ```bash
     brew install --cask docker
     ```
   - **Installation on Windows**
     ```bash
     choco install docker-desktop
     ```

2. NodeJs and Yarn

   - **Installation on [Ubuntu](https://nodejs.org/en/download/package-manager)**
   - **Installation on MacOs**
     ```bash
     brew install node@20 yarn
     ```
   - **Installation on Windows**
     ```bash
     choco install nodejs-lts yarn
     ```

3. [Set up personal SSH keys](https://support.atlassian.com/bitbucket-cloud/docs/set-up-personal-ssh-keys-on-linux/)
   ```bash
   ssh-keygen -t ed25519 -C "your_email@garagelabs.cl"
   eval "$(ssh-agent)"
   ssh-add ~/.ssh/id_ed25519
   pbcopy < ~/.ssh/id_ed25519.pub
   # Add key in personal Bitbucket settings
   ```

### Installation

1. Clone the project

   ```bash
   git clone git@bitbucket.org:garage-labs/miele.git && cd miele
   ```

2. Execute the command to set the initial run environment (provide the basics for running the application)

   ```bash
   make setup
   ```

3. Populate database with production data

   [Download dump file (requires requesting access)]

   ```bash
   make restore_db
   ```

## Development

### How to run the app

1. Run the rails app with all dependent services as Docker containers: postgreSql (Database), Redis and Sidekiq.

   ```
   make server
   ```

2. To execute bash commands inside the container
   ```
   make shell
   ```
3. To execute commands in the **rails** console
   ```
   make console
   ```

### Troubleshooting

If you need to destroy the project, you can clean the containers and data volumes (including the database).

```bash
make destroy
```

## Deploy

We have CI/CD pipelines with AWS CODEPIPELINE

If you want to deploy to **staging** create a PR to develop, 
If you want to deploy to **production** create a PR to master
