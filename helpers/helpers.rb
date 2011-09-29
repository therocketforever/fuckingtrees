module Helpers
  def authorized?
    return true if session[:creature]
  end
  def authorize!
    redirect '/login'
  def logout!
    session[:creature] = false
  end
end