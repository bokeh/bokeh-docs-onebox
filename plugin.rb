# frozen_string_literal: true

require 'htmlentities'

Onebox = Onebox

module Onebox
  module Engine
    class BokehDocsOnebox
      include Engine
      include StandardEmbed
      include LayoutSupport

      REGEX = /^https?:\/\/docs.bokeh.org(?:\/\w+)*\/[\w\-\.]+#([\w\-]+)$/
      matches_regexp REGEX

      def self.priority
        0
      end

      def self.onebox_name
        "allowlistedgeneric"
      end

      def data
        @data ||= begin
          id = url.match(REGEX)[1]
          header = html_doc.xpath("//div[@id='#{id}']/h2[1]")
          section = html_doc.xpath("//div[@id='#{id}']/p")

          html_entities = HTMLEntities.new

          d = { link: link }.merge(raw)
          d[:title] = html_entities.decode(Onebox::Helpers.truncate(header.text[0...-1], 80))
          d[:description] = html_entities.decode(Onebox::Helpers.truncate(section.text, 250))

          if !Onebox::Helpers.blank?(d[:site_name])
            d[:domain] = html_entities.decode(Onebox::Helpers.truncate(d[:site_name], 80))
          elsif !Onebox::Helpers.blank?(d[:domain])
            d[:domain] = "http://#{d[:domain]}" unless d[:domain] =~ /^https?:\/\//
            d[:domain] = URI(d[:domain]).host.to_s.sub(/^www\./, '') rescue nil
          end

          d
        end
      end

    end
  end
end
