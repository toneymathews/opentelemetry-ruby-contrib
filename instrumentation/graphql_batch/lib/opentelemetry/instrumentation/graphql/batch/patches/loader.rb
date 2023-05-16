# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Instrumentation
    module GraphQL
      module Batch
        module Patches
          # Module to prepend to GraphQL::Batch::Loader for instrumentation
          module Loader
            def around_perform
              tracer.in_span(span_name, attributes: attributes) do
                super
              end
            end

            private

            def tracer
              GraphQL::Batch::Instrumentation.instance.tracer
            end

            def span_name
              loader_name.split('::').last
            end

            def attributes
              {
                'batch_loader' => loader_name
              }
            end

            def loader_name
              self.class.name
            end
          end
        end
      end
    end
  end
end
