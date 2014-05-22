# -*- encoding : utf-8 -*-

require 'faraday'
require 'faraday_middleware'

module Ashikawa
  module Core
    module Faraday
      # A more minimal logger as replacement for the very chatty Faraday logger
      class MinimalLogger < Faraday::Response::Middleware
        # The logger to be used
        #
        # @api public
        # @return [Logger] The configured logger
        attr_reader :logger

        # Should HTTP headers be logged
        #
        # @api public
        # @return [Boolean] If the headers will be logged or not. Defaults to `false`
        attr_reader :debug_headers

        # Initialize the middleware
        #
        # @api public
        # @param [Faraday::Middleware] app The middleware to nest this one in
        # @param [Logger] logger The logger to be used
        # @param [Boolean] debug_headers Should the headers be logged. Defaults to `false`
        def initialize(app, logger, debug_headers = false)
          super(app)
          @logger        = logger
          @debug_headers = false
        end

        # Calls the this middleware and passes on to `super`
        #
        # @api public
        # @param [Faraday::Env] env The current env object
        def call(env)
          logger.debug('request') { "#{env.method.upcase} #{env.url}#{dump_headers(env.request_headers)}" }
          super
        end

        # The callback when the request was completed
        #
        # @api public
        # @param [Faraday::Env] env The current env object
        def on_complete(env)
          logger.debug('response') { "#{env.method.upcase} #{env.url} #{env.status}#{dump_headers(env.response_headers)}" }
        end

        private

        # Creates a one-liner out of headers
        #
        # @api private
        # @params [Hash] headers A headers hash
        def dump_headers(headers)
          " #{headers.map { |k, v| "#{k}: #{v.inspect}" }.join(' ')}" if debug_headers
        end
      end

      Faraday::Response.register_middleware minimal_logger: -> { MinimalLogger }
    end
  end
end
