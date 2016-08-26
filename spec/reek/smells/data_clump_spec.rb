require_relative '../../spec_helper'
require_lib 'reek/smells/data_clump'

RSpec.describe Reek::Smells::DataClump do
  it 'reports the right values' do
    src = <<-EOS
      class Dummy
        def x(y1,y2); end
        def y(y1,y2); end
        def z(y1,y2); end
      end
    EOS

    expect(src).to reek_of(described_class,
                           lines:      [2, 3, 4],
                           context:    'Dummy',
                           message:    'takes parameters [y1, y2] to 3 methods',
                           source:     'string',
                           parameters: ['y1', 'y2'],
                           count:      3)
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Dummy
        def a(x1,x2); end
        def b(x1,x2); end
        def c(x1,x2); end

        def x(y1,y2); end
        def y(y1,y2); end
        def z(y1,y2); end
      end
    EOS

    expect(src).
      to reek_of(described_class, lines: [2, 3, 4], parameters: ['x1', 'x2']).
      and reek_of(described_class, lines: [6, 7, 8], parameters: ['y1', 'y2'])
  end

  %w(class module).each do |scope|
    it "does not report parameter sets < 2 for #{scope}" do
      src = <<-EOS
        #{scope} Dummy
          def x(y1); end
          def y(y1); end
          def z(y1); end
        end
      EOS

      expect(src).not_to reek_of(described_class)
    end

    it 'does not care about the order of arguments' do
      src = <<-EOS
        #{scope} Dummy
          def x(y1,y2); end
          def y(y2,y1); end # <- This is the swapped one!
          def z(y1,y2); end
        end
      EOS

      expect(src).to reek_of(described_class,
                             count: 3,
                             parameters: ['y1', 'y2'])
    end

    it 'reports parameter sets that are >= 2' do
      src = <<-EOS
        #{scope} Dummy
          def x(y1, y2, y3); end
          def y(y1, y2, y3); end
          def z(y1, y2, y3); end
        end
      EOS

      expect(src).to reek_of(described_class,
                             count: 3,
                             parameters: ['y1', 'y2', 'y3'])
    end

    it 'detects clumps smaller than the total number of arguments' do
      src = <<-EOS
        # Total number of arguments is 3 but the clump size is 2.
        #{scope} Dummy
          def x(y1, y2, y3); end
          def y(y1, y3, y2); end
          def z(y4, y1, y2); end
        end
      EOS

      expect(src).to reek_of(described_class,
                             parameters: %w(y1 y2))
    end

    it 'ignores anonymous parameters' do
      src = <<-EOS
        #{scope} Dummy
          def x(y1, y2, *); end
          def y(y1, y2, *); end
          def z(y1, y2, *); end
        end
      EOS

      expect(src).to reek_of(described_class,
                             parameters: %w(y1 y2))
    end

    it 'gets a real example right' do
      src = <<-EOS
        #{scope} Inline
          def generate(src, options) end
          def c (src, options) end
          def c_singleton (src, options) end
          def c_raw (src, options) end
          def c_raw_singleton (src, options) end
        end
      EOS

      expect(src).to reek_of(described_class, count: 5)
    end
  end
end
