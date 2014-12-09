require 'spec_helper'

describe Signpost::Builder::Plain::Path do
  let(:instance) { described_class.new(pattern, options) }

  describe '#to' do

  end

  describe '#as' do

  end

  describe '#except' do

  end

  describe '#capture' do

  end

  describe '#params' do

  end

  describe '.new' do
    subject do
      described_class.new(pattern, options) do
        to('foo#bar')
      end

      it 'should evaluate given block'
    end
  end

end
