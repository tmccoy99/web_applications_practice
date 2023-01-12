# file: app.rb
require 'sinatra'
require 'sinatra/reloader'
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

  def initialize
    super
    @artist_repo, @album_repo = ArtistRepository.new, AlbumRepository.new
  end

  get '/albums' do
    @albums = @album_repo.all
    erb(:albums)
  end

  post '/albums' do
    @album = Album.new
    album_attributes = [params[:title],
    params[:release_year], 
    params[:artist_id]]
    if album_attributes.any?(&:nil?)
      status 400
      return ""
    end
    @album.title, @album.release_year, @album.artist_id = album_attributes
    @album_repo.create(@album)
    erb(:created_album)
  end

  get '/artists' do
    @artists = @artist_repo.all
    erb(:artists)
  end

  post '/artists' do
    @artist = Artist.new
    @artist.name, @artist.genre = params[:name], params[:genre]
    if @artist.name.nil? || @artist.genre.nil?
      status 400
      return ""
    end
    @artist_repo.create(@artist)
    erb(:created_artist)
  end

  get "/hello" do
    erb(:hello)
  end

  get "/albums/new" do
    erb(:new_album)
  end

  get "/albums/:id" do
    @album = @album_repo.find(params[:id])
    @artist = @artist_repo.find(@album.artist_id)
    erb(:album)
  end

  get "/artists/new" do
    erb(:new_artist)
  end

  get "/artists/:id" do
    @artist = @artist_repo.find(params[:id])
    erb(:artist)
  end
end
