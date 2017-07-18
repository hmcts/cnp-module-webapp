require 'azure_backend'

# Class to retrieve information about the specified virtual machine
#
# @author Daniel Sanabria
#
# @attr_reader [Azure::ARM::Web::AppServicePlans] sp Service Plan object as retrieved from Azure
class AzureSp < Inspec.resource(1)
  name 'azure_service_plan'

  desc "
    This resource gathers information about a service plan
  "

  example "
    describe azure_sp(name: 'acme-test-01', resource_group: 'ACME') do
      its('location') { should eq 'UK South'}
    end
  "

  attr_accessor :sp, :helpers

  # Constructor to retrieve the Service Plan from Azure
  #
  # @author Daniel Sanabria
  #
  # @param [Hash] opts Hashtable of options
  #     opts[:name] The name of the Service Plan in the resource group.
  #     opts[:resource_group] Name of the resource group in which the Service plan will be found
  def initialize(opts)
    opts = opts
    @helpers = Helpers.new
    @sp = helpers.web_mgmt.get_service_plan(opts[:rg_name], opts[:name])

    # Ensure that the sp is an object
    raise format('An error has occured: %s', sp) if sp.instance_of?(String)
  end

  filter = FilterTable.create
  filter.add_accessor(:where)
        .add_accessor(:entries)
        .add(:location, field: 'location')
        .add(:name, field: 'name')
  
  def name
    sp.name
  end

  def location
    sp.location
  end

  def ase_name
    sp.hosting_environment_profile.name
  end

  def maximum_number_of_workers
    sp.maximum_number_of_workers
  end

  def number_of_sites
    sp.number_of_sites
  end

end
