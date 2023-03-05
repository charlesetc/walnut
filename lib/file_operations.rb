module Walnut

  DB = "./store"

  module FileOperations

    def self.init
      FileUtils.mkdir_p(Walnut::DB)
    end

    def self.read(id)
      read_from_file Dir["store/*-#{id}.json"][0]
    end

    def self.find_all(tag)
      Dir["store/#{tag}-*.json"].map do |filename|
        read_from_file(filename)
      end
    end

    def self.find_with_fields(tag, fields)
      self.find_all(tag).filter do |v|
        fields.map do |field, value|
          v.respond_to?(field) && v.send(field) == value
        end.all?
      end
    end

    private

      def self.read_from_file(filename)
        File.basename(filename, ".json").split("-") => [tag, id]
        JSON.parse(File.read(filename)) => fields
        Variant.recreate_from_file(tag, id, fields)
      end
  end

end
