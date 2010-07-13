module EM::Mongo
  class Collection
    attr_accessor :connection

    def initialize(db, ns, connection = nil)
      @db = db || "db"
      @ns = ns || "ns"
      @name = [@db,@ns].join('.')
      @connection = connection || EM::Mongo::Connection.new
    end

    def find(selector={}, opts={}, &blk)
      raise "find requires a block" if not block_given?

      skip  = opts.delete(:skip) || 0
      limit = opts.delete(:limit) || 0
      fields = opts.delete(:fields)

      @connection.find(@name, skip, limit, selector, fields, &blk)
    end

    def first(selector={}, opts={}, &blk)
      opts[:limit] = 1
      find(selector, opts) do |res|
        yield res.first
      end
    end

    def insert(obj)
      obj['_id'] ||= EM::Mongo::Util.unique_id
      @connection.insert(@name, obj)
      obj
    end

    def update(selector, updater, opts={})
      @connection.update(@name, selector, updater, opts)
      true
    end

    def remove(obj = {})
      @connection.delete(@name, obj)
      true
    end

  end
end
