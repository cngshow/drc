require 'warbler'
require './lib/util/helpers'
require 'fileutils'
Rake::TaskManager.record_task_metadata = true
include VSOUtilities

WINDOWS ||= (java.lang.System.getProperties['os.name'] =~ /win/i)
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
  ENV['NODE_ENV'] = ENV['RAILS_ENV']

  desc 'build maven\'s target folder if needed'
  task :maven_target do |task|
    Dir.mkdir(VSOUtilities::MAVEN_TARGET_DIRECTORY) unless File.exists?(VSOUtilities::MAVEN_TARGET_DIRECTORY)
  end

  desc 'build the context file'
  task :generate_context_file do |task|
    p task.comment
    p "context is #{context}"
    File.open("context.txt", 'w') {|f| f.write(context)}
  end

  desc 'build the version file'
  task :generate_version_file do |task|
    p task.comment
    p "version is #{version}"
    File.open("version.txt", 'w') {|f| f.write(version)}
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

  slash = java.io.File.separator #or FILE::ALT_SEPARATOR
  src_war = "#{VSOUtilities::MAVEN_TARGET_DIRECTORY}#{slash}#{Rails.application.class.parent_name.to_s.downcase}.war"
  tomcat_war_dst =  "#{ENV['TOMCAT_DEPLOY_DIRECTORY']}"
  tomcat_war ="#{tomcat_war_dst}#{slash}#{Rails.application.class.parent_name.to_s.downcase}.war"
  tomcat_base_dir = "#{tomcat_war_dst}#{slash}..#{slash}"

  desc 'stop local tomcat instance'
  task :stop_tomcat do |task|
    p task.comment
    system "cd #{tomcat_base_dir} && .#{slash}bin#{slash}shutdown" # we will not use sh, best effort to stop tomcat, it  might not be running.
  end

  desc 'start local tomcat instance'
  task :start_tomcat do |task|
    p task.comment
    ENV['LOAD_WEBSOCKET_JARS'] = nil
    if WINDOWS
      command = %q{start "cd #{tomcat_base_dir} && .#{slash}bin#{slash}startup"}
      p command
    else
      p command
      command = "cd #{tomcat_base_dir} && .#{slash}bin#{slash}startup &"
    end
    sh "cd #{tomcat_base_dir} && .#{slash}bin#{slash}startup"
  end

  ld = 'move war'
  desc ld
  task :move_war do |task|
    FileUtils.copy(src_war,tomcat_war)
    FileUtils.remove_dir(tomcat_war_dst) rescue nil
    Dir.mkdir(tomcat_war_dst) unless File.exists?(tomcat_war_dst
  end

  ld = 'local deploy'
  desc ld
  task :local_deploy do |task|
    Rake::Task['devops:stop_tomcat'].invoke
    Rake::Task['devops:move_war'].invoke
    Rake::Task['devops:start_tomcat'].invoke
  end

  desc ld
  task :ld => :local_deploy

  lbd = 'local build and deploy'
  desc lbd
  task :local_build_and_deploy do |task|
    Rake::Task['devops:build_war'].invoke
    Rake::Task['devops:local_deploy'].invoke
  end

  desc lbd
  task :lbd => :local_build_and_deploy

end

if WINDOWS
  class Webpacker::Compiler
    def run_webpack
      sterr, stdout, status = Open3.capture3(webpack_env, "bundle.bat exec webpack")
      if status.success?
        logger.info "Compiled all packs in #{config.public_output_path}"
      else
        logger.error "Compilation failed:\n#{sterr}\n#{stdout}"
      end
      status.success?
    end
  end
end