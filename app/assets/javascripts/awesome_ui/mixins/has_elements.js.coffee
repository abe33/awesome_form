class mixins.HasElements
  @has_elements: (collection_names...) ->
    for collection_name in collection_names
      @::[collection_name] = new widgets.Hash


