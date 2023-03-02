
def is_walnut_reference?(value)
  value.is_a? Hash and value.include? "__walnut_variant_id"
end

class Hash
  def instantiate_walnut_references
    self.each do |key, value|
      value.instantiate_walnut_references if value.respond_to? :instantiate_walnut_references
      @fields[key] = Walnut.read(value["__walnut_variant_id"]) if is_walnut_reference?(value)
    end
  end
end

class Array
  def instantiate_walnut_references
    self.map! do |value|
      value.instantiate_walnut_references if value.respond_to? :instantiate_walnut_references
      is_walnut_reference?(value) ? Walnut.read(value["__walnut_variant_id"]) : value
    end
  end
end

