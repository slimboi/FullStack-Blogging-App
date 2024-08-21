pipeline {
    agent any
    
    tools {
        jdk 'jdk17'
        maven 'maven3.9'
    }
    
    environment {
        SCANNER_HOME= tool 'sonar-scanner'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: 'https://github.com/slimboi/FullStack-Blogging-App.git'
            }
        }
        
        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }

        stage('Unit Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs --format table -o trivy-fs.html ."
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=BloggingApp -Dsonar.projectKey=BloggingApp \
                    -Dsonar.java.binaries=target '''
                }
            }
        }
        
        stage('Build and Deploy Artifacts To Nexus') {
            steps {
                withMaven(globalMavenSettingsConfig: 'maven-settings') {
                    sh "mvn deploy"
                }
            }
        }
        
        stage('Docker Build Image') {
            steps {
                script {
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                    sh "docker build -t slimboi/bloggingapp:latest ."
                    }     
                }
            }
        }
        
        stage('Trivy Image scan') {
            steps {
                sh "trivy image --format table -o trivy-image.html slimboi/bloggingapp:latest"
            }
        }
        
        stage('Docker Push Image') {
            steps {
                script {
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                  sh "docker push slimboi/bloggingapp:latest"
                  }       
                }
            }
        }
    }
}