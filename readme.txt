# Run docker-compose

docker-compose build --no-cache
docker-compose up -d --force-recreate 


# docker-compose build -t vstore-dlt-webapp .
# docker-compose up

# Run Dockerfile
docker image build -t vstore-dlt-webapp .
docker run -it --rm -p 8000:80 -p 8443:443 --name vstore-dlt-apache2-ssl-php8.2-sqlsrv5.11 -v ./src:/var/www/html/ vstore-dlt-webapp

# To check if the job is scheduled
docker exec -ti e82a8c16fd41 bash -c "crontab -l"
# To check if the cron service is running
docker exec -ti <your-container-id> bash -c "pgrep cron"
