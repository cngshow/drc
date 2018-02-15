#WebsocketTestJob
class WebsocketTestJob < ApplicationJob
  queue_as :default
  include SuckerPunch::Job
  workers 4

  def perform(*args)
    server_uuid  = args.shift
    client_uuid  = args.shift
    msg = "hello from the server at #{Time.now}"
    WebSocketSupport.client_chat(uuid: server_uuid, client_uuid: client_uuid, message: msg)
  end
end

#job = TestJob.perform_later
#job = TestJob.set(wait_until: 5.seconds.from_now).perform_later
#job = TestJob.set(wait_until: 5.weeks.from_now).perform_later({job_tag: 'flipper4'})
#job = TestJob.perform_now
#
# load('./app/jobs/test_job.rb')