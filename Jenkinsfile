pipeline {

  agent any

  environment {
    DOCKER_IMAGE = "mikejohnp/tess_jenkins"
  }

  stages {
        stage("Test") {
            agent {
                docker {
                    image 'maven:3.9.1-amazoncorretto-19'
                    args '-u 0:0 -v /tmp:/root/.cache'
                }
            }
            steps {
                sh "mvn test"
            }
        }

   stage("build") {
            //agent { node { label 'Built-In Node' } }
            environment {
                DOCKER_TAG = "${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
            }
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                sh "docker image ls | grep ${DOCKER_IMAGE}"
                withCredentials([usernamePassword(credentialsId: 'docker-hub-cred', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin'
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
                sh "docker image rm ${DOCKER_IMAGE}:${DOCKER_TAG}"
                sh "docker image rm ${DOCKER_IMAGE}:latest"
            }
        }

  stage('deploy') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ssh-mikejohnp-deploy', keyFileVariable: 'SSH_KEY')]) {
                    sh "ssh -o StrictHostKeyChecking=no -i \$SSH_KEY deploy@159.223.35.43 './deploy.sh'"
                }
            }
        }
  }

  post {
    success {
      echo "SUCCESSFUL"
    }
    failure {
      echo "FAILED"
    }
  }
}
