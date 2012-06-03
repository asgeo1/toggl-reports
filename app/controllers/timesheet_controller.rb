
class TimesheetController < ApplicationController
  def index
  end

  def imagesoft
    toggl = Toggl.new(ENV['TOGGL_API_KEY'], 'api_token')

    start_date = DateTime.parse('2012-05-01T00:00:00+10:00')
    end_date   = DateTime.parse('2012-05-31T23:59:59+10:00')

    time_entries = toggl.timeentries({:query => {
      :start_date => start_date.iso8601,
      :end_date   => end_date.iso8601,
    }})

    @time_entries = []
    @weeks = {}

    time_entries['data'].each do |time_entry|
      if time_entry['project']['client_project_name'] =~
      /^Dyers|Ausfast|Imagesoft/ then
        @time_entries << time_entry
      end

      date       = Date.parse(time_entry['start'])
      week_start = Date.commercial(date.year, date.cweek, 1)
      week_end   = Date.commercial(date.year, date.cweek, 7)

      if week_end > end_date then
        week_end = end_date
      end

      if week_start < start_date then
        week_start = start_date
      end

      if not @weeks.has_key?("#{date.year}_#{date.cweek}") then
        @weeks["#{date.year}_#{date.cweek}"] = {
          :start => week_start,
          :end   => week_end
        }
      end
    end

    # :user_id => 273621

    @clients  = toggl.clients()
    @projects = toggl.projects()
  end

  def ipra
  end
end
