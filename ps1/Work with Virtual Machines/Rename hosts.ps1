$iplastnum = 1
$hostnum = 1
$hosts = 1
for($i=1; $i -le $hosts; $i++)
{
    $oldname = '10.10.10.'+$iplastnum
    $newname = '*'+$hostnum+'*'
    write-host $oldname
    write-host $newname
    Rename-Computer -ComputerName $oldname -NewName $newname -LocalCredential * -Force -PassThru -Restart
    $iplastnum++
    $hostnum++
}