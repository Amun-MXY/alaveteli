# == Schema Information
# Schema version: 20210114161442
#
# Table name: track_things
#
#  id               :integer          not null, primary key
#  tracking_user_id :integer          not null
#  track_query      :string(500)      not null
#  info_request_id  :integer
#  tracked_user_id  :integer
#  public_body_id   :integer
#  track_medium     :string           not null
#  track_type       :string           default("internal_error"), not null
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'

RSpec.describe TrackThing, "when tracking changes" do

  before do
    @track_thing = track_things(:track_fancy_dog_search)
  end

  it "requires a type" do
    @track_thing.track_type = nil
    @track_thing.valid?
    expect(@track_thing.errors[:track_type].size).to eq(2)
  end

  it "requires a valid type" do
    @track_thing.track_type = 'gibberish'
    @track_thing.valid?
    expect(@track_thing.errors[:track_type].size).to eq(1)
  end

  it "requires a valid medium" do
    @track_thing.track_medium = 'pigeon'
    @track_thing.valid?
    expect(@track_thing.errors[:track_medium].size).to eq(1)
  end

  it "will find existing tracks which are the same" do
    track_thing = TrackThing.create_track_for_search_query('fancy dog')
    found_track = TrackThing.find_existing(users(:silly_name_user), track_thing)
    expect(found_track).to eq(@track_thing)
  end

  it "can display the description of a deleted track_thing" do
    track_thing = TrackThing.create_track_for_search_query('fancy dog')
    description = track_thing.track_query_description
    track_thing.destroy
    expect(track_thing.track_query_description).to eq(description)
  end

  it "will make some sane descriptions of search-based tracks" do
    tests = { ' (variety:sent OR variety:followup_sent OR variety:response OR variety:comment)' => 'all requests or comments',
              'bob (variety:sent OR variety:followup_sent OR variety:response OR variety:comment)' => "all requests or comments matching text 'bob'",
              'bob (latest_status:successful OR latest_status:partially_successful)' => "requests which are successful matching text 'bob'",
              '(latest_status:successful OR latest_status:partially_successful)' => 'requests which are successful',
              'bob' => "anything matching text 'bob'" }
    tests.each do |query, description|
      track_thing = TrackThing.create_track_for_search_query(query)
      expect(track_thing.track_query_description).to eq(description)
    end
  end

  it "will create an authority-based track when called using a 'bodies' postfix" do
    track_thing = TrackThing.create_track_for_search_query('fancy dog', 'bodies')
    expect(track_thing.track_query).to match(/variety:authority/)
  end

  it "will check that the query isn't too long to store" do
    long_query = "Lorem ipsum " * 42 # 504 chars
    track_thing = TrackThing.create_track_for_search_query(long_query)
    track_thing.valid?
    expect(track_thing.errors[:track_query][0]).to eq("Query is too long")
  end
end

RSpec.describe TrackThing, "destroy" do
  let(:track_thing) { FactoryBot.create(:search_track) }

  it "should destroy the track_thing" do
    track_thing.destroy
    expect(TrackThing.where(id: track_thing.id)).to be_empty
  end

  it "should destroy related track_things_sent_emails" do
    TrackThingsSentEmail.create(track_thing: track_thing)
    track_thing.destroy
    expect(TrackThingsSentEmail.where(track_thing_id: track_thing.id)).to be_empty
  end
end
