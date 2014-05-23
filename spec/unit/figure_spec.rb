# -*- encoding : utf-8 -*-
require 'ashikawa-core/figure'

describe Ashikawa::Core::Figure do
  let(:alive_size) { 0 }
  let(:alive_count) { 0 }
  let(:dead_size) { 2384 }
  let(:dead_count) { 149 }
  let(:dead_deletion) { 0 }
  let(:datafiles_count) { 1 }
  let(:datafiles_file_size) { 0 }
  let(:journals_count) { 1 }
  let(:journals_file_size) { 33_554_432 }
  let(:shapes_count) { 6 }
  let(:attributes_count) { 0 }

  let(:raw_figures) do
    {
      'alive' => {
        'size' => alive_size,
        'count' => alive_count
      },
      'dead' => {
        'size' => dead_size,
        'count' => dead_count,
        'deletion' => dead_deletion
      },
      'datafiles' => {
        'count' => datafiles_count,
        'fileSize' => datafiles_file_size
      },
      'journals' => {
        'count' => journals_count,
        'fileSize' => journals_file_size
      },
      'shapes' => {
        'count' => shapes_count
      },
      'attributes' => {
        'count' => attributes_count
      }
    }
  end

  subject { Ashikawa::Core::Figure.new(raw_figures) }

  its(:alive_size)          { should be(alive_size) }
  its(:alive_count)         { should be(alive_count) }
  its(:dead_size)           { should be(dead_size) }
  its(:dead_count)          { should be(dead_count) }
  its(:dead_deletion)       { should be(dead_deletion) }
  its(:datafiles_count)     { should be(datafiles_count) }
  its(:datafiles_file_size) { should be(datafiles_file_size) }
  its(:journals_count)      { should be(journals_count) }
  its(:journals_file_size)  { should be(journals_file_size) }
  its(:shapes_count)        { should be(shapes_count) }
  its(:attributes_count)    { should be(attributes_count) }
end
