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

					stage('Plan'){

						sh 'git clone "https://$TOKEN@github.com/contino/moj-appservice-environment.git"'
						sh "cd moj-appservice-environment && chmod 755 ./terraform.sh && ./terraform.sh plan"
#						sh "cd moj-appservice-environment && chmod 755 ./terraform.sh && ./terraform.sh plan -out=plan.out -detailed-exitcode; echo \$? > status"
#            def exitCode = readFile('status').trim()
#            def apply = false
#            echo "Terraform Plan Exit Code: ${exitCode}"
#	          if (exitCode == "0") {
#  	            currentBuild.result = 'SUCCESS'
#    	      }
#      	    if (exitCode == "1") {
#  	            try {
#                  input id: 'Tfapply', message: 'Do you want to apply your changes?', ok: 'apply'
#                  apply = true
#        	      }
#                catch (err) {
#                  apply = false
#                  currentBuild.result = 'FAILURE'
#            	  }
#            }
#            if (exitCode == "2") {
#             	  stash name: "plan", includes: "plan.out"
#  	            try {
#                  input id: 'Tfapply', message: 'Do you want to apply your changes?', ok: 'apply'
#                  apply = true
#        	      }
#                catch (err) {
#                  apply = false
#                  currentBuild.result = 'UNSTABLE'
#            	  }
#							}
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
