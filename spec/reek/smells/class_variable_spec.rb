require_relative '../../spec_helper'
require_lib 'reek/smells/class_variable'

RSpec.describe Reek::Smells::ClassVariable do
  it 'reports the right values' do
    src = <<-EOS
      class Klass
        @@klassy = 5
      end
    EOS

    expect(src).to reek_of(described_class,
                           lines:   [2],
                           context: 'Klass',
                           message: 'declares the class variable @@klassy',
                           source:  'string',
                           name:    '@@klassy')
  end

  it 'does count all class variables' do
    src = <<-EOS
      class Klass
        @@very_klassy = 42
        @@super_klassy = 99
      end
    EOS

    expect(src).to reek_of(described_class, name: '@@very_klassy')
    expect(src).to reek_of(described_class, name: '@@super_klassy')
  end

  it 'does not report class instance variables' do
    src = <<-EOS
      class Klass
        @klass_instancy = 42
      end
    EOS

    expect(src).to_not reek_of(described_class)
  end

  context 'with no class variables' do
    it 'records nothing in the class' do
      src = <<-EOS
        class Klass
          def meth; end
        end
      EOS

      expect(src).to_not reek_of(described_class)
    end

    it 'records nothing in the module' do
      src = <<-EOS
        module Klass
          def meth; end
        end
      EOS

      expect(src).to_not reek_of(described_class)
    end
  end

  ['class', 'module'].each do |scope|
    context "Scoped to #{scope}" do
      context 'set in a method' do
        it 'reports correctly' do
          src = <<-EOS
            #{scope} MyScope
              def meth
                @@klassy = {}
              end
            end
          EOS

          expect(src).to reek_of(described_class, name: '@@klassy')
        end
      end

      context 'used in a method' do
        it 'reports correctly' do
          src = <<-EOS
            #{scope} MyScope
              def meth
                puts @@klassy
              end
            end
          EOS

          expect(src).to reek_of(described_class, name: '@@klassy')
        end
      end

      context "set in #{scope} and used in a method" do
        it 'reports correctly' do
          src = <<-EOS
            #{scope} MyScope
              @@klassy = 42

              def meth
                puts @@klassy
              end
            end
          EOS

          expect(src).to reek_of(described_class, name: '@@klassy')
        end
      end
    end
  end
end
