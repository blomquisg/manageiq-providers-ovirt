class ManageIQ::Providers::Redhat::Inventory::Persister < ManagerRefresh::Inventory::Persister
  require_nested :InfraManager
  require_nested :TargetCollection

  attr_reader :collector
  attr_reader :tag_mapper

  def initialize(manager, target, collector)
    @manager   = manager
    @target    = target
    @collector = collector

    @collections = {}
    @collection_group = nil

    initialize_inventory_collections
  end

  protected

  def initialize_tag_mapper
    @tag_mapper = ContainerLabelTagMapping.mapper
    collections[:tags_to_resolve] = @tag_mapper.tags_to_resolve_collection
  end

  # should be overriden by subclasses
  def strategy
    nil
  end

  def parent
    manager.presence
  end

  # Shared properties for InventoryCollections
  def shared_options
    {
      :parent   => parent,
      :strategy => strategy,
      :targeted => targeted?
    }
  end
end
