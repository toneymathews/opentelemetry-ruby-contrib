# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Instrumentation
    module GraphQL
      module Batch
        # The Instrumentation class contains logic to detect and install the GraphQL::Batch
        # instrumentation
        class Instrumentation < OpenTelemetry::Instrumentation::Base
          install do |_config|
            require_dependencies
            patch
          end

          present do
            defined?(::GraphQL::Batch)
          end

          private

          def require_dependencies
            require_relative 'patches/loader'
          end

          def patch
            ::GraphQL::Batch::Loader.prepend(Patches::Loader)
          end
        end
      end
    end
  end
end
