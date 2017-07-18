title 'Check Webapps'

control 'azure-webapp-1.0' do

  impact 1.0
  title 'Check that the service has the correct properties'

  # Ensure that the expected resources have been deployed
  describe azure_webapp(rg_name: 'inspect-frontend-int', name: 'inspect-frontend-int') do
    its('location') { should eq 'UK South' }
    its('default_host_name') { should eq 'inspect-frontend-int.sandbox-core-infra.p.azurewebsites.net' }
    its('enabled_host_names') { should include 'inspect-frontend-int.scm.sandbox-core-infra.p.azurewebsites.net' }
  end
end
