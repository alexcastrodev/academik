class PdfImportJob < ApplicationJob
  queue_as :imports

  discard_on ActiveRecord::RecordNotFound

  def perform(paper_id)
    paper = Paper.find(paper_id)
    text = PdfTextExtractor.new(paper).extract
    paper.update!(extracted_text: text)
  end
end
