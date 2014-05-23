# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/database'

describe Ashikawa::Core::Database do
  subject { Ashikawa::Core::Database }

  let(:connection) { instance_double('Ashikawa::Core::Connection', host: 'localhost', port: 8529, scheme: 'https') }
  let(:collection) { instance_double('Ashikawa::Core::Collection') }
  let(:raw_collection) { double('RawCollection') }

  it 'should initialize with a configuration object' do
    configuration = instance_double('Ashikawa::Core::Configuration')
    expect(Ashikawa::Core::Configuration).to receive(:new)
      .and_return(configuration)
    expect(configuration).to receive(:connection)
    expect { |b| Ashikawa::Core::Database.new(&b) }.to yield_with_args(configuration)
  end

  describe 'initialized database' do
    subject do
      Ashikawa::Core::Database.new do |config|
        config.connection = connection
      end
    end

    it 'should create a query' do
      expect(Ashikawa::Core::Query).to receive(:new)
        .once
        .with(subject)

      subject.query
    end

    it 'should list all databases' do
      database_list = %w(_system cupcakes ponies)
      expect(connection).to receive(:send_request)
        .with('database')
        .and_return({ 'result' => database_list, 'error' => false, 'code' => 200 })

      expect(subject.all_databases).to be database_list
    end

    context "using a database called 'ashikawa'" do
      before { allow(connection).to receive(:database_name).and_return('ashikawa') }

      its(:name) { should eq 'ashikawa' }

      describe 'create' do
        it 'should be able to create itself' do
          expect(connection).to receive(:send_request_without_database_suffix)
            .with('database', post: { name: 'ashikawa' })

          subject.create
        end

        it 'should return an error message if the database name is already taken' do
          expect(connection).to receive(:send_request_without_database_suffix)
            .with('database', post: { name: 'ashikawa' })
            .and_raise(Ashikawa::Core::ClientError, '1207: duplicate name')

          expect { subject.create }.to raise_error(Ashikawa::Core::ClientError, '1207: duplicate name')
        end
      end

      describe 'drop' do
        it 'should be able to drop itself' do
          expect(connection).to receive(:send_request_without_database_suffix)
            .with('database/ashikawa', delete: {})

          subject.drop
        end
      end
    end

    it 'should fetch all available non-system collections' do
      expect(connection).to receive(:send_request)
        .with('collection')
        .and_return(server_response('collections/all'))

      (0..1).each do |k|
        expect(Ashikawa::Core::Collection).to receive(:new)
          .with(subject, server_response('collections/all')['collections'][k])
      end

      expect(subject.collections.length).to eq(2)
    end

    it 'should fetch all available non-system collections' do
      expect(connection).to receive(:send_request)
        .with('collection')
        .and_return(server_response('collections/all'))

      expect(Ashikawa::Core::Collection).to receive(:new)
        .exactly(5).times

      expect(subject.system_collections.length).to eq(5)
    end

    it 'should truncate all documents in all collections' do
      allow(subject).to receive(:collections)
        .and_return([collection])
      expect(collection).to receive(:truncate)

      subject.truncate
    end

    it 'should create a non volatile collection by default' do
      expect(connection).to receive(:send_request)
        .with('collection', post: { name: 'volatile_collection' })
        .and_return(raw_collection)

      expect(Ashikawa::Core::Collection).to receive(:new)
        .with(subject, raw_collection)

      subject.create_collection('volatile_collection')
    end

    it 'should create a volatile collection when asked' do
      expect(connection).to receive(:send_request)
        .with('collection', post: { name: 'volatile_collection', isVolatile: true })
        .and_return(raw_collection)

      expect(Ashikawa::Core::Collection).to receive(:new)
        .with(subject, raw_collection)

      subject.create_collection('volatile_collection', is_volatile: true)
    end

    it 'should create an autoincrement collection when asked' do
      expect(connection).to receive(:send_request).with('collection',
                                                        post: {
          name: 'autoincrement_collection', keyOptions: {
            type: 'autoincrement',
            offset: 0,
            increment: 10,
            allowUserKeys: false
          }
        }
      )

      expect(Ashikawa::Core::Collection).to receive(:new)

      subject.create_collection('autoincrement_collection', key_options: {
        type: :autoincrement,
        offset: 0,
        increment: 10,
        allow_user_keys: false
      })
    end

    it 'should create an edge collection when asked' do
      expect(connection).to receive(:send_request)
        .with('collection', post: { name: 'volatile_collection', type: 3 })
        .and_return(raw_collection)

      expect(Ashikawa::Core::Collection).to receive(:new)
        .with(subject, raw_collection)

      subject.create_collection('volatile_collection', content_type: :edge)
    end

    it 'should fetch a single collection if it exists' do
      expect(connection).to receive(:send_request)
        .with('collection/60768679')
        .and_return(raw_collection)

      expect(Ashikawa::Core::Collection).to receive(:new)
        .with(subject, raw_collection)

      subject.collection(60_768_679)
    end

    it 'should fetch a single collection with the array syntax' do
      expect(connection).to receive(:send_request)
        .with('collection/60768679')
        .and_return(raw_collection)

      expect(Ashikawa::Core::Collection).to receive(:new)
        .with(subject, raw_collection)

      subject[60_768_679]
    end

    it "should create a single collection if it doesn't exist" do
      expect(connection).to receive(:send_request).with('collection/new_collection') do
        raise Ashikawa::Core::CollectionNotFoundException
      end
      expect(subject).to receive(:create_collection).with('new_collection').and_return(collection)

      subject['new_collection']
    end

    it 'should send a request via the connection object' do
      expect(connection).to receive(:send_request)
        .with('my/path', post: { data: 'mydata' })

      subject.send_request 'my/path', post: { data: 'mydata' }
    end

    it 'should create a transaction' do
      js_function = 'function () { return 5; }'
      collections = { read: ['collection_1'] }
      transaction = instance_double('Ashikawa::Core::Transaction')
      expect(Ashikawa::Core::Transaction).to receive(:new)
        .with(subject, js_function, collections)
        .and_return(transaction)

      expect(subject.create_transaction(js_function, collections)).to be(transaction)
    end
  end
end
