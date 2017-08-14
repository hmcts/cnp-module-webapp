# moj-module-webapp
A module that lets you creates a Web App and it's associated App Service Plan, and assigns it to to an Application Service Environment.

## Variables Usage
This module lets you host java 8, and nodejs applications. to use this module, you need to provide the following parameters:-

-	source
-	product
-	location
- 	env
- 	asename
-	app_settings

## Paramters Explanation

-	source is the location source for the moj-module-webapp
- 	product is the name of the product or project i.e. probate
-	location is the azure region for this service
-	env is used to differentiate the environments e.g dev, prod, test etc.
-	asename is the name of the application service enviroments that will be used by the web app
-	app_settings is the key valued pairs of application settings used by the application at runtime.

## Usage Examples and Explanation

Following is an example of provisioning a nodejs and java enabled empty web app, the following shows a web app for a typical frontend:-

module "frontend" { <br />
&nbsp;&nbsp;&nbsp;source   = "git::https://yourgithubrepo/moj-module-webapp?ref=0.0.67" <br />
&nbsp;&nbsp;&nbsp;product  = "${var.product}-frontend" <br />
&nbsp;&nbsp;&nbsp;location = "${var.location}" <br />
&nbsp;&nbsp;&nbsp;env      = "${var.env}" <br />
&nbsp;&nbsp;&nbsp;asename  = "${var.asename}"<br />

app_settings = { <br />
&nbsp;&nbsp;&nbsp;SERVICE_URL  = "url-to-validationservice" <br />
&nbsp;&nbsp;&nbsp;} <br />
} <br />

In the example above, you can set the variables using terraform variables, so you can set these values in a .tfvars file.
or pass them in from a Jenkins file.

for a complete example of the various usages of the moj-module-webapp please refer to the repo moj-probate-infrastructure.



