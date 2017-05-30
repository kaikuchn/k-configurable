# frozen_string_literal: true

require 'test_helper'

module K
  class ConfigurableTest < Minitest::Test
    class TestConfigurableClass
      include Configurable.[](:name, :title, :country) {
        def greeting
          "Hello #{[title, name].compact.join(' ')} from #{country}, " \
          'how are you today?'
        end
      }

      extend SingleForwardable
      def_single_delegators :configuration, :country, :title
    end

    class ConfigurableClassWithoutBlock
      include Configurable[:name]
    end

    class ConfigurableClassWithDefaults
      include Configurable[:title, :country, name: 'John Doe']
    end

    def test_configure_name
      assert_nil TestConfigurableClass.configuration.name
      TestConfigurableClass.configure { |c| c.name = 'John Doe' }
      assert_equal 'John Doe', TestConfigurableClass.configuration.name
    ensure
      reset(:name)
    end

    def test_configure_title
      assert_nil TestConfigurableClass.configuration.title
      TestConfigurableClass.configure { |c| c.title = 'Dr. med.' }
      assert_equal 'Dr. med.', TestConfigurableClass.configuration.title
      assert_equal 'Dr. med.', TestConfigurableClass.title
    ensure
      reset(:title)
    end

    def test_configure_country
      assert_nil TestConfigurableClass.configuration.country
      TestConfigurableClass.configure { |c| c.country = 'Ireland' }
      assert_equal 'Ireland', TestConfigurableClass.configuration.country
      assert_equal 'Ireland', TestConfigurableClass.country
    ensure
      reset(:country)
    end

    def test_cannot_configure_unknown_attribute
      exception = assert_raises(NoMethodError) do
        TestConfigurableClass.configure { |c| c.origin = 'USA' }
      end
      assert_match("undefined method `origin=' for", exception.message)
    end

    def test_configuration_is_not_nil_by_default
      refute_nil TestConfigurableClass.configuration
    end

    def test_configuration_to_params_provides_non_nil_keywords
      TestConfigurableClass.configure do |c|
        c.name    = 'John Doe'
        c.country = 'Ireland'
      end
      assert_equal(
        { name: 'John Doe', country: 'Ireland' },
        TestConfigurableClass.configuration.to_params
      )
    ensure
      reset(:name, :country)
    end

    def test_configuration_has_greeting_method
      TestConfigurableClass.configure do |c|
        c.name    = 'John Doe'
        c.country = 'Ireland'
      end
      assert_equal(
        'Hello John Doe from Ireland, how are you today?',
        TestConfigurableClass.configuration.greeting
      )
    ensure
      reset(:name, :country)
    end

    def test_configurable_without_block
      ConfigurableClassWithoutBlock.configure { |c| c.name = 'John Doe' }
      assert_equal 'John Doe', ConfigurableClassWithoutBlock.configuration.name
    ensure
      reset(:name)
    end

    def test_configurable_with_defaults
      ConfigurableClassWithDefaults.configure { |c| c.country = 'Ireland' }
      config = ConfigurableClassWithDefaults.configuration
      assert_equal 'John Doe', config.name
      assert_equal 'Ireland', config.country
      assert_nil config.title
    ensure
      reset(:country)
    end

    def reset(*attributes)
      TestConfigurableClass.configure do |c|
        attributes.each { |attr| c.public_send("#{attr}=", nil) }
      end
    end
  end
end
