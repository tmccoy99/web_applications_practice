require "spec_helper"
require "rack/test"
require_relative '../../app'

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  after(:each) do
    expect(@request.status).to eq 200
  end

  context "POST /albums request with body params" do
    it "returns status 200 and adds album to albums table" do
      @request = post("/albums?title=Voyage&release_year=2022&artist_id=2")
      repo = AlbumRepository.new
      expect(repo.all.last.title).to eq  "Voyage"
    end
  end

#   # Request:
# POST /albums

# # With body parameters:
# title=Voyage
# release_year=2022
# artist_id=2

# # Expected response (200 OK)
# (No content)
end
