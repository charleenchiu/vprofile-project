pipeline {

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
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

        stage('Terraform Plan') {
            steps {
                sh 'whoami'
                sh 'pwd;cd terraform/ ; terraform init'
                // path will be /var/lib/jenkins/workspace/vprofile-project/terraform/
                sh 'pwd;cd terraform/ ; terraform plan -out tfplan'
                sh 'pwd;cd terraform/ ; terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Terraform Approval'){
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

        stage('Terraform Apply'){
            steps{
                sh 'pwd; cd terraform/ ; terraform apply -input=false tfplan'
            }
        }

        stage('Setup') {
            steps {
                // 設置私鑰文件的權限
                sh 'chmod 600 /var/lib/jenkins/workspace/vprofile-project/terraform/charleen_Terraform_test_nfs.pem'
            }
        }
        stage('Deploy') {
            steps {
                // 執行Ansible playbook
                sh 'ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key /var/lib/jenkins/workspace/vprofile-project/terraform/charleen_Terraform_test_nfs.pem -i "3.86.177.86," master.yml -e "file_sys_id=fs-03267e0cada2b466a"'
            }
        }

        stage('Ansible Version'){
            steps{
                sh '''
                    ansible --version
                    ansible-playbook --version
                    ansible-galaxy --version
                '''
            }
        }

        /*
        //取回Terraform建好的私鑰，改權限
        stage('Retrieve Private Key') {
            steps {
                script {
                    def privateKey = sh(script: 'terraform output -raw private_key', returnStdout: true).trim()
                    writeFile file: '~/.ssh/jenkins_key', text: privateKey
                    sh 'chmod 600 ~/.ssh/jenkins_key'
                }
            }
        }  

        //把新建的EC2 IP寫入Ansible inventory檔，並執行palybook
        stage('Run Ansible Playbook') {
            steps {
                script {
                    def myWebOSIp = sh(script: 'terraform output -raw myWebOS_public_ip', returnStdout: true).trim()
                    writeFile file: 'inventory.ini', text: "[mywebos]\nmywebos ansible_host=${myWebOSIp} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/jenkins_key"
                    sh 'ansible-playbook -i inventory.ini /path/to/master.yml'
                }
            }
        }
        */
    }
}