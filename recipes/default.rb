node['deploy'].each do |application, deploy|

  src_filename = node['remote_syslog2']['filename']
  src_filepath = "#{Chef::Config['file_cache_path']}/#{src_filename}"
  extract_path = "#{Chef::Config['file_cache_path']}/remote_syslog2/#{['remote_syslog2']['checksum']}"

  remote_file src_filepath do
    source "https://github.com/papertrail/remote_syslog2/releases/download/#{node['remote_syslog2']['version']}/remote_syslog_linux_386.tar.gz"
    checksum node['remote_syslog2']['checksum']
    owner 'root'
    group 'root'
    mode "0644"
  end

  bash 'extract and copy executable' do
    cwd ::File.dirname(src_filepath)
    code <<-EOH
      mkdir -p #{extract_path}
      tar xzf #{src_filename} -C #{extract_path}
      mv #{extract_path}/remote_syslog #{node['remote_syslog2']['install_dir']}
      EOH
    not_if { ::File.exists?(extract_path) }
  end

end
