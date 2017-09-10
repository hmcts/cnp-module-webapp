#!groovy
properties(
    [[$class: 'GithubProjectProperty', projectUrlStr: 'https://www.github.com/contino/moj-module-webapp/'],
     pipelineTriggers([[$class: 'GitHubPushTrigger']])]
)
withCredentials([string(credentialsId: 'sp_password', variable: 'ARM_CLIENT_SECRET'),
                 string(credentialsId: 'tenant_id', variable: 'ARM_TENANT_ID'),
                 string(credentialsId: 'subscription_id', variable: 'ARM_SUBSCRIPTION_ID'),
                 string(credentialsId: 'object_id', variable: 'ARM_CLIENT_ID'),
                 string(credentialsId: 'kitchen_github', variable: 'TOKEN'),
                 string(credentialsId: 'kitchen_github', variable: 'TF_VAR_token'),
                 string(credentialsId: 'kitchen_client_secret', variable: 'AZURE_CLIENT_SECRET'),
                 string(credentialsId: 'kitchen_tenant_id', variable: 'AZURE_TENANT_ID'),
                 string(credentialsId: 'kitchen_subscription_id', variable: 'AZURE_SUBSCRIPTION_ID'),
                 string(credentialsId: 'kitchen_client_id', variable: 'AZURE_CLIENT_ID')]) {
  try {
    node {
      ansiColor('xterm') {
        withEnv(["GIT_COMMITTER_NAME=jenkinsmoj",
                 "GIT_COMMITTER_EMAIL=jenkinsmoj@contino.io"]) {
          stage('Checkout') {
            deleteDir()
            checkout scm
          }

          stage('Terraform Linting Checks') {
            def terraform = new Terraform(this)
            terraform.lint()
          }

          stage('Terraform Unit Testing') {
            docker.image('dsanabria/terraform_validate:latest').inside {
              sh 'cd tests/unit && python tests.py'
            }
          }

          stage('Terraform Integration Testing') {
            new Testing(this).moduleIntegrationTests()
          }

          stage('Tagging') {
            def tag = new Tagging(this)
            String result = utils.applyTag(utils.nextTag())
            sh "echo $result"

          }
        }
      }
    }
  }
  catch (err) {
    throw err
  }
}
