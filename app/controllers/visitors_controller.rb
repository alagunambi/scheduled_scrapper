class VisitorsController < ApplicationController

  def schedule
    if params[:schedule][:tag_title] =~ URI::regexp
      tag = Tag.find_or_create_by(:title => params[:schedule][:tag_title])
      schedule = Schedule.find_or_create_by(:tag_id => tag.id, :date => params[:schedule][:date])

      Puller.perform_async(:schedule => schedule.id)
      @job = Sidekiq::Cron::Job.create(name: schedule.id.to_s + "-" + Time.now.to_i.to_s, cron: generate_cron(schedule), klass: 'Puller', :args => {:schedule => schedule.id} )
    else
      @job = false
    end

    respond_to do |format|
      if @job
        format.html { redirect_to schedules_path, notice: 'Scheduled Ads gathering started now, next will start at 9AM.' }
      else
        format.html { redirect_to :back, notice: 'Failed to schedule, please try again.' }
      end
    end

  end
end
