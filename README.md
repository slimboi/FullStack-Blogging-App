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

     echo "Installation completed. Docker group membership is now active for both the current user and Jenkins."
     ```

   - Make the script executable and run it:

     ```bash
     sudo chmod +x jenkins.sh
     ./jenkins.sh
     ```

3. Access Jenkins' initial admin password:

   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

### SonarQube & Nexus Server

1. **Provision a t2.medium EC2 instance** for SonarQube and Nexus.

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
