class Formtastic::SemanticFormBuilder
  # This method provides similar functionality to #semantic_fields_for except that it
  # behaves for an array, putting the +index+ specified into the form field names.
  def array_fields_for(index, *args, &block)
    return semantic_fields_for(index.to_s, self.object.try(:[], index), *args, &block) unless index.is_a?(Symbol)

    object, index = index, args.shift
    semantic_fields_for(object, *args) { |fields| fields.array_fields_for(index, *args, &block) }
  end
end

