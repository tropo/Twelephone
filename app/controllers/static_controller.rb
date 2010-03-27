class StaticController < ApplicationController
    
  def index
    @users = User.all(:order => "created_at DESC", :limit => 16)
    
    if logged_in?
      # @skypes = Skype.find(:first, :conditions => ["user_id = ?", current_user])
      
      # if !@skypes 
      #   @skype = Skype.new
      #   redirect_to :controller => 'skypes', :action => 'new'
      # end
      
    end
    
  end
  
  
end
