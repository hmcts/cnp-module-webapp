#!groovy
@Library('Infrastructure') _
import uk.gov.hmcts.contino.Testing
import uk.gov.hmcts.contino.Tagging

GITHUB_PROTOCOL = "https"
GITHUB_REPO = "github.com/contino/moj-module-webapp/"

properties(
    [[$class: 'GithubProjectProperty', projectUrlStr: 'https://www.github.com/contino/moj-module-webapp/'],
     pipelineTriggers([[$class: 'GitHubPushTrigger']])]
)

try {
  node {
    platformSetup {

      stage('Checkout') {
        deleteDir()
        checkout scm
      }

      terraform.ini(this)
      stage('Terraform Linting Checks') {
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
        printf $result
      }
    }
  }
}
catch (err) {
  throw err
}
