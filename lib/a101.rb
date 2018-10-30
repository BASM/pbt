#!/usr/bin/env ruby
#
#
require 'rails'
require 'excon'
require 'nokogiri'

Excon.ssl_verify_peer = false
Cache=ActiveSupport::Cache::FileStore.new("tmp")
def GET(uri)
	res=Cache.fetch(uri, :expires_in => 60) {
		puts "REAL GET: #{uri}..."
		r=Excon.get(uri)
		r.body
	}
	res 
end
#body=GET("https://old.a101.ru/projects/moskva-a101/kupit/parkovochnyie-mesta") # old site
body=GET("https://a101.ru/projects/moskva-a101/building/226/parking/#genplan")
b=Nokogiri::HTML(body)

hold=0
free=0
total=0
reserve=0
b.css("g.parkplace").each{|x|
  if x.to_s =~ /fill="rgba/
    if x.to_s =~ /rgba\(230/
          hold+=1
    else  reserve+=1
    end
	else    free+=1
	end
	total+=1
}

printf "Статистика заполнения паркинга на основе сайта a101 от #{Time.new.strftime("%d.%m.%Y")} - %5.2f%%:\n", hold/total.to_f*100
puts "Всего - #{total}"
puts "Свободно - #{free}"
puts "В резерве - #{reserve}"
puts "Занято - #{hold}"
