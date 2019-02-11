node {
    checkout scm

    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-jbyrd') {

        def customImage = docker.build("skateboard:${env.BUILD_ID}")

        /* Push the container to the custom Registry */
        customImage.push()
    }
}

/*
pipeline {
    agent {
        dockerfile {
            registryCredentialsId 'dockerhub-jbyrd'
        }
    }
    stages {
        stage('date') {
            steps {
                sh 'date'
            }
        }
    }
}
*/
