include_recipe 'nginx'
include_recipe 'runit'
include_recipe 'apt'
include_recipe 'git'
include_recipe 'sample_app::ruby'

['unicorn'].each do |gem_name|
  rvm_global_gem gem_name do
    action :install
  end
end

directory node[:sample_app][:unicorn][:dir] do
  owner node[:sample_app][:user]
  group node[:sample_app][:group]
  mode 00755
end

conf_folder = File.join(node[:sample_app][:unicorn][:dir], 'sample_app')
directory conf_folder do
  owner node[:sample_app][:user]
  group node[:sample_app][:group]
  mode 00755
end

conf_file = File.join(conf_folder, "unicorn.conf.rb")
template conf_file do
  source 'unicorn.conf.rb.erb'
  owner node[:sample_app][:user]
  group node[:sample_app][:group]
  mode 0644
end

runit_service "sample_app_unicorn" do
  sv_timeout 60
  supports status: false, reload: false
end

package "postgresql-contrib" do
  action :install
end

package "nodejs" do
  action :install
end

deploy_to = node[:sample_app][:deploy_to]

# create shared directory
directory(File.join(deploy_to, 'shared')) do
  owner node[:sample_app][:user]
  group node[:sample_app][:group]
  mode 00777
  recursive true
end

['log', 'pids', 'system', 'config', 'public'].each do |dir_name|
  directory(File.join(deploy_to, 'shared', dir_name)) do
	  owner node[:sample_app][:user]
	  group node[:sample_app][:group]
    mode 00775
  end
end

# create default config files
config_files = [
  'database.yml'
]

config_files.each do |config_file|
  template File.join(deploy_to, 'shared', 'config', config_file) do
    source "rails/#{config_file}.erb"
		owner node[:sample_app][:user]
		group node[:sample_app][:group]
    mode 0644
    action :create_if_missing
  end
end

ssh_known_hosts_entry(node[:sample_app][:repo_host]) do
  host node[:sample_app][:repo_host]
end

deploy(deploy_to) do
  scm_provider Chef::Provider::Git
  environment "RAILS_ENV" => node[:sample_app][:env]
  repo node[:sample_app][:repository]
  revision node[:sample_app][:revision]

  user node[:sample_app][:user]
  group node[:sample_app][:group]
  keep_releases node[:sample_app][:keep_releases]

  action :deploy

  symlinks_hash = config_files.inject({}) do |memo, config_file|
    config_file_path = "config/#{config_file}"
    memo[config_file_path] = config_file_path
    memo
  end

  symlinks(symlinks_hash)

  before_restart do
    rvm_shell "Bundle install" do
      cwd release_path
  		user node[:sample_app][:user]
  		group node[:sample_app][:group]

      code %{
        bundle install --path #{deploy_to}/shared/bundle --deployment --without development test mysql
      }
    end

    rvm_shell "Migrations" do
      cwd release_path
  		user node[:sample_app][:user]
  		group node[:sample_app][:group]

      code %{
        export RAILS_ENV=#{node[:sample_app][:env]}
        bundle exec rake db:migrate
      }
    end

    rvm_shell "Assets" do
      cwd release_path
  		user node[:sample_app][:user]
  		group node[:sample_app][:group]

      code %{
        export RAILS_ENV=#{node[:sample_app][:env]}
        bundle exec rake assets:precompile
      }
    end
  end

  notifies :restart, "runit_service[sample_app_unicorn]"  
end

nginx_site 'default' do
  enable false
end

template "/etc/nginx/sites-available/sample_app" do
  source "nginx/vhost.conf.erb"
  mode 0777
  owner node[:nginx][:user]
  group node[:nginx][:user]
  notifies :restart, 'service[nginx]'
end

nginx_site "sample_app" do
  enable true
end
