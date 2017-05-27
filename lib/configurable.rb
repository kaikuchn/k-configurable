# frozen_string_literal: true

require 'configurable/version'

module Configurable
  def self.included(_base)
    raise 'Cannot include Configurable, include Configurable::[] instead'
  end

  # Use `include Configurable [:foo, :bar]` to make your class/module
  # configurable with configuration options :foo and :bar. If you want your
  # configuration object to be able to respond to some custom methods you can
  # extend it by passing a block. In that case you have to call `[]` like this:
  # include(Configurable.[](:foo) do
  #   def bazinga
  #     ...
  #   end
  # end)
  # Because MRI cannot parse `Configurable[...] {}`. Also keep in mind that the
  # do-end block would get bound to `include` without the parens, you could also
  # use {}-block instead, which binds tighter.
  def self.[](*attributes, **defaults, &block)
    Module.new do
      @__attributes = (attributes + defaults.keys).uniq
      @__defaults = defaults
      @__block = block || -> {}

      def self.included(base)
        base.instance_variable_set(:@__configurable_attributes, @__attributes)
        base.instance_variable_set(:@__configurable_defaults, @__defaults)
        base.instance_variable_set(:@__configurable_block, @__block)
        base.extend(ClassMethods)
      end
    end
  end

  module ClassMethods
    def configuration
      @configuration ||= anonymous_configuration_class.new(
        *__configurable_defaults
      )
    end

    def configure
      yield(configuration)
    end

    private

    def anonymous_configuration_class
      block = __configurable_block
      Struct.new(*__configurable_attributes) do |klass|
        klass.class_exec(&block)

        def to_params
          Hash[
            members
            .map { |attr| [attr, public_send(attr)] }
            .reject { |_, value| value.nil? }
          ]
        end
      end
    end

    def __configurable_attributes
      @__configurable_attributes
    end

    def __configurable_defaults
      @__configurable_defaults.values_at(*__configurable_attributes)
    end

    def __configurable_block
      @__configurable_block
    end
  end
end
