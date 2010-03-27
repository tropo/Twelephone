class UsersController < ApplicationController
    
  def show
    # @listeners = user.listeners.by_count.all(:limit => 25)
    @user = user
  end
  
  def tweetcall
    refnumber = 1 + rand(1000)
    message = "#twelephone @#{params[:twele][:target]} ref:#{refnumber.to_s}"
    @tweet = current_user.twitter.post('/statuses/update.json', :status => message)  
    
    target = User.find(:first, :conditions => ['login = ?', params[:twele][:target]])
      
    render :update do |page| 
      if target
        page.replace_html 'results', 'Please wait while we initiate the calls...'
      else
        page.replace_html 'results', 'We just sent @' + params[:twele][:target] + ' a requst to signup for Twelephone...'
      end
      page.visual_effect :highlight, 'results', :duration => 1
    end
  end
  
  def updatephone
    @user = User.find(current_user.id)
    @user.phone = params[:twele][:phone]
    @user.save
    render :action => 'show'
  end
    
  protected
  
  def user
    @user ||= User.from_param(params[:id])
  end
  helper_method :user
end
