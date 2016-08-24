require_relative '../../spec_helper'
require_lib 'reek/smells/boolean_parameter'

RSpec.describe Reek::Smells::BooleanParameter do
  it 'reports the right values' do
    src = <<-EOS
      def m(a = true)
      end
    EOS

    expect(src).to reek_of(:BooleanParameter,
                           lines: [1],
                           context: 'm',
                           message: "has boolean parameter 'a'",
                           source: 'string',
                           parameter: 'a')
  end

  it 'does count all occurences' do
    src = <<-EOS
      def m1(a = true, b = true)
      end
    EOS

    expect(src).to reek_of(described_class,
                           lines:   [1],
                           context: 'm1',
                           parameter: 'a')
    expect(src).to reek_of(described_class,
                           lines:   [1],
                           context: 'm1',
                           parameter: 'b')
  end

  context 'in a method' do
    it 'reports a parameter defaulted to false' do
      src = 'def cc(arga = false) end'
      expect(src).to reek_of(:BooleanParameter, parameter: 'arga')
    end

    it 'reports two parameters defaulted to booleans in a mixed parameter list' do
      src = 'def cc(nowt, arga = true, argb = false, &blk) end'
      expect(src).to reek_of(:BooleanParameter, parameter: 'arga')
      expect(src).to reek_of(:BooleanParameter, parameter: 'argb')
    end

    it 'reports keyword parameters defaulted to booleans' do
      src = 'def cc(arga: true, argb: false) end'
      expect(src).to reek_of(:BooleanParameter, parameter: 'arga')
      expect(src).to reek_of(:BooleanParameter, parameter: 'argb')
    end

    it 'does not report regular parameters' do
      src = 'def cc(a, b) end'
      expect(src).not_to reek_of(described_class)
    end

    it 'does not report array decomposition parameters' do
      src = 'def cc((a, b)) end'
      expect(src).not_to reek_of(described_class)
    end

    it 'does not report keyword parameters with no default' do
      src = 'def cc(a:, b:) end'
      expect(src).not_to reek_of(described_class)
    end

    it 'does not report keyword parameters with non-boolean default' do
      src = 'def cc(a: 42, b: "32") end'
      expect(src).not_to reek_of(described_class)
    end
  end

  context 'in a singleton method' do
    it 'reports a parameter defaulted to true' do
      src = 'def self.cc(arga = true) end'
      expect(src).to reek_of(:BooleanParameter, parameter: 'arga')
    end

    it 'reports a parameter defaulted to false' do
      src = 'def fred.cc(arga = false) end'
      expect(src).to reek_of(:BooleanParameter, parameter: 'arga')
    end

    it 'reports two parameters defaulted to booleans' do
      src = 'def Module.cc(nowt, arga = true, argb = false, &blk) end'
      expect(src).to reek_of(:BooleanParameter, parameter: 'arga')
      expect(src).to reek_of(:BooleanParameter, parameter: 'argb')
    end
  end
end
