
class TimesheetController < ApplicationController
  def index
  end

  def imagesoft
    toggl = Toggl.new(ENV['TOGGL_API_KEY'], 'api_token')

    @time_entries = toggl.timeentries({:query => {
      :start_date => '2012-05-01T00:00:00+10:00',
      :end_date   => '2012-05-31T23:59:59+10:00'
    }})

    @clients  = toggl.clients()
    @projects = toggl.projects()
  end

  def ipra
  end
end
