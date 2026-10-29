# GET /busca?q=matrix
class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @movies = tmdb.search(@query)
  end
end
