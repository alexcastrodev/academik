class PapersController < ApplicationController
  before_action :set_paper, only: %i[show edit update destroy summarize latex_preview pdf_viewer]

  def index
    @papers = Paper.all.includes(:tags, :collections)
    @papers = @papers.by_status(params[:reading_status]) if params[:reading_status].present?
    @papers = @papers.search(params[:q]) if params[:q].present?
    if params[:collection_id].present?
      collection = Collection.find(params[:collection_id])
      @papers = @papers.where(id: collection.paper_ids)
    end
    @papers = @papers.joins(:paper_tags).where(paper_tags: { tag_id: params[:tag_id] }) if params[:tag_id].present?
    @papers = @papers.order(created_at: :desc)

    @collections = Collection.roots.includes(:children)
    @tags = Tag.all
  end

  def show
    @collections = Collection.all
    @tags = Tag.all
  end

  def new
    @paper = Paper.new
    @collections = Collection.all
    @tags = Tag.all
  end

  def edit
    @collections = Collection.all
    @tags = Tag.all
  end

  def create
    resolved  = nil
    pdf_url   = nil
    doi_attrs = {}
    if params.dig(:paper, :doi_input).present?
      resolved  = DoiResolverService.new(params[:paper][:doi_input]).resolve
      pdf_url   = resolved&.delete(:pdf_url)
      doi_attrs = resolved || {}
    end

    pdf_file = params.dig(:paper, :pdf)
    @paper = Paper.new(paper_params.except(:doi_input, :pdf).merge(doi_attrs))

    if @paper.save
      if pdf_file.present?
        attach_pdf_and_enqueue(pdf_file)
      elsif pdf_url.present?
        PdfDownloadJob.perform_later(@paper.id, pdf_url)
      end
      redirect_to @paper, notice: "Paper added successfully."
    else
      @collections = Collection.all
      @tags = Tag.all
      render :new, status: :unprocessable_entity
    end
  end

  def update
    pdf_file = params.dig(:paper, :pdf)
    if @paper.update(paper_params.except(:doi_input, :pdf))
      attach_pdf_and_enqueue(pdf_file)
      redirect_to @paper, notice: "Paper updated."
    else
      @collections = Collection.all
      @tags = Tag.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @paper.destroy
    redirect_to papers_path, notice: "Paper deleted."
  end

  def summarize
    if @paper.extracted_text.blank?
      redirect_to @paper, alert: "Extract text from the PDF first."
      return
    end

    OllamaSummarizeJob.perform_later(@paper.id)
    redirect_to @paper, notice: "Summary generation started."
  end

  def pdf_viewer
    redirect_to @paper, alert: "No PDF attached." unless @paper.pdf.attached?
  end

  def resolve_doi
    input = params[:input].to_s.strip
    result = input.present? ? DoiResolverService.new(input).resolve : nil
    render json: result || {}
  end

  def latex_preview
    @latex_content = LatexTemplateBuilder.new(@paper).build
    render layout: false
  end

  private

  def set_paper
    @paper = Paper.find(params[:id])
  end

  def paper_params
    params.require(:paper).permit(
      :title, :authors, :year, :journal, :doi, :abstract,
      :reading_status, :rating, :notes, :doi_input,
      collection_ids: [], tag_ids: []
    )
  end

  def attach_pdf_and_enqueue(pdf_file)
    return if pdf_file.blank?
    @paper.pdf.attach(pdf_file)
    PdfImportJob.perform_later(@paper.id)
  end
end
