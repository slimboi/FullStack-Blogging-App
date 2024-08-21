
#!/bin/bash
set -e

# Update cache
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

# Install Trivy
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

# Add current user and Jenkins to Docker group
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins

# Change permission for docker.sock
sudo chmod 666 /var/run/docker.sock

echo "Installation complete. Docker and Trivy are installed and configured."
