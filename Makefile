DOCKER_IMAGE_NAME = zbe
DOCKER_CONTAINER_NAME = zbe
DOCKER_GHCR_IMAGE_NAME = ghcr.io/nighthawk-apps/zcash-explorer

.PHONY: docker_build docker_run docker_clean docker_publish

# Build the Docker image
docker_build:
	docker build -t $(DOCKER_IMAGE_NAME) .

# Run the Docker container
docker_run:
	docker run -d --name $(DOCKER_CONTAINER_NAME) $(DOCKER_IMAGE_NAME)

# Clean Docker resources (stop and remove the container, remove the image)
docker_clean:
	-docker stop $(DOCKER_CONTAINER_NAME)
	-docker rm $(DOCKER_CONTAINER_NAME)
	-docker rmi $(DOCKER_IMAGE_NAME)

# Publish the Docker image to GitHub Container Registry
docker_publish:
	docker tag $(DOCKER_IMAGE_NAME) $(DOCKER_GHCR_IMAGE_NAME)
	docker push $(DOCKER_GHCR_IMAGE_NAME)
