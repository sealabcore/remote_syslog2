src_filename = node['remote_syslog2']['filename']
src_filepath = "#{Chef::Config['file_cache_path']}/#{src_filename}"
extract_path = "#{Chef::Config['file_cache_path']}/remote_syslog2"

remote_file src_filepath do
  source "https://github.com/papertrail/remote_syslog2/releases/download/#{node['remote_syslog2']['version']}/#{node['remote_syslog2']['filename']}"
  owner 'root'
  group 'root'
  mode "0777"
end

bash 'extract and copy executable' do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    mkdir -p #{extract_path}
    tar xzf #{src_filename} -C #{extract_path}
    mv #{extract_path}/remote_syslog/remote_syslog #{node['remote_syslog2']['install_dir']}
    EOH
  not_if { ::File.exists?(extract_path) }
end

file "#{node['remote_syslog2']['install_dir']}/remote_syslog" do
  owner "root"
  group "root"
  mode "0777"
  action :touch
end

template "/etc/log_files.yml" do
  action :create
  owner 'root'
  group 'root'
  mode  '0777'
  source 'logs.yml.erb'
end

file "/etc/remote_syslog.log" do
  owner 'root'
  group 'root'
  mode  '0777'
  action :touch
end

file "/var/run/remote_syslog.pid" do
  owner 'root'
  group 'root'
  mode  '0777'
  action :touch
end

cookbook_file '/etc/init.d/remote_syslog' do
  action :create
  owner 'root'
  group 'root'
  mode '0777'
  source 'remote_syslog.init'
end

service 'remote_syslog' do
  action [:stop]
  supports :status => true, :restart => true, :reload => true
  init_command "/etc/init.d/remote_syslog"
  action [:enable, :start]
end
