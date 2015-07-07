require 'test_helper'

describe 'Stemmer' do
  def stem(value)
    BlueSkies::Stemmer.stem(value)
  end

  it 'strips dots' do
    assert_equal 'base', stem('b.a.s.e')
  end

  it 'strips spaces' do
    assert_equal 'basejump', stem('base jump')
  end

  it 'strips dashes' do
    assert_equal 'basejump', stem('base-jump')
  end

  it 'converts to lowercase' do
    assert_equal 'base', stem('BASE')
  end

  it 'converts special characters' do
    assert_equal 'base', stem('bàse')
  end

  it 'returns stem' do
    assert_equal 'paraglid', stem('paragliding')
  end
end
