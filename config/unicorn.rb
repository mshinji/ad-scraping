# worker_processes Integer(ENV['WEB_CONCURRENCY'] || 3)
# timeout 15
# preload_app true
#
# # listen Rails.root.join('tmp', 'unicorn.sock')
# # pid    Rails.root.join('tmp', 'unicorn.pid')
# listen '/home/takumi/amazon_reseller_ban/tmp/unicorn.sock'
# pid '/home/takumi/amazon_reseller_ban/tmp/unicorn.pid'
#
# before_fork do |server, worker|
#   Signal.trap 'TEAM' do
#     puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
#     Process.kill('QUIT', Process.pid)
#   end
#
#   defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
# end
#
# after_fork do |server, worker|
#   Signal.trap 'TERM' do
#     puts 'Unicorn worker intercepting TERM and doing nothind. Wait for master to send QUIT'
#   end
#
#   defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
# end
#
# stderr_path File.expand_path('log/unicorn.log', '/home/takumi/amazon_reseller_ban/')
# stdout_path File.expand_path('log/unicorn.log', '/home/takumi/amazon_reseller_ban/')

#  unicron.rb
# set lets
$worker  = 2
$timeout = 240
$app_dir = "/home/www/AdScraping/" #アプリの場所
$listen  = File.expand_path 'tmp/unicorn.sock', $app_dir
$pid     = File.expand_path 'tmp/unicorn.pid', $app_dir
$std_log = File.expand_path 'log/unicorn.log', $app_dir

# set config
worker_processes  $worker
working_directory $app_dir
stderr_path $std_log
stdout_path $std_log
timeout $timeout
listen  $listen
pid $pid

# loading booster
preload_app true

# before starting processes
before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      Process.kill "QUIT", File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

# after finishing processes
after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
