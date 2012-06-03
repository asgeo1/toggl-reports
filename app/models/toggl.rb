class Toggl
  include HTTParty
  base_uri 'https://www.toggl.com'

  def initialize(u, p)
    @auth = {:username => u, :password => p}
  end

  def timeentries(options = {})
    options.merge!({:basic_auth => @auth})
    self.class.get('/api/v6/time_entries.json', options)
  end

  def clients(options = {})
    options.merge!({:basic_auth => @auth})
    self.class.get('/api/v6/clients.json', options)
  end

  def projects(options = {})
    options.merge!({:basic_auth => @auth})
    self.class.get('/api/v6/projects.json', options)
  end
end
