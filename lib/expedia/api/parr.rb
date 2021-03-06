# frozen_string_literal: true

require 'active_support/concern'
require 'xml_mapper'
require 'nokogiri'
require 'expedia/resource'

module Expedia
  module API
    # The Product, Availability and Rate Retrieval Request and Response API
    # https://expediaconnectivity.com/apis/product-management/expedia-quickconnect-products-availability-and-rates-retrieval-api/quick-start.html
    module Parr
      # A RoomType
      class RoomType
        include XmlMapper::XmlResource

        attributes :code, :name, :status

        has_many :rate_plan do
          attributes :id, :code, :name, :status, :type
          attribute :distribution_model, as: 'distributionModel'
        end
      end

      # A ProductList
      class ProductList
        include XmlMapper::XmlResource
        element :hotel do
          attribute :id
          attribute :name
          attribute :city
        end
        element :room_type, class: RoomType
      end

      def fetch_parr
        conn = make_conn
        resp = conn.post '/eqc/parr' do |req|
          req.body = <<~END
            <ProductAvailRateRetrievalRQ xmlns="http://www.expediaconnect.com/EQC/PAR/2013/07">
                <Authentication username="EQC16636843hotel" password="Btm6noE!&amp;ZC=TKaU"/>
                <Hotel id="16636843"/>
                <ParamSet>
                    <ProductRetrieval/>
                </ParamSet>
            </ProductAvailRateRetrievalRQ>
          END
        end
        doc = Nokogiri::XML(resp.body)
        ProductList.from_node(doc.at('ProductList'))
      end
    end
  end
end
