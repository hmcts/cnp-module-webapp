title 'Check Service Plans'

control 'azure-service-plan-1.0' do

  impact 1.0
  title 'Check that the service has the correct properties'

  # Ensure that the expected resources have been deployed
  describe azure_service_plan(rg_name: 'inspect-frontend-int', name: 'inspect-frontend-int') do
    its('location') { should eq 'UK South' }
    its('name') { should eq 'inspect-frontend-int' }
    its('ase_name') { should eq 'sandbox-core-infra' }
    its('maximum_number_of_workers') { should eq 1 }
    its('number_of_sites') { should eq 1 }
  end
end

