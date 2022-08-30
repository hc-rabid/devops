pipeline{
    agent {
        label 'devops-dev'
    }
    
    environment { 
        containerRegistryCredentials = credentials('ARTIFACTORY_PUBLISH') 
        containerRegistry = 'jack.hc-sc.gc.ca'
    }

    stages {
        stage('Environment Setup') {
            steps {
                checkout scm
                script{
                    version = "1.0.${env.BUILD_ID}"
                    // Setup Artifactory connection
                    artifactoryServer = Artifactory.server 'default'
                    artifactoryDocker = Artifactory.docker server: artifactoryServer
                    buildInfo = Artifactory.newBuildInfo()
                }
            }
        }
        //stage terraform init
        stage('Plan'){
            steps{
                sh """
                    docker login -u ${containerRegistryCredentials_USR} -p ${containerRegistryCredentials_PSW} ${containerRegistry}
                    terraform init -input=false
                    terraform plan -input=false -var image_version=${version}
                """
            }
        }
        //stage terraform apply
        stage('Apply'){
            steps{
                sh 'terraform apply -auto-approve -var image_version=${version}'
            }
        }
    }
    post{
        always {
            script {
                resultString = "None"
            }
        }
        success {
            script {
                resultString = "Success"
            }
        }
        unstable {
            script {
                resultString = "Unstable"
            }
        }
        failure {
            script {
                resultString = "Failure"
            }
        }
        cleanup {
            emailext body: "<p>See build result details at: <a href='${env.JOB_URL}'>${env.JOB_URL}</a></p>", mimeType: 'text/html; charset=UTF-8', recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'DevelopersRecipientProvider'], [$class: 'UpstreamComitterRecipientProvider'], [$class: 'RequesterRecipientProvider']], replyTo: 'devops@hc-sc.gc.ca', subject: "${currentBuild.fullDisplayName} ${resultString}"
        }
    }
}