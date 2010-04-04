# SCHEDULER THAT POLLS EVERY MINUTE TO CHECK FOR #TWELEPHONE REQUESTS
require 'rubygems'
require 'rest_client'
require 'json'
require 'rufus/scheduler'

scheduler = Rufus::Scheduler.start_new

scheduler.every("1m") do


  res = RestClient.get URI.encode('http://itpints.com/api/search?q=#twelephone') rescue ''  
  result = JSON.parse(res)
  
  if result['resultCount'] > 0
    
    result['results'].each do |u|
      
      if u['title'].index("#twelephone")
        
      calls ||= Call.find(:first, :conditions => ['timestamp = ?', u['timestamp']])
      
      if !calls
        target = u['title'].scan(/@([A-Za-z0-9_]+)/)

        logit = Call.new
        logit.timestamp = u['timestamp']
        logit.author = u['author']
        logit.target = target[0]
        logit.save
        
        source = User.find(:first, :conditions => ['UPPER(login) = ?', u['author'].upcase]) rescue false
        destination = User.find(:first, :conditions => ['UPPER(login) = ?', target[0].upcase]) rescue false
        
        if source and destination
            dial = RestClient.get URI.encode('http://teleku.com/connect/' + source.phone + '/' + destination.phone ) rescue '' 
        
        elsif source.nil?
          
          if u['author'].downcase != 'twelephoneapp'
            resource = RestClient::Resource.new 'http://twitter.com/statuses/update.xml', :user => 'twelephoneapp', :password => 'dvtdvt'
            resource.post :status => '@' + u['author'] + ': Before giving someone a twelephone call, you must register at http://twelephone.com!', :content_type => 'application/xml'
          end
          
        elsif destination.nil?
          
          resource = RestClient::Resource.new 'http://twitter.com/statuses/update.xml', :user => 'twelephoneapp', :password => 'dvtdvt'
          resource.post :status => '@' + target[0].to_s + ': @' + u['author'] + ' is trying to give you a twelephone call. Register at http://twelephone.com!', :content_type => 'application/xml'
          
          
        end
        
      end
    end
  end

  end 
 
end 


# OR

# # TWEETSTREAM REAL-TIME SEARCH FEEDS
# require 'rubygems'
# require 'rest_client'
# require 'tweetstream'
# 
# # Thread.new do
# TweetStream::Client.new('twelephoneapp','dvtdvt').track('#twelephone') do |status|
# # TweetStream::Daemon.new('twelephoneapp','dvtdvt','tracker').track('#twelephone') do |status|  
# # TweetStream::Daemon.new('twelephoneapp','dvtdvt').track('#twelephone') do |status|  
#   # puts "#{status.text}"
#   # puts "#{status.id}"
#   # puts "#{status.user.screen_name}"
#   
#   # calls ||= Call.find(:first, :conditions => ['twitterid = ?', status.id])
#   # 
#   # if calls.nil?
#     target = status.text.scan(/@([A-Za-z0-9_]+)/)
#     
#     # logit = Call.new
#     # logit.twitterid = status.id
#     # logit.author = status.user.screen_name
#     # logit.target = target[0]
#     # logit.save
#     
#     source = User.find(:first, :conditions => ['login = ?', status.user.screen_name]) rescue false
#     destination = User.find(:first, :conditions => ['login = ?', target[0]]) rescue false
#     
#     if source and destination
#         dial = RestClient.get URI.encode('http://teleku.com/connect/' + source.phone + '/' + destination.phone ) rescue '' 
#     
#     elsif source.nil?
#       
#       if status.user.screen_name != 'twelephoneapp'
#         resource = RestClient::Resource.new 'http://twitter.com/statuses/update.xml', :user => 'twelephoneapp', :password => 'dvtdvt'
#         resource.post :status => '@' + status.user.screen_name + ': Before giving someone a twelephone call, you must register at http://twelephone.com!', :content_type => 'application/xml'
#       end
#       
#     elsif destination.nil?
#       
#       resource = RestClient::Resource.new 'http://twitter.com/statuses/update.xml', :user => 'twelephoneapp', :password => 'dvtdvt'
#       resource.post :status => '@' + target[0].to_s + ': @' + status.user.screen_name + ' is trying to give you a twelephone call. Register at http://twelephone.com!', :content_type => 'application/xml'
#       
#       
#     end
#     
#   # end
# # end
#   
# end


