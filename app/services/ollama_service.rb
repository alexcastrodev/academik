class OllamaService
  class ConnectionError < StandardError; end

  TIMEOUT = 300

  def initialize
    endpoint = AppSetting.get("ollama_endpoint") || "http://localhost:11434/api/generate"
    @conn = Faraday.new(url: endpoint) do |f|
      f.options.open_timeout = 10
      f.options.timeout = TIMEOUT
      f.adapter Faraday.default_adapter
    end
    @model = AppSetting.get("ollama_model") || "llama3.2"
  end

  def generate(prompt:, model: nil)
    response = @conn.post("") do |req|
      req.headers["Content-Type"] = "application/json"
      req.body = JSON.generate(model: model || @model, prompt: prompt, stream: false)
    end

    raise ConnectionError, "Ollama returned #{response.status}" unless response.success?

    JSON.parse(response.body)["response"]
  rescue Faraday::Error => e
    raise ConnectionError, e.message
  end
end
