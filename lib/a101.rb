#!/usr/bin/env ruby
#
#
require 'rails'
require 'excon'
require 'nokogiri'

Cache=ActiveSupport::Cache::FileStore.new("tmp")
def GET(uri)
	res=Cache.fetch(uri, :expires_in => 60) {
		puts "REAL GET: #{uri}..."
		r=Excon.get(uri)
		r.body
	}
	res 
end
body=GET("https://old.a101.ru/projects/moskva-a101/kupit/parkovochnyie-mesta")
b=Nokogiri::HTML(body)

hold=0
free=0
total=0
b.css("div.park-place").each{|x|
	if x['class'].to_s =~ /hold-place/
		hold+=1
	else
		free+=1
	end
	total+=1
}

printf "Статистика заполнения паркинга на основе сайта a101 от #{Time.new.strftime("%d.%m.%Y")} - %5.2f%%:\n", hold/total.to_f*100
puts "Всего - #{total}"
puts "Свободно - #{free}"
puts "Занято - #{hold}"
