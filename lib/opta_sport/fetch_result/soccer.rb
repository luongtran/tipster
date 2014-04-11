module OptaSport
  module FetchResult
    class Base
      attr_accessor :xml_doc

      def initialize(xml_doc)
        @xml_doc = xml_doc
      end
    end
  end
end