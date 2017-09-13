#!groovy
@Library('Infrastructure@helpers-for-jenkins-test-steps')
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

          def envSuffix = (env.BRANCH_NAME == 'master') ? 'dev' : env.BRANCH_NAME

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
