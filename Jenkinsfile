#!groovy
@Library('Infrastructure')
import uk.gov.hmcts.contino.*

GITHUB_PROTOCOL = "https"
GITHUB_REPO = "github.com/contino/moj-module-webapp/"

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

          testLib = new Testing(this)
          stage('Terraform Unit Testing') {
            testLib.unitTest()
          }

          stage('Terraform Integration Testing') {
            testLib.moduleIntegrationTests()
          }

          stage('Tagging') {
            def tag = new Tagging(this)
            String result = tag.applyTag(tag.nextTag())
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
