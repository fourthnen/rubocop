# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::FinalNewline do
  subject(:cop) { described_class.new }

  it 'registers an offence for missing final newline' do
    source = ['x = 0', 'top']
    inspect_source(cop, source)
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts a final newline' do
    source = ['x = 0', 'top', '']
    inspect_source(cop, source)
    expect(cop.offences).to be_empty
  end

  it 'accepts an empty file' do
    source = ['']
    inspect_source(cop, source)
    expect(cop.offences).to be_empty
  end
end
