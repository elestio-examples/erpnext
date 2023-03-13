#set env vars
#set -o allexport; source .env; set +o allexport;

# apt install jq -y

mkdir -p ./sites
mkdir -p ./logs
mkdir -p ./db-data
mkdir -p ./redis-queue-data
mkdir -p ./redis-cache-data
mkdir -p ./redis-socketio-data
chown -R 1000:1000 ./sites
chown -R 1000:1000 ./logs
chown -R 1000:1000 ./db-data
chown -R 1000:1000 ./redis-queue-data
chown -R 1000:1000 ./redis-cache-data
chown -R 1000:1000 ./redis-socketio-data
