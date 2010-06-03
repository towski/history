working_directory '/home/wastro/art/history'
worker_processes 4
listen '/home/wastro/art/history/log/unicorn_market.sock', :backlog => 1024
timeout 60
pid "/home/wastro/art/history/log/unicorn_market.pid"

# Based on http://gist.github.com/206253

logger Logger.new("log/unicorn.log")

# Load the app into the master before forking workers for super-fast worker spawn times
preload_app true

# some applications/frameworks log to stderr or stdout, so prevent
# them from going to /dev/null when daemonized here:
stderr_path "log/unicorn.stderr.log"
stdout_path "log/unicorn.stdout.log"

# REE - http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|

  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.
  old_pid = "#{server.config[:pid]}.oldbin"

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :TERM : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  worker_pid = File.join(File.dirname(server.config[:pid]), "unicorn_worker_market_#{worker.nr}.pid")
  File.open(worker_pid, "w") { |f| f.puts Process.pid }
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
