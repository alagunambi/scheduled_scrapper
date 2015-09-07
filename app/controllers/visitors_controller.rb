class VisitorsController < ApplicationController

  def schedule

    tag = Tag.find_or_create_by(:title => params[:schedule][:tag_title])

    schedule = Schedule.find_or_create_by(:tag_id => tag.id, :date => params[:schedule][:date])

    #@ads = from_haraj(schedule)
    #@ads = Ad.all

    @job = Sidekiq::Cron::Job.create(name: schedule.id.to_s + "-" + Time.now.to_i.to_s, cron: generate_cron(schedule), klass: 'Puller', :args => {:schedule => schedule.id} )

    respond_to do |format|
      if job.count > 0
        format.html { redirect_to schedules_path, notice: 'Scheduled Ads gathering will start at 9AM.' }
      else
        format.html { redirect_to :back, notice: 'Failed to schedule, please try again.' }
      end
    end

  end
end
