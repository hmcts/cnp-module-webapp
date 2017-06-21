#!groovy
properties(
        [[$class: 'GithubProjectProperty', projectUrlStr: 'https://github.com/contino/moj-demo-environment'],
         pipelineTriggers([[$class: 'GitHubPushTrigger']])]
)

def state_store_resource_group = "contino-moj-tf-state"
def state_store_storage_acccount = "continomojtfstate"
def bootstrap_state_storage_container = "contino-moj-tfstate-container"
def product = "demo-product"
def productEnv = "local"

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
			stage('Terraform Plan - Dev ') {
				productEnv = "dev"
				def tfHome = tool name: 'Terraform', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
				env.PATH = "${tfHome}:${env.PATH}"

				sh """\
					terraform init \
					-backend-config "storage_account_name=${state_store_storage_acccount}" \ 
					-backend-config "container_name=${bootstrap_state_storage_container}" \ 
					-backend-config "resource_group_name=${state_store_resource_group}" \
					-backend-config "key=${product}/${productEnv}/terraform.tfstate"
					"""
				sh "terraform get -update=true"
				sh "terraform plan -var 'env=${productEnv}'"
			
				
			}
			stage('Terraform Apply - Dev') {
		
				def tfHome = tool name: 'Terraform', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
				env.PATH = "${tfHome}:${env.PATH}"

				
				sh "terraform apply -var 'env=${productEnv}'"
			
				
			}
		}
	}
	catch (err) {
		slackSend(
				channel: "#${uk-moj-pipeline}",
				color: 'danger',
				message: "${env.JOB_NAME}:  <${env.BUILD_URL}console|Build ${env.BUILD_DISPLAY_NAME}> has FAILED")
		throw err
	}

}