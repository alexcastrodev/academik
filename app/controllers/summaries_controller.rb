class SummariesController < ApplicationController
  before_action :set_paper

  def index
    @summaries = @paper.summaries.order(created_at: :desc)
  end

  def show
    @summary = @paper.summaries.find(params[:id])
  end

  def destroy
    @summary = @paper.summaries.find(params[:id])
    @summary.destroy
    redirect_to paper_summaries_path(@paper), notice: "Summary deleted."
  end

  private

  def set_paper
    @paper = Paper.find(params[:paper_id])
  end
end
