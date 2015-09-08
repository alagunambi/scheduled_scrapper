class Puller
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  unique_args: ->(args) { [ args.first ] }


  def perform(*args)
    logger.info args.first["schedule"]
    logger.info "Arguments visible or not?"
    schedule = Schedule.find(args.first["schedule"])
    @ads = from_haraj(schedule)
    if @ads.count > 1
      schedule.status = 1
    else
      schedule.status = 2
    end
    schedule.save!
  end

  def from_haraj(schedule)
    url = URI.encode(schedule.tag.title.to_s)

    tag = schedule.tag

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

    begin
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


  def iterate_ads(agent, ads_list, tag)
  #  key = Base64.strict_encode64(url)
    ads_list.each_with_index do |item, i|
      begin
        if ad = Ad.find_by(:ad_id => item.search("td")[0].text.squish)
          logger.info ad.inspect
        else
          link = item.search("a").attr("href")
          logger.info link
          ad_page = agent.get(link)

          ad = Ad.new

          ad.link = link
          ad.ad_id = item.search("td")[0].text.squish
          ad.title = ad_page.search("h3").text.squish
          ad.user = ad_page.search("a.username").text.squish
          ad.description = ad_page.search("div.ads_body").text.squish
          ad.contact = ad_page.search("div.contact").search("a").text.squish
          ad.tag_id = tag.id

          logger.info ad.inspect

          ad.save!
        end
      rescue => e
        puts "SSSSSTTTTTTTAAAAAAAAARRRRRRRRRRRTTTTTTTTTTTTTTTTTTTTTTTTT"
        puts e
        puts e.backtrace
        puts "EEEEEEEEEEEEEEEENNNNNNNNNNNNNNNNNNNNDDDDDDDDDDDDDDDDDDDDD"
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
end
