class OllamaSummarizeJob < ApplicationJob
  queue_as :ai

  discard_on ActiveRecord::RecordNotFound
  retry_on AiService::ConnectionError, wait: 30.seconds, attempts: 3

  def perform(paper_id)
    paper = Paper.find(paper_id)
    service = AiService.new

    summary = paper.summaries.create!(
      status: :generating,
      model_used: service.model_label
    )

    prompt = <<~PROMPT
      Summarize the following academik paper in 3-5 paragraphs, highlighting the research question, methodology, key findings, and contributions:

      #{paper.extracted_text.to_s.first(32_000)}
    PROMPT

    begin
      response = service.generate(prompt: prompt)
      summary.update!(status: :complete, content: response, generated_at: Time.current)
    rescue AiService::ConnectionError
      summary.update!(status: :failed)
      raise
    end
  end
end
