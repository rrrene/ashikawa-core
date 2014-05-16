# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/edge'
require 'ashikawa-core/database'

describe Ashikawa::Core::Edge do
  let(:database) { instance_double('Ashikawa::Core::Database') }
  let(:id) { '23914039/25880119' }
  let(:path) { 'edge/23914039/25880119' }
  let(:key) { '25880119' }
  let(:revision) { '13728680' }
  let(:from_id) { 'nodes/source_node' }
  let(:to_id) { 'nodes/target_node' }
  let(:first_name) { 'Jeff' }
  let(:last_name) { 'Lebowski' }
  let(:raw_data) do
    {
      '_id' => id,
      '_key' => key,
      '_rev' => revision,
      '_from' => from_id,
      '_to' => to_id,
      'first_name' => first_name,
      'last_name' => last_name
    }
  end
  let(:new_last_name) { 'Dudemeister' }
  let(:raw_data_without_meta_data_and_new_last_name) do
    {
      'first_name' => first_name,
      'last_name' => new_last_name
    }
  end

  describe 'initialized edge' do
    subject { Ashikawa::Core::Edge.new(database, raw_data) }

    its(:id) { should be(id) }
    its(:key) { should be(key) }
    its(:revision) { should be(revision) }
    its(:from_id) { should eq(from_id) }
    its(:to_id) { should eq(to_id) }

    it 'should be deletable' do
      expect(database).to receive(:send_request)
        .with(path, { delete: {} })

      subject.delete
    end

    it 'should store changes to the database' do
      expect(database).to receive(:send_request)
        .with(path, { put: raw_data_without_meta_data_and_new_last_name })

      subject['last_name'] = new_last_name
      subject.save
    end
  end

  describe 'initializing edge with additional data' do
    let(:more_info) { 'Some very important information' }
    let(:additional_data) { { more_info: more_info } }
    subject { Ashikawa::Core::Edge.new(database, raw_data, additional_data) }

    its(['more_info']) { should eq(more_info) }
  end
end
