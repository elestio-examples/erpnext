<a href="https://elest.io">
  <img src="https://elest.io/images/elestio.svg" alt="elest.io" width="150" height="75">
</a>

[![Discord](https://img.shields.io/static/v1.svg?logo=discord&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=Discord&message=community)](https://discord.gg/4T4JGaMYrD "Get instant assistance and engage in live discussions with both the community and team through our chat feature.")
[![Elestio examples](https://img.shields.io/static/v1.svg?logo=github&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=github&message=open%20source)](https://github.com/elestio-examples "Access the source code for all our repositories by viewing them.")
[![Blog](https://img.shields.io/static/v1.svg?color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=elest.io&message=Blog)](https://blog.elest.io "Latest news about elestio, open source software, and DevOps techniques.")

# ERPNext, verified and packaged by Elestio

A better community platform for the modern web.

[ERPNext](https://erpnext.com/)ERPNext is the leading open-source enterprise resource planning (ERP) software.fiveLinesIntro":

<img src="https://github.com/elestio-examples/erpnext/raw/main/ERPNext.png" alt="erpnext" width="800">

Deploy a <a target="_blank" href="https://elest.io/open-source/erpnext">fully managed ERPNext</a> on <a target="_blank" href="https://elest.io/">elest.io</a> ERPNext is a free and open-source integrated Enterprise Resource Planning software developed by Frappé Technologies Pvt. Ltd. and is built on MariaDB database system using Frappe, a Python based server-side framework.

[![deploy](https://github.com/elestio-examples/erpnext/raw/main/deploy-on-elestio.png)](https://dash.elest.io/deploy?source=cicd&social=dockerCompose&url=https://github.com/elestio-examples/erpnext)

# Why use Elestio images?

- Elestio stays in sync with updates from the original source and quickly releases new versions of this image through our automated processes.
- Elestio images provide timely access to the most recent bug fixes and features.
- Our team performs quality control checks to ensure the products we release meet our high standards.

# Usage

## Git clone

You can deploy it easily with the following command:

    git clone https://github.com/elestio-examples/erpnext.git

Copy the .env file from tests folder to the project directory

    cp ./tests/.env ./.env

Edit the .env file with your own values.


Run the project with the following command

    docker-compose up -d

You can access the Web UI at: `http://your-domain:8989`

## Docker-compose

Here are some example snippets to help you get started creating a container.

            version: "3.3"
            services:
            backend:
                image: frappe/erpnext-worker:${SOFTWARE_VERSION_TAG}
                restart: always
                volumes:
                - sites:/home/frappe/frappe-bench/sites
                - assets:/home/frappe/frappe-bench/sites/assets

            configurator:
                image: frappe/erpnext-worker:${SOFTWARE_VERSION_TAG}
                command:
                - configure.py
                environment:
                DB_HOST: db
                DB_PORT: "3306"
                REDIS_CACHE: redis-cache:6379
                REDIS_QUEUE: redis-queue:6379
                REDIS_SOCKETIO: redis-socketio:6379
                SOCKETIO_PORT: "9000"
                volumes:
                - sites:/home/frappe/frappe-bench/sites

            create-site:
                image: frappe/erpnext-worker:${SOFTWARE_VERSION_TAG}
                deploy:
                restart_policy:
                    condition: on-failure
                volumes:
                - sites:/home/frappe/frappe-bench/sites
                - assets:/home/frappe/frappe-bench/sites/assets
                entrypoint:
                - bash
                - -c
                command:
                - >
                    wait-for-it -t 120 db:3306;
                    wait-for-it -t 120 redis-cache:6379;
                    wait-for-it -t 120 redis-queue:6379;
                    wait-for-it -t 120 redis-socketio:6379;
                    export start=`date +%s`;
                    until [[ -n `grep -hs ^ common_site_config.json | jq -r ".db_host // empty"` ]] && \
                    [[ -n `grep -hs ^ common_site_config.json | jq -r ".redis_cache // empty"` ]] && \
                    [[ -n `grep -hs ^ common_site_config.json | jq -r ".redis_queue // empty"` ]];
                    do
                    echo "Waiting for common_site_config.json to be created";
                    sleep 5;
                    if (( `date +%s`-start > 120 )); then
                        echo "could not find common_site_config.json with required keys";
                        exit 1
                    fi
                    done;
                    echo "common_site_config.json found";
                    bench new-site frontend --admin-password=${ADMIN_PASSWORD} --db-root-password=admin --install-app payments --install-app erpnext --set-default;
            db:
                image: mariadb:10.6
                restart: always
                command:
                - --character-set-server=utf8mb4
                - --collation-server=utf8mb4_unicode_ci
                - --skip-character-set-client-handshake
                - --skip-innodb-read-only-compressed # Temporary fix for MariaDB 10.6
                environment:
                MYSQL_ROOT_PASSWORD: admin
                volumes:
                - db-data:/var/lib/mysql

            frontend:
                image: frappe/erpnext-nginx:${SOFTWARE_VERSION_TAG}
                restart: always
                depends_on:
                backend:
                    condition: service_started
                websocket:
                    condition: service_started
                environment:
                BACKEND: backend:8000
                FRAPPE_SITE_NAME_HEADER: frontend
                SOCKETIO: websocket:9000
                UPSTREAM_REAL_IP_ADDRESS: 127.0.0.1
                UPSTREAM_REAL_IP_HEADER: X-Forwarded-For
                UPSTREAM_REAL_IP_RECURSIVE: "off"
                volumes:
                - sites:/usr/share/nginx/html/sites
                - assets:/usr/share/nginx/html/assets
                ports:
                - "172.17.0.1:8989:8080"

            queue-default:
                image: frappe/erpnext-worker:${SOFTWARE_VERSION_TAG}
                restart: always
                command:
                - bench
                - worker
                - --queue
                - default
                volumes:
                - sites:/home/frappe/frappe-bench/sites
                - assets:/home/frappe/frappe-bench/sites/assets

            queue-long:
                image: frappe/erpnext-worker:${SOFTWARE_VERSION_TAG}
                restart: always
                command:
                - bench
                - worker
                - --queue
                - long
                volumes:
                - sites:/home/frappe/frappe-bench/sites
                - assets:/home/frappe/frappe-bench/sites/assets

            queue-short:
                image: frappe/erpnext-worker:${SOFTWARE_VERSION_TAG}
                restart: always
                command:
                - bench
                - worker
                - --queue
                - short
                volumes:
                - sites:/home/frappe/frappe-bench/sites
                - assets:/home/frappe/frappe-bench/sites/assets

            redis-queue:
                image: redis:6.2-alpine
                restart: alwayse
                volumes:
                - redis-queue-data:/data

            redis-cache:
                image: redis:6.2-alpine
                restart: always
                volumes:
                - redis-cache-data:/data

            redis-socketio:
                image: redis:6.2-alpine
                restart: always
                volumes:
                - redis-socketio-data:/data

            scheduler:
                image: frappe/erpnext-worker:${SOFTWARE_VERSION_TAG}
                restart: always
                command:
                - bench
                - schedule
                volumes:
                - sites:/home/frappe/frappe-bench/sites
                - assets:/home/frappe/frappe-bench/sites/assets

            websocket:
                image: frappe/frappe-socketio:${SOFTWARE_VERSION_TAG}
                restart: always
                volumes:
                - sites:/home/frappe/frappe-bench/sites
                - assets:/home/frappe/frappe-bench/sites/assets

            volumes:
            assets:
                driver: local
                driver_opts:
                type: none
                device: ${PWD}/assets
                o: bind
            db-data:
                driver: local
                driver_opts:
                type: none
                device: ${PWD}/db-data
                o: bind
            redis-queue-data:
                driver: local
                driver_opts:
                type: none
                device: ${PWD}/redis-queue-data
                o: bind
            redis-cache-data:
                driver: local
                driver_opts:
                type: none
                device: ${PWD}/redis-cache-data
                o: bind
            redis-socketio-data:
                driver: local
                driver_opts:
                type: none
                device: ${PWD}/redis-socketio-data
                o: bind
            sites:
                driver: local
                driver_opts:
                type: none
                device: ${PWD}/sites
                o: bind

### Environment variables

|       Variable       | Value (example) |
| :------------------: | :-------------: |
| ADMIN_PASSWORD       | your Password   |
| SECRET_KEY_BASE      | your Secret Key |



# Maintenance

## Logging

The Elestio ERPNext Docker image sends the container logs to stdout. To view the logs, you can use the following command:

    docker-compose logs -f

To stop the stack you can use the following command:

    docker-compose down

## Backup and Restore with Docker Compose

To make backup and restore operations easier, we are using folder volume mounts. You can simply stop your stack with docker-compose down, then backup all the files and subfolders in the folder near the docker-compose.yml file.

Creating a ZIP Archive
For example, if you want to create a ZIP archive, navigate to the folder where you have your docker-compose.yml file and use this command:

    zip -r myarchive.zip .

Restoring from ZIP Archive
To restore from a ZIP archive, unzip the archive into the original folder using the following command:

    unzip myarchive.zip -d /path/to/original/folder

Starting Your Stack
Once your backup is complete, you can start your stack again with the following command:

    docker-compose up -d

That's it! With these simple steps, you can easily backup and restore your data volumes using Docker Compose.

# Links

- <a target="_blank" href="https://erpnext.com/">ERP Next documentation</a>

- <a target="_blank" href="https://github.com/frappe/erpnext">ERP Next Github repository</a>

- <a target="_blank" href="https://github.com/elestio-examples/erpnext">Elestio/ERPNext Github repository</a>