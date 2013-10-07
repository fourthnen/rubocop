# encoding: utf-8

require 'json'
require 'pathname'

module Rubocop
  module Formatter
    # This formatter formats the report data in JSON format.
    class HtmlFormatter < BaseFormatter
      attr_reader :output_hash

      def initialize(output)
        super
        @output_hash = {
          metadata: metadata_hash,
          files:    [],
          summary:  { offence_count: 0 }
        }
        @page = "<div class='files'>"
      end

      def started(target_files)
        output_hash[:summary][:target_file_count] = target_files.count
      end

      def file_finished(file, offences)
        @page += element_for_file(file, offences)
        output_hash[:summary][:offence_count] += offences.count
      end

      def finished(inspected_files)
        @page += "</div>"
        output_hash[:summary][:inspected_file_count] = inspected_files.count
        output.write @page  #output_hash.to_json
      end

      def metadata_hash
        {
          rubocop_version: Rubocop::Version::STRING,
          ruby_engine:     RUBY_ENGINE,
          ruby_version:    RUBY_VERSION,
          ruby_patchlevel: RUBY_PATCHLEVEL.to_s,
          ruby_platform:   RUBY_PLATFORM
        }
      end

      def element_for_file(file, offences)
        file = "<div class='file'>" +
                "<div class='path'>#{relative_path(file)}</div>" +
                "<div class='offences'>"

        offences.map { |o| file += element_for_offence(o) }

        file += "</div></div>"
      end

      def element_for_offence(offence)
        "<div class='offence #{offence.severity}'>" +
          #"<span class='severity'>#{offence.severity}</span>" +
          "<span class='message'>#{offence.message}</span>" +
          "<br/>" +
          "<span class='location'>line: #{offence.line}, column:#{offence.real_column}</span>" +
          "</div>"
        #cop_name: offence.cop_name,
      end

      private

      def relative_path(path)
        Pathname.new(path).relative_path_from(Pathname.getwd).to_s
      end
    end
  end
end

