require 'dry-validation'

module Performify
  module Validation
    def self.extended(base)
      base.extend Performify::Validation::ClassMethods
      base.include Performify::Validation::InstanceMethods
    end

    module ClassMethods
      def schema(outer_schema = nil, &block)
        if block_given?
          @schema = Dry::Validation.Schema(Dry::Validation::Schema::Form, {}, &block)
        elsif outer_schema.present? && outer_schema.is_a?(Dry::Validation::Schema)
          @schema = outer_schema
        else
          @schema
        end
      end
    end

    module InstanceMethods
      def schema
        self.class.schema
      end

      def validate
        return args if schema.nil?
        result = schema.call(args)
        errors!(result.errors) unless result.success?
        result.output
      end

      def errors!(new_errors)
        raise ArgumentError, 'Errors should be a hash' if new_errors.nil? || !new_errors.respond_to?(:to_h)
        errors.merge!(new_errors.to_h)
      end

      def errors
        @errors ||= {}
      end

      def errors?
        errors.any?
      end
    end
  end
end
