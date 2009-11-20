module HTTParty
  module Hashpath
    # do meta-magic on Hashes and Arrays to access nested data using
    # simple dot-syntax
    def self.wrap(data)
      case data
      when Hash
        def data.method_missing(name, *args, &block)
          if args.empty?
            value = self[name] || self[name.to_s]
            case value
            when Hash, Array
              return HTTParty::Hashpath.wrap(value)
            else
              return value
            end
          end
          super
        end
      when Array
        data.class.class_eval do
          alias old_brackets []
          alias old_each each
          alias old_map map
          alias old_count count if RUBY_VERSION > "1.8.6"
        end

        class << data
          def first
            self[0]
          end

          def last
            self[self.size - 1]
          end

          def [](index)
            HTTParty::Hashpath.wrap(old_brackets(index))
          end

          def each
            old_each { |x| yield HTTParty::Hashpath.wrap(x) }
          end

          def map
            old_map { |x| yield HTTParty::Hashpath.wrap(x) }
          end

          if RUBY_VERSION > "1.8.6"
            def count(val=nil)
              if block_given?
                old_count { |x| yield HTTParty::Hashpath.wrap(x) }
              else
                val.nil? ? old_count : old_count(val)
              end
            end
          end
        end
      end
      data
    end
  end
end
