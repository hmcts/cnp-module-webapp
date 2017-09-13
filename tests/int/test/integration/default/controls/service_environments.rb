title 'Check Service Environments'

control 'azure-service-environment' do

  impact 1.0
  title 'Check that the service has the correct properties'

  # TODO: Because of the limitations for ASEv1 we use an existing ASE
  # to validate our lib
  # Ensure that the expected resources have been deployed
  describe azure_service_environment(rg_name: 'sandbox-core-infra-dev', name: 'sandbox-core-infra-dev') do
    its('location') { should eq 'UK South' }
    its('name') { should eq 'sandbox-core-infra-dev' }
    its('vnet_name') { should eq 'sandbox-core-infra-vnet-dev' }
    its('vnet_resource_group_name') { should eq 'sandbox-core-infra-dev' }
    its('vnet_subnet_name') { should eq 'sandbox-core-infra-subnet-0-dev' }
    its('internal_load_balancing_mode') { should eq 'Web, Publishing' }
    its('maximum_number_of_machines') { should eq 250 }
  end
end

