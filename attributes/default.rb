default['remote_syslog2']['install_dir'] = '/usr/local/bin'
default['remote_syslog2']['version']     = 'v0.13'
default['remote_syslog2']['filename']    = 'remote_syslog_linux_amd64.tar.gz'

default[:papertrail][:host] = 'logs.papertrailapp.com'
default[:papertrail][:port] = '514'
default[:papertrail][:logs] = []
default[:papertrail][:exclude_patterns] = []

default[:remote_syslog][:pid_file] = "/tmp/remote_syslog.pid"
default[:remote_syslog][:start_command] = "/etc/init.d/remote_syslog start"
default[:remote_syslog][:stop_command] = "/etc/init.d/remote_syslog stop"
