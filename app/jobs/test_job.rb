#TestJob
class TestJob < ApplicationJob
  queue_as :default
  include SuckerPunch::Job
  workers 4

  def perform(*args)
    puts "I love you!"
  end
end

#job = TestJob.perform_later
#job = TestJob.set(wait_until: 5.seconds.from_now).perform_later
#job = TestJob.set(wait_until: 5.weeks.from_now).perform_later({job_tag: 'flipper4'})
#job = TestJob.perform_now
#
# load('./app/jobs/test_job.rb')