require 'spec_helper'

describe FriendRequest do 

  it 'should require a url' do
    friend_request = FriendRequest.new
    friend_request.valid?.should be false
    friend_request.url = "http://google.com/"
    friend_request.valid?.should be true
  end

  it 'should generate xml for the User as a Friend' do 
    friend_request = FriendRequest.new(:url => "http://www.google.com")
    user = Factory.create(:user)
    friend_request.sender = user
    friend_xml = friend_request.to_friend_xml.to_s
    friend_xml.include?(user.email).should be true
    friend_xml.include?(user.url).should be true
    friend_xml.include?(user.profile.first_name).should be true
    friend_xml.include?(user.profile.last_name).should be true
  end

  it 'should be sent to the url upon for action' do
    FriendRequest.send(:class_variable_get, :@@queue).should_receive(:add_post_request)
    Factory.create(:user)
    FriendRequest.for("http://www.google.com")
  end

  it "should activate a friend if it exists on creation of a request for that url" do
    user = Factory.create(:user)
    friend = Factory.create(:friend, :url => "http://google.com/")
    FriendRequest.create(:url => friend.url, :sender => user)
    Friend.first.active.should be true
  end

end
