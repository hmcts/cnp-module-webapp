# moj-module-webapp
A module that lets you create a Web App and its associated App Service Plan, and depending on the environment you are targeting, the module will automatically deploy to the correct Application Service Environment.
Refer to the following links for a detailed explanation of an App Service Plan, Web App and Application Service Environment in Azure.

[App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/azure-web-sites-web-hosting-plans-in-depth-overview) <br />
[Web Apps](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-web-overview) <br />
[Application Service Environment](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-app-service-environment-intro) <br />

As part of the web app creation, an SSL cert for it is created and whitelisted at the application gateway provided in the appGateway var provided in the declaration of the module

## Variables
This module lets you host Java 8, Spring Boot, and NodeJs applications.

Name | Type |  Required | Default | description
--- | --- | --- | --- | ---
`source` | String | Yes | | this is the location source for the moj-module-webapp, the example implies a github repo containing the moj-module-webapp source
`product` | String | Yes | |  this is the name of the product or project i.e. probate, divorce etc.
`location` | String | No | UK South | this is the azure region for this service
`env` | String | Yes | | this is used to differentiate the environments e.g dev, prod, test etc
`app_settings` String | | Yes | | this is the key valued pairs of application settings used by the application at runtime
`is_frontend` | Boolean | No | False | Indicates that this app could be routable from the public internet
`additional_host_name` | String | No | | A custom domain name for your web application
`https_only` | String | No | `"false"` | Configures a web site to accept only https requests. Issues redirect for http requests. NB this is a string value that accepts values "true" or "false" - the string type is required to work around issues with Terraform and ARM template handling of boolean value.

## Usage
Following is an example of provisioning a NodeJs, SpringBoot, and Java enabled web app, the following code fragment shows how you could use the moj-module-webapp to provision the infrastructure for a typical frontend.  To provision a backend Java, or SpringBoot infrastructure the code is exactly the same except 'is_frontend' must be set to false.

```terraform
module "frontend" {
	source       = "git@github.com:contino/moj-module-webapp?ref=master"
	product      = "${var.product}-frontend"
	location     = "${var.location}"
	env          = "${var.env}"
	capacity     = "${var.capacity}"
	is_frontend  = true
	subscription = "${var.subscription}"
	app_settings = {
		WEBSITE_NODE_DEFAULT_VERSION = "8.8.0"
	}
}
```

In the example above, you can set the variables using terraform variables, so you can set these values in a .tfvars file,
or pass them in from a Jenkins file.

For a complete example of provisioning NodeJs, Java or Springboot application infrastructure, please refer to the repo moj-probate-infrastructure.

Creating a web app to host your application will create a Resource Group containing an App Service Plan, and a Web App.

Each of the aforementioned resources will be named the same, using the convention product-env, so if I provide the values for product as "probate", and env
as "dev" then the resulting resource group, app service plan and web app will be called probate-dev.

Additional and optional parameter which you can add to terraform template is 'capacity'. It defines how many instances will run per environment. Default value is 2 instances per environment but if from some reason production requires more resources you can simply change it. Please be aware that Azure resources are limited and spinning to much boxes might affect whole subscription. Spinning more than 2 instances per environment is not recommended on envs different to production or in case of performance tests

## Testing
There's a library of unit tests and integration tests in this repository.  In the root of this repository is a tests folder.
Inside that are two folders named int and unit.  Folder int contains the integration tests and fixtures, the obviously named folder called unit contains
the unit tests.  These tests are here to give quality assurance and should be added to and modified if changes are made to moj-module-webapp.  Every commit to the moj-module-webapp will result in all the unit and integration tests being executed against it, if all of this succeeds it's verisoned and released in github.  This so exisiting code that uses older versions of the moj-module-webapp will not break, and new infrastructure code can reference later releases.

##Testing Dependencies:
TODO. write about sandbox and other dependencies for tests to work

Consider the following code fragment:-

```terraform
source   = "git::https://yourgithubrepo/moj-module-webapp?ref=0.0.67"
```

the 'ref=0.0.67' in the example code fragment suggests that it is using version 0.0.67 of the moj-module-webapp.

## Unit Testing
The unit tests are written in Python, they contain many examples of how to test different aspects of the moj-module-webapp terraform code.

The following line of code from the tests.py file in the unit folder enforces the naming convention for the web app, as explained earlier the convention is
product-env, the following code fragment enforces this in a unit test:-

```python
self.v.resources('azurerm_template_deployment').property('name').should_equal('${var.product}-${var.env}')
```

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
