"`nTesting availability public domain 'domain.com' ..."
"`nAvailability on http port 80: " 
Test-NetConnection domain.com -Port 80 -InformationLevel Quiet
"`nAvailability on ssh port 22: " 
Test-NetConnection domain.com -Port 22 -InformationLevel Quiet
"`nAvailability by icmp ping: " 
Test-NetConnection domain.com -InformationLevel Quiet
"`n--------------------------------------------------"

write-host "Press any key to exit..."
