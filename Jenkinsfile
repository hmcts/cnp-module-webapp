#!groovy
@Library('Infrastructure@different-approach')
import uk.gov.hmcts.contino.*

GITHUB_PROTOCOL = "https"
GITHUB_REPO = "github.com/contino/moj-module-webapp/"

properties(
    [[$class: 'GithubProjectProperty', projectUrlStr: 'https://www.github.com/contino/moj-module-webapp/'],
     pipelineTriggers([[$class: 'GitHubPushTrigger']])]
)
try {
  node {
    platformSetup {
      withEnv(["GIT_COMMITTER_NAME=jenkinsmoj",
               "GIT_COMMITTER_EMAIL=jenkinsmoj@contino.io"]) {

//        step([$class: 'GitHubSetCommitStatusBuilder'])

        stage('Checkout') {
          deleteDir()
          checkout scm
        }

        stage('Terraform Linting Checks') {
          terraform 'fmt --diff=true > diff.out'
          sh 'if [ ! -s diff.out ]; then echo "Initial Linting OK ..."; else echo "Linting errors found while running terraform fmt --diff=true... Applying terraform fmt first" && cat diff.out &&  terraform fmt; fi'
        }

/*
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
*/
      }
    }
  }
}
catch (err) {
  throw err
}
finally {
  step([$class: 'GitHubCommitStatusSetter'])
}

