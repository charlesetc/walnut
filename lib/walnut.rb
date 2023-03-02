require "nanoid"
require "json"
require_relative "./variant"
require_relative "./extensions_for_instantiation"

module Walnut

  $saving_walnut_value = false 

  DB = "./store"

  def self.save(variant, *rest)
    $saving_walnut_value = true 
    File.write("#{DB}/#{variant.__walnut_tag}-#{variant.__walnut_id}.json", variant.internal_json)
    $saving_walnut_value = false
  end

  def self.read(id)
    read_from_file Dir["store/*-#{id}.json"][0]
  end

  def self.find(tag)
    Dir["store/#{tag}-*.json"].map do |filename|
      read_from_file(filename)
    end
  end


  private

    def self.parse_filename(filename)
      File.basename(filename, ".json").split("-") => [tag, id]
      return { tag:, id: }
    end

    def self.read_from_file(filename)
      parse_filename(filename) => {tag:, id:}
      JSON.parse(File.read(filename)) => fields
      Variant.recreate_from_file(tag, id, fields)
    end

end

