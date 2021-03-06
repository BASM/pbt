#!/usr/bin/env ruby
#
#
require 'rails'
require 'excon'
require 'nokogiri'

Excon.ssl_verify_peer = false
Cache=ActiveSupport::Cache::FileStore.new("tmp")
def GET(uri)
	res=Cache.fetch(uri, :expires_in => 600) {
		puts "REAL GET: #{uri}..."
		r=Excon.get(uri)
		r.body
	}
	res 
end
#body=GET("https://old.a101.ru/projects/moskva-a101/kupit/parkovochnyie-mesta") # old site
body=GET("https://a101.ru/projects/moskva-a101/building/226/parking/#genplan")
b=Nokogiri::HTML(body)

#File.open("x", "w+").write(body.force_encoding("UTF-8"))

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

floornames=[]
# Смотрим сколько этажей отображено на сайте и записываем размер корректировки и названия этажей 
floorselllist=1210 - b.css("div.js-parking-page-floor-btn").map{|x|
	num=x.attr('data-floor').to_i
	floornames+=[num]
	case num
	when 1 then    152
	when 2..6 then 175
	when 7 then    183
	end
}.inject(0,:+) #fucking ".sum" isn't works everywere
# Корректировка из-за пропадания на сайте проданных этажей
hold+=floorselllist
total+=floorselllist

raise "Неверное кол-во мест, должно быть #{1210} а мы насчитали #{total}" if total!=1210

printf "Статистика заполнения паркинга на основе сайта a101 от #{Time.new.strftime("%d.%m.%Y")} - %5.2f%%:\n", hold/total.to_f*100
puts "Всего - #{total}"
puts "Свободно - #{free}"
puts "В резерве - #{reserve}"
puts "Занято - #{hold}"

####################3
puts ""
puts "Обзор по ценам"
levels=[]
b.css("div.complex-detail-visual__tooltips").each{|x|
  placeinfo=[]
  x.css("div.no-anim").each{|y|
    num   =y.children[1].text.sub(/[^0-9]*/,'')#.scan(/[0-9-]*/)[0]
    price = y.children.css("div.fs-14").text.gsub(/[^0-9]/,'').to_i/1000
    placeinfo+=[[num,price]]
  }
  levels+=[placeinfo]
}
totalfree=0
#requi=40 #раньше было
requi=10 # говорят сейчас так
levels.to_enum.with_index(1).each{|level,num|
  price=0
  pnum=0
  total=0
  price_max=0
  price_min=2000
  level.each{|place|
    p=place[1]
    if p != 0
      pnum+=1
      price+=p
      price_min=p if p < price_min
      price_max=p if p > price_max
    end
    total+=1
  }
  break if pnum==0
  price_m=price/pnum
  puts "Этаж #{floornames[num-1]}: в продаже #{pnum}/#{total}, цена #{price_min}-#{price_max} (#{price_min+requi}-#{price_max+requi}) (в среднем #{price_m}, #{price_m+requi})"
  totalfree+=pnum
}
puts "В скобках указаны реальные цены, с учётом обязательного взоса #{requi} т.р."
raise "Кол-во свободных мест не сходится #{totalfree} != #{free+reserve}" if totalfree!=(free+reserve)
