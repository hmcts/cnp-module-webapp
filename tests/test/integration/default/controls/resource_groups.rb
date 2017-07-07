# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved

title 'Check Azure Resource Group Configuration'

control 'azure-resource-groups' do

  impact 1.0
  title ' Check that the resource group exist'

  describe azure_resource_group(name: 'probate-test') do
    its('location') { should eq 'uksouth' }
  end
end