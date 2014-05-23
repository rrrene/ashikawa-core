# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/key_options'

describe Ashikawa::Core::KeyOptions do
  let(:type) { :autoincrement }
  let(:offset) { 12 }
  let(:increment) { 2 }
  let(:allow_user_keys) { double('Boolean') }

  subject do
    Ashikawa::Core::KeyOptions.new(
      'type' => type,
      'offset' => offset,
      'increment' => increment,
      'allowUserKeys' => allow_user_keys
    )
  end

  its(:type) { should eq(type) }
  its(:offset) { should eq(offset) }
  its(:increment) { should eq(increment) }
  its(:allow_user_keys) { should eq(allow_user_keys) }
end
