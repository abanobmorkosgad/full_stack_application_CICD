pipeline {
    agent any
    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        REPO_SERVER = "abanobmorkos10"
        REPO_NAME_BACKEND = "${REPO_SERVER}/backend_pwc"
        REPO_NAME_FRONTEND = "${REPO_SERVER}/frontend_pwc"
        IMAGE_VERSION = "${BUILD_NUMBER}"
        // AWS_ACCESS_KEY_ID = credentials("aws_access_key_id")
        // AWS_SECRET_ACCESS_KEY = credentials("aws_secret_access_key")
    }
    stages {
        stage("SonarQube Analysis - Frontend") {
            steps {
                dir('frontend') {
                    withSonarQubeEnv('sonar-server') {
                        sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=pwc-Frontend \
                        -Dsonar.projectKey=pwc-Frontend'''
                    }
                }
            }
        }
        stage("SonarQube Analysis - Backend") {
            steps {
                dir('backend') {
                    withSonarQubeEnv('sonar-server') {
                        sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=pwc-Backend \
                        -Dsonar.projectKey=pwc-Backend'''
                    }
                }
            }
        }
        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }
        stage("build image") {
            steps {
                script {
                    echo "building docker images ..."
                    withCredentials([
                        usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')
                    ]){
                        sh "docker login -u ${USER} -p ${PASS}"
                        sh "docker build backend/. -t ${REPO_NAME_BACKEND}:${IMAGE_VERSION}"
                        sh "docker push ${REPO_NAME_BACKEND}:${IMAGE_VERSION}"
                        sh "docker build frontend/. -t ${REPO_NAME_FRONTEND}:${IMAGE_VERSION}"
                        sh "docker push ${REPO_NAME_FRONTEND}:${IMAGE_VERSION}"
                    }
                }
            }
        }
        stage("trivy scan"){
            steps{
                sh "trivy image ${REPO_NAME_BACKEND}:${IMAGE_VERSION} > trivy_scan_backend.txt"
                sh "trivy image ${REPO_NAME_FRONTEND}:${IMAGE_VERSION} > trivy_scan_frontend.txt"
            }
        }
        stage("change image version in k8s manifests") {
            steps {
                script {
                    echo "change image version .."
                    sh "sed -i \"s|image:.*|image: ${REPO_NAME_BACKEND}:${IMAGE_VERSION}|g\" k8s_manifests/backend-deployment.yaml"
                    sh "sed -i \"s|image:.*|image: ${REPO_NAME_FRONTEND}:${IMAGE_VERSION}|g\" k8s_manifests/frontend-deployment.yaml"
                }
            }
        }
        stage('Update repo') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                        git config user.email "abanobmorkos10@gmail.com"
                        git config user.name "abanobmorkosgad"
                        git remote set-url origin https://${USER}:${PASS}@github.com/abanobmorkosgad/DevOps_Task_03.git
                        git add .
                        git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                        git push origin HEAD:main
                    '''
                }
            }
        }
    }
}
