require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'


RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  desc "Run on three Rubies"
  task :platforms do
    current = %x{rvm-prompt v}
    
    fail = false
    %w{1.8.7 1.9.2}.each do |version|
      puts "Switching to #{version}"
      Bundler.with_clean_env do
        system %{bash -c 'source ~/.rvm/scripts/rvm && rvm #{version} && bundle exec rake spec'}
      end
      if $?.exitstatus != 0
        fail = true
        break
      end
    end

    system %{rvm #{current}}

    exit (fail ? 1 : 0)
  end
end

task :default => 'spec'
