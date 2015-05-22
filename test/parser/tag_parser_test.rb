require 'taggata_test_helper'

module Taggata
  module Parser
    describe Tag do
      let(:parser) { ::Taggata::Parser::Tag }

      after do
        ::Taggata::Tag.each(&:destroy)
      end

      it 'parses' do
        parsed = parser.parse('+tag1')
        parsed[:add].length.must_equal 1
        parsed[:add].first.name.must_equal 'tag1'
        parsed = parser.parse('+tag2 -tag1')
        parsed[:add].map(&:name).must_equal ['tag2']
        parsed[:del].map(&:name).must_equal ['tag1']
      end

      it 'fails when no + or - is provided' do
        proc { parser.parse('badtag') }.must_raise RuntimeError
      end

      it 'always returns a hash' do
        parsed = parser.parse('+tag1 +tag2 -tag3 +tag4 -tag5')
        parsed.must_be_instance_of Hash
        parsed[:add].must_be_instance_of Array
        parsed[:del].must_be_instance_of Array
      end
    end
  end
end
