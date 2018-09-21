require 'paralleldots'
require 'awesome_print'
require 'elasticsearch'
require 'json'

class MoodAnalyzer
  def initialize
    @client = Elasticsearch::Client.new log: true
    @videos = { "Video1" => { :link => "https://google.com", :comments => ["i am happy","i am not happy","i am rather content so yeah"] },
               "Video2" => { :link => "https://reddit.com", :comments => ["i am happy","i am not happy","i am rather content so yeah"] },
               "Video3" => { :link => "https://twitter.com", :comments => ["i am happy","i am not happy","i am rather content so yeah"] }
             }
    file = File.read('input.json')
    videos = JSON.parse(file)
    @videos2 = videos["value"][0..2]
  end

  def convert_videos
    converted_hash = Hash.new { |hash,key| hash[key] = Hash.new }

    @videos2.each do |video|
      name = video["Description"]

      # print
      # ap "New video available: #{name}"
      # ap "Link: #{video["VideoUrl"]}"
      # video["CommentList"].each do |comment|
      #   ap "#{name} comment: #{comment}"
      # end
      # ap emotion(comment)

      converted_hash[name][:link] = video["VideoUrl"]
      converted_hash[name][:input] = video["CommentList"][0..9]
      # hash[name][:mood] = emotion(subhash[:comments].join(","))
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
      # @client.index index: 'mood-analyzer', type: 'my-video-mood', id: 1, body: { title: video_name, info: video_info }
    end
  end
end

analyzer = MoodAnalyzer.new
analyzer.elastic_insert
