require File.dirname(__FILE__) + '/../../lib/i18n_sync_simple_to_active_record'

namespace :translations do
  namespace :activerecord do
    task :load_config => :rails_env do
      require 'active_record'
      config = Rails.application.config.database_configuration[Rails.env]
      ActiveRecord::Base.establish_connection(config)
    end

    desc "clean I18n::Backend::ActiveRecord::Translation table"
    task :clear => :load_config do
      I18nSyncSimpleToActiveRecord.clean
    end

    desc "load I18n::Backend::Simple (yaml) to I18n::Backend::ActiveRecord::Translation table"
    task :load  => :load_config do
      I18nSyncSimpleToActiveRecord.load
    end

    desc "clean I18n::Backend::ActiveRecord::Translation table and load I18n::Backend::Simple (yaml) to it"
    task :sync => :load_config do
      I18nSyncSimpleToActiveRecord.sync
    end
  end
end


