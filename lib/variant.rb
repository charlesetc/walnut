
class Symbol
  def call(fields = {})
    return Walnut::Variant.new(self, nanoid(), fields).save
  end

  def find(fields = {})
    return Walnut.find_with_fields(self, fields)
  end

  alias :old_respond_to? :respond_to?

  def respond_to?(m)
    m == :call ? false : super
  end
end

module Walnut

  class Variant

    def self.recreate_from_file(tag, id, fields)
      v = Variant.new(tag, id, fields)
      v.instantiate_walnut_references
      v
    end

    def initialize(tag, id, fields)
      @tag = tag
      @fields = fields
      @id = id
      initialize_field_accessors()
      return self 
    end

    def initialize_field_accessors
      @fields.each do |key, _value|
        self.define_singleton_method(key) { @fields[key] }
        self.define_singleton_method("#{key}=".to_sym) do |newValue|
          @fields[key] = newValue
          Walnut.save(self)
        end
      end
    end

    def inspect
      ":#{@tag}.({#{@fields.map { |k,v| "#{k}: #{v.inspect}" }.join(', ')}})"
    end

    def to_json(json_state)
      return {
        __walnut_variant_id: @id,
        # tag: @tag, # might not need this so I commented it out
      }.to_json(json_state)
    end

    def instantiate_walnut_references
      @fields.instantiate_walnut_references
    end

    def filename
      return "#{Walnut::DB}/#{@tag}-#{@id}.json"
    end

    def save
      FileUtils.mkdir_p(Walnut::DB)
      self.recursive_map do |variant|
        File.write(self.filename, @fields.to_json)
      end
      self
    end

    def remove
      File.delete(self.filename)
    end

    alias :delete :remove
    
    private

      def self.nanoid(size=12) 
       Nanoid.generate(alphabet: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", size:)
      end

      def recursive_map(&block)
        @fields.recursive_map(&block)
        block.call(self)
      end

  end

end

class Hash

  def recursive_map(&block)
    self.values.each do |value|
      value.recursive_map(block) if value.respond_to?(:recursive_map)
    end
  end

end

class Array

  def recursive_map(&block)
    self.each do |value|
      value.recursive_map(block) if value.respond_to?(:recursive_map)
    end
  end

end
