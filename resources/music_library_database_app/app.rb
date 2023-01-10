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

  post '/albums' do
    album = Album.new
    album.title, album.release_year, album.artist_id =
      params[:title],
      params[:release_year],
      params[:artist_id]
    repo = AlbumRepository.new
    repo.create(album)
  end

  get '/artists' do
    repo = ArtistRepository.new
    repo.all.map(&:name).join(', ')
  end

  post '/artists' do
    artist = Artist.new
    artist.genre, artist.name = params[:genre], params[:name]
    repo = ArtistRepository.new
    repo.create(artist)
  end

  get "/hello" do
    erb(:hello)
  end

  get "/album/:id" do
    album_repo = AlbumRepository.new ; artist_repo = ArtistRepository.new
    @album = album_repo.find(params[:id])
    @artist = artist_repo.find(@album.artist_id)
    erb(:album)
  end
end
