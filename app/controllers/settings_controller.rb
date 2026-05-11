class SettingsController < ApplicationController
  def show
    @ai_provider     = AppSetting.get("ai_provider")      || "ollama"
    @ollama_model    = AppSetting.get("ollama_model")      || "llama3.2"
    @ollama_endpoint = AppSetting.get("ollama_endpoint")   || "http://localhost:11434/api/generate"
    @claude_api_key  = AppSetting.get("claude_api_key")    || ""
    @claude_model    = AppSetting.get("claude_model")      || "claude-sonnet-4-6"
    @available_models = fetch_ollama_models(@ollama_endpoint)
  end

  def update
    %w[ai_provider ollama_model ollama_endpoint claude_model].each do |key|
      next unless params.dig(:settings, key)
      AppSetting.set(key, params[:settings][key].to_s.strip)
    end
    # Only update API key if a real value was submitted (not the masked placeholder)
    if (key = params.dig(:settings, :claude_api_key).to_s.strip).present? && !key.start_with?("•")
      AppSetting.set("claude_api_key", key)
    end
    redirect_to settings_path, notice: "Settings saved."
  end

  private

  def fetch_ollama_models(endpoint)
    base = URI.parse(endpoint).then { |u| "#{u.scheme}://#{u.host}:#{u.port}" }
    conn = Faraday.new(url: base)
    resp = conn.get("/api/tags")
    return [] unless resp.success?
    JSON.parse(resp.body).fetch("models", []).map { |m| m["name"] }.sort
  rescue StandardError
    []
  end
end
