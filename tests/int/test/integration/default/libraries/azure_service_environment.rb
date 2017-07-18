require 'azure_backend'

# Class to retrieve information about the specified virtual machine
#
# @author Daniel Sanabria
#
# @attr_reader [Azure::ARM::Web::AppServicePlans] sp Service Plan object as retrieved from Azure
class AzureSe < Inspec.resource(1)
  name 'azure_service_environment'

  desc "
    This resource gathers information about a service environemnt
  "

  example "
    describe azure_service_environment(name: 'acme-test-01', resource_group: 'ACME') do
      its('location') { should eq 'UK South'}
    end
  "

  attr_accessor :se, :helpers

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
    @se = helpers.web_mgmt.get_ase(opts[:rg_name], opts[:name])

    # Ensure that the sp is an object
    raise format('An error has occured: %s', se) if se.instance_of?(String)
  end

  filter = FilterTable.create
  filter.add_accessor(:where)
        .add_accessor(:entries)
        .add(:location, field: 'location')
        .add(:name, field: 'name')

  def name
    se.name
  end

  def location
    se.location
  end

  def vnet_name
    se.vnet_name
  end

  def vnet_resource_group_name
    se.vnet_resource_group_name
  end

  def vnet_subnet_name
    se.vnet_subnet_name
  end

  def internal_load_balancing_mode
    se.internal_load_balancing_mode
  end

  def maximum_number_of_machines
    se.maximum_number_of_machines
  end

end
