require 'spec_helper'
require 'rack/test'
require_relative '../../app'

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  after(:each) { expect(@response.status).to eq 200 }

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

      seed_sql = File.read('spec/seeds/artists_seeds.sql')
      connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
      connection.exec(seed_sql)
    end
  end

  context "GET /hello" do
    it "returns HTML greeting page" do
      @response = get("/hello")
      expect(@response.body).to include "<h1>Hello!</h1>"
    end
  end

  context "GET /album/:id" do
    it "returns HTML page with corresponding album information" do
      @response = get("/album/2")
      expect(@response.body).to include("<h1>Surfer Rosa</h1>",
      "Release year: 1988", "Artist: Pixies")
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
