title 'Check Webapps'

control 'azure-webapp' do

  impact 1.0
  title 'Check that the service has the correct properties'
  json_obj = json('.kitchen/kitchen-terraform/default-azure/terraform.tfstate')
  random_name = json_obj['modules'][0]['outputs']['random_name']['value'] + '-frontend-sandboxtestsupport'

  # Ensure that the expected resources have been deployed
  describe azure_webapp(rg_name: random_name, name: random_name) do
    its('location') { should eq 'UK South' }
    its('default_host_name') { should eq "#{random_name.downcase}.app-compute-sandboxtestsupport.p.azurewebsites.net" }
    its('enabled_host_names') { should include "#{random_name.downcase}.scm.app-compute-sandboxtestsupport.p.azurewebsites.net" }
  end
end
