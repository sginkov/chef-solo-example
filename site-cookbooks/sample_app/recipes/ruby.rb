include_recipe 'rvm::system'

['bundler'].each do |gem_name|
  rvm_global_gem gem_name do
    action :install
  end
end