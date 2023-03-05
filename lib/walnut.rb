require "nanoid"
require "json"
require_relative "./variant"
require_relative "./extensions_for_instantiation"

module Walnut

  DB = "./store"

  def self.read(id)
    read_from_file Dir["store/*-#{id}.json"][0]
  end

  def self.find(tag)
    Dir["store/#{tag}-*.json"].map do |filename|
      read_from_file(filename)
    end
  end

  def self.find_with_fields(tag, fields)
    results = []
    Dir["store/#{tag}-*.json"].each do |filename|
      v = read_from_file(filename)
      results << v if fields.map { |field, value| begin v.send(field) == value rescue false end }.all?
    end
    return results
  end

  private

    def self.read_from_file(filename)
      File.basename(filename, ".json").split("-") => [tag, id]
      JSON.parse(File.read(filename)) => fields
      Variant.recreate_from_file(tag, id, fields)
    end

end

