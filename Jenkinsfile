pipeline {
    agent any

    environment {
        DOCKER_USER  = "morningstart123"
        IMAGE_NAME   = "truyenapi"
        IMAGE_TAG    = "${BUILD_NUMBER}"
        SCANNER_HOME = tool 'sonar-scanner'
        JAVA_HOME    = "/usr/lib/jvm/java-17-openjdk-amd64"
        PATH         = "/usr/lib/jvm/java-17-openjdk-amd64/bin:${env.PATH}"
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('2. Build & SonarQube Scan') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    dir('truyenapi') {
                        sh """
                            chmod +x mvnw
                            ./mvnw clean test-compile -DskipTests
                            ${SCANNER_HOME}/bin/sonar-scanner \
                              -Dsonar.projectKey=nt548-truyenapi \
                              -Dsonar.sources=src \
                              -Dsonar.java.binaries=target/classes
                        """
                    }
                }
            }
        }

        stage('3. Build & Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-token',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    sh """
                        echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin
                        docker build -t ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} -t ${DOCKER_USER}/${IMAGE_NAME}:latest ./truyenapi
                        docker push ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${DOCKER_USER}/${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('4. Deploy to k3s') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh """
                        kubectl --insecure-skip-tls-verify apply -f k8s/
                        kubectl --insecure-skip-tls-verify rollout restart deployment/truyenapi
                        kubectl --insecure-skip-tls-verify get pods,svc
                    """
                }
            }
        }
    }
}