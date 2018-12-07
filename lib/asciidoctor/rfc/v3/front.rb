module Asciidoctor
  module Rfc::V3
    module Front
      # Syntax:
      #   = Title
      #   Author
      #   :METADATA
      def front(node, xml)
        xml.front do |xml_front|
          title node, xml_front
          series_info node, xml_front
          author node, xml_front
          date node, xml_front
          area node, xml_front
          workgroup node, xml_front
          keyword node, xml_front
        end
      end

      def series_info(node, xml)
        docname = node.attr("name")
        return if docname.nil? || docname&.empty?
        is_rfc = docname =~ /^rfc-?/i || node.attr("doctype") == "rfc"

        if is_rfc
          name = docname.gsub(/^rfc-?/i, "") 
          nameattr = "RFC" 
        else
          name = docname
          nameattr = "Internet-Draft"
        end
        value = name.gsub(/\.[^\/]+$/, "")

        seriesInfo_attributes = {
          name: nameattr,
          status: node.attr("status"),
          stream: node.attr("submission-type") || "IETF",
          value: value,
        }
        xml.seriesInfo **attr_code(seriesInfo_attributes)

        intendedstatus = node.attr("intended-series")
        if !is_rfc && !intendedstatus.nil?
          unless intendedstatus =~ /^(standard|full-standard|bcp|fyi|informational|experimental|historic)$/
            warn %(asciidoctor: WARNING (#{current_location(node)}): disallowed value for intended-series in document header: #{intendedstatus})
          end
          seriesInfo_attributes = {
            name: "",
            status: intendedstatus,
            value: value,
          }
          xml.seriesInfo **attr_code(seriesInfo_attributes)
        end

        rfcstatus = intendedstatus
        if is_rfc && !rfcstatus.nil?
          m = /^(\S+) (\d+)$/.match rfcstatus
          if m.nil?
            rfcstatus = "exp" if rfcstatus == "experimental"
            rfcstatus = "info" if rfcstatus == "informational"
            warn %(asciidoctor: WARNING (#{current_location(node)}): disallowed value for intended-series in document header with no series number: #{rfcstatus}) unless rfcstatus =~ /^(info|exp|historic)$/
          else
            rfcstatus = m[1]
            value = m[2]
            warn %(asciidoctor: WARNING (#{current_location(node)}): disallowed value for intended-series in document header with series number: #{rfcstatus}) unless rfcstatus =~ /^(standard|full-standard|bcp)$/
          end
          seriesInfo_attributes = {
            name: "",
            status: rfcstatus,
            value: value,
          }
          xml.seriesInfo **attr_code(seriesInfo_attributes)
        end
      end

      def organization(node, suffix, xml)
        organization = node.attr("organization#{suffix}")
        xml.organization { |org| org << organization } unless organization.nil?
      end

      def address(node, suffix, xml)
        email = node.attr("email#{suffix}")
        facsimile = node.attr("fax#{suffix}")
        phone = node.attr("phone#{suffix}")
        postalline = node.attr("postal-line#{suffix}")
        street = node.attr("street#{suffix}")
        uri = node.attr("uri#{suffix}")
        if [email, facsimile, phone, postalline, street, uri].any?
          xml.address do |xml_address|
            address1 node, suffix, xml_address if [postalline, street].any?
            xml_address.phone { |p| p << phone } unless phone.nil?
            xml_address.facsimile { |f| f << facsimile } unless facsimile.nil?
            xml_address.email { |e| e << email } unless email.nil?
            xml_address.uri { |u| u << uri } unless uri.nil?
          end
        end
      end

      private

      def address1(node, suffix, xml_address)
        postalline = node.attr("postal-line#{suffix}")
        street = node.attr("street#{suffix}")
        xml_address.postal do |xml_postal|
          if postalline.nil?
            city = node.attr("city#{suffix}")
            code = node.attr("code#{suffix}")
            country = node.attr("country#{suffix}")
            region = node.attr("region#{suffix}")
            street&.split("\\ ")&.each { |st| xml_postal.street { |s| s << st } }
            xml_postal.city { |c| c << city } unless city.nil?
            xml_postal.region { |r| r << region } unless region.nil?
            xml_postal.code { |c| c << code } unless code.nil?
            xml_postal.country { |c| c << country } unless country.nil?
          else
            postalline&.split("\\ ")&.each { |pl| xml_postal.postalLine { |p| p << pl } }
          end
        end
      end
    end
  end
end
