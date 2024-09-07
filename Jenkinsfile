pipeline {

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Destroy all builded resources?')
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    agent any
    stages {
        stage('Git Clone'){
            steps{
                script{
                    dir("terraform"){
                        git branch: 'cicd-kube', url:'https://github.com/charleenchiu/vprofile-project.git'
                    }
                }
            }
            post {
                // git clone 失敗
                failure {
                    echo "[*] git clone failure"
                }
                // git clone 成功
                success {
                    echo "[*] git clone successful"
                }
            }
        }

        stage('Plan') {
            steps {
                sh 'whoami'
                sh 'pwd;cd terraform/ ; terraform init'
                // path will be /var/lib/jenkins/workspace/vprofile-project/terraform/
                sh 'pwd;cd terraform/ ; terraform plan -out tfplan'
                sh 'pwd;cd terraform/ ; terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Approval'){
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }

            steps{
                script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: 'Do you want to apply the plan?',
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply'){
            steps{
                sh 'pwd; cd terraform/ ; terraform apply -input=false tfplan'
            }
        }

        stage('Ansible'){
            steps{
                sh 'ansible --version'
                echo "Kops.public_ip = ${aws_instance.Kops.public_ip}"
                echo "Kops.private_ip = ${aws_instance.Kops.private_ip}"
            }
        }

        stage('Destroy'){
            when {
                not {
                    equals expected: true, actual: params.destroy
                }
            }

            steps{
                // path will be /var/lib/jenkins/workspace/vprofile-project/terraform/
                // Clean-Up Files
                //rm -rf .terraform*
                //rm -rf terraform.tfstate*                    
              sh '''
                    pwd; cd terraform/ ; terraform destroy -auto-approve
                    rm -rf /var/lib/jenkins/workspace/*
                    pwd; ls
                '''
            }
        }
    }
}