class LatexGeneratorJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound

  def perform(collection_id)
    collection = Collection.find(collection_id)
    papers = collection.papers.includes(:summaries)
    content = LatexTemplateBuilder.new(papers).build

    LatexDocument.create!(
      title: "#{collection.name} — Literature Review",
      content: content,
      generation_type: :collection,
      sourceable: collection
    )
  end
end
