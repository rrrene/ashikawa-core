# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/index'
require 'ashikawa-core/collection'

describe Ashikawa::Core::Index do
  let(:collection) { instance_double('Ashikawa::Core::Collection') }
  let(:id) { '167137465/168054969' }
  let(:path) { 'index/167137465/168054969' }
  let(:delete_payload) { { delete: {} } }
  let(:type_as_sym) { :skiplist }
  let(:type) { 'skiplist' }
  let(:field_as_sym) { :name }
  let(:field) { 'name' }
  let(:unique) { double('Boolean') }
  let(:raw_data) do
    {
      'code' => 201,
      'fields' => [field],
      'id' => id,
      'type' => type,
      'isNewlyCreated' => true,
      'unique' => unique,
      'error' => false
    }
  end

  describe 'initialized index' do
    subject { Ashikawa::Core::Index.new(collection, raw_data) }

    its(:id) { should be(id) }
    its(:type) { should be(type_as_sym) }

    it 'should know which fields it is on' do
      skip 'Currently not working on Rubinius'
      expect(subject).to include(field_as_sym)
    end

    its(:unique) { should be(unique) }

    it 'should be deletable' do
      expect(collection).to receive(:send_request)
        .with(path, delete_payload)

      subject.delete
    end
  end
end
