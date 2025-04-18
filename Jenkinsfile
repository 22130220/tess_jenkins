pipeline {

  agent any

  environment {
    DOCKER_IMAGE = "mikejohnp/tess_jenkins"
    DOCKER_DB = "mikejohnp/shopgachmendb"
    DOCKER_TAG = "${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
  }

  stages {
stage("Test") {
            agent {
                docker {
                    image 'gradle:8.10-jdk21'
                    args '-u 0:0 -v /tmp:/root/.cache'
                }
            }
            steps {
                sh "gradle test --no-daemon"
            }
         }

   stage("build") {
            //agent { node { label 'Built-In Node' } }
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                sh "docker commit mysql ${DOCKER_DB}:${DOCKER_TAG}"
                sh "docker image ls | grep ${DOCKER_IMAGE}"
                withCredentials([usernamePassword(credentialsId: 'docker-hub-cred', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin'
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                    sh "docker push ${DOCKER_DB}:${DOCKER_TAG}"
                }
            }
        }

  stage('deploy') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ssh-mikejohnp-deploy', keyFileVariable: 'SSH_KEY')]) {
                    sh "ssh -o StrictHostKeyChecking=no -i \$SSH_KEY deploy@159.223.35.43 './deploy.sh'"
                }
            }
        }

    stage('clean') {
            steps {
                sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG}"
                sh "docker rmi ${DOCKER_DB}:${DOCKER_TAG}"
               // sh "docker rmi ${DOCKER_IMAGE}:latest"
                sh "docker image prune -f"
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
