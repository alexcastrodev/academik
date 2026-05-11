class PdfDownloadJob < ApplicationJob
  queue_as :imports

  discard_on ActiveRecord::RecordNotFound

  def perform(paper_id, url)
    paper = Paper.find(paper_id)
    return if paper.pdf.attached?

    response = Faraday.get(url) do |req|
      req.options.timeout      = 120
      req.options.open_timeout = 15
      # Some servers (arxiv) require a browser-like User-Agent
      req.headers["User-Agent"] = "Mozilla/5.0 (compatible; academikApp/1.0)"
    end

    raise "PDF download failed: HTTP #{response.status}" unless response.success?

    content_type = response.headers["content-type"].to_s.split(";").first.strip
    raise "Not a PDF (got #{content_type})" unless content_type == "application/pdf"

    filename = URI.parse(url).path.split("/").last.then { |f| f.end_with?(".pdf") ? f : "#{f}.pdf" }

    paper.pdf.attach(
      io:           StringIO.new(response.body),
      filename:     filename,
      content_type: "application/pdf"
    )

    PdfImportJob.perform_later(paper.id)
  end
end
