require "nanoid"
require "json"

$saving = false 

class WalnutDB

  def initialize(path)
    FileUtils.mkdir_p(path)
    @path = path
  end

  def save(variant)
    $saving = true 
    File.write("#{@path}/#{variant.__walnut_tag}-#{variant.__walnut_id}.json",
               variant.internal_json)
    $saving = false
  end

  def read(id)
    read_from_file Dir.glob("store/*-#{id}.json")[0]
  end

  def find(tag)
    Dir.glob("store/person-*.json").map do |filename|
      read_from_file(filename)
    end
  end

  private

    def parse_filename(filename)
      File.basename(filename, ".json").split("-") => [tag, id]
      return { tag:, id: }
    end

    def read_from_file(filename)
      parse_filename(filename) => {tag:, id:}
      JSON.parse(File.read(filename)) => fields
      Variant.new(tag, id, fields)
    end
end

Walnut = WalnutDB.new("./store")

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

class Variant

  def initialize(tag, id, fields)
    @tag = tag
    @fields = fields
    @id = id

    @fields.instantiate_walnut_references

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
    if $saving
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
end

def nanoid(size=12) 
  Nanoid.generate(alphabet: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", size:)
end


class Symbol
  def call(fields = {})
    return Variant.new(self,  nanoid(), fields) 
  end
end



=begin

WalnutStore = {}

class WalnutRef
    def initialize(tag, fields)
        @tag = tag
        @fields = fields
    end
    
    def [](field)
        @fields[field]
    end

    def []=(field, val)
        @fields[field] = val
    end

    def inspect
        ":#{@tag}.({#{@fields.map { |k,v| "#{k}: #{v.inspect}" }.join(', ')}})"
    end
end

class Symbol
    def call(fields)
        tag = self
        ref = WalnutRef.new(tag, fields)
        WalnutStore[tag] ||= []
        WalnutStore[tag] << ref
        ref
    end

    def select(condition = nil)
        if condition == nil
            condition = lambda { |ref| true }
        end
        tag = self
        WalnutStore[tag] ||= []
        WalnutStore[tag].select { |ref| condition.call(ref) }
    end

    def self.condition(name, op)
        define_method(name) do |other|
            field = self
            lambda do |ref|
                ref[field].send(op, other)
            end
        end
    end

    condition(:eq, :==)
    condition(:ne, :!=)
    condition(:gt, :>)
    condition(:lt, :<)
end

=end
