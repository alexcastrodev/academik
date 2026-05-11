class CollectionsController < ApplicationController
  before_action :set_collection, only: %i[show edit update destroy generate_latex]

  def index
    @collections = Collection.roots.includes(:children, :papers)
  end

  def show
    @papers = @collection.papers.includes(:tags)
  end

  def new
    @collection = Collection.new
    @parent_collections = Collection.all
  end

  def edit
    @parent_collections = Collection.all.where.not(id: @collection.id)
  end

  def create
    @collection = Collection.new(collection_params)
    if @collection.save
      redirect_to @collection, notice: "Collection created."
    else
      @parent_collections = Collection.all
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @collection.update(collection_params)
      redirect_to @collection, notice: "Collection updated."
    else
      @parent_collections = Collection.all.where.not(id: @collection.id)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collection.destroy
    redirect_to collections_path, notice: "Collection deleted."
  end

  def generate_latex
    LatexGeneratorJob.perform_later(@collection.id)
    redirect_to @collection, notice: "LaTeX generation started. Check LaTeX Documents when complete."
  end

  private

  def set_collection
    @collection = Collection.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(:name, :description, :parent_id)
  end
end
