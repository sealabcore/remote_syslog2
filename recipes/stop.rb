service "remote_syslog" do
  init_command "/etc/init.d/remote_syslog"
  reload_command "/etc/init.d/remote_syslog reload"
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true
end

service "remote_syslog" do
  action [:stop]
end