Rails.application.routes.draw do
  # Model Context Protocol
  post "/mcp", to: "mcp#handle"
  get  "/mcp", to: "mcp#handle"

  root "papers#index"

  resources :papers do
    collection do
      get :resolve_doi
    end
    member do
      post :summarize
      get  :latex_preview
      get  :pdf_viewer
    end
    resources :summaries, only: %i[index show destroy]
    resources :annotations, only: %i[index create update destroy]
  end

  resources :collections do
    member do
      post :generate_latex
    end
  end

  resources :tags
  resources :latex_documents do
    member do
      get :download
    end
  end
  resource :settings, only: %i[show update]

  get "up" => "rails/health#show", as: :rails_health_check
end
