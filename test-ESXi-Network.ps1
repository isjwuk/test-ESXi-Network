#----------------------------------------
#-                                      -
#-      Test Network Connectivity       -
#-          on New ESXi Host            -
#- Are physical NICs patched correctly? -
#-           CB 2017-07-18              -
#-                                      -
#----------------------------------------


#----------------------------------------
#-      Define Environment Here         -
#----------------------------------------
#Define Host to Check Here
$vHostName="MyHost1.MyDomain.com"

#Define Network Interfaces Here. For Each NIC add an extra line
#Include the vmnic name, an available IP to temporarily use, a subnet mask, and an IP to ping.
$nics = @{}
$nics.Add("vmnic0",(@{ "HostIP"="192.168.0.7"; "SubnetMask"="255.255.255.0"; "TargetIP"="192.168.0.1" }))
$nics.Add("vmnic1",(@{ "HostIP"="192.168.0.7"; "SubnetMask"="255.255.255.0"; "TargetIP"="192.168.0.1" }))
$nics.Add("vmnic2",(@{ "HostIP"="10.0.1.240"; "SubnetMask"="255.255.255.0"; "TargetIP"="10.0.1.1" }))
$nics.Add("vmnic3",(@{ "HostIP"="10.0.1.240"; "SubnetMask"="255.255.255.0"; "TargetIP"="10.0.1.1" }))

#----------------------------------------
#-      Run Tests on Environment        -
#----------------------------------------
#Connect to Server
Connect-VIServer -Server $vHostName  


foreach($nic in $nics.Keys) #Loop through NICs to test
{
    #Create Virtual Switches
    $Switch1=New-VirtualSwitch -Name "sw_Connectivity_Test" -Nic $Nic
    #Create PortGroups
    $Portgroup1=New-VirtualPortGroup -Name "pg_Connectivity_Test" -VirtualSwitch $Switch1 
    #Create VMK Adapter
    $vmk1=New-VMHostNetworkAdapter -PortGroup $Portgroup1 -VirtualSwitch $Switch1 -IP ($nics."$nic").HostIP -SubnetMask ($nics."$nic").SubnetMask

    #Test the connection
    $esxcli= get-esxcli -V2                                          #Use the ESXCLI to run the ping from the host
    $arguments = $esxcli.network.diag.ping.CreateArgs()
    $arguments.host=($nics."$nic").TargetIP                          #Set IP Address to Ping
    $arguments.count="2"                                             #How Many Times to Ping
    $arguments.interface=$vmk1                                       #Use the configured VMKernel Interface
    $Result=($esxcli.network.diag.ping.Invoke($arguments)).Summary.Recieved
    if ($Result -gt 0) {
        #OK, we got a ping response
        "Test "+$vHostName+" "+$Nic+" OK"
    }else{
        #Not OK. Packets have disappeared into the Ether
        "Test "+$vHostName+" "+$Nic+" Fail"
    }
    #Tidy up- delete all the Networking Components created
    Remove-VMHostNetworkAdapter $vmk1 -Confirm:$false
    Remove-VirtualPortGroup $PortGroup1 -Confirm:$false
    Remove-VirtualSwitch $Switch1 -Confirm:$false
}
#Disconnect from the host
Disconnect-VIServer -Server $vHostName -Confirm:$false

