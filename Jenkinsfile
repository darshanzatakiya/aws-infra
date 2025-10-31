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

    parameters {
        booleanParam(name: 'PLAN_TERRAFORM', defaultValue: false, description: 'Run Terraform plan')
        booleanParam(name: 'APPLY_TERRAFORM', defaultValue: false, description: 'Run Terraform apply')
        booleanParam(name: 'DESTROY_TERRAFORM', defaultValue: false, description: 'Destroy Terraform resources')
        booleanParam(name: 'RUN_APP_SCRIPT_ON_EC2', defaultValue: false, description: 'Deploy/Update Flask app on EC2')
    }

    stages {
        stage('Clone Repository') {
            steps {
                deleteDir()
                git branch: 'main', url: 'https://github.com/darshanzatakiya/aws-infra.git'
                sh "ls -lart"
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-bd']]) {
                    dir('infra') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            when { expression { params.PLAN_TERRAFORM } }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-bd']]) {
                    dir('infra') {
                        sh 'terraform plan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when { expression { params.APPLY_TERRAFORM } }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-bd']]) {
                    dir('infra') {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Run App Script on EC2') {
            when { expression { params.RUN_APP_SCRIPT_ON_EC2 } }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-bd']]) {
                    dir('infra') {
                        sh '''
                        echo "================= Running App Script on EC2 =================="
                        EC2_IP=$(terraform output -raw ec2_public_ip)
                        echo "Connecting to EC2: $EC2_IP"

                        ssh -o StrictHostKeyChecking=no -i "../jenkins_demo.pem" ubuntu@$EC2_IP << 'EOF'
                            cd /home/ubuntu
                            yes | sudo apt update
                            yes | sudo apt install python3 python3-pip -y
                            if [ -d "flask-app" ]; then
                                cd flask-app
                                git reset --hard
                                git pull
                            else
                                git clone https://github.com/darshanzatakiya/flask-app.git
                                cd flask-app
                            fi
                            pip3 install -r requirements.txt
                            pkill -f app.py || true
                            setsid python3 -u app.py &
                            echo "✅ Flask App Deployed Successfully!"
                        EOF
                        '''
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            when { expression { params.DESTROY_TERRAFORM } }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-bd']]) {
                    dir('infra') {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }
}
