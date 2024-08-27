include .env

start:
	docker-compose up -d

stop:
	docker-compose down

dump:
	docker exec $(DOCKER_DB_NAME) mysqldump -u root -proot $(MYSQL_DATABASE) > $(MYSQL_DATABASE)-$(shell date +'%Y-%m-%d-%H-%M-%S').sql
