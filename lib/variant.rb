module Walnut

  class Variant

    def initialize(tag, id, fields)
      @tag = tag
      @fields = fields.transform_keys { |k| k.to_s }
      @id = id
      initialize_field_accessors()
      return self
    end

    def id
      @id
    end

    def eql?(other)
      return false unless other.class == Variant
      self.id == other.id
    end
    alias :== :eql?

    def self.recreate_from_file(tag, id, fields)
      v = Variant.new(tag, id, fields)
      v.instantiate_walnut_references
      v
    end

    def set_field_and_save(field, value)
      @fields["updated_at"] = Time.now
      @fields[field] = value
      self.save
    end

    def method_missing(name, *args)
      return super unless name.to_s[-1] == '='
      field = name[0..-2]
      value = args[0]
      set_field_and_save(field, value)
    end

    def initialize_field_accessors
      @fields.each do |field, _value|
        self.define_singleton_method(field) { @fields[field] }
        # still define these just for the autocomplete in a repl \_(*v*)_/
        self.define_singleton_method("#{field}=".to_sym) do |newValue|
          set_field_and_save(field, newValue)
        end
      end
    end

    def inspect
      fields = @fields.except("created_at", "updated_at")
      ":#{@tag}.(#{fields.map { |k,v| "#{k}: #{v.inspect}" }.join(', ')})"
    end


    def to_json(json_state = nil)
      return {
        Walnut::ID_STRING =>  @id,
        # tag: @tag, # might not need this so I commented it out
      }.to_json(json_state || JSON::Ext::Generator::State.new)
    end

    def to_json_full(json_state = nil)
      self.to_hash.to_json(json_state)
    end

    def to_hash
      @fields.merge({id: @id, tag: @tag})
    end

    def instantiate_walnut_references
      @fields.instantiate_walnut_references
    end

    def filename
      return "#{Walnut::DB}/#{@tag}-#{@id}.json"
    end

    def save
      Walnut::FileOperations::init
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

      def recursive_map(&block)
        @fields.recursive_map(&block)
        block.call(self)
      end
  end

end

class Hash

  def recursive_map(&block)
    self.values.each do |value|
      value.recursive_map(&block) if value.respond_to?(:recursive_map)
    end
  end

end

class Array

  def recursive_map(&block)
    self.each do |value|
      value.recursive_map(&block) if value.respond_to?(:recursive_map)
    end
  end

end
