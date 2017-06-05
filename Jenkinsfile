#!groovy
properties(
        [[$class: 'GithubProjectProperty', projectUrlStr: 'https://github.com/contino/moj-appservice-environment'],
         pipelineTriggers([[$class: 'GitHubPushTrigger']])]
)
withCredentials([string(credentialsId: 'sp_password', variable: 'ARM_CLIENT_SECRET'),
				string(credentialsId: 'tenant_id', variable: 'ARM_TENANT_ID'),
				string(credentialsId: 'contino_github', variable: 'TOKEN'),
				string(credentialsId: 'subscription_id', variable: 'ARM_SUBSCRIPTION_ID'),
				string(credentialsId: 'object_id', variable: 'ARM_CLIENT_ID')]) {
	try {
		node {
			stage('Checkout') {
				deleteDir()
				checkout scm
			}
			stage('Terraform'){
				docker.image('dsanabria/aztf:latest').inside {

					stage('Plan and Apply'){

						sh 'git clone "https://$TOKEN@github.com/contino/moj-appservice-environment.git"'
						sh "cd moj-appservice-environment && chmod 755 ./terraform.sh && ./terraform.sh plan && ./terraform.sh apply"
					}
				}
			}
		}
  }
	catch (err) {
		slackSend(
	            channel: "#${product}",
	            color: 'danger',
	            message: "${env.JOB_NAME}:  <${env.BUILD_URL}console|Build ${env.BUILD_DISPLAY_NAME}> has FAILED")
	    throw err
	}
}
