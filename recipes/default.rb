service "remote_syslog" do
  init_command "/etc/init.d/remote_syslog"
  reload_command "/etc/init.d/remote_syslog reload"
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true
end

service 'monit' do
  action :nothing
end

src_filename = node['remote_syslog2']['filename']
src_filepath = "#{Chef::Config['file_cache_path']}/#{src_filename}"
extract_path = "#{Chef::Config['file_cache_path']}/remote_syslog2"

node[:deploy].each do |application, deploy|

  remote_file src_filepath do
    source "https://remote-syslogger-dl.s3.amazonaws.com/remote_syslog_linux_amd64.tar.gz"
    owner deploy[:user]
    group deploy[:group]
    mode "0644"
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
    owner deploy[:user]
    group deploy[:group]
    mode "0755"
    action :touch
  end

  file "/tmp/remote_syslog.log" do
    owner deploy[:user]
    group deploy[:group]
    mode "0755"
    action :touch
  end

  file "/etc/remote_syslog.pid" do
    owner deploy[:user]
    group deploy[:group]
    mode "0755"
    action :touch
  end

  template "/etc/log_files.yml" do
    action :create
    owner deploy[:user]
    group deploy[:group]
    mode  '0644'
    source 'logs.yml.erb'
  end

  cookbook_file '/etc/init.d/remote_syslog' do
    action :create
    owner deploy[:user]
    group deploy[:group]
    mode '0755'
    source 'remote_syslog.init'

    notifies :reload, "service[remote_syslog]", :immediately
  end
end

template "#{node[:monit][:conf_dir]}/remote_syslog.monitrc" do
  source 'remote_syslog.monitrc.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, "service[monit]"
end

service "remote_syslog" do
  action [:reload]
end
