# test-ESXi-Network
Test network connectivity on a new ESXi host- Are the physical NICs patched correctly?

This quick PowerCLI/PowerShell program was written to test connectivity on some new hosts before they were connected to vCenter and Distributed vSwitches setup. Rather than manually creating temporary Standard vSwitches, manually using vmkping, and then tidying up before progressing to the next NIC (and then the other hosts), this automates the testing process.
A blueprint for the expected network connectivity is defined at the top of the code (If I assign THIS IP to a vmk attached to THIS NIC (using THIS SUBNET MASK) I should be able to ping THIS TARGET IP. Any number of NICS to test can be added, the code loops through them in turn and returns an "OK" or "FAIL" message for each ping test.

## Example Output
Test MyHost1.MyDomain.com vmnic0 OK
Test MyHost1.MyDomain.com vmnic1 OK
Test MyHost1.MyDomain.com vmnic4 OK
Test MyHost1.MyDomain.com vmnic5 OK
