# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/query'
require 'ashikawa-core/database'

describe Ashikawa::Core::Query do
  let(:collection_name) { 'my_collection' }
  let(:database) { instance_double('Ashikawa::Core::Database') }
  let(:collection) { instance_double('Ashikawa::Core::Collection', name: collection_name, database: database) }

  context 'initialized with collection' do
    subject { Ashikawa::Core::Query.new(collection) }

    describe 'get all' do
      it 'should list all documents' do
        expect(collection).to receive(:send_request)
          .with('simple/all', put: { 'collection' => collection_name })
          .and_return(server_response('simple-queries/all'))
        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.all
      end

      it 'should be able to limit the number of documents' do
        expect(collection).to receive(:send_request)
          .with('simple/all', put: { 'collection' => collection_name, 'limit' => 20 })
          .and_return(server_response('simple-queries/all_skip'))
        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.all(limit: 20)
      end

      it 'should be able to skip documents' do
        expect(collection).to receive(:send_request)
          .with('simple/all', put: { 'collection' => collection_name, 'skip' => 5 })
          .and_return(server_response('simple-queries/all_limit'))
        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.all(skip: 5)
      end
    end

    describe 'first by example' do
      let(:example_document) { double('ExampleDocument') }
      let(:response) { server_response('simple-queries/example') }

      it 'should find exactly one fitting document' do
        allow(collection).to receive(:database)
          .and_return(database)
        expect(collection).to receive(:send_request)
          .with('simple/first-example', put: {
            'collection' => collection_name,
            'example' => example_document
          }).and_return(response)
        expect(Ashikawa::Core::Document).to receive(:new)

        subject.first_example(example_document)
      end
    end

    describe 'all by example' do
      let(:example_document) { { hello: 'world' } }
      let(:response) { server_response('simple-queries/example') }

      it 'should find all fitting documents' do
        expect(collection).to receive(:send_request)
          .with('simple/by-example', put: {
            'collection' => collection_name,
            'example' => example_document
          }).and_return(response)
        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.by_example(example_document)
      end

      it 'should be able to limit the number of documents' do
        expect(collection).to receive(:send_request)
          .with('simple/by-example', put: {
            'collection' => collection_name,
            'limit' => 10,
            'example' => example_document
          }).and_return(response)
        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.by_example(example_document, limit: 10)
      end

      it 'should be able to skip documents' do
        expect(collection).to receive(:send_request)
          .with('simple/by-example', put: {
            'collection' => collection_name,
            'skip' => 2,
            'example' => example_document
          }).and_return(response)
        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.by_example(example_document, skip: 2)
      end
    end

    describe 'near a geolocation' do
      let(:latitude) { 37.332095 }
      let(:longitude) { -122.030757 }
      let(:arguments) do
        {
          'collection' => collection_name,
          'latitude' => latitude,
          'longitude' => longitude
        }
      end
      let(:response) { server_response('simple-queries/near') }

      it 'should find documents based on latitude/longitude' do
        expect(collection).to receive(:send_request)
          .with('simple/near', put: arguments)
          .and_return(response)
        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.near(latitude: latitude, longitude: longitude)
      end
    end

    describe 'within a radius of a geolocation' do
      let(:latitude) { 37.332095 }
      let(:longitude) { -122.030757 }
      let(:radius) { 50 }
      let(:arguments) do
        {
          'collection' => collection_name,
          'latitude' => latitude,
          'longitude' => longitude,
          'radius' => radius
        }
      end
      let(:response) { server_response('simple-queries/within') }

      it 'should look for documents based on latidude/longitude' do
        expect(collection).to receive(:send_request)
          .with('simple/within' , put: arguments)
          .and_return(response)
        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.within(latitude: latitude, longitude: longitude, radius: radius)
      end
    end

    describe 'in a certain range' do
      let(:attribute) { 'age' }
      let(:left) { 45 }
      let(:right) { 50 }
      let(:closed) { true }
      let(:arguments) do
        { 'collection' => collection_name,
          'attribute' => attribute,
          'left' => left,
          'right' => right,
          'closed' => closed
        }
      end
      let(:response) { server_response('simple-queries/range') }

      it 'should look for documents with an attribute in that range' do
        expect(collection).to receive(:send_request)
          .with('simple/range' , put: arguments)
          .and_return(response)
        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.in_range(attribute: attribute, left: left, right: right, closed: closed)
      end
    end

    describe 'with an AQL query' do
      let(:query) { 'FOR human IN humans RETURN human' }
      let(:count) { 5 }
      let(:batch_size) { 200 }
      let(:arguments) do
        {
          'query' => query,
          'count' => count,
          'batchSize' => batch_size
        }
      end
      let(:response) { server_response('cursor/query') }

      it 'should be able to execute it' do
        allow(collection).to receive(:database)
          .and_return(database)
        expect(collection).to receive(:send_request)
          .with('cursor', post: arguments)
          .and_return(response)
        expect(Ashikawa::Core::Cursor).to receive(:new)
          .with(collection.database, response)

        subject.execute(query, count: count, batch_size: batch_size)
      end

      it 'passes bound variables to the server' do
        allow(collection).to receive(:database)
          .and_return(database)
        expect(collection).to receive(:send_request)
          .with('cursor', post: { 'bindVars' => { 'foo' => 'bar' }, 'query' => query })
          .and_return(response)

        subject.execute(query, bind_vars: { 'foo' => 'bar' })
      end

      it 'should return true when asked if a valid query is valid' do
        expect(collection).to receive(:send_request)
          .with('query', post: { 'query' => query })
          .and_return(server_response('query/valid'))

        expect(subject.valid?(query)).to be_truthy
      end

      it 'should return false when asked if an invalid query is valid' do
        allow(collection).to receive(:send_request)
          .and_raise(Ashikawa::Core::BadSyntax)
        expect(collection).to receive(:send_request)
          .with('query', post: { 'query' => query })

        expect(subject.valid?(query)).to be_falsey
      end
    end
  end

  context 'initialized with database' do
    subject { Ashikawa::Core::Query.new(database) }

    it 'should throw an exception when a simple query is executed' do
      [:all, :by_example, :first_example, :near, :within, :in_range].each do |method|
        expect { subject.send method }.to raise_error(Ashikawa::Core::NoCollectionProvidedException)
      end
    end

    describe 'with an AQL query' do
      let(:query) { 'FOR pony IN ponies RETURN pony' }
      let(:count) { 5 }
      let(:batch_size) { 2 }
      let(:arguments) do
        {
          'query' => query,
          'count' => count,
          'batchSize' => batch_size
        }
      end
      let(:query_response) { server_response('cursor/query') }
      let(:valid_response) { server_response('cursor/query') }

      it 'should be able to execute it' do
        expect(database).to receive(:send_request)
          .with('cursor', post: arguments)
          .and_return(query_response)
        expect(Ashikawa::Core::Cursor).to receive(:new)
          .with(database, query_response)

        subject.execute(query, count: count, batch_size: batch_size)
      end

      it 'should return true when asked if a valid query is valid' do
        expect(database).to receive(:send_request)
          .with('query', post: { 'query' => query })
          .and_return(valid_response)

        expect(subject.valid?(query)).to be_truthy
      end

      it 'should return false when asked if an invalid query is valid' do
        expect(database).to receive(:send_request)
          .with('query', post: { 'query' => query })
          .and_raise(Ashikawa::Core::BadSyntax)

        expect(subject.valid?(query)).to be_falsey
      end
    end
  end
end
