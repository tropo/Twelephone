require 'rubygems'
require 'rest_client'
require 'json'
require 'rufus/scheduler'

scheduler = Rufus::Scheduler.start_new

scheduler.every("1m") do

  res = RestClient.get URI.encode('http://itpints.com/api/search?q=twelephone') rescue ''  
  result = JSON.parse(res)
  
  if result['resultCount'] > 0
    
    result['results'].each do |u|
      calls ||= Call.find(:first, :conditions => ['timestamp = ?', u['timestamp']])
      
      if !calls
        target = u['title'].scan(/@([A-Za-z0-9_]+)/)

        logit = Call.new
        logit.timestamp = u['timestamp']
        logit.author = u['author']
        logit.target = target[0]
        logit.save
        
        source = User.find(:first, :conditions => ['login = ?', u['author']]) rescue false
        destination = User.find(:first, :conditions => ['login = ?', target[0]]) rescue false
        
        if source and destination
          # spawn do
            dial = RestClient.get URI.encode('http://teleku.com/connect/' + source.phone + '/' + destination.phone ) rescue '' 
          # end
        
        elsif source.nil?
          
          resource = RestClient::Resource.new 'http://twitter.com/statuses/update.xml', :user => 'twelephoneapp', :password => 'dvtdvt'
          resource.post :status => '@' + u['author'] + ': Before giving someone a twelephone call, you must register at http://twelephone.com!', :content_type => 'application/xml'
          
        elsif destination.nil?
          
          resource = RestClient::Resource.new 'http://twitter.com/statuses/update.xml', :user => 'twelephoneapp', :password => 'dvtdvt'
          resource.post :status => '@' + target[0].to_s + ': @' + u['author'] + ' is trying to give you a twelephone call. Register at http://twelephone.com!', :content_type => 'application/xml'
          
          
        end
        
      end
    end

  end 
    
    # result['responseData']['translatedText']
  
end 