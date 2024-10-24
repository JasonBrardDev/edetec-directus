include .env

help:
	@echo ""
	@echo " start: Start the containers"
	@echo ""
	@echo " stop: Stop the containers"
	@echo ""
	@echo " restart: Restart the containers"
	@echo ""
	@echo " db-dump: Dump the database"
	@echo ""
	@echo " db-import: Import the database. Usage: make db-import SQL_FILE=filename.sql"
	@echo ""
	@echo " uploads-dump: Backup the uploads"
	@echo ""
	@echo " uploads-import: Import the uploads. Notice: import only uploads-backup.tar.gz file. Usage: make uploads-import"
	@echo ""
	@echo " schema-snapshot: Create a schema snapshot"
	@echo ""
	@echo " schema-apply: Apply the last schema snapshot"
	@echo ""
	@echo " exec: Execute a command in the directus container. Usage: make exec DOCKER_DIRECTUS_NAME=container_name (optional. Default: directus) CMD=command (optional. Default: sh)"
	@echo ""

start:
	@echo "Starting containers..."
	docker compose up -d
	@echo "Containers started"

stop:
	@echo "Stopping containers..."
	docker compose down
	@echo "Containers stopped"

restart:
	@echo "Restarting containers..."
	docker compose down
	docker compose up -d
	@echo "Containers restarted"

db-dump:
	@echo "Dumping database..."
	docker exec $(DOCKER_DB_NAME) mysqldump -u root -p$(MYSQL_ROOT_PASSWORD) $(MYSQL_DATABASE) > $(MYSQL_DATABASE)-$(shell date +'%Y-%m-%d-%H-%M-%S').sql
	@echo "Database dumped"

db-import:
	@echo "Importing database..."
	docker exec -i $(DOCKER_DB_NAME) mysql -u root -p$(MYSQL_ROOT_PASSWORD) $(MYSQL_DATABASE) < $(SQL_FILE)
	@echo "Database imported"

uploads-dump:
	@echo "Backing up uploads..."
	docker exec $(DOCKER_DIRECTUS_NAME) sh -c "tar -czf /tmp/uploads-backup.tar.gz -C /directus/uploads ."
	@echo "Uploads backed up"
	@echo "Downloading uploads..."
	docker cp $(DOCKER_DIRECTUS_NAME):/tmp/uploads-backup.tar.gz .
	docker exec $(DOCKER_DIRECTUS_NAME) rm /tmp/uploads-backup.tar.gz
	@echo "Uploads downloaded"

uploads-import:
	@echo "Importing uploads..."
	tar -xzf uploads-backup.tar.gz -C uploads
	rm uploads-backup.tar.gz
	@echo "Uploads imported and extracted"
	@echo "Restart the containers to apply the changes"
	make restart

schema-snapshot:
	@echo "Creating schema snapshot..."
	docker exec $(DOCKER_DIRECTUS_NAME) npx directus schema snapshot --yes ./snapshots/\$(shell date +'%Y-%m-%d-%H-%M-%S')\-snapshot.yaml
	@echo "Schema snapshot created"

schema-apply:
	@echo "Applying schema snapshot..."
	docker exec $(DOCKER_DIRECTUS_NAME) npx directus schema apply --yes ./snapshots/$(shell ls -t ./snapshots | head -1)
	@echo "Schema snapshot applied"

exec:
	docker exec -it -u root $(DOCKER_DIRECTUS_NAME) $(CMD)
