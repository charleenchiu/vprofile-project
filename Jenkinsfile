pipeline {
    agent any

    environment {
        registry = 'registry'
        registryCredential = ''
    }
    stages {
        stage('Check Terraform'){
            steps{
                sh 'terraform -version'
            }
        }

        stage('BUILD'){
            steps{
                echo 'stage(BUILD).steps'
            }
            post{
                success {
                    echo 'stage(BUILD).post.success'
                }
            }
        }

        stage('UNIT TEST'){
            steps{
                echo 'stage(UNIT TEST).steps'
            }
        }

        stage('INTEGRATION TEST'){
            steps{
                echo 'stage(INTEGRATION TEST).steps'
            }
        }

        stage('CODE ANALYSIS WITH CHECKSTYLE'){
            steps{
                echo 'stage(CODE ANALYSIS WITH CHECKSTYLE).steps'
            }
            post{
                success {
                    echo 'stage(CODE ANALYSIS WITH CHECKSTYLE).post.success'
                }
            }
        }

        stage('Building Image'){
            steps{
                echo 'stage(Building Image).steps'
            }
        }

        stage('Deploy Image'){
            steps{
                echo 'stage(Deploy Image).steps'
            }
        }

        stage('Remove Unused docker image'){
            steps{
                echo 'Remove Unused docker image'
            }
        }

        stage('CODE ANALYSIS with SONARQUBE'){
            steps{
                echo 'CODE ANALYSIS with SONARQUBE'
            }
        }

        stage('Kubernetes Deploy'){
            steps{
                echo 'Kubernetes Deploy'
            }
        }
    }
}