# frozen_string_literal: true

# name: bokeh-docs-onebox
# about: Onebox engine for Bokeh docs
# version: 0.1
# authors: @bryevdv
# url: https://github.com/bokeh/discourse-bokeh-onebox

require 'htmlentities'

require_relative "../../lib/onebox"

Onebox = Onebox

module Onebox
  module Engine
    class BokehDocsOnebox
      include Engine
      include StandardEmbed
      include LayoutSupport

      REF_REGEX = /^https?:\/\/docs.bokeh.org\/(?:\w+)[\/\w\-\.]+#((?:bokeh\.)[\w\-\.]+)$/
      NARRATIVE_REGEX = /^https?:\/\/docs.bokeh.org\/(?:\w+)[\/\w\-\.]+#([\w\-]+)$/
      matches_regexp Regexp.union(NARRATIVE_REGEX, REF_REGEX)

      def self.priority
        0
      end

      def self.onebox_name
        "allowlistedgeneric"
      end

      def narrative_data
        id = url.match(NARRATIVE_REGEX)[1]
        header = html_doc.xpath("//div[@id='#{id}']/*[self::h1 or self::h2 or self::h3 or self::h4][1]")
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

      def ref_data
        id = url.match(REF_REGEX)[1]
        section = html_doc.xpath("//dt[@id='#{id}']/..//p")
        html_entities = HTMLEntities.new

        d = { link: link }.merge(raw)
        d[:title] = html_entities.decode(Onebox::Helpers.truncate(id, 80))
        d[:description] = html_entities.decode(Onebox::Helpers.truncate(section.text, 250))

        if !Onebox::Helpers.blank?(d[:site_name])
          d[:domain] = html_entities.decode(Onebox::Helpers.truncate(d[:site_name], 80))
        elsif !Onebox::Helpers.blank?(d[:domain])
          d[:domain] = "http://#{d[:domain]}" unless d[:domain] =~ /^https?:\/\//
          d[:domain] = URI(d[:domain]).host.to_s.sub(/^www\./, '') rescue nil
        end

        d
      end

      def data
        if (url =~ NARRATIVE_REGEX)
          @data ||= narrative_data
        elsif (url =~ REF_REGEX)
          puts "LKSFJKLFJLDKJF"
          @data ||= ref_data
        end
      end

    end
  end
end
