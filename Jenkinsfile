pipeline {
    agent any
    stages {
        stage('Clone') {
            steps {
                git credentialsId: 'github-pat', branch: 'main', url: 'https://github.com/cyse7125-su24-team10/infra-aws.git'
            }
        }
        stage('Terraform Validate') {
            steps {
                script {
                    sh "terraform init"
                    sh "terraform validate"
                }
            }
        }
    }
}