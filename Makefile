PROJECT ?= miele_b2b_cl

help:
	@echo "Local environment tasks:"
	@echo "  setup        Setup the environment, create containers and initialize app"
	@echo "  server		  	Run the rails app"
	@echo "  shell        Run bash interactive shell on the app container"
	@echo "  console      Run rails c on the app container"
	@echo "  restore_db   Run script to restore database with DUMP file"
	@echo "  destroy      Clean the environment, remove volumes, containers and images"

setup:
	@echo ""
	@echo "Building app container image..."
	docker compose build app

	@echo ""
	@echo "Initializating database..."
	docker compose run --rm app bash -c "rake db:create && rake db:migrate && rake db:seed"

	@echo ""
	@echo "All is well"

server:
	docker compose up app

shell:
	docker compose run --rm app bash

console:
	docker compose run --rm app bundle exec rails c

test:
ifdef ARGS
	docker compose run --rm app rspec $(ARGS)
else
	docker compose run --rm app rspec --exclude-pattern "spec/old_test/**/*_spec.rb" --tag ~pending
endif

restore_db:
	-docker compose run --rm app bash -c "rake db:drop && rake db:create"
	-wget -O /tmp/miele_development.sql "https://miele-assets.s3.amazonaws.com/backups/miele_development.sql"
	-docker compose exec -T postgres psql -U oferusdev -W -h localhost db/miele_development < /tmp/miele_development.sql
	-docker compose run --rm app bundle exec rake db:migrate
	-docker compose run --rm app bundle exec rake db:seed
	

destroy:
	-docker compose run --rm app rake db:drop
	-docker compose down --volumes
	-docker rmi -f $(PROJECT)-dev:latest >/dev/null 2>&1

