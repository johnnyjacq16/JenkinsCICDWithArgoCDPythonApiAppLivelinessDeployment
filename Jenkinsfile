pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'
        ACCOUNT_ID = '522836376191'
        IMAGE_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/ecr-python-api"
        IMAGE_TAG = "${BUILD_NUMBER}"
        HELM_CHART_DIRECTORY = "python-api-with-liveliness-probe-helm-chart"
        DOCKER_IMAGE_NAME = "python-api"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                url: 'https://github.com/johnnyjacq16/JenkinsCICDWithArgoCDPythonApiAppLivelinessDeployment.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin $IMAGE_REPO
                    '''
                }
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                docker tag ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} $IMAGE_REPO:${IMAGE_TAG}
                docker push $IMAGE_REPO:${IMAGE_TAG}
                '''
            }
        }

        stage('Update Helm Values') {
            steps {
                sh '''
                sed -i "s/tag:.*/tag: ${IMAGE_TAG}/" ${HELM_CHART_DIRECTORY}/values.yaml
                '''
            }
        }

        stage('Commit Manifest Change') {
            steps {
                sh '''
                git config user.email "jenkins@company.com"
                git config user.name "jenkins"

                git add ${HELM_CHART_DIRECTORY}/values.yaml
                git commit -m "Deploy image ${IMAGE_TAG}" || true
                git push origin main
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully'
        }

        failure {
            echo 'Pipeline failed'
        }
    }
}
