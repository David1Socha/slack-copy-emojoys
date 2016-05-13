require 'nokogiri'
require 'rest-client'
require 'open-uri'
#by default (at least on windows) ruby doesn't install the ssl cert file, follow https://gist.github.com/fnichol/867550 if needed

team_name = ARGV[0]
cookie = ARGV[1]

IMG_FOLDER = "img"
Dir.mkdir IMG_FOLDER if !Dir.exist? IMG_FOLDER

resp = RestClient.get("https://#{team_name}.slack.com/customize/emoji", Cookie: cookie)
html = Nokogiri::HTML(resp)

emojoy_regex = /https:\/\/.*(\/.*\/).*(png|jpg|gif)/
emojoy_links = html.css('span.lazy.emoji-wrapper').map {|s| s['data-original'] }
emojoy_names = emojoy_links.map {|l| emojoy_regex.match(l)[1][1...-1] }
emojoy_formats = emojoy_links.map {|l| emojoy_regex.match(l)[2] }

emojoys = Array.new
emojoy_links.each_index do |i|
  filename = "#{IMG_FOLDER}/#{emojoy_names[i]}.#{emojoy_formats[i]}"
  IO.copy_stream(open(emojoy_links[i]), filename)
  emojoys << {name: emojoy_names[i], link: emojoy_links[i], local: filename}
end

File.open("emojoys.txt", "w+") {|file| file.puts emojoys}