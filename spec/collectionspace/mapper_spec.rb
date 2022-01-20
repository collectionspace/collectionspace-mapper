# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper do
  it 'has a version number' do
    expect(CollectionSpace::Mapper::VERSION).not_to be nil
  end

  describe '#setup_data' do
    context 'when passed a CollectionSpace::Mapper::Response' do
      it 'returns that Response' do
        response = CollectionSpace::Mapper::Response.new({'objectNumber' => '123'})
        expect(CollectionSpace::Mapper.setup_data(response)).to eq(response)
      end
    end
    context 'when passed a Hash' do
      before(:all) do
        @data = {'objectNumber' => '123'}
        @response = CollectionSpace::Mapper.setup_data(@data)
      end
      it 'returns a CollectionSpace::Mapper::Response with expected orig_data' do
        expect(@response).to be_a(CollectionSpace::Mapper::Response)
        expect(@response.orig_data).to eq(@data)
      end
    end
    context 'when passed other class of object' do
      it 'returns a CollectionSpace::Mapper::Response' do
        data = %w[objectNumber 123]
        expect do
          CollectionSpace::Mapper.setup_data(data)
        end.to raise_error(CollectionSpace::Mapper::Errors::UnprocessableDataError,
                           'Cannot process a Array. Need a Hash or Mapper::Response')
      end
    end
  end
end
