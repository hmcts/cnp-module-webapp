require 'azure_backend'

# Class to retrieve information about the specified virtual machine
#
# @author Daniel Sanabria
#
# @attr_reader [Azure::ARM::Web::AppServicePlans] sp Service Plan object as retrieved from Azure
class AzureWa < Inspec.resource(1)
  name 'azure_webapp'

  desc "
    This resource gathers information about a webapp
  "

  example "
    describe azure_webapp(name: 'acme-test-01', resource_group: 'ACME') do
      its('location') { should eq 'UK South'}
    end
  "

  attr_accessor :wa, :helpers

  # Constructor to retrieve the Web App from Azure
  #
  # @author Daniel Sanabria
  #
  # @param [Hash] opts Hashtable of options
  #     opts[:name] The name of the Web App in the resource group.
  #     opts[:resource_group] Name of the resource group in which the Web App will be found
  def initialize(opts)
    opts = opts
    @helpers = Helpers.new
    @wa = helpers.web_mgmt.get_webapp(opts[:rg_name], opts[:name])

    # Ensure that the sp is an object
    raise format('An error has occured: %s', wa) if wa.instance_of?(String)
  end

  filter = FilterTable.create
  filter.add_accessor(:where)
        .add_accessor(:entries)
        .add(:location, field: 'location')
        .add(:name, field: 'name')
  
  def name
    wa.name
  end

  def location
    wa.location
  end

  def default_host_name
    wa.default_host_name
  end

  def enabled_host_names
    wa.enabled_host_names
  end
end
