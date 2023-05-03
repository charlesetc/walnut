class Symbol # Extending normal ruby symbols with a call syntax.

  def call(**fields)
    fields[:created_at] = fields[:updated_at] = Time.now
    return Walnut::Variant.new(self, Walnut.nanoid(), fields).save
  end

  def find_many(**fields)
    return Walnut::FileOperations.find_with_fields(self, fields)
  end

  alias :findmany :find_many
  alias :all :find_many

  def find_one(**fields)
    results = findmany(**fields)
    if results.length == 0
      return nil
    elsif results.length == 1
      return results[0]
    else
      raise "#{self}.find_one - expected a single result but got multiple"
    end
  end

  def find_last(**fields)
    return Walnut::FileOperations.find_last(self, fields)
  end

  def find_first(**fields)
    return Walnut::FileOperations.find_first(self, fields)
  end

  alias :findone :find_one
  alias :findfirst :find_first
  alias :findlast :find_last
  alias :old_respond_to? :respond_to?

  def respond_to?(m)
    m == :call ? false : super
  end

end
