class Sobject

  cattr_accessor :client
  attr_accessor  :object_hash

  def self.all(conditions = nil)
    # construct query
    soql = "select #{fields} from #{table}"
    soql += " where #{conditions}" unless conditions.blank?

    # perform query
    results = Sobject.client.query(soql)

    # loop through Restforce result set
    # instantiate new objects for each result
    # allows us to use our own wrappers
    return results.collect { |property_hash| new(property_hash) }
  end

  def self.find(id)
    # do IN query if id is array
    return find_by_ids(id) if id.is_a?(Array)

    # instantiate new object for result
    # allows us to use our own wrappers
    return new(Sobject.client.find(table, id))
  end

  def self.find_by_ids(id_array)
    # like ActiveRecord, can find by array
    all("Id IN('#{id_array.join("','")}')")
  end

  def self.update!(params)
    # determines table and passes params
    Sobject.client.update!(table, params)
  end

  def self.create!(params)
    # determines table and passes params
    Sobject.client.create!(table, params)
  end

  def self.custom_fields
    # useful for generating a form
    describe.fields.select { |field| field.name.end_with?("__c") }
  end

  def self.describe
    # uses Restforce to get metadata about object
    return Sobject.client.describe(table)
  end

  def initialize(object_hash)
    # decorator pattern
    # save a copy of the Restforce object hash
    # will use metaprogramming to determine when to use
    @object_hash = object_hash
  end

  def respond_to?(sym, include_private = false)
    pass_sym_to_hash?(sym) || super(sym, include_private)
  end

  def method_missing(sym, *args, &block)
    # work-around the annoying fact that Salesforce uses all caps for methods
    # turns :id into :Id, :name into :Name
    # so can use lower-case and not run into an error
    # # this fancy split/join allows for underscores to be converted too
    titleized = sym.to_s.titleize.split(" ").join("_")

    titleized_sym = titleized.to_sym
    return @object_hash.send(titleized_sym, *args, &block) if pass_sym_to_hash?(titleized_sym)

    # ok, if titleize by itself didn't work, maybe it's because it's a custom field
    # try appending __c to the end and see if that works
    # so :zip_code should translate to :Zip_Code__c which should evaluate on the SF object
    titleized_custom = "#{titleized}__c"
    titleized_custom_sym = titleized_custom.to_sym
    return @object_hash.send(titleized_custom_sym, *args, &block) if pass_sym_to_hash?(titleized_custom_sym)

    # otherwise check to see if Restforce hash object accepts symbol just as is
    # IMPORTANT try all these other cases before trying this normal one
    # mainly because :id would evaluate on an object, whereas we want to try :Id first
    return @object_hash.send(sym, *args, &block) if pass_sym_to_hash?(sym)

    # otherwise, method is indeed missing
    super(sym, *args, &block)
  end

protected

  def pass_sym_to_hash?(sym)
    @object_hash.respond_to?(sym)
  end


end
