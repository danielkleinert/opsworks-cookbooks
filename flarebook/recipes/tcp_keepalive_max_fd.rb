bash "TCP keepalive configuration" do
  user "root"
  code <<-EOF
    echo 300 > /proc/sys/net/ipv4/tcp_keepalive_time
  EOF
end

bash "Configuration of maximum number of open file descriptors" do
  user "root"
  code <<-EOF
	ulimit -n 16000
  EOF
end

