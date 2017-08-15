# moj-module-webapp
A module that lets you create a Web App and its associated App Service Plan, and assign it to to an Application Service Environment.
Refer to the following links for a detailed explanation of an App Service Plan, Web App and Application Service Environment in Azure.

[App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/azure-web-sites-web-hosting-plans-in-depth-overview) <br />
[Web Apps](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-web-overview) <br />
[Application Service Environment](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-app-service-environment-intro) <br />

## Variables
This module lets you host Java 8, Spring Boot, and NodeJs applications. to use this module, you need to provide the following variables:-

-	source, this is the location source for the moj-module-webapp, the example implies a github repo containing the moj-module-webapp source
-	product,  this is the name of the product or project i.e. probate, divorce etc.
-	location, this is the azure region for this service
- 	env, this is used to differentiate the environments e.g dev, prod, test etc
- 	asename, this is the name of the application service enviroments that will be hosting the web app
-	app_settings, this is the key valued pairs of application settings used by the application at runtime

## Usage
Following is an example of provisioning a NodeJs, SpringBoot, and Java enabled web app, the following code fragment shows how you could use the moj-module-webapp to provision the infrastructure for a typical frontend.  To provision a backend Java, or SpringBoot infrastructure the code is exactly the same, however you would probably replace "${var.product}-frontend" with "${var.product}-frontend" so that it's obvious what it is, in the Azure portal:-

module "frontend" { <br />
&nbsp;&nbsp;&nbsp;source   = "git::https://yourgithubrepo/moj-module-webapp?ref=0.0.67" <br />
&nbsp;&nbsp;&nbsp;product  = "${var.product}-frontend" <br />
&nbsp;&nbsp;&nbsp;location = "${var.location}" <br />
&nbsp;&nbsp;&nbsp;env      = "${var.env}" <br />
&nbsp;&nbsp;&nbsp;asename  = "${var.asename}"<br />

app_settings = { <br />
&nbsp;&nbsp;&nbsp;SERVICE_URL  = "url-to-backendservice" <br />
&nbsp;&nbsp;&nbsp;} <br />
} <br />

In the example above, you can set the variables using terraform variables, so you can set these values in a .tfvars file,
or pass them in from a Jenkins file.

For a complete example of provisioning NodeJs, Java or Springboot application infrastructure, please refer to the repo moj-probate-infrastructure.

Creating a web app to host your application will create a Resource Group containing an App Service Plan, and a Web App.

Each of the aforementioned resources will be named the same, using the convention product-env, so if I provide the values for product as "probate", and env
as "dev" then the resulting resource group, app service plan and web app will be called probate-dev.

## Testing
There's a library of unit tests and integration tests in this repository.  In the root of this repository is a tests folder.
Inside that are two folders named int and unit.  Folder int contains the integration tests and fixtures, the obviously named folder called unit contains
the unit tests.  These tests are here to give quality assurance and should be added to and modified if changes are made to moj-module-webapp.  Every commit to the moj-module-webapp will result in all the unit and integration tests being executed against it, if all of this succeeds it's verisoned and released in github.  This so exisiting code that uses older versions of the moj-module-webapp will not break, and new infrastructure code can reference later releases.

Consider the following code fragment:-

source   = "git::https://yourgithubrepo/moj-module-webapp?ref=0.0.67" <br />

the 'ref=0.0.67' in the example code fragment suggests that it is using version 0.0.67 of the moj-module-webapp.

## Unit Testing
The unit tests are written in Python, they contain many examples of how to test different aspects of the moj-module-webapp terraform code.

The following line of code from the tests.py file in the unit folder enforces the naming convention for the web app, as explained earlier the convention is 
product-env, the following code fragment enforces this in a unit test:-

self.v.resources('azurerm_template_deployment').property('name').should_equal('${var.product}-${var.env}')

You can find the complete set of tests in the file tests.py

## Integration Testing
The int folder contains a test folder in which there are seperate folders for fixtures code, and integration tests. the file moj_azure_fixtures.tf contains
the terraform code that spins up the dependencies that the webapp would need in order to function in production.  The suite of integration tests run against this ephemeral infrastructure to validate the web app, once all the tests are succesfully executed the infrastructure is destroyed.  The resources created use random names so that the integration tests don't conflict with each other, if more that one person is working on the repository.  If any tests fail, the infrastructure is not automatically destroyed, this is so you can investigate the fixtures and the webapp through the Azure
Portal, to help debug the unit test.

All of this automation is driven by Chef Kitchen, the configuration of all this is in the file called .kitchen.yml at the root of the int folder.  The actual 
integration tests are in the default/controls sub folder in the integration folder.  All the code used to drive the integration tests are written in Ruby.  The folder default/libraries contain the ruby libraries that gather information required for the tests to execute.

## Terraform
All infrastructure provisioning is done using Terraform native azurerm provider where possible.  You can find the documentation for this at the following link:-

[Terraform azurerm](https://www.terraform.io/docs/providers/azurerm/index.html) <br />

At the time of writing the web app does not have native azurerm provider support in terraform at version 0.0.9, so an ARM template has been used for creation of the Web App and App Service Plan. The template can be found in the templates folder at the repository root.

The ARM template is wrapped in azurerm_template_deployment provider in terraform, this is the provider used to run any custom ARM templates using Terraform.
