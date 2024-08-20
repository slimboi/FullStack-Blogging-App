#!/bin/bash

# Update package information and install Docker
sudo apt-get update
sudo apt-get install -y docker.io

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker || sudo systemctl restart docker

# Add the current user to the Docker group
sudo usermod -aG docker $USER

sudo chmod 666 /var/run/docker.sock

# Run SonarQube container
docker run -d -p 9000:9000 --name sonarqube sonarqube:lts-community

# Run Nexus container
docker run -d -p 8081:8081 --name nexus sonatype/nexus3

# Display running containers
docker ps

# Wait for Nexus to fully start
echo "Waiting for Nexus to start..."
sleep 90

# Retrieve the Nexus admin password
echo "Nexus admin password:"
docker exec -i nexus cat sonatype-work/nexus3/admin.password

