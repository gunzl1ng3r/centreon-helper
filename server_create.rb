#!/usr/bin/ruby

cacti_cli_dir = "/opt/cacti/share/www/cli"
centreon_cli = "/opt/centreon/www/modules/centreon-clapi/core/centreon"
centreon_poller = "Nagios"
create_cacti = false
create_centreon = true
filename = ARGV.first
fetched_hosts_csv = ''
new_hosts = []

require 'csv'
require 'open3'

if create_centreon
  puts "### Enter Centreon Credentials ###"
  print "Please enter Centreon Username: "
  centreon_cli_user = $stdin.gets.chomp
  print "Please enter Centreon Password: "
  centreon_cli_password = $stdin.gets.chomp
end

puts "### Enter SNMPv3 Credentials (User: monitoring) ###"
print "Please enter SNMPv3 Passphrase: "
snmpv3_passphrase = $stdin.gets.chomp
print "Please enter SNMPv3 Password: "
snmpv3_password = $stdin.gets.chomp

CSV.open(filename, 'r', fs = ';') do |row|

  if create_centreon
    cmd_create_hosts = "#{centreon_cli} -u #{centreon_cli_user} -p #{centreon_cli_password} -o HOST -a ADD -v \"#{row[0]};#{row[0]};#{row[1]};#{row[2]};#{centreon_poller};#{row[4]}\""
    Open3.popen3(cmd_create_hosts) do |stdin,stdout,stderr|
      while line = stdout.gets
        puts line
      end
    end

    cmd_set_macro_SNMPUSER = "#{centreon_cli} -u #{centreon_cli_user} -p #{centreon_cli_password} -o HOST -a setmacro -v \"#{row[0]};SNMPUSER;monitoring;0;SNMPUSER\""
    Open3.popen3(cmd_set_macro_SNMPUSER) do |stdin,stdout,stderr|
      while line = stdout.gets
        puts line
      end
    end

    cmd_set_macro_SNMPPASSWORD = "#{centreon_cli} -u #{centreon_cli_user} -p #{centreon_cli_password} -o HOST -a setmacro -v \"#{row[0]};SNMPPASSWORD;#{snmpv3_password};1;SNMPPASSWORD\""
    Open3.popen3(cmd_set_macro_SNMPPASSWORD) do |stdin,stdout,stderr|
      while line = stdout.gets
        puts line
      end
    end

    cmd_set_macro_SNMPPRIVACYPASS = "#{centreon_cli} -u #{centreon_cli_user} -p #{centreon_cli_password} -o HOST -a setmacro -v \"#{row[0]};SNMPPRIVACYPASS;#{snmpv3_passphrase};1;SNMPPRIVACYPASS\""
    Open3.popen3(cmd_set_macro_SNMPPRIVACYPASS) do |stdin,stdout,stderr|
      while line = stdout.gets
        puts line
      end
    end

  end

  if create_cacti
    cacti_create_hosts_snmp = "--version=3 --authproto=\"SHA\" --privproto=\"AES\" --username=\"monitoring\" --password=\"#{snmpv3_password}\" --privpass=\"#{snmpv3_passphrase}\""
    cmd_cacti_create_hosts = "php -q #{cacti_cli_dir}/add_device.php --description=\"#{row[0]}\" --ip=\"#{row[1]}\" --template=80 #{cacti_create_hosts_snmp}"

    Open3.popen3(cmd_cacti_create_hosts) do |stdin,stdout,stderr|
      while line = stdout.gets
        puts line
      end
      while line = stderr.gets
        puts line
      end
    end
  end

end

#p new_hosts
