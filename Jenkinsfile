// pipeline {
//     agent any

//     parameters {
//             booleanParam(name: 'PLAN_TERRAFORM', defaultValue: false, description: 'Check to plan Terraform changes')
//             booleanParam(name: 'APPLY_TERRAFORM', defaultValue: false, description: 'Check to apply Terraform changes')
//             booleanParam(name: 'DESTROY_TERRAFORM', defaultValue: false, description: 'Check to apply Terraform changes')
//     }

//     stages {
//         stage('Clone Repository') {
//             steps {
//                 // Clean workspace before cloning (optional)
//                 deleteDir()

//                 // Clone the Git repository
//                 git branch: 'main',
//                     url: 'https://github.com/darshanzatakiya/aws-infra.git'

//                 sh "ls -lart"
//             }
//         }

//         stage('Terraform Init') {
//                     steps {
//                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-bd']]){
//                             dir('infra') {
//                             sh 'echo "=================Terraform Init=================="'
//                             sh 'terraform init'
//                         }
//                     }
//                 }
//         }

//         stage('Terraform Plan') {
//             steps {
//                 script {
//                     if (params.PLAN_TERRAFORM) {
//                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-bd']]){
//                             dir('infra') {
//                                 sh 'echo "=================Terraform Plan=================="'
//                                 sh 'terraform plan'
//                             }
//                         }
//                     }
//                 }
//             }
//         }

//         stage('Terraform Apply') {
//             steps {
//                 script {
//                     if (params.APPLY_TERRAFORM) {
//                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-bd']]){
//                             dir('infra') {
//                                 sh 'echo "=================Terraform Apply=================="'
//                                 sh 'terraform apply -auto-approve'
//                             }
//                         }
//                     }
//                 }
//             }
//         }

//         stage('Terraform Destroy') {
//             steps {
//                 script {
//                     if (params.DESTROY_TERRAFORM) {
//                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-bd']]){
//                             dir('infra') {
//                                 sh 'echo "=================Terraform Destroy=================="'
//                                 sh 'terraform destroy -auto-approve'
//                             }
//                         }
//                     }
//                 }
//             }
//         }
//     }
// }
pipeline {
    agent any

    triggers {
        // Automatically run every 5 minutes to detect repo changes
        pollSCM('H/5 * * * *')
    }

    stages {
        stage('Clone Repository') {
            steps {
                deleteDir()
                git branch: 'main', url: 'https://github.com/darshanzatakiya/aws-infra.git'
                sh "ls -lart"
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-bd']]) {
                    dir('infra') {
                        sh '''
                        echo "================= Terraform Init =================="
                        terraform init -input=false
                        
                        echo "================= Terraform Apply =================="
                        terraform apply -auto-approve -input=false
                        '''
                    }
                }
            }
        }

        stage('Deploy Flask App to EC2') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-bd']]) {
                    dir('infra') {
                        sh '''
                        echo "================= Updating Flask App on EC2 =================="
                        
                        # Get EC2 public IP from Terraform output
                        EC2_IP=$(terraform output -raw ec2_public_ip)
                        echo "EC2 IP: $EC2_IP"

                        # Connect to EC2 and deploy Flask app
                        ssh -o StrictHostKeyChecking=no -i "../jenkins_demo.pem" ubuntu@$EC2_IP << 'EOF'
                            set -e
                            cd /home/ubuntu
                            
                            yes | sudo apt update
                            yes | sudo apt install python3 python3-pip git -y

                            if [ -d "flask-app" ]; then
                                cd flask-app
                                git fetch --all
                                git reset --hard origin/main
                            else
                                git clone https://github.com/darshanzatakiya/flask-app.git
                                cd flask-app
                            fi

                            pip3 install -r requirements.txt

                            # Restart Flask app
                            pkill -f app.py || true
                            nohup python3 -u app.py > app.log 2>&1 &
                            echo "✅ Flask App Deployed Successfully!"
                        EOF
                        '''
                    }
                }
            }
        }
    }
}
