# ワーカーの数
worker_processes 2

# RAILS ROOT
#working_directory "/home/ec2-user/current/"
working_directory File.expand_path ENV['RAILS_ROOT']

# ソケット経由で通信する
#listen File.expand_path('/tmp/blog.sock')
listen File.expand_path ENV['SOCKET_PATH']
pid File.expand_path('tmp/pids/unicorn.pid', ENV['RAILS_ROOT'])

# ログ
stderr_path File.expand_path('log/unicorn_stderr.log', ENV['RAILS_ROOT'])
stdout_path File.expand_path('log/unicorn_stdout.log', ENV['RAILS_ROOT'])

# ダウンタイムなくす
preload_app true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "#{ server.config[:pid] }.oldbin"
  unless old_pid == server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      puts "Sending #{sig} signal to old unicorn master..."
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
  #sleep 1
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end