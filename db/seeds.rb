AppSetting.find_or_create_by!(key: "ollama_model").update!(value: "llama3.2")
AppSetting.find_or_create_by!(key: "ollama_endpoint").update!(value: "http://localhost:11434/api/generate")
