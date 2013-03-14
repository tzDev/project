#!/usr/bin/env ruby
###############################################################################
# Collect Hosts 0.1.2b by Chase Higins 
# Windows Support by Jon Cornwell
###############################################################################
# As the name would imply, this script will scan the local network and 
# retrieve a list of hosts that are currently alive. 
##############################################################################
# TODO:
	#
###############################################################################

class FindHosts
	def self.findHosts(local_net)
		# the findHosts method takes the local network address as its argument it 
		# will then scan the network using the ping command from the system.
		# Obviously it is important that the machine the script is ran on uses
		# unix style ping calls, in this case ping -qc1 -w 1 <network>
		# local net should look like 192.168.1.0
		# we will need to remove the last octet to work with the loop
		ip_parts = local_net.split('.');
		local_net = ''; 
		# reconstruct the ip
		i = 0;
		ip_parts.each { |part|
			if i == 3
				break;
			end; 
			local_net += part + '.';	
			i += 1;
		};	
		i = 1;
		ips = Array.new;		
		254.times { # run 254 times to get all IPs on the subnet
			ips << local_net + i.to_s;
			i += 1;
		}
		live_hosts = Array.new;
		threads = Array.new;
		for ip in ips
			threads << Thread.new(ip) { |tip|
				## Edited to check for windows or unix operating system to use proper ping command
				if(/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
					out = `ping -n 2 -w 1 #{tip}`; #WINDOWS
				else
					out = `ping -qc2 -w 1 #{tip}`; #UNIX
				end
				
				if not out =~ /100%/
					# this would mean 0% packet loss
					live_hosts << tip;
				end;
			};
		end;
		threads.each { |t| t.join};	
		return live_hosts;
	end; # end findHosts method
end; # end FindHosts class

