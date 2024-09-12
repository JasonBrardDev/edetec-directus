include .env

start:
	docker-compose up -d

stop:
	docker-compose down

dump:
	docker exec $(DOCKER_DB_NAME) mysqldump -u root -proot $(MYSQL_DATABASE) > $(MYSQL_DATABASE)-$(shell date +'%Y-%m-%d-%H-%M-%S').sql

schema-snapshot:
	docker exec $(DOCKER_DIRECTUS_NAME) npx directus schema snapshot --yes ./snapshots/\$(shell date +'%Y-%m-%d-%H-%M-%S')\-snapshot.yaml

schema-apply:
	docker exec $(DOCKER_DIRECTUS_NAME) npx directus schema apply --dry-run ./snapshots/$(shell ls -t ./snapshots | head -1)