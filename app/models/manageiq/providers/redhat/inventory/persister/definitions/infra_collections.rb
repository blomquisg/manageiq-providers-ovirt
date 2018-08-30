module ManageIQ::Providers::Redhat::Inventory::Persister::Definitions::InfraCollections
  extend ActiveSupport::Concern

  include ::ManageIQ::Providers::Redhat::Inventory::Persister::Definitions::InfraGroup::ClusterCollections
  include ::ManageIQ::Providers::Redhat::Inventory::Persister::Definitions::InfraGroup::VmsCollections
  include ::ManageIQ::Providers::Redhat::Inventory::Persister::Definitions::InfraGroup::DatacentersCollections
  include ::ManageIQ::Providers::Redhat::Inventory::Persister::Definitions::InfraGroup::StoragedomainsCollections
  include ::ManageIQ::Providers::Redhat::Inventory::Persister::Definitions::InfraGroup::NetworksCollections
  include ::ManageIQ::Providers::Redhat::Inventory::Persister::Definitions::InfraGroup::VmsDependencyCollections

  def initialize_infra_inventory_collections
    add_collection(infra, :ems_folders)

    add_clusters_group
    add_vms_group
    add_hosts_group
    add_datacenters_group
    add_storagedomains_group
    add_networks_group
    add_vms_dependency_collections_group
    add_other_collections
  end

  # --- IC groups definitions ---

  def add_clusters_group
    add_collection(infra, :ems_clusters)
    add_resource_pools
  end

  def add_vms_group
    add_miq_templates

    %i(vms
       disks
       networks
       hardwares
       guest_devices
       snapshots
       operating_systems
       vm_and_template_ems_custom_fields).each do |name|

      add_collection(infra, name)
    end
  end

  def add_vms_dependency_collections_group
    add_ems_folder_children
    add_ems_cluster_children
    add_snapshot_parent
  end

  def add_datacenters_group
    add_datacenters
  end

  def add_hosts_group
    %i(hosts
       host_hardwares
       host_networks
       host_operating_systems
       host_storages
       host_switches
       host_labels
       host_taggings).each do |name|

      add_collection(infra, name)
    end
  end

  def add_host_labels
    add_collection(infra, :host_labels) do |builder|
      builder.add_targeted_arel(
        lambda do |inventory_collection|
          manager_uuids = inventory_collection.parent_inventory_collections.collect(&:manager__uuids).map(&:to_a).flatten
          inventory_collection.parent.host_labels.where(
            'hosts' => {:ems_ref => manager_uuids}
          )
        end
      )
    end
  end

  def add_host_taggings
    add_collection(infra, :host_taggings) do |builder|
      builder.add_properties(
        :model_class                  => Tagging,
        :manager_ref                  => %i(taggable tag),
        :parent_inventory_collections => %i(hosts)
      )

      builder.add_targeted_arel(
        lambda do |inventory_collection|
          manager_uuids = inventory_collection.parent_inventory_collections.collect(&:manager_uuids).map(&:to_a).flatten
          ems = inventory_collection.parent
          ems.host_taggings.where('taggable_id' => ems.hosts.where(:emf_ref => manager_uuids))
        end
      )
    end
  end

  def add_storagedomains_group
    add_storages
  end

  def add_networks_group
    add_switches
  end

  def add_other_collections
    add_collection(infra, :lans)
  end
end
