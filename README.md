## Introduction

In the modern software development landscape, Continuous Integration and Continuous Deployment (CI/CD) pipelines are critical for ensuring that code changes are automatically built, tested, and deployed to production environments in a consistent and reliable manner. This document provides a comprehensive guide to setting up a robust CI/CD pipeline using various tools hosted on AWS EC2 instances. The process will cover everything from setting up the necessary infrastructure to deploying an application on an Amazon EKS
(Elastic Kubernetes Service) cluster, assigning a custom domain, and monitoring the application to ensure its stability and performance.

The pipeline will incorporate several industry-standard tools:
AWS : Creating virtual machines .
Jenkins for automating the build, test, and deployment processes.
SonarQube for static code analysis to ensure code quality.
Trivy file scan to scan files and vulnerability scanning for Docker images.
Nexus Repository Manager for managing artifacts.
Terraform as infrastructure as code to create EKS Cluster.
Docker: Containerization for consistency and portability.
Kubernetes: Container orchestration for deployment.
Prometheus and Grafana for monitoring the pipeline and application performance.

By following this guide, you'll be able to set up a fully functional CI/CD pipeline that supports continuous delivery and helps maintain high standards for code quality and application performance.

## Project Steps

1. Setup Repository
2. Setup Required Servers (Jenkins, SonarQube, Nexus, Monitoring Tools)
3. Configure Tools
4. Create the Pipeline & Create EKS Cluster
5. Trigger the Pipeline to Deploy the Application
6. Assign a Custome Domain to the Deployed Application
7. Monitor the Application

# Clone repository
git clone https://github.com/jaiswaladi246/FullStack-Blogging-App.git

# Create new repository in Github named FullStack-Blogging-App

# Change remote url to new created repo
git remote set-url origin https://github.com/slimboi/FullStack-Blogging-App.git

# Verify remote url change
git remote -v

# Set up virtual machine to named sonar-nexus to host sonarqube and nexus
Use t.2medium machine - Nexus needs minumum 4GB of RAM

# Set up virtual machine to host Jenkins
Use t.2large machine

## Install Jenkins
1. Create a bash script named `jenkins.sh` and add in the code below
```bash
#!/bin/bash

# Jenkins and Docker installation script

set -e  # Exit immediately if a command exits with a non-zero status

# Update Cache
sudo apt-get update

# Install Java
sudo apt-get install openjdk-17-jre-headless -y

# Install Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install jenkins -y

# Enable and start Jenkins service if not already running
sudo systemctl enable jenkins
sudo systemctl start jenkins || sudo systemctl restart jenkins

# Install Docker
sudo apt-get install docker.io -y

# Enable and start Docker service if not already running
sudo systemctl enable docker
sudo systemctl start docker || sudo systemctl restart docker

# Add the current user and Jenkins user to the Docker group
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins

# Activate the new group membership in the current session for the current user
newgrp docker

echo "Installation completed. The Docker group membership is now active for both the current user and Jenkins."
```

2. Make it executable with the following command:

   ```bash
   sudo chmod +x jenkins.sh
   ```

3. Execute the script:

   ```bash
   ./jenkins.sh
   ```

# Access Jenkins initialAdmin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# On the sonar-nexus server
1. Create a bash script named `setup_docker_nexus.sh`. 
This script installs Docker, adds the user to the Docker group, and runs the containers.
```bash
#!/bin/bash

# Update package information and install Docker
sudo apt-get update
sudo apt-get install -y docker.io

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker || sudo systemctl restart docker

# Add the current user to the Docker group
sudo usermod -aG docker $USER

# Print a message to log out and log back in
echo "Docker has been installed and the current user has been added to the Docker group."
echo "Please log out and log back in or reboot your system to apply the group membership changes."
echo "After that, you can run the following script start_nexus_sonarqube.sh to start the containers."

# Exit the script
exit 0
```
2. Create a bash script named `start_nexus_sonarqube.sh`.
This script should be run after logging back in or rebooting to start the containers and retrieve the admin password.
```bash
#!/bin/bash

# Run SonarQube container
docker run -d -p 9000:9000 --name sonarqube sonarqube:lts-community

# Run Nexus container
docker run -d -p 8081:8081 --name nexus sonatype/nexus3

# Display running containers
docker ps

# Wait for Nexus to fully start
echo "Waiting for Nexus to start..."
sleep 60

# Retrieve the Nexus admin password
echo "Nexus admin password:"
docker exec -i nexus cat sonatype-work/nexus3/admin.password
```
2. Make the scripts executable with the following command:

   ```bash
   sudo chmod +x setup_docker_nexus.sh
   sudo chmod +x start_nexus_sonarqube.sh
   ```

3. Execute the setup_docker_nexus.sh script:

   ```bash
   ./setup_docker_nexus.sh
   ```

4. Log out and log back in, or reboot your machine to ensure the Docker group membership is applied.

5. Execute the start_nexus_sonarqube.sh:

   ```bash
   ./start_nexus_sonarqube.sh
   ```