pipeline {
    agent any

    environment {
        DOCKER_USER  = "morningstart123"
        IMAGE_TAG    = "${BUILD_NUMBER}"
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('2. SonarQube Security & Quality Scan') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                        ${SCANNER_HOME}/bin/sonar-scanner \
                          -Dsonar.projectKey=nt548-microservices \
                          -Dsonar.sources=product-service,user-service
                    """
                }
            }
        }

        stage('3. Build & Push Docker Images') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-token',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    sh """
                        echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin

                        docker build -t ${DOCKER_USER}/product-service:${IMAGE_TAG} -t ${DOCKER_USER}/product-service:latest ./product-service
                        docker push ${DOCKER_USER}/product-service:${IMAGE_TAG}
                        docker push ${DOCKER_USER}/product-service:latest

                        docker build -t ${DOCKER_USER}/user-service:${IMAGE_TAG} -t ${DOCKER_USER}/user-service:latest ./user-service
                        docker push ${DOCKER_USER}/user-service:${IMAGE_TAG}
                        docker push ${DOCKER_USER}/user-service:latest
                    """
                }
            }
        }

        stage('4. Deploy to k3s') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh """
                        kubectl --insecure-skip-tls-verify apply -f k8s/
                        kubectl --insecure-skip-tls-verify rollout restart deployment/product-service deployment/user-service
                        kubectl --insecure-skip-tls-verify get pods,svc
                    """
                }
            }
        }
    }
}