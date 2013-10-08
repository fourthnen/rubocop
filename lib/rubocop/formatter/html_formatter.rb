# encoding: utf-8

#require 'json'
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
        @page = "<style>
        body {
          background-color: 111;
        }
        span {
          line-height: 20px;
        }
        .files {
          color: F1F0F0;
          font-family: helvetica;
          font-size: 13px;
          margin: 50px 10px;
        }
        .file {
          background-color: 222;
          margin-bottom: 20px;
        }
        .page {
          color: lightgreen;
        }
        .path {
          color: lightblue;
          font-weight: bold;
          padding: 5px;
          font-size: 14px;
        }
        .offences {
          margin: 5px;
          border: 1px dotted grey;
        }
        .offence { 
          padding: 10px 5px;
        }
        .convention {
          background: darkslategrey;
        }
        .warning {
          background-color: 500000;
        }
        .location {
          font-size: 12px;
        }
        </style><div class='files'>"
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
                  "<a href='#{relative_path(file)}'>"+
                    "<div class='path'>#{relative_path(file)}</div>" +
                  "</a>" +
                  "<div class='offences'>"

        offences.map { |o| file += element_for_offence(o) }

        file += "</div></div>"
      end

      def element_for_offence(offence)
        "<div class='offence #{offence.severity}'>" +
          "#{offence.inspect}" +
          #"<span class='severity'>#{offence.severity}</span>" +
          "<span class='message'>#{offence.message}</span>" +
          "<br/>" +
          "<span class='location'>line: #{offence.line}, column:#{offence.real_column}</span>, &nbsp;<span class='cop'>cop name: #{offence.cop_name}</span>" +
          source(offence) +
          "</div>"
      end

      def source(offence)
          source_line = offence.location.source_line

          if source_line.blank?
            ''
          else
            "<pre class='source-lines'>
              <span class='source-line'>#{source_line}</span>
              <span class='source-highlight'>#{' ' * offence.location.column + '^' * offence.location.column_range.count}</span>
             </pre>"
          end

      end
      private

      def relative_path(path)
        Pathname.new(path).relative_path_from(Pathname.getwd).to_s
      end
    end
  end
end

