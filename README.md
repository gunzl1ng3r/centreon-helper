# centreon-helper
I wrote these scripts to help me setup multiple hosts and services in Centreon, as doing so manually is a) monotonous and b) error prone.

The following points are noteworthy, when using the scripts:
* they make use of Centreons API `clapi`
  * the path to the binary is set at the top of the script, it is (currently) not a parameter
* they were written within in our environment and are currently only used by me - therefore there little to none validation or error handling steps
* they do not check whether a host or service already exists - as this does not disturb `clapi` (it simply states, "Object already exists")

## server_create.rb
* parses a file to create hosts in Centreon
* prompts for Centreon Credentials
  * plaintext, so better have nobody standing behind you ;)
* asks for SNMPv3 Credentials (uses them for all servers in file)
  * plaintext, so better have nobody standing behind you ;)
* creates three macros for each host (SNMPUSER, SNMPPASSWORD, SNMPPASSPHRASE)
* How to call: `ruby server_create.rb myservers.csv`
  * example content for `myservers.csv`:
    ```
    Server1;Server1-Hostname.Or.IP;MyHostTemplate
    Server2;Server2-Hostname.Or.IP;MyOtherHostTemplate
    ```
* **Extra**: if `create_cacti` is set to `true` it will use Cacti's PHP scripts to create the hosts there too. 
  * Does not care about anything but Name and IP (Template is currently hardcoded #80)

## service_create.rb
* parses a file to create / alter services in Centreon
* How to call: `ruby server_create.rb myservices.csv`
  * example content for `myservices.csv`:
    ```
    Server1;MyServiceName;MyServiceTemplate
    Server1;MyServiceName;MyServiceTemplate;MyArgs
    ```
