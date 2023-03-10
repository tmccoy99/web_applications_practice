require 'spec_helper'
require 'rack/test'
require_relative '../../app'

describe "Application testing for 200 ok responses" do
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
      expect(album_repo.all.last.title).to eq 'Voyage'
      expect(@response.body).to include("<h1>Success</h1>",
      "Voyage has been added to the database!")
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

  context "GET /albums/new" do
    it "returns the form page and 200ok status" do
      @response = get("/albums/new")
      expect(@response.body).to include("<h1>Add an Album</h1>",
      "<input type=\"text\" name=\"title\"",
      "<input type=\"text\" name=\"release_year\">",
      "<input type=\"submit\" value=\"Submit the form\">")
    end
  end

  context "GET /artists/new" do
    it "returns the form page and 200ok status" do
      @response = get("/artists/new")
      expect(@response.body).to include("<h1>Add an Artist</h1>",
      "<input type=\"text\" name=\"name\"",
      "<input type=\"text\" name=\"genre\">",
      "<input type=\"submit\" value=\"Submit the form\">")
    end
  end

  context "POST /artists with valid body params" do
    it "Adds artist to database and returns HTML confirmation" do
      @response = post("/artists", name: "Arctic Monkeys",
      genre: "Alternative")
      expect(artist_repo.find(5).name).to eq "Arctic Monkeys"
      expect(@response.body).to include("<h1>Success</h1>",
      "Arctic Monkeys has been added to the database!")
    end
  end

end

describe "Application testing for other response codes" do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }
  let(:album_repo) { AlbumRepository.new }
  let(:artist_repo) { ArtistRepository.new }


  after(:each) do 
    reset_artists_sql = File.read('spec/seeds/artists_seeds.sql')
    reset_albums_sql = File.read('spec/seeds/albums_seeds.sql')
    connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
    connection.exec(reset_albums_sql)
    connection.exec(reset_artists_sql)
  end

  context "POST /albums request with invalid body parameters" do
    it "response has status 400 and empty body" do
      response = post("/albums", title: "Hello")
      expect(response.status).to eq 400
      expect(response.body).to eq ""
    end
  end

  context "POST /artists request with invalid body parameters" do
    it "response has status 400 and empty body" do
      response = post("/artists", genre: "METAL BRO")
      expect(response.status).to eq 400
      expect(response.body).to eq ""
    end
  end

end
