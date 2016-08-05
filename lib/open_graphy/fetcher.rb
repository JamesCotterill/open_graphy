require 'socket'

module OpenGraphy
  class Fetcher
    def initialize(uri)
      @uri = uri
    end

    def self.fetch(uri)
      new(uri).fetch
    end

    def fetch
      begin
        valid_meta_tags.each do |tag|
          data.add_data(tag.name, tag.value)
        end
        data.add_data('__html_title_tag',  doc.css('title').text)
      rescue SocketError, Errno::ENOENT
        data.add_data("url", @uri)
      end

      data
    end

    private

    def valid_meta_tags
      valid_meta_tags ||= meta_tags.select(&:valid?)
    end

    class MetaTag
      def initialize(doc, meta_tag)
        @doc, @meta_tag = doc, meta_tag
      end

      def valid?
        tag_name
      end

      def name
        @meta_tag.attr('property').sub(tag_name, '')
      end

      def value
        @meta_tag.attr('content').to_s
      end

      private

      def tag_name
        OpenGraphy.configuration.metatags.find do |valid_meta_tag_name|
          @meta_tag.attr('property') =~ Regexp.new(valid_meta_tag_name)
        end
      end
    end

    def meta_tags
      doc.css('//meta').map { |tag| MetaTag.new(doc, tag) }
    end

    def data
      @data ||= Data.new
    end

    def doc
      @doc ||= Nokogiri::HTML(open(@uri))
    end
  end
end
