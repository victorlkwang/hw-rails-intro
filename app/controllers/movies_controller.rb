class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show edit update destroy ]

  # GET /movies or /movies.json

  def index
    @all_ratings = Movie.all_ratings

    # Determine which ratings to display.
    if params[:ratings].present?
      @ratings_to_show =
        params[:ratings].keys & @all_ratings

    elsif params.key?(:commit)
      # Refresh was clicked with no ratings checked.
      @ratings_to_show = @all_ratings

    else
      # Restore previously selected ratings.
      @ratings_to_show =
        session[:ratings] || @all_ratings
    end

    # Determine how to sort movies.
    allowed_sorts = ['title', 'release_date']

    requested_sort =
      params[:sort_by].presence || session[:sort_by]

    @sort_by = allowed_sorts.include?(requested_sort) ?
      requested_sort : 'title'

    # Remember the settings for future requests.
    session[:ratings] = @ratings_to_show
    session[:sort_by] = @sort_by

    # Retrieve matching movies in the right order.
    @movies = Movie.with_ratings(@ratings_to_show)
                  .order(@sort_by)
  end

  # GET /movies/1 or /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies or /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Movie was successfully created." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1 or /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Movie was successfully updated." }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1 or /movies/1.json
  def destroy
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, status: :see_other, notice: "Movie was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end
