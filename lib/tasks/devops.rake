require 'warbler'
require './lib/util/helpers'
Rake::TaskManager.record_task_metadata = true
include VSOUtilities
namespace :devops do
  def env(env_var, default)
    ENV[env_var].nil? ? default : ENV[env_var]
  end

  def version_to_rails_mode(version)
    p "The version is #{version}"
    mode = 'production'
    if (version =~ /snapshot$/i)
      mode = 'test'
    end
    p "Setting rails war to use #{mode}"
    mode
  end


  default_name = to_snake_case(Rails.application.class.parent)
  default_war = "#{default_name}.war"
  context = env('RAILS_RELATIVE_URL_ROOT', "/#{default_name}")
  version = env('PROJECT_VERSION', "unversioned")
  ENV['RAILS_RELATIVE_URL_ROOT'] = env('RAILS_RELATIVE_URL_ROOT', "/#{default_name}")
  ENV['RAILS_ENV'] = version_to_rails_mode(ENV['PROJECT_VERSION'])

  desc 'build maven\'s target folder if needed'
  task :maven_target do |task|
    Dir.mkdir(VSOUtilities::MAVEN_TARGET_DIRECTORY) unless File.exists?(VSOUtilities::MAVEN_TARGET_DIRECTORY)
  end

  desc 'build the context file'
  task  :generate_context_file do |task|
    p task.comment
    p "context is #{context}"
    File.open("context.txt", 'w') {|f| f.write(context) }
  end

  desc 'build the version file'
  task  :generate_version_file do |task|
    p task.comment
    p "version is #{version}"
    File.open("version.txt", 'w') {|f| f.write(version) }
  end

  desc 'Build war file'
  task :build_war do |task|
    p task.comment
    Rake::Task['devops:maven_target'].invoke
    Rake::Task['devops:compile_assets'].invoke
    Rake::Task['devops:generate_context_file'].invoke
    Rake::Task['devops:generate_version_file'].invoke
    # Rake::Task['devops:create_version'].invoke
    #sh "warble"
    Warbler::Task.new
    Rake::Task['war'].invoke
  end

  desc 'Compile assets'
  task :compile_assets do |task|
    p task.comment
    p "rails env is #{ENV['RAILS_ENV']}"
    Rake::Task['assets:clobber'].invoke
    Rake::Task['assets:precompile'].invoke()
  end

  desc 'Install bundle'
  task :bundle do |task|
    p task.comment
    sh 'bundle install'
  end
end