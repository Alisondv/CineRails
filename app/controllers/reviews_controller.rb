# Avaliações feitas no app. Chamado pela rota POST /movies/:movie_id/reviews
# (config/routes.rb), a partir do formulário em reviews/_form.html.erb.
class ReviewsController < ApplicationController
  # POST /movies/:movie_id/reviews
  def create
    @movie = Movie.from_tmdb(tmdb.details(params[:movie_id]))

    # Cada perfil tem UMA avaliação por filme: se já existir, atualizamos.
    @review = current_profile.reviews.find_or_initialize_by(movie: @movie)
    @review.assign_attributes(review_params)

    if @review.save
      # Renderiza reviews/create.turbo_stream.erb (atualiza média, lista e formulário).
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to movie_path(@movie.tmdb_id), notice: "Avaliação salva!" }
      end
    else
      # 422 => o Turbo entende que deu erro de validação e aplica o stream com as mensagens.
      render turbo_stream: turbo_stream.replace("review_form", partial: "reviews/form",
                                                locals: { review: @review, tmdb_id: @movie.tmdb_id }),
             status: :unprocessable_entity
    end
  end

  private

  # Strong parameters de novo (ver RegistrationsController#registration_params
  # pra explicação completa): só deixamos passar os campos esperados do
  # formulário, nunca profile_id ou movie_id vindos do próprio usuário.
  def review_params
    params.expect(review: [ :rating, :comment ])
  end
end
