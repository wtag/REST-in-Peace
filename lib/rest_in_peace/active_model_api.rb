require 'active_model'

module RESTinPeace
  module ActiveModelAPI
    class MissingMethod < RESTinPeace::DefaultError
      def initialize(method)
        super "No #{method} method has been defined. "\
              'Maybe you called acts_as_active_model before defining the api endpoints?'
      end
    end

    def self.included(base)
      check_for_missing_methods(base)

      base.send(:include, ActiveModel::Conversion)
      base.extend ActiveModel::Naming

      base.send(:alias_method, :save_without_dirty_tracking, :save)
      base.send(:alias_method, :save, :save_with_dirty_tracking)

      def base.human_attribute_name(attr, options = {})
        attr.to_s
      end

      def base.lookup_ancestors
        [self]
      end
    end

    def self.check_for_missing_methods(base)
      raise MissingMethod, :save unless base.instance_methods.include?(:save)
      raise MissingMethod, :create unless base.instance_methods.include?(:create)
    end

    def save_with_dirty_tracking
      save_without_dirty_tracking.tap do
        clear_changes
      end
    end

    def persisted?
      !!id
    end

    def read_attribute_for_validation(attr)
      send(attr)
    end

    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    def errors=(new_errors)
      new_errors.each do |key, value|
        errors.set(key.to_sym, [value].flatten)
      end
    end
  end
end
