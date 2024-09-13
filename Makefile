include .env

start:
	docker-compose up -d

stop:
	docker-compose down

db-dump:
	docker exec $(DOCKER_DB_NAME) mysqldump -u root -p$(MYSQL_ROOT_PASSWORD) $(MYSQL_DATABASE) > $(MYSQL_DATABASE)-$(shell date +'%Y-%m-%d-%H-%M-%S').sql

db-import:
	docker exec -i $(DOCKER_DB_NAME) mysql -u root -p$(MYSQL_ROOT_PASSWORD) $(MYSQL_DATABASE) < $(SQL_FILE)

schema-snapshot:
	docker exec $(DOCKER_DIRECTUS_NAME) npx directus schema snapshot --yes ./snapshots/\$(shell date +'%Y-%m-%d-%H-%M-%S')\-snapshot.yaml

schema-apply:
	docker exec $(DOCKER_DIRECTUS_NAME) npx directus schema apply --dry-run ./snapshots/$(shell ls -t ./snapshots | head -1)

exec:
	docker exec -it $(DOCKER_DIRECTUS_NAME) $(CMD)

exec-sh:
	docker exec -it $(DOCKER_DIRECTUS_NAME) sh