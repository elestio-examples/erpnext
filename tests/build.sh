cp images/production/Containerfile .
docker buildx build . --output type=docker,name=elestio4test/erpnext:latest | docker load