# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

require_relative '../../../../lib/opentelemetry/instrumentation/graphql/batch'

describe OpenTelemetry::Instrumentation::GraphQL::Batch do
  let(:instrumentation) { OpenTelemetry::Instrumentation::GraphQL::Batch::Instrumentation.instance }
  let(:exporter) { EXPORTER }
  let(:spans) { exporter.finished_spans }

  before do
    exporter.reset
    instrumentation.install
    GraphQL::Batch::Executor.current = GraphQL::Batch::Executor.new
  end

  after do
    GraphQL::Batch::Executor.current = nil
  end

  it 'has #name' do
    _(instrumentation.name).must_equal 'OpenTelemetry::Instrumentation::GraphQL::Batch'
  end

  it 'has #version' do
    _(instrumentation.version).wont_be_nil
    _(instrumentation.version).wont_be_empty
  end

  describe 'loader' do
    it 'when the patch is installed' do
      expected_attributes = {
        'batch_loader' => 'GroupCountLoader'
      }

      GroupCountLoader.for('single').load('first').sync

      assert spans.size.must_equal 1

      span = spans.first
      assert span.name.must_equal 'GroupCountLoader'
      assert span.attributes.must_equal(expected_attributes)
    end

    it 'when a field resolves lazily' do
      Schema.execute('{ int }')
      # two spans must be created, one for each loader
      # assert spans.size.must_equal 2
    end
  end

  class GroupCountLoader < GraphQL::Batch::Loader
    def initialize(key); end # rubocop:disable Style/RedundantInitialize

    def perform(keys)
      keys.each { |key| fulfill(key, keys.size) }
    end
  end

  class QueryRoot < GraphQL::Schema::Object
    field :int, Integer, null: false

    def int
      # these are separate loaders and hence should create separate spans (I think)
      GroupCountLoader.for('single').load('first')
      GroupCountLoader.for('double').load('second')
    end
  end

  class Schema < GraphQL::Schema
    query QueryRoot
    use GraphQL::Batch
  end
end
