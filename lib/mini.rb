#!/usr/bin/env ruby
require 'rails'
require 'excon'
require 'nokogiri'
Cache=ActiveSupport::Cache::FileStore.new("tmp")
body=Cache.fetch("req", :expires_in => 60) { Excon.get("https://old.a101.ru/projects/moskva-a101/kupit/parkovochnyie-mesta").body }
hold=free=0; Nokogiri::HTML(body).css("div.park-place").each{|x| if x['class'].to_s =~ /hold-place/ then hold+=1 else free+=1 end }
printf "Статистика заполнения паркинга на основе сайта a101 от #{Time.new.strftime("%d.%m.%Y")} - %5.2f%%:\n", hold/(free+hold).to_f*100
puts "Всего - #{free+hold}\nСвободно - #{free}\nЗанято - #{hold}"
