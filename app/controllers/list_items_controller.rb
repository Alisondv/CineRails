# "Minha Lista" do perfil atual.
class ListItemsController < ApplicationController
  # GET /minha-lista
  def index
    # has_many :through em ação: current_profile.movies faz o JOIN com list_items.
    @movies = current_profile.movies.order("list_items.created_at DESC")
  end

  # POST /movies/:movie_id/list_item
  def create
    # Só agora o filme vira registro no nosso banco (cache local mínimo).
    @movie = Movie.from_tmdb(tmdb.details(params[:movie_id]))
    current_profile.list_items.find_or_create_by!(movie: @movie)
    respond_to_list_change
  end

  # DELETE /movies/:movie_id/list_item
  def destroy
    @movie = Movie.find_by!(tmdb_id: params[:movie_id])
    current_profile.list_items.where(movie: @movie).destroy_all
    respond_to_list_change
  end

  private

  # respond_to escolhe a resposta pelo formato que o navegador pediu:
  # - turbo_stream: o Turbo enviou o form via fetch e aceita "pedaços" de HTML.
  #   O Rails renderiza create/destroy.turbo_stream.erb e só o botão muda na tela.
  # - html: navegador sem JavaScript => volta para a página anterior (recarrega).
  def respond_to_list_change
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: movie_path(@movie.tmdb_id) }
    end
  end
end
