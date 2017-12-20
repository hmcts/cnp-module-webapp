#!groovy
@Library('Infrastructure') _
import uk.gov.hmcts.contino.Testing
import uk.gov.hmcts.contino.Tagging
import groovy.json.JsonSlurper
import org.apache.commons.lang.RandomStringUtils

try {
  node {
    platformSetup {

      stage('Checkout') {
        deleteDir()
        checkout scm
      }

      stage('ssl_creation') {
        String pxfPass = org.apache.commons.lang.RandomStringUtils.random(9, true, true)
        def script = "./create-cert.sh"
        def command = "bash ${script} ${BUILD_NUMBER} ${pxfPass}"
        "script".execute()
        pxfPass = ""
      }

      stage('create_consul_record'){
        def response = httpRequest httpMode: 'POST', requestBody: "grant_type=client_credentials&resource=https%3A%2F%2Fmanagement.core.windows.net%2F&client_id=$ARM_CLIENT_ID&client_secret=$ARM_CLIENT_SECRET", acceptType: 'APPLICATION_JSON', url: "https://login.microsoftonline.com/$ARM_TENANT_ID/oauth2/token"
        TOKEN = new JsonSlurper().parseText(response.content).access_token
        def vip = httpRequest httpMode: 'GET', customHeaders: [[name: 'Authorization', value: "Bearer ${TOKEN}"]], url: "https://management.azure.com/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/applications-infra-mo-dev/providers/Microsoft.Web/hostingEnvironments/applications-compute-4-dev/capacities/virtualip?api-version=2016-09-01"
        def internalip = new JsonSlurper().parseText(vip.content).internalIpAddress
        println internalip
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
        // Disabled until moj-azure-inspec is open sourced CNP-260
        // testLib.moduleIntegrationTests()
      }

      stage('Tagging') {
        def tag = new Tagging(this)
        printf tag.applyTag(tag.nextTag())
      }
    }
  }
}
catch (err) {
  throw err
}
