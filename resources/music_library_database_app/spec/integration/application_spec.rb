require 'spec_helper'
require 'rack/test'
require_relative '../../app'

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }
  let(:album_repo) { AlbumRepository.new }
  let(:artist_repo) { ArtistRepository.new }


  after(:each) do 
    expect(@response.status).to eq 200
    reset_artists_sql = File.read('spec/seeds/artists_seeds.sql')
    reset_albums_sql = File.read('spec/seeds/albums_seeds.sql')
    connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
    connection.exec(reset_albums_sql)
    connection.exec(reset_artists_sql)
  end

  context 'GET /albums' do 
    it 'should return the list of albums each in its own div' do
      albums = album_repo.all
      @response = get('/albums')
      albums.each do |album|
        expect(@response.body).to include("Title: #{album.title}", 
        "Release Year: #{album.release_year}",
        "<a href=\"/albums/#{album.id}\">Go to the album page</a>")
      end
    end
  end

  context 'POST /albums request with body params' do
    it 'returns status 200 and adds album to albums table' do
      @response = post('/albums?title=Voyage&release_year=2022&artist_id=2')
      repo = AlbumRepository.new
      expect(repo.all.last.title).to eq 'Voyage'
    end
  end

  context 'GET /artists request' do
    it "response is a HTML page of artists with 200ok status" do
      @response = get('/artists')
      artist_repo.all.each do |artist|
        expect(@response.body).to include("Name: #{artist.name}",
        "Genre: #{artist.genre}", 
        "<a href=\"/artists/#{artist.id}\">Go to the artist page</a>")
      end
    end
  end

  context "GET /hello" do
    it "returns HTML greeting page and 200 ok" do
      @response = get("/hello")
      expect(@response.body).to include "<h1>Hello!</h1>"
    end
  end

  context "GET /albums/:id" do
    it "returns HTML page with corresponding album information and 200 ok" do
      @response = get("/albums/2")
      expect(@response.body).to include("<h1>Surfer Rosa</h1>",
      "Release year: 1988", "Artist: Pixies")
    end
  end

  context "GET /artists/:id" do
    it "returns HTML page with artist info and 200ok status" do
      @response = get("/artists/2")
      expect(@response.body).to include("Name: ABBA", "Genre: Pop")
    end
  end

end
