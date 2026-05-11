class PdfTextExtractor
  MAX_CHARS = 32_000

  def initialize(paper)
    @paper = paper
  end

  def extract
    return "" unless @paper.pdf.attached?

    @paper.pdf.open do |tempfile|
      reader = PDF::Reader.new(tempfile.path)
      text = reader.pages.map(&:text).join("\n").strip
      text.first(MAX_CHARS)
    end
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError => e
    Rails.logger.error("PdfTextExtractor error for paper #{@paper.id}: #{e.message}")
    ""
  end
end
