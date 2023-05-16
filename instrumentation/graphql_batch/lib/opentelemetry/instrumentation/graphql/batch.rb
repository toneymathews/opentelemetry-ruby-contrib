# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'opentelemetry'
require 'opentelemetry/common'
require 'opentelemetry-instrumentation-base'

module OpenTelemetry
  module Instrumentation
    module GraphQL
      # Contains the OpenTelemetry instrumentation for the GraphQL::Batch gem
      module Batch
      end
    end
  end
end

require_relative './batch/instrumentation'
require_relative './batch/version'
