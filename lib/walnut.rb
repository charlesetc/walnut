require "nanoid"
require "json"
require_relative "./symbol"
require_relative "./variant"
require_relative "./extensions_for_instantiation"
require_relative "./file_operations"

module Walnut
  ID_STRING = "^walnut_id"

  def self.nanoid(size=12)
    Nanoid.generate(alphabet: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", size:)
  end

  def self.all_tags
    Walnut::FileOperations::all_tags
  end
end
