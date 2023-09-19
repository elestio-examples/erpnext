cp images/production/Containerfile ./
mv Containerfile Dockerfile
docker buildx build . --output type=docker,name=elestio4test/erpnext:latest | docker load
