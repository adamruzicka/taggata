require 'taggata_test_helper'

module Taggata
  module Parser
    describe Tag do
      let(:parser) { ::Taggata::Parser::Tag }

      it 'parses' do
        ::Taggata::Tag.expects(:find_or_create).with(:name => 'tag1').returns(1)
        ::Taggata::Tag.expects(:find).with(:name => 'tag1').returns(1)
        ::Taggata::Tag.expects(:find_or_create).with(:name => 'tag2').returns(2)
        parser.parse('+tag1').must_equal(:add => [1], :del => [])
        parser.parse('+tag2 -tag1').must_equal(:add => [2], :del => [1])
      end

      it 'fails when no + or - is provided' do
        proc { parser.parse('badtag') }.must_raise RuntimeError
      end

      it 'does not create -tags' do
        ::Taggata::Tag.expects(:find).with(:name => 'missingtag').returns(nil)
        parser.parse('-missingtag').must_equal(:add => [], :del => [])
      end
    end
  end
end
