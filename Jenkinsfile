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
        booleanParam(name: 'APPLY_TERRAFORM', defaultValue: false, description: 'Run Terraform apply and deploy Flask app')
        booleanParam(name: 'DESTROY_TERRAFORM', defaultValue: false, description: 'Destroy Terraform infrastructure')
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
                        sh 'echo "================= Terraform Init =================="'
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    if (params.PLAN_TERRAFORM) {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-bd']]) {
                            dir('infra') {
                                sh 'echo "================= Terraform Plan =================="'
                                sh 'terraform plan'
                            }
                        }
                    }
                }
            }
        }

        stage('Terraform Apply & Deploy Flask App') {
            steps {
                script {
                    if (params.APPLY_TERRAFORM) {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-bd']]) {
                            dir('infra') {
                                // Apply Terraform
                                sh '''
                                echo "================= Terraform Apply =================="
                                terraform apply -auto-approve
                                '''

                                // Deploy Flask app
                                sh '''
                                echo "================= Deploying Flask App =================="

                                # Get EC2 public IP
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
                                        pip3 install -r requirements.txt
                                        pkill -f app.py || true
                                        setsid python3 -u app.py &
                                    else
                                        git clone https://github.com/darshanzatakiya/flask-app.git
                                        cd flask-app
                                        pip3 install -r requirements.txt
                                        setsid python3 -u app.py &
                                    fi

                                    echo "✅ Flask App Deployed Successfully!"
                                EOF
                                '''
                            }
                        }
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                script {
                    if (params.DESTROY_TERRAFORM) {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-bd']]) {
                            dir('infra') {
                                sh 'echo "================= Terraform Destroy =================="'
                                sh 'terraform destroy -auto-approve'
                            }
                        }
                    }
                }
            }
        }
    }
}
