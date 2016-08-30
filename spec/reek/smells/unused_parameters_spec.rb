require_relative '../../spec_helper'
require_lib 'reek/smells/unused_parameters'

RSpec.describe Reek::Smells::UnusedParameters do
  it 'reports the right values' do
    src = <<-EOS
      def m(a)
      end
    EOS

    expect(src).to reek_of(described_class,
                           lines:   [1],
                           context: 'm',
                           message: "has unused parameter 'a'",
                           source:  'string',
                           name:    'a')
  end

  it 'does count all occurences' do
    src = <<-EOS
      def m(a, b)
      end
    EOS

    expect(src).to reek_of(described_class,
                           lines: [1],
                           name:  'a')
    expect(src).to reek_of(described_class,
                           lines: [1],
                           name:  'b')
  end

  it 'reports nothing for no parameters' do
    src = 'def simple; true end'
    expect(src).not_to reek_of(:UnusedParameters)
  end

  it 'reports nothing for used parameter' do
    src = 'def simple(sum); sum end'
    expect(src).not_to reek_of(:UnusedParameters)
  end

  it 'reports for 1 used and 2 unused parameter' do
    src = 'def simple(num,sum,denum); sum end'
    expect(src).to reek_of(:UnusedParameters, name: 'num')
    expect(src).to reek_of(:UnusedParameters, name: 'denum')
  end

  it 'reports for 3 used and 1 unused parameter' do
    src = 'def simple(num,sum,denum,quotient); num + denum + sum end'
    expect(src).to reek_of(:UnusedParameters,
                           name: 'quotient')
  end

  it 'reports nothing for used splatted parameter' do
    src = 'def simple(*sum); sum end'
    expect(src).not_to reek_of(:UnusedParameters)
  end

  it 'reports nothing for unused anonymous parameter' do
    src = 'def simple(_); end'
    expect(src).not_to reek_of(:UnusedParameters)
  end

  it 'reports nothing for named parameters prefixed with _' do
    src = 'def simple(_name); end'
    expect(src).not_to reek_of(:UnusedParameters)
  end

  it 'reports nothing for unused anonymous splatted parameter' do
    src = 'def simple(*); end'
    expect(src).not_to reek_of(:UnusedParameters)
  end

  it 'reports nothing when using super with implicit arguments' do
    src = 'def simple(*args); super; end'
    expect(src).not_to reek_of(:UnusedParameters)
  end

  it 'reports something when using super explicitely passing no arguments' do
    src = 'def simple(*args); super(); end'
    expect(src).to reek_of(:UnusedParameters)
  end

  it 'reports nothing when using super explicitely passing all arguments' do
    src = 'def simple(*args); super(*args); end'
    expect(src).not_to reek_of(:UnusedParameters)
  end

  it 'reports nothing when using super in a nested context' do
    src = 'def simple(*args); call_other("something", super); end'
    expect(src).
      not_to reek_of(:UnusedParameters)
  end

  it 'reports something when not using a keyword argument with splat' do
    src = 'def simple(var, kw: :val, **args); @var, @kw = var, kw; end'
    expect(src).
      to reek_of(:UnusedParameters)
  end

  it 'reports nothing when using a keyword argument with splat' do
    src = 'def simple(var, kw: :val, **args); @var, @kw, @args = var, kw, args; end'
    expect(src).
      not_to reek_of(:UnusedParameters)
  end

  it 'reports nothing when using a parameter via self assignment' do
    src = 'def simple(counter); counter += 1; end'
    expect(src).not_to reek_of(:UnusedParameters)
  end

  it 'reports nothing when using a parameter on a rescue' do
    src = 'def simple(tries = 3); puts "nothing"; rescue; retry if tries -= 1 > 0; raise; end'
    expect(src).
      not_to reek_of(:UnusedParameters)
  end
end
