# Production Level CI/CD Pipeline Project Setup Guide

## Introduction

In modern software development, Continuous Integration and Continuous Deployment (CI/CD) pipelines are essential for automating the build, test, and deployment processes. This guide walks you through setting up a robust CI/CD pipeline on AWS EC2 instances, covering infrastructure setup, application deployment on an Amazon EKS (Elastic Kubernetes Service) cluster, custom domain assignment, and application monitoring.

### Tools Overview

The pipeline utilizes the following industry-standard tools:

- **AWS**: Provisioning virtual machines.
- **Jenkins**: Automating build, test, and deployment processes.
- **SonarQube**: Static code analysis for ensuring code quality.
- **Trivy**: Vulnerability scanning for files and Docker images.
- **Nexus Repository Manager**: Managing artifacts.
- **Terraform**: Infrastructure as Code for creating the EKS Cluster.
- **Docker**: Containerization for consistency and portability.
- **Kubernetes**: Orchestrating container deployments.
- **Prometheus & Grafana**: Monitoring pipeline and application performance.

By following this guide, you'll set up a fully functional CI/CD pipeline that ensures continuous delivery, high code quality, and excellent application performance.

## Project Steps

1. **Setup Repository**: Initialize your project repository.
2. **Setup Required Servers**: Configure servers for Jenkins, SonarQube, Nexus, and monitoring tools.
3. **Configure Tools**: Integrate and configure all tools within the pipeline.
4. **Create the Pipeline & EKS Cluster**: Establish the CI/CD pipeline and deploy to an EKS Cluster.
5. **Trigger the Pipeline**: Deploy the application.
6. **Assign a Custom Domain**: Set up a custom domain for the deployed application.
7. **Monitor the Application**: Ensure stability and performance using monitoring tools.

## Repository Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/jaiswaladi246/FullStack-Blogging-App.git
   ```

2. Create a new GitHub repository named `FullStack-Blogging-App`.

3. Change the remote URL to the new repository:

   ```bash
   git remote set-url origin https://github.com/slimboi/FullStack-Blogging-App.git
   ```

4. Verify the remote URL change:

   ```bash
   git remote -v
   ```

## Server Setup

### Jenkins Server

1. **Provision a t2.large EC2 instance** for Jenkins.

2. **Install Jenkins**:

   - Create a bash script named `jenkins.sh`:

```bash
    #!/bin/bash
set -e

# Update Cache
sudo apt-get update

# Install Java
sudo apt-get install openjdk-17-jre-headless -y

# Install Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install jenkins -y

# Enable and start Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins || sudo systemctl restart jenkins

# Install Trivy on Jenkins server
sudo apt install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null
sudo apt update
sudo apt install trivy -y

# Install Docker
sudo apt-get install docker.io -y

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker || sudo systemctl restart docker

# Add the current user and Jenkins user to the Docker group
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins

# Activate Docker group membership
newgrp docker

echo "Installation completed. Docker and Trivy are installed and configured."
 ```

   - Make the script executable and run it:

     ```bash
     chmod +x jenkins.sh
     ./jenkins.sh
     ```

3. Access Jenkins' initial admin password:

   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

### SonarQube & Nexus Server

1. **Provision a t2.large EC2 instance** for SonarQube and Nexus.

2. **Install Docker and Run Containers**:

   - Create a setup script `setup_docker_nexus.sh`:

     ```bash
     #!/bin/bash
     sudo apt-get update
     sudo apt-get install -y docker.io

     sudo systemctl enable docker
     sudo systemctl start docker || sudo systemctl restart docker

     sudo usermod -aG docker $USER

     echo "Docker installed. Please log out and back in, or reboot your system to apply Docker group changes."
     ```

   - Make the script executable and run it:

     ```bash
     sudo chmod +x setup_docker_nexus.sh
     ./setup_docker_nexus.sh
     ```

3. **Run SonarQube and Nexus Containers**:

   - After logging back in, create and run the `start_nexus_sonarqube.sh` script:

     ```bash
     #!/bin/bash
     docker run -d -p 9000:9000 --name sonarqube sonarqube:lts-community
     docker run -d -p 8081:8081 --name nexus sonatype/nexus3

     echo "Waiting for Nexus to start..."
     sleep 60

     echo "Nexus admin password:"
     docker exec -i nexus cat sonatype-work/nexus3/admin.password
     ```

   - Make the script executable and run it:

     ```bash
     sudo chmod +x start_nexus_sonarqube.sh
     ./start_nexus_sonarqube.sh
     ```

# On jenkins server install the following plugins
 - Eclipse Temurin installer
 - SonarQube Scanner
 - Docker
 - Docker Pipeline
 - docker-build-step **
 - Maven Integration
 - Config File Provider
 - Nexus Artifact Uploader **
 - Pipeline Maven Integration
 - Kubernetes
 - Kubernetes CLI
 - Kubernetes Client API Plugin
 - Kubernetes Credentials

# Generate Token for jenkins auth in Sonarqube server
jenkins token = squ_b99533c52405f7707499998c1168557467902ced

# Add jenkins token as credential on jenkins server -> sonar-token
# Add Docker credentials named docker-cred on jenkins server
# Add Github credentials named github-cred on jenkins server
# Configure sonarqube server on jenkins via system -> sonar-server

# Add Nexus repo to pom.xml file
https://github.com/slimboi/FullStack-Blogging-App/blob/main/pom.xml

# Generate a settings.xml file on jenkins server under managed files
maven-settings -> Add Nexus server credentials 
<server>
      <id>maven-releases</id>
      <username>admin</username>
      <password>passwd</password>
</server>
    
<server>
      <id>maven-snapshots</id>
      <username>admin</username>
      <password>passwd</password>
</server>

# Configure the following tools
 - jdk17
 - sonar-scanner -> latest version
 - maven -> maven3.9
 - dc9.2 -> dependency check **
 - docker -> latest

# Create private Dockerhub repo named bloggingapp