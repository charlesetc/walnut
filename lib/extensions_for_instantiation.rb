
def is_walnut_reference?(value)
  value.is_a? Hash and value.include? Walnut::ID_STRING
end

class Hash
  def instantiate_walnut_references
    self.each do |key, value|
      value.instantiate_walnut_references if value.respond_to? :instantiate_walnut_references
      self[key] = Walnut::FileOperations.read(value[Walnut::ID_STRING]) if is_walnut_reference?(value)
    end
  end
end

class Array
  def instantiate_walnut_references
    self.map! do |value|
      value.instantiate_walnut_references if value.respond_to? :instantiate_walnut_references
      is_walnut_reference?(value) ? Walnut::FileOperations.read(value[Walnut::ID_STRING]) : value
    end
  end
end

