namespace :s3_archive do

  def strategy
    @strategy ||= Capistrano::S3Archive::SCM.new(self, fetch(:s3_archive_strategy, Capistrano::S3Archive::SCM::RsyncStrategy))
  end

  desc 'Check that the S3 buckets are reachable'
  task :check  do
    on release_roles :all do
      strategy.check
    end
  end

  desc 'Extruct and stage the S3 archive in a stage directory'
  task :stage do
    on release_roles :all do
      strategy.stage
    end
  end

  desc 'Copy repo to releases'
  task :create_release => :stage do
    on release_roles :all do |server|
      execute :mkdir, '-p', release_path
      strategy.release(server)
    end
  end

  desc 'Determine the revision that will be deployed'
  task :set_current_revision do
    set :current_revision, strategy.current_revision
  end
end