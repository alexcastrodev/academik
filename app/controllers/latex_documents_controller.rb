class LatexDocumentsController < ApplicationController
  before_action :set_document, only: %i[show edit update destroy download]

  def index
    @documents = LatexDocument.all.order(created_at: :desc)
  end

  def show; end

  def new
    @document = LatexDocument.new(generation_type: :manual)
    @papers = Paper.all
  end

  def edit
    @papers = Paper.all
  end

  def create
    @document = LatexDocument.new(document_params)
    if @document.save
      redirect_to @document, notice: "Document created."
    else
      @papers = Paper.all
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @document.update(document_params)
      redirect_to @document, notice: "Document saved."
    else
      @papers = Paper.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @document.destroy
    redirect_to latex_documents_path, notice: "Document deleted."
  end

  def download
    send_data @document.content.to_s,
      filename: "#{@document.title.parameterize}.tex",
      type: "text/plain",
      disposition: "attachment"
  end

  private

  def set_document
    @document = LatexDocument.find(params[:id])
  end

  def document_params
    params.require(:latex_document).permit(:title, :content, :generation_type, :sourceable_type, :sourceable_id)
  end
end
