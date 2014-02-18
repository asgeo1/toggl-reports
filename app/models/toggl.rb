class Toggl
  include HTTParty
  debug_output $stderr if Rails.env.development?
  base_uri 'https://www.toggl.com'

  def initialize(u, p)
    @auth = {:username => u, :password => p}
  end

  def timeentries(options = {})
    options.merge!({:basic_auth => @auth})
    self.class.get('/api/v7/time_entries.json', options)
  end

  def clients(options = {})
    options.merge!({:basic_auth => @auth})
    self.class.get('/api/v7/clients.json', options)
  end

  def projects(options = {})
    options.merge!({:basic_auth => @auth})
    self.class.get('/api/v7/projects.json', options)
  end

  def tasks(options = {})
    options.merge!({:basic_auth => @auth})
    self.class.get('/api/v7/tasks.json', options)
  end
end
