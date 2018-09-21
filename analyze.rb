require 'paralleldots'
require 'awesome_print'
require 'elasticsearch'
require 'json'

class MoodAnalyzer
  def initialize
    @client = Elasticsearch::Client.new log: true
    file = File.read('input.json')
    videos = JSON.parse(file)
    @videos2 = videos
  end

  def convert_videos
    converted_hash = Hash.new { |hash,key| hash[key] = Hash.new }

    @videos2.first(10).each do |video|
      name = video["Title"]

      # print
      # ap "New video available: #{name}"
      # ap "Link: #{video["VideoUrl"]}"
      # video["CommentList"].each do |comment|
      #   ap "#{name} comment: #{comment}"
      # end
      # ap emotion(comment)

      next if video["CommentList"].nil?

      converted_hash[name][:link] = video["VideoUrl"]
      # converted_hash[name][:input] = video["CommentList"].first(5)
      converted_hash[name][:mood] = emotion(video["CommentList"].first(5))
      # converted_hash[name][:mood] = "test"
    end

    converted_hash
  end

  def elastic_insert
    mood_hash = convert_videos

    mood_hash.each do |video_name,video_info|
      puts video_name
      puts video_info
      @client.index index: 'mood-analyzer', type: 'my-video-mood', body: { title: video_name, link: video_info[:link], mood: video_info[:mood] }
    end
  end
end

analyzer = MoodAnalyzer.new
analyzer.elastic_insert
