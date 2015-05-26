default[:sample_app][:deploy_to] = '/home/deploy/sample_app'

default[:sample_app][:repo_host] = "github.com"
default[:sample_app][:repository] = "https://github.com/sginkov/rails4-pg-unicorn-sample.git"
default[:sample_app][:revision] = "master"
default[:sample_app][:keep_releases] = 5

default[:sample_app][:unicorn][:dir] = "/etc/unicorn"
default[:sample_app][:unicorn][:sock] = "/tmp/sample_app.unicorn.socket"
default[:sample_app][:unicorn][:pid] = "/var/run/sample_app.unicorn.pid"
default[:sample_app][:unicorn][:stderr] = "/var/log/sample_app.unicorn.stderr.log"
default[:sample_app][:unicorn][:stdout] = "/var/log/sample_app.unicorn.stdout.log"

default[:sample_app][:user] = 'root'
default[:sample_app][:group] = 'root'

default[:sample_app][:env] = "production"
default[:sample_app][:secret_key_base] = ""

default[:sample_app][:database][:name] = 'sample_app'
default[:sample_app][:database][:user] = 'sample_app'
default[:sample_app][:database][:password] = 'sample_app'
default[:sample_app][:database][:host] = 'localhost'
default[:sample_app][:database][:port] = '5432'