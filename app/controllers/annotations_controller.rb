class AnnotationsController < ApplicationController
  before_action :set_paper

  def index
    render json: @paper.annotations.order(:page, :created_at)
  end

  def create
    annotation = @paper.annotations.build(annotation_params)
    if annotation.save
      render json: annotation, status: :created
    else
      render json: { errors: annotation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    annotation = @paper.annotations.find(params[:id])
    if annotation.update(annotation_params)
      render json: annotation
    else
      render json: { errors: annotation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @paper.annotations.find(params[:id]).destroy
    head :no_content
  end

  private

  def set_paper
    @paper = Paper.find(params[:paper_id])
  end

  def annotation_params
    params.require(:annotation).permit(:page, :start_offset, :end_offset, :selected_text, :color, :note)
  end
end
