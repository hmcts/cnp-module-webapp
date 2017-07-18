
require 'azure_backend'

# Class to test the configuration and the resources in a virtual network
#
# @author Gianluca Ciocci
#
# @attr_reader [Hashtable] items List of items in the resource group
# @attr_reader [Azure::ARM::Resources::Models::ResourceGroup] rg Resource group under interrogation
# @attr_reader [Hashtable] counts Hashtable containing the counts of the different types in the resource group
class AzureVNet < Inspec.resource(1)
  name 'azure_virtual_network'

  desc "
    This resource returns information about the specified virtual network
  "

  example "
    describe azure_virtual_network(name: 'ACME') do
      its('cdir') { should eq 10.0.0.0/24 }
      its('sub_network_count) { should eq 2 }
    end
  "

  attr_reader :vnet, :counts

  def initialize(opts)
    opts = opts
    helpers = Helpers.new

    # resource group exist?
    raise format("Unable to find resource group '%s' in Azure subscription '%s'", opts[:rg_name], helpers.azure.subscription_id) unless helpers.resource_mgmt.exists opts[:rg_name]

    # helpers.network_mgmt.
    @vnet = helpers.network_mgmt.get_virtual_network(opts[:rg_name], opts[:name])

    raise format('VNet %s not found in Azure subscription %s', opts[:name], helpers.azure.subcription_id) if vnet.nil?

    # Retrieve the items within the resource group
    vnet_items = helpers.network_mgmt.get_items(opts[:rg_name])

    # Parse the resources
    @items = parse_vnet_resources(vnet_items.value)


    puts @items
  end

  # Create a FilterTable so that items can be selected
  filter = FilterTable.create
  filter.add_accessor(:where)
        .add_accessor(:entries)
        .add_accessor(:count)
        .add_accessor(:contains)
        .add(:type, field: 'type')
        .add(:name, field: 'name')
        .add(:id, field: 'id')
        .add(:address_space, field: 'addressspace')
        .add( :provisioning_state, field: 'state')
        #.add(:state, field: 'state')

  # Determine the location of the resource group
  #
  # @return [String Location of the resource group
  #
  def location
    vnet.location
  end

  def total
    counts['total']
  end

  def count
    entries.length
  end

  def state
    vnet.provisioning_state
  end

  def cidr
    vnet.address_space.address_prefixes[0]
  end

  def name
    vnet.name
  end

  def subnets_count
    vnet.subnets.count
  end

  def tags_count
    vnet.tags.count
  end

  private

  def parse_vnet_resources(resources)
    # Declare the hashtable of counts
    @counts = {
        'total' => 0,
    }

    resources.each.map do |resource|
      parse_item(resource)
    end.compact
  end

  def parse_item(item)
    # Increment the count total
    counts['total'] += 1

    # Update the count for the resource type in the count table
    counts.key?(item.type) ? counts[item.type] +=1 : counts[item.type] = 1

    {
        'location' => item.location,
        'name' => item.name,
        'type' => item.type,
        'id' => item.id,
        'addressspace' => item.address_space,
        'state' => item.provisioning_state,
    }
  end

end
