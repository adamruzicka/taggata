require 'taggata_test_helper'

module Taggata
  module Parser
    describe Query do
      let(:parser) { ::Taggata::Parser::Query }

      it 'translates' do
        parser.send(:translate, '&').must_equal :and
        parser.send(:translate, 'and').must_equal :and
        parser.send(:translate, 'AND').must_equal :and
        parser.send(:translate, '|').must_equal :or
        parser.send(:translate, 'or').must_equal :or
        parser.send(:translate, 'OR').must_equal :or
        parser.send(:translate, 'asdasd').must_equal 'asdasd'
      end

      it 'applies' do
        parser.apply(:and, [1, 2], [2, 3]).must_equal [2]
        parser.apply(:or, [1, 2], [2, 3]).must_equal [1, 2, 3]
        proc { parser.apply('q', [], []) }.must_raise RuntimeError
      end

      it 'converts to postfix' do
        parser.send(:postfix, '').must_equal []
        parser.send(:postfix, 'is:2014').must_equal ['is:2014']
        parser.send(:postfix, 'is:2014 and tag:2015')
          .must_equal ['is:2014', 'tag:2015', :and]
        parser.send(:postfix, 'is:2014 or tag:2015')
          .must_equal ['is:2014', 'tag:2015', :or]
        parser.send(:postfix, 'is:2014 and ( is:2015 or is:2016 )')
          .must_equal ['is:2014', 'is:2015', 'is:2016', :or, :and]
      end

      it 'tries to resolve the token' do
        tag = mock.tap { |t| t.expects(:files).returns([1]) }
        ::Taggata::Tag.expects(:find).with(:name => '2014').returns(tag)
        parser.send(:resolve, 'is:2014').must_equal([1])
      end
    end
  end
end
