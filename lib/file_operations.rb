module Walnut

  DB = "./store"

  module FileOperations

    def self.init
      begin
        FileUtils.mkdir_p(Walnut::DB)
      rescue Errno::EEXIST
        # ignore: not perfect, mabye we should instead try to readlink the file
        # in case it's a symlink, but this at least lets the case when the dir
        # exists to work
      end
    end

    def self.read(id)
      read_from_file Dir["store/*-#{id}.json"][0]
    end

    def self.find_all(tag)
      Dir["store/#{tag}-*.json"].map do |filename|
        read_from_file(filename)
      end
    end

    def self.all_tags
      Dir["store/*.json"].map do |filename|
        File.basename(filename).split('-')[0]
      end.uniq.map(&:to_sym)
    end

    def self.find_with_fields(tag, fields)
      self.find_all(tag).filter do |v|
        fields.map do |field, value|
          v.respond_to?(field) && v.send(field) == value
        end.all?
      end
    end

    def self.find_last(tag, fields)
      self.find_with_fields(tag, fields).sort_by {|v| v.created_at}.last
    end

    def self.find_first(tag, fields)
      self.find_with_fields(tag, fields).sort_by {|v| v.created_at}.first
    end

    private

      def self.read_from_file(filename)
        File.basename(filename, ".json").split("-") => [tag, id]
        JSON.parse(File.read(filename)) => fields
        Variant.recreate_from_file(tag, id, fields)
      end
  end

end
