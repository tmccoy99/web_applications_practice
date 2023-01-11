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
      response = get('/albums')
      albums.each do |record|
        expect(response.body).to include("Title: #{record.title}", "Release Year: #{record.release_year}")
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

  context 'GET /artist request' do
    it 'return 200 ok and a list of artists names' do
      @response = get('/artists')
      expect(@response.body).to eq 'Pixies, ABBA, Taylor Swift, Nina Simone'
    end
  end

  context "POST /artists with body parameters" do
    it "returns 200 ok and inserts artist into database" do
      @response = post("/artists", name: "Wild Nothing",
      genre: "Indie")
      expect(get("/artists").body).to eq 'Pixies, ABBA, Taylor Swift, Nina Simone, Wild Nothing'

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

  context "GET /albums" do
    it "returns HTML page of all albums in database and 200 ok" do
      @response = get("/albums")
      repo = AlbumRepository.new
      repo.all.each do |album|
        expect(@response.body).to include("Title: #{album.title}", 
        "Released: #{album.release_year}")
      end
      expect(@response.body).to include "<h1>Albums</h1>"
    end
  end



  #   # Request:
  # POST /albums

  # # With body parameters:
  # title=Voyage
  # release_year=2022
  # artist_id=2

  # # Expected @response (200 OK)
  # (No content)
end
