require_relative '../../spec_helper'
require_lib 'reek/smells/attribute'

RSpec.describe Reek::Smells::Attribute do
  it 'reports the right values' do
    src = <<-EOS
      class Klass
        attr_writer :my_attr
      end
    EOS

    expect(src).to reek_of(described_class,
                           lines: [2],
                           context: 'Klass#my_attr',
                           message: 'is a writable attribute')
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Klass
        attr_writer :my_attr_1
        attr_writer :my_attr_2
      end
    EOS

    expect(src).to reek_of(described_class,
                           lines:   [2],
                           context: 'Klass#my_attr_1')
    expect(src).to reek_of(described_class,
                           lines:   [3],
                           context: 'Klass#my_attr_2')
  end

  it 'records nothing with no attributes' do
    src = <<-EOS
      class Klass
      end
    EOS

    expect(src).not_to reek_of(described_class)
  end

  context 'with attributes' do
    it 'records nothing for attribute readers' do
      src = <<-EOS
        class Klass
          attr :my_attr
          attr_reader :my_attr2
        end
      EOS
      expect(src).not_to reek_of(described_class)
    end

    it 'records writer attribute' do
      src = <<-EOS
        class Klass
          attr_writer :my_attr
        end
      EOS
      expect(src).to reek_of(:Attribute, context: 'Klass#my_attr')
    end

    it 'does not record writer attribute if suppressed with a preceding code comment' do
      src = <<-EOS
        class Klass
          # :reek:Attribute
          attr_writer :my_attr
        end
      EOS

      expect(src).not_to reek_of(described_class)
    end

    it 'records attr_writer attribute in a module' do
      src = <<-EOS
        module Mod
          attr_writer :my_attr
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Mod#my_attr')
    end

    it 'records accessor attribute' do
      src = <<-EOS
        class Klass
          attr_accessor :my_attr
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Klass#my_attr')
    end

    it 'records attr defining a writer' do
      src = <<-EOS
        class Klass
          attr :my_attr, true
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Klass#my_attr')
    end

    it "doesn't record protected attributes" do
      src = <<-EOS
        class Klass
          protected
          attr_writer :attr1
          attr_accessor :attr2
          attr :attr3
          attr :attr4, true
          attr_reader :attr5
        end
      EOS

      expect(src).not_to reek_of(described_class)
    end

    it "doesn't record private attributes" do
      src = <<-EOS
        class Klass
          private
          attr_writer :attr1
          attr_accessor :attr2
          attr :attr3
          attr :attr4, true
          attr_reader :attr5
        end
      EOS

      expect(src).not_to reek_of(described_class)
    end

    it 'records attr_writer defined in public section' do
      src = <<-EOS
        class Klass
          private
          public
          attr_writer :my_attr
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Klass#my_attr')
    end

    it 'records attr_writer after switching visbility to public' do
      src = <<-EOS
        class Klass
          private
          attr_writer :my_attr
          public :my_attr
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Klass#my_attr')
    end

    it 'resets visibility in new contexts' do
      src = <<-EOS
        class Klass
          private
          attr_writer :attr1
        end

        class OtherKlass
          attr_writer :attr1
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'OtherKlass#attr1')
    end

    it 'records attr_writer defining a class attribute' do
      src = <<-EOS
        class Klass
          class << self
            attr_writer :my_attr
          end
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Klass#my_attr')
    end

    it 'does not record private class attributes' do
      src = <<-EOS
        class Klass
          class << self
            private
            attr_writer :my_attr
          end
        end
      EOS

      expect(src).not_to reek_of(described_class)
    end

    it 'tracks visibility in metaclasses separately' do
      src = <<-EOS
        class Klass
          private
          class << self
            attr_writer :my_attr
          end
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Klass#my_attr')
    end
  end
end
