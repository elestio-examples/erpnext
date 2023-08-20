#set env vars
#set -o allexport; source .env; set +o allexport;

# mkdir -p ./assets
mkdir -p ./db-data
mkdir -p ./redis-queue-data
mkdir -p ./redis-cache-data
mkdir -p ./redis-socketio-data
mkdir -p ./sites
mkdir -p ./logs


# chown -R 1000:1000 ./assets
chown -R 1000:1000 ./db-data
chown -R 1000:1000 ./redis-queue-data
chown -R 1000:1000 ./redis-cache-data
chown -R 1000:1000 ./redis-socketio-data
chown -R 1000:1000 ./sites
chown -R 1000:1000 ./logs