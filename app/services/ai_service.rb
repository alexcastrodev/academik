class AiService
  class ConnectionError < StandardError; end

  def self.generate(prompt:)
    new.generate(prompt: prompt)
  end

  def generate(prompt:)
    case provider
    when "claude" then generate_claude(prompt)
    else               generate_ollama(prompt)
    end
  end

  def provider
    AppSetting.get("ai_provider") || "ollama"
  end

  def model_label
    case provider
    when "claude"
      AppSetting.get("claude_model") || "claude-sonnet-4-6"
    else
      AppSetting.get("ollama_model") || "llama3.2"
    end
  end

  private

  def generate_claude(prompt)
    api_key = AppSetting.get("claude_api_key").presence
    raise ConnectionError, "Claude API key not configured" unless api_key

    model = AppSetting.get("claude_model") || "claude-sonnet-4-6"
    client = Anthropic::Client.new(api_key: api_key)

    message = client.messages.create(
      model: model,
      max_tokens: 4096,
      messages: [ { role: "user", content: prompt } ]
    )

    message.content.first.text
  rescue Anthropic::Error => e
    raise ConnectionError, e.message
  end

  def generate_ollama(prompt)
    OllamaService.new.generate(prompt: prompt)
  rescue OllamaService::ConnectionError => e
    raise ConnectionError, e.message
  end
end
