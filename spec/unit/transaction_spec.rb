# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/transaction'
require 'ashikawa-core/database'

describe Ashikawa::Core::Transaction do
  let(:db) { instance_double('Ashikawa::Core::Database') }
  let(:action) { 'function () { return 5; }' }

  describe 'creating a transaction' do
    subject { Ashikawa::Core::Transaction }

    it 'should be initialized with only write collections' do
      transaction = subject.new(db, action, write: ['collection_1'])
      expect(transaction.write_collections).to eq(['collection_1'])
    end

    it 'should be initialized with only read collections' do
      transaction = subject.new(db, action, read: ['collection_1'])
      expect(transaction.read_collections).to eq(['collection_1'])
    end
  end

  describe 'using a transaction' do
    let(:read_and_write_collections) do
      {
        read: ['collection_1'],
        write: ['collection_2']
      }
    end

    let(:only_read_collection) do
      {
        read: ['collection_1']
      }
    end

    let(:only_write_collection) do
      {
        write: ['collection_1']
      }
    end

    subject { Ashikawa::Core::Transaction.new(db, action, read_and_write_collections) }

    it 'should be possible to activate waiting for sync' do
      expect(subject.wait_for_sync).to be_falsey
      subject.wait_for_sync = true
      expect(subject.wait_for_sync).to be_truthy
    end

    it 'should be possible to set the lock timeout' do
      expect(subject.lock_timeout).to be_nil
      subject.lock_timeout = 30
      expect(subject.lock_timeout).to be 30
    end

    describe 'execute' do
      let(:response) { double('Response') }
      let(:result) { double('Result') }

      before do
        allow(response).to receive(:[])
        allow(db).to receive(:send_request)
          .and_return(response)
      end

      it 'should return the result from the database' do
        expect(response).to receive(:[])
          .with('result')
          .and_return(result)
        expect(db).to receive(:send_request)
          .and_return(response)
        expect(subject.execute).to eq(result)
      end

      it 'should post to `transaction` endpoint' do
        expect(db).to receive(:send_request)
          .with('transaction', post: an_instance_of(Hash))
        subject.execute
      end

      it 'should only send the read collection if no write collection was provided' do
        transaction = Ashikawa::Core::Transaction.new(db, action, only_read_collection)
        expect(db).to receive(:send_request)
          .with(anything, { post: hash_including(collections: only_read_collection) })
        transaction.execute
      end

      it 'should send the information about the read and write collections' do
        expect(db).to receive(:send_request)
          .with(anything, { post: hash_including(collections: read_and_write_collections) })
        subject.execute
      end

      it 'should only send the write collection if no read collection was provided' do
        transaction = Ashikawa::Core::Transaction.new(db, action, only_write_collection)
        expect(db).to receive(:send_request)
          .with(anything, { post: hash_including(collections: only_write_collection) })
        transaction.execute
      end

      it 'should send the information about the action' do
        expect(db).to receive(:send_request)
          .with(anything, { post: hash_including(action: action) })
        subject.execute
      end

      it 'should send with wait for sync set to false by default' do
        expect(db).to receive(:send_request)
          .with(anything, { post: hash_including(waitForSync: false) })
        subject.execute
      end

      it 'should allow to set wait for sync to true' do
        expect(db).to receive(:send_request)
          .with(anything, { post: hash_including(waitForSync: true) })
        subject.wait_for_sync = true
        subject.execute
      end

      it 'should not send lock timeout by default' do
        expect(db).to receive(:send_request)
          .with(anything, { post: hash_not_including(lockTimeout: anything) })
        subject.execute
      end

      it 'should send the configured lock timeout' do
        expect(db).to receive(:send_request)
          .with(anything, { post: hash_including(lockTimeout: 30) })
        subject.lock_timeout = 30
        subject.execute
      end

      it 'should send the arguments object if it was provided' do
        expect(db).to receive(:send_request)
          .with(anything, { post: hash_including(params: { a: 5 }) })
        subject.execute(a: 5)
      end

      it 'should not send params by default' do
        expect(db).to receive(:send_request)
          .with(anything, { post: hash_not_including(params: anything) })
        subject.execute
      end
    end
  end
end
