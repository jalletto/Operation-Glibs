require 'net/http'
require 'json'

module AnalyzableHelper

  def self.picling(user_url)
      pic_data_set = self.pic_call(user_url)
      pulled_tags = [pic_data_set[0]]
      pulled_caption = [pic_data_set[1]]
      pulled_POS = self.ling_call(pulled_tags)
      return [pulled_caption, pulled_tags, pulled_POS]
  end


private
  def self.pic_call(user_url)
    uri = URI('https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/analyze')
    uri.query = URI.encode_www_form({
      'visualFeatures' => 'Description',
      'language' => 'en'
    })

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    request['Ocp-Apim-Subscription-Key'] = ENV['Ocp_Apim_Subscription_Key']
    request.body = "{'url': '#{user_url}' }"

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
    end

    # puts response.body
    photo_data = JSON.parse(response.body)
    tags = photo_data["description"]["tags"]
    caption = photo_data["description"]["captions"][0]["text"]
    all_pic_data = [tags, caption]
    return all_pic_data

  end

  def self.ling_call(word_array)
    word_string = word_array.join(" ")
    uri = URI('https://westus.api.cognitive.microsoft.com/linguistics/v1.0/analyze')
    uri.query = URI.encode_www_form({
        # 'visualFeatures' => 'Description',
        # 'language' => 'en'
    })

      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      request['Ocp-Apim-Subscription-Key'] = ENV['Ocp_Apim_Ling_Key']
      request.body = "{
        'language': 'en',
      	'analyzerIds': ['4fa79af1-f22c-408d-98bb-b7d7aeef7f04', '22a6b758-420f-4745-8a3c-46835a67c0d2'],
      	'text': '#{word_string}'
      }"

      response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          http.request(request)
      end

    # puts response.body
    ling_data = JSON.parse(response.body)
    word_pos = ling_data[0]["result"]
    return word_pos.flatten
  end
end