#!/usr/bin/ruby

centreon_cli = "/opt/centreon/www/modules/centreon-clapi/core/centreon"
centreon_poller = "Nagios"
create_centreon = true
filename = ARGV.first
# filename is expected to contain one or multiple lines in the following format:
#           servername;servicename;servicetemplate[;check_args]
#  example: abc-live-web01;SYSTEM_ping;SYSTEM_ping
#  example: abc-live-web01;NRPE_stuff;NRPE;!nrpe_command

require 'csv'
require 'open3'

if create_centreon
  puts "### Enter Centreon Credentials ###"
  print "Please enter Centreon Username: "
  centreon_cli_user = $stdin.gets.chomp
  print "Please enter Centreon Password: "
  centreon_cli_password = $stdin.gets.chomp
end

CSV.open(filename, 'r', fs = ';') do |row|
  if create_centreon
    cmd_add_service = "#{centreon_cli} -u #{centreon_cli_user} -p #{centreon_cli_password} -o SERVICE -a ADD -v \"#{row[0]};#{row[1]};#{row[2]};\""
    Open3.popen3(cmd_add_service) do |stdin,stdout,stderr|
      while line = stdout.gets
        puts line
      end
    end
    
    if row[3]
      cmd_set_param = "#{centreon_cli} -u #{centreon_cli_user} -p #{centreon_cli_password} -o SERVICE -a SETPARAM -v \"#{row[0]};#{row[1]};check_command_arguments;#{row[3]}\""
    end
    Open3.popen3(cmd_set_param) do |stdin,stdout,stderr|
      while line = stdout.gets
        puts line
      end
    end
  end
end
