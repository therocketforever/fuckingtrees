helpers do
  def authorized?
    return true if session[:creature]
  end
  def authorize!
    redirect '/login' unless authorized?
  end
  def logout!
    session[:creature] = false
  end
end