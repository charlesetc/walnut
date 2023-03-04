
class Symbol
  def call(fields = {})
    return Walnut::Variant.create_and_persist(self, fields) 
  end

  def find(fields = {})
    return Walnut.find_with_fields(self, fields)
  end
end

module Walnut

  class Variant

    def self.create_and_persist(tag, fields)
      v = Variant.new(tag, nanoid(), fields)
      Walnut.save(v)
      v
    end

    def self.recreate_from_file(tag, id, fields)
      v = Variant.new(tag, id, fields)
      v.instantiate_walnut_references
      v
    end

    def initialize(tag, id, fields)
      @tag = tag
      @fields = fields
      @id = id

      @fields.each do |key, _value|
        self.define_singleton_method(key) { @fields[key] }
        self.define_singleton_method("#{key}=".to_sym) do |newValue|
          @fields[key] = newValue
          Walnut.save(self)
        end
      end
      return self 
    end

    def inspect
      ":#{@tag}.({#{@fields.map { |k,v| "#{k}: #{v.inspect}" }.join(', ')}})"
    end

    def to_json(json_state)
      if $saving_walnut_value
        Walnut.save(self)
      end
      return {
        __walnut_variant_id: @id,
        # tag: @tag, # might not need this so I commented it out
      }.to_json(json_state)
    end

    def internal_json
      @fields.to_json
    end

    def __walnut_tag
      return @tag
    end

    def __walnut_id
      return @id
    end

    def instantiate_walnut_references
      @fields.instantiate_walnut_references
    end
    
    private

      def self.nanoid(size=12) 
       Nanoid.generate(alphabet: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", size:)
      end

  end

end
