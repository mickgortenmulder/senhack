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

    @videos2.each do |video|
      name = video["Title"]

      # print
      # ap "New video available: #{name}"
      # ap "Link: #{video["VideoUrl"]}"
      # video["CommentList"].each do |comment|
      #   ap "#{name} comment: #{comment}"
      # end
      # ap emotion(comment)

      next if video["CommentList"].nil?

      converted_hash[name][:description] = video["Description"]
      converted_hash[name][:link] = video["VideoUrl"]
      converted_hash[name][:input] = video["CommentList"][0..9]
      # converted_hash[name][:mood] = emotion(subhash[:comments].join(","))
      converted_hash[name][:mood] = "test"
      converted_hash[name][:converted_time] = Time.now
    end

    converted_hash
  end

  def elastic_insert
    mood_hash = convert_videos

    mood_hash.each do |video_name,video_info|
      puts video_name
      puts video_info
      @client.index index: 'mood-analyzer', type: 'my-video-mood', id: 1, body: { title: video_name, description: video_info[:description], link: video_info[:link], input: video_info[:input], mood: video_info[:mood], converted_time: video_info[:converted_time] }
    end
  end
end

analyzer = MoodAnalyzer.new
analyzer.elastic_insert
