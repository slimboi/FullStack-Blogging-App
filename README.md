
---

# Production-Level CI/CD Pipeline Setup Guide

## Introduction

Continuous Integration and Continuous Deployment (CI/CD) pipelines are crucial in modern software development for automating build, test, and deployment processes. This guide details the setup of a robust CI/CD pipeline on AWS EC2 instances, covering everything from infrastructure setup to application monitoring.

### Tools and Technologies

The following tools are used in this pipeline:

- **AWS**: Cloud infrastructure for provisioning virtual machines.
- **Jenkins**: Automating the build, test, and deployment processes.
- **SonarQube**: Static code analysis to ensure code quality.
- **Trivy**: Vulnerability scanning for files and Docker images.
- **Nexus Repository Manager**: Artifact management.
- **Terraform**: Infrastructure as Code (IaC) for EKS cluster creation.
- **Docker**: Containerization for consistency and portability.
- **Kubernetes**: Container orchestration.
- **Prometheus & Grafana**: Monitoring and performance management.

By following this guide, you will establish a fully functional CI/CD pipeline that ensures continuous delivery, high code quality, and optimal application performance.

## Project Steps Overview

1. **Repository Setup**: Initialize the project repository.
2. **Server Setup**: Configure servers for Jenkins, SonarQube, Nexus, and monitoring tools.
3. **Tool Configuration**: Integrate and configure all tools within the pipeline.
4. **Pipeline & EKS Cluster Creation**: Set up the CI/CD pipeline and deploy it to an EKS cluster.
5. **Pipeline Execution**: Deploy the application.
6. **Custom Domain Assignment**: Configure a custom domain for the deployed application.
7. **Application Monitoring**: Ensure application stability and performance.

## Repository Setup

1. **Clone the repository:**

   ```bash
   git clone https://github.com/jaiswaladi246/FullStack-Blogging-App.git
   ```

2. **Create a new GitHub repository** named `FullStack-Blogging-App`.

3. **Change the remote URL** to point to the new repository:

   ```bash
   git remote set-url origin https://github.com/slimboi/FullStack-Blogging-App.git
   ```

4. **Verify the remote URL change:**

   ```bash
   git remote -v
   ```

## Server Setup

### Jenkins Server

1. **Provision a t2.large EC2 instance** for Jenkins.

2. **Install Jenkins** by creating a bash script `setup_jenkins_trivy_docker.sh` and add the contents in the [setup_jenkins_trivy_docker.sh file](https://github.com/slimboi/FullStack-Blogging-App/blob/main/setup_sonar_nexus.sh)


   - **Run the script:**

     ```bash
     chmod +x setup_jenkins_trivy_docker.sh
     ./setup_jenkins_trivy_docker.sh
     ```

3. **Retrieve Jenkins' initial admin password:**

   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

### SonarQube & Nexus Server

1. **Provision a t2.large EC2 instance** for SonarQube and Nexus.

2. **Install Docker and run containers**:

   - Create a script `setup_docker_nexus.sh`:

     ```bash
     #!/bin/bash
     sudo apt-get update
     sudo apt-get install -y docker.io

     sudo systemctl enable docker
     sudo systemctl start docker || sudo systemctl restart docker

     sudo usermod -aG docker $USER

     echo "Docker installed. Please log out and back in, or reboot your system to apply Docker group changes."
     ```

   - **Run the script:**

     ```bash
     sudo chmod +x setup_docker_nexus.sh
     ./setup_docker_nexus.sh
     ```

3. **Run SonarQube and Nexus containers**:

   - Create and run the script `start_nexus_sonarqube.sh`:

     ```bash
     #!/bin/bash
     docker run -d -p 9000:9000 --name sonarqube sonarqube:lts-community
     docker run -d -p 8081:8081 --name nexus sonatype/nexus3

     echo "Waiting for Nexus to start..."
     sleep 60

     echo "Nexus admin password:"
     docker exec -i nexus cat sonatype-work/nexus3/admin.password
     ```

   - **Run the script:**

     ```bash
     sudo chmod +x start_nexus_sonarqube.sh
     ./start_nexus_sonarqube.sh
     ```

### Jenkins Plugin Installation

Install the following plugins on the Jenkins server:

- Eclipse Temurin installer
- SonarQube Scanner
- Docker
- Docker Pipeline
- Docker Build Step
- Maven Integration
- Config File Provider
- Nexus Artifact Uploader
- Pipeline Maven Integration
- Kubernetes
- Kubernetes CLI
- Kubernetes Client API Plugin
- Kubernetes Credentials

### Jenkins Configuration

1. **Generate a Jenkins token** for SonarQube authentication.
   - Example token: `squ_sampletoken`

2. **Add credentials** on the Jenkins server:
   - **SonarQube**: Token named `sonar-token`
   - **Docker**: Credentials named `docker-cred`
   - **GitHub**: Credentials named `github-cred`

3. **Configure SonarQube server** on Jenkins via `Manage Jenkins -> Configure System -> SonarQube Servers`.

4. **Add Nexus repo details** to the `pom.xml` file:
   - Example: [pom.xml](https://github.com/slimboi/FullStack-Blogging-App/blob/main/pom.xml)

5. **Generate a `settings.xml` file** on Jenkins under `Manage Jenkins -> Managed files -> Add a new Maven settings file`.
   - Include Nexus server credentials:

     ```xml
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
     ```

6. **Configure Tools**:
   - JDK 17
   - Sonar Scanner (latest version)
   - Maven 3.9
   - Dependency Check 9.2
   - Docker (latest version)

### Docker Hub

Create a private Docker Hub repository named `bloggingapp`.

### Pipeline Verification

Ensure that the pipeline can be successfully built and executed.

## Terraform Server Setup

1. **Create a Virtual Machine** on AWS.
2. **SSH into the VM** and install Terraform:

   ```bash
   sudo apt update
   sudo snap install terraform --classic
   ```

3. **Install AWS CLI**:

   ```bash
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   aws configure
   ```

4. **Install `kubectl`**:

   ```bash
   sudo snap install kubectl --classic
   ```

5. **Set up EKS with Terraform**:

   - Navigate to the `EKS_Terraform` directory.
   - Run the following commands:

     ```bash
     terraform init
     terraform validate
     terraform plan
     terraform apply --auto-approve
     ```

6. **Update the kubeconfig**:

   ```bash
   aws eks --region eu-west-2 update-kubeconfig --name ofagbule-cluster
   ```
