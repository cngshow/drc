require 'warbler'
require './lib/util/helpers'
require 'fileutils'
Rake::TaskManager.record_task_metadata = true
include DRCUtilities

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

  slash = java.io.File.separator #or FILE::ALT_SEPARATOR
  src_war = "#{DRCUtilities::MAVEN_TARGET_DIRECTORY}#{slash}#{Rails.application.class.parent_name.to_s.downcase}.war"
  tomcat_war_dst =  "#{ENV['TOMCAT_DEPLOY_DIRECTORY']}"
  app_name = Rails.application.class.parent_name.to_s.downcase
  tomcat_war ="#{tomcat_war_dst}#{slash}#{app_name}.war"
  tomcat_base_dir = "#{tomcat_war_dst}#{slash}..#{slash}"
  $war_name = version.eql?('unversioned') ? default_name  : "#{default_name}-#{version}"

  desc 'build maven\'s target folder if needed'
  task :maven_target do |task|
    Dir.mkdir(DRCUtilities::MAVEN_TARGET_DIRECTORY) unless File.exists?(DRCUtilities::MAVEN_TARGET_DIRECTORY)
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
    # Delete old war files
    old_war_files = Dir.glob(File.join("target", "drc*.war"))
    old_war_files.each do |war|
	    File.delete(war)
    end
    Rake::Task['devops:maven_target'].invoke
    Rake::Task['devops:compile_assets'].invoke
    Rake::Task['devops:generate_context_file'].invoke
    Rake::Task['devops:generate_version_file'].invoke
    # Rake::Task['devops:create_version'].invoke
    #sh "warble"
    Warbler::Task.new
    Rake::Task['war'].invoke
    #if war file has the 1.00 snapshot then copy to tomcat here otherwise the copy will occur at move_war
    if version != "unversioned"
      new_war = Dir.glob(File.join("target", "drc*.war"))
      new_war.each do |war|
        FileUtils.copy(war,src_war)
        File.rename(src_war, "#{tomcat_war}")
      end
    end
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

  desc 'stop local tomcat instance'
  task :stop_tomcat do |task|
    p task.comment
    if WINDOWS
      command = "cd #{tomcat_base_dir} && .#{slash}bin#{slash}shutdown"
    else
      command = "cd #{tomcat_base_dir} && .#{slash}bin#{slash}shutdown.sh &"
    end
    p command
    system command # we will not use sh, best effort to stop tomcat, it  might not be running.
  end

  desc 'start local tomcat instance'
  task :start_tomcat do |task|
    p task.comment
    ENV['LOAD_WEBSOCKET_JARS'] = nil
    if WINDOWS
      #to get help screen for start type:
      # start /max start /?
      command = %Q{start "Tomcat: Meow!" /D #{tomcat_base_dir}#{slash}bin#{slash} startup}
    else
      command = "cd #{tomcat_base_dir} && .#{slash}bin#{slash}startup.sh &"
    end
    p command
    sh command
  end

  ld = 'move war'
  desc ld
  task :move_war do |task|
    Dir.mkdir(tomcat_war_dst) unless File.exists?(tomcat_war_dst)
    p "#{tomcat_war} *********** && #{src_war}"
    FileUtils.copy(src_war,tomcat_war)
    FileUtils.remove_dir("#{tomcat_war_dst}/#{app_name}") rescue nil
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

  wbdescr = 'build websocket jar and deploy'
  desc wbdescr
  task :websocket do |task|
    p task.comment
    tomcat_copy_dir = "#{tomcat_base_dir}lib"
    # Grabs all previous websocket_rails_snapshots created by Maven -- needs to mirror POM.xml <version>
    previous_rails_snapshots = Dir.glob(File.join("lib", "websocket", "websocket_rails*.jar"))
    previous_tomcat_snapshots = Dir.glob("#{tomcat_copy_dir}/websocket_rails*.jar")
    # Combine all of the previous snapshots
    previous_snapshots = previous_rails_snapshots.concat previous_tomcat_snapshots
    # Delete previous websocket_rails snapshots in order to prevent duplicates
    previous_snapshots.each { |snap| File.delete(snap)}
    pull = "cd #{ENV['WEBSOCKET_POM_LOC']} && git pull"
    build = "cd #{ENV['WEBSOCKET_POM_LOC']} && mvn clean package"
    puts "Executing: #{pull}"
    sh pull
    puts "Executing #{build}"
    sh build
    jars = Dir.glob("#{ENV['WEBSOCKET_POM_LOC']}#{slash}target/*.jar")#glob will not work with windows style slash before the 'glob', interesting..
    puts "I will move the following jars: #{jars}"
    Dir.mkdir(tomcat_war_dst) unless File.exists?(tomcat_war_dst)
    jars.each do |jar|
      copy_rails = "#{Rails.root}#{slash}lib#{slash}websocket"
      puts "Copying #{jar} to #{copy_rails}"
      FileUtils.copy(jar,copy_rails)
      puts 'Done!'
    end
  end

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
