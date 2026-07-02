# frozen_string_literal: true

class Captain::Llm::LocalRagService
  class << self
    def clean_text(text)
      text.to_s.gsub(/\s+/, ' ').strip
    end

    # Ported from mmechatbot/app/rag.py chunk_text logic
    def chunk_text(text, max_chars: 1200, overlap: 180)
      normalized = clean_text(text)
      return [] if normalized.empty?

      chunks = []
      start = 0
      len = normalized.length

      while start < len
        end_pos = [start + max_chars, len].min
        boundary = normalized.rindex('. ', end_pos - 1)

        if boundary && boundary > start + 400
          end_pos = boundary + 1
        end

        chunk = normalized[start...end_pos].to_s.strip
        chunks << chunk if chunk.present?

        break if end_pos >= len

        start = [0, end_pos - overlap].max
      end

      chunks
    end

    def extract_pdf_text(io_or_blob)
      if defined?(PDF::Reader)
        reader = PDF::Reader.new(io_or_blob)
        return clean_text(reader.pages.map(&:text).join("\n\n"))
      end

      content = io_or_blob.respond_to?(:read) ? io_or_blob.read : io_or_blob.to_s
      io_or_blob.rewind if io_or_blob.respond_to?(:rewind)

      extracted_parts = []
      content.scan(/BT(.*?)ET/m) do |block|
        text_commands = block[0]
        text_commands.scan(/\((.*?)\)\s*T[jj]/) do |match|
          extracted_parts << match[0].gsub(/\\n/, "\n").gsub(/\\(.)/, '\1')
        end
        text_commands.scan(/\[(.*?)\]\s*TJ/) do |match|
          array_content = match[0]
          array_content.scan(/\((.*?)\)/) do |str_match|
            extracted_parts << str_match[0].gsub(/\\n/, "\n").gsub(/\\(.)/, '\1')
          end
        end
      end

      result = clean_text(extracted_parts.join(' '))
      if result.length < 50
        # Fallback to readable strings extraction if streams are compressed
        result = clean_text(content.force_encoding('BINARY').scrub.scan(/[\x20-\x7E\u00A0-\uFFFF]{4,}/).join(' '))
      end

      result
    rescue StandardError => e
      Rails.logger.warn("[LocalRagService] PDF text extraction warning: #{e.message}")
      clean_text(content.to_s)
    end
  end
end
