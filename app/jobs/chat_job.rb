#TestJob
class ChatJob < ApplicationJob
  queue_as :default
  include SuckerPunch::Job
  workers 1

  def perform(*args)
    @@count ||= 1
    begin
      $log.debug("Before broadcast")
      ActionCable.server.broadcast "web_notifications_channel", message: "The count is #{@@count}"
      $log.debug "After #{@@count}"
    rescue => ex
      $log.error(LEX("error in chat job",ex))
    end
    @@count += 1
    ChatJob.set(wait_until: 10.seconds.from_now).perform_later
  end
end

#job = TestJob.perform_later
#job = TestJob.set(wait_until: 5.seconds.from_now).perform_later
#job = TestJob.set(wait_until: 5.weeks.from_now).perform_later({job_tag: 'flipper4'})
#job = TestJob.perform_now
#
# load('./app/jobs/test_job.rb')