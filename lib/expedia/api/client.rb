# frozen_string_literal: true

require 'active_support/core_ext/hash'
require 'faraday'
require 'json'

# The Expedia 'namespace'
module Expedia

  %w[EQC_PROPERTY_ID EQC_USERNAME EQC_PASSWORD].each do |key|
    const_set key, ENV[key]
  end

  # Expedia::API
  module API
    # The main Expedia API client
    class Client

      def properties
        conn = Faraday.new url: 'https://services.expediapartnercentral.com' do |faraday|
          faraday.request  :url_encoded             # form-encode POST params
          faraday.response :logger                  # log requests to STDOUT
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          faraday.basic_auth(EQC_USERNAME, EQC_PASSWORD)
        end

        resp = conn.get '/products/properties'
        json = JSON.parse(resp.body).with_indifferent_access
        json[:entity]
      end

    end
  end
end

require 'expedia/api/client'
