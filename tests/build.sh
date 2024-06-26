#!/usr/bin/env bash
cp images/production/Containerfile ./
mv Containerfile Dockerfile
APPS_JSON=./apps.json
APPS_JSON_BASE64=$(cat ${APPS_JSON} | base64 | tr -d '\n')
sed -i '99i\
ARG APPS_JSON_BASE64\
RUN if [ -n "${APPS_JSON_BASE64}" ]; then \\\
    mkdir /opt/frappe && echo "${APPS_JSON_BASE64}" | base64 -d > /opt/frappe/apps.json; \\\
  fi' ./Dockerfile
sed -i '109d' ./Dockerfile
sed -i '109i\
RUN export APP_INSTALL_ARGS="" && \\\
    if [ -n "${APPS_JSON_BASE64}" ]; then \\\
      export APP_INSTALL_ARGS="--apps_path=/opt/frappe/apps.json"; \\\
    fi && \\\
    bench init ${APP_INSTALL_ARGS}\\\
' Dockerfile
sed -i '114d' ./Dockerfile
sed -i "s~ARG APPS_JSON_BASE64~ARG APPS_JSON_BASE64=${APPS_JSON_BASE64}~g" ./Dockerfile
sed -i "s~FRAPPE_BRANCH=version-15~FRAPPE_BRANCH=develop~g" ./Dockerfile
sed -i "s~ERPNEXT_BRANCH=version-15~ERPNEXT_BRANCH=develop~g" ./Dockerfile
rm -f compose.yaml
docker buildx build . --output type=docker,name=elestio4test/erpnext:latest | docker load