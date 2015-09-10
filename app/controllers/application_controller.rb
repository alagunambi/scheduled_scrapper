require 'tor-privoxy'

class ApplicationController < ActionController::Base

  before_action :authenticate_admin!
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def from_haraj(schedule)
    begin
      url = URI.encode("http://haraj.com.sa/tags/" + schedule.tag.title.to_s)

      tag = Tag.find_by(:title => schedule.tag.title.to_s)

      agent = Mechanize.new

      agent = TorPrivoxy::Agent.new '127.0.0.1', '', {8118 => 9051} do |agent|
       sleep 1
      #  logger.debug "New IP is #{agent.ip}------------------------------------------------===================================================="
      #  logger.info "New IP is #{agent.ip}------------------------------------------------===================================================="
      end

      agent.user_agent_alias = Ad.random_desktop_user_agent

      #page = agent.get('http://www.amazon.in/s/ref=nb_sb_noss_1/278-0803572-2415314?url=search-alias%3Daps&field-keywords=royal+canin')
      #page = agent.get('http://www.amazon.in/s/ref=nb_sb_noss_2/277-7862435-2981953?url=search-alias%3Daps&field-keywords=bajaj&rh=i%3Aaps%2Ck%3Abajaj')

      hostname = URI.parse(url).host

      #key = Base64.strict_encode64(url)

      #Ads.where(:source => key).destroy_all

      page = agent.get(url)
    #  logger.info "New IP is #{agent.ip}------------------------------------------------===================================================="

      iterate_ads(agent, page.search("table.tableAds tr"), tag)

      pages = page.search("ul.pagination").search("li").each_with_index do |p, i|
        if i != 0
          link = p.search("a").attr("href")
          page = agent.get(link)

          iterate_ads(agent, page.search("table.tableAds tr"), tag)
        end
      end
      #
      # loop do
      #   if link = page.link_with(:dom_id => "pagnNextLink") # As long as there is still a nextpage link...
      #     page = link.click
      #   else # If no link left, then break out of loop
      #     break
      #   end
      #
      #   iterate_ads(agent, page.search("li.s-result-item"), url)
      # end
    rescue => e
      puts "Pochu da..."
      puts e
      puts e.backtrace
    end

    Ad.where(:tag_id => tag.id)
  end
end

def iterate_ads(agent, ads_list, tag)
#  key = Base64.strict_encode64(url)
  ads_list.each_with_index do |item, i|
    begin
      link = item.search("a").attr("href")
      logger.info link
      ad_page = agent.get(link)

      ad = Ad.new

      ad.link = link
      ad.ad_id = item.search("td")[0].text
      ad.title = ad_page.search("h3").text
      ad.user = ad_page.search("a.username").text
      ad.description = ad_page.search("div.ads_body").text
      ad.contact = ad_page.search("div.contact").search("a").text
      ad.tag_id = tag.id

      logger.info ad.inspect

      ad.save!
    rescue => e
      puts e
      puts e.backtrace
    end
  end
end

def generate_cron(schedule)
  d = schedule.date.to_date
  if d > Date.today
    cron = "00 09 #{Date.today.day}-#{d.day} #{Date.today.month}-#{d.month} *"
  else
    cron = "00 09 #{d.day} #{d.month} *"
  end
  puts cron
  cron
end
