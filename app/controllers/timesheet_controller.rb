class TimesheetController < ApplicationController
  http_basic_authenticate_with :name => ENV['TIMESHEET_USERNAME'], :password => ENV['TIMESHEET_PASSWORD']

  def imagesoft
    toggl = Toggl.new(ENV['TOGGL_API_KEY'], 'api_token')

    if params.has_key?(:start_date) then
      @start_date = DateTime.parse("#{params[:start_date]}T00:00:00+10:00")
    else
      @start_date = Date.today.prev_month.beginning_of_month
    end

    if params.has_key?(:end_date) then
      @end_date = DateTime.parse("#{params[:end_date]}T23:59:59+10:00")
    else
      @end_date = DateTime.parse(
        "#{Date.today.prev_month.end_of_month.strftime('%Y-%m-%d')}T23:59:59+10:00"
      )
    end

    time_entries = toggl.timeentries({:query => {
      :start_date => @start_date.iso8601,
      :end_date   => @end_date.iso8601,
    }})

    @time_entries = []
    @weeks = {}
    @timesheet = {}
    @round_to_nearest = 30
    @round_threshold  = @round_to_nearest / 2

    @clients  = toggl.clients()
    @projects = toggl.projects()
    @tasks    = toggl.tasks()

    if time_entries.present? and time_entries['data'].present?
      time_entries['data'].each do |time_entry|
        project = @projects['data'].find {|p| p['id'] == time_entry['pid'] }
        if project.nil?
          next
        end
        client = @clients['data'].find {|c| c['id'] == project['cid'] }
        task = @tasks['data'].find {|t| t['id'] == time_entry['tid'] }

        if time_entry['pid'].present? and client['name'] =~ /^Dyers|Ausfast|Imagesoft|DKL/ then
          time_entry['project'] = {'client_project_name' => "#{client['name']} - #{project['name']}"}
          time_entry['task'] = {'name' => task['name']}
          @time_entries << time_entry
        else
          next
        end

        date        = Date.parse(time_entry['start'])
        start       = DateTime.parse(time_entry['start'])
        stop        = DateTime.parse(time_entry['stop'])
        client_name = "#{client['name']} - #{project['name']}".sub('-', '/')
        dateIdx     = date.strftime('%Y%m%d')
        week_start  = Date.commercial(date.cwyear, date.cweek, 1)
        week_end    = Date.commercial(date.cwyear, date.cweek, 7)

        if week_end > @end_date then
          week_end = @end_date
        end

        if week_start < @start_date then
          week_start = @start_date
        end

        if not @weeks.has_key?("#{date.cwyear}_#{date.cweek}") then
          @weeks["#{date.cwyear}_#{date.cweek}"] = {
            :start => week_start,
            :end   => week_end
          }
        end

        if not @timesheet.has_key?("#{dateIdx}") then
          @timesheet[dateIdx] = {}
          #round start-of-day time to nearest half-hour based on first 20 minutes
          @round_threshold = @round_to_nearest / 3 * 2
        else
          @round_threshold = @round_to_nearest / 2
        end

        if not @timesheet[dateIdx].has_key?("#{client_name}") then
          @timesheet[dateIdx][client_name] = {
            :duration => 0,
            :travel   => 0,
            :times    => [],
            :tasks    => []
          }
        end

        #Round the individual tasks first
        start_floor = Time.at((start.to_f / (@round_to_nearest*60)).floor * (@round_to_nearest*60))
        stop_floor  = Time.at((stop.to_f  / (@round_to_nearest*60)).floor * (@round_to_nearest*60))

        if Time.at(start.to_f) - start_floor > @round_threshold*60 then
          start = start_floor + @round_to_nearest*60
        else
          start = start_floor
        end

        if Time.at(stop.to_f) - stop_floor > @round_threshold*60 then
          stop = stop_floor + @round_to_nearest*60
        else
          stop = stop_floor
        end

        # toggle for some reason records the end time if it is past midnight as
        # the same date, even though it is really the next day
        if stop < start then
          stop = stop + 1.day
        end

        duration = ((stop - start) / 60).to_i

        @timesheet[dateIdx][client_name][:duration] += duration

        if not time_entry['task'].nil? and time_entry['task']['name'] == 'Travel'
          @timesheet[dateIdx][client_name][:travel] += duration
        end

        if not @timesheet[dateIdx][client_name][:tasks].include?(
          time_entry['description']
        ) then
          @timesheet[dateIdx][client_name][:tasks] << time_entry['description']
        end

        last = @timesheet[dateIdx][client_name][:times].last

        if not last.nil? and last[:stop] == start
          @timesheet[dateIdx][client_name][:times][-1][:stop] = stop
        elsif start != stop
          @timesheet[dateIdx][client_name][:times] << {
            :start => start,
            :stop  => stop
          }
        end
      end
    end

    # :user_id => 273621

    respond_to do |format|
      format.html
      format.xls {
        send_data(
          render_to_string,
          :type        => 'application/vnd.ms-excel',
          :disposition => 'attachment',
          :filename    => "timesheet_adam_#{@start_date.strftime('%Y-%m-%d')}_#{@end_date.strftime('%Y-%m-%d')}.xls"
        )
      }
    end
  end

  def ipra
  end
end
