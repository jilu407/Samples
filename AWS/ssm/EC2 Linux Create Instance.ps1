﻿# You should define before running this script.
#    $name - Name identifies logfile and test name in results
#            When running in parallel, name maps to unique ID.
#            Some thing like '0', '1', etc when running in parallel
#     $obj - This is a global dictionary, used to pass output values
#            (e.g.) report the metrics back, or pass output values that will be input to subsequent functions

param ($Name = "ssm-linux", $InstanceType = 't2.micro',
        $ImagePrefix='amzn-ami-hvm-*gp2',$Region = 'us-east-1')

Set-DefaultAWSRegion $Region
. "$PSScriptRoot\Common Setup.ps1"

Remove-WinEC2Instance $Name -NoWait


#Create Instance
$userdata = @'
#cloud-config
packages:
- amazon-ssm-agent

runcmd:
- start amazon-ssm-agent

'@.Replace("`r",'')

$userdata = @'
#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

sudo yum -y install amazon-ssm-agent
sudo start amazon-ssm-agent
'@.Replace("`r",'')

$securityGroup = @('test')
if (Get-EC2SecurityGroup -GroupName 'corp') {
    $securityGroup += 'corp'
}

Write-Verbose 'Creating EC2 Windows Instance.'
$global:instance = New-WinEC2Instance -Name $Name -InstanceType $InstanceType `
                        -ImagePrefix $ImagePrefix -Linux `
                        -IamRoleName 'test' -SecurityGroupName $securityGroup -KeyPairName 'test' `
                        -UserData $userdata -SSMHeartBeat 

$obj.'InstanceType' = $Instance.Instance.InstanceType
$Obj.'InstanceId' = $instance.InstanceId
$Obj.'ImageName' = (get-ec2image $instance.Instance.ImageId).Name
$obj.'PublicIpAddress' = $instance.PublicIpAddress
$obj.'SSMHeartBeat' = $instance.Time.SSMHeartBeat

<#
if (-not (Test-Path "$HOME\.ssh" -PathType Container)) {
    throw '.ssh folder not found'
}

$a = (Get-WinEC2ConsoleOutput $instance.InstanceId).split("`n") | where { $_ -like 'ecdsa-sha2-nistp256*' }
$a = $a.Split(' ')
$fingerprint = "$($a[0]) $($a[1])"
$knownhosts = "$HOME\.ssh\known_hosts"
$found = cat $knownhosts | select-string $fingerprint

if ($found.Matches.Count -eq 0) {
    "$($instance.PublicIpAddress) $fingerprint" | Out-File -Encoding ascii -Append  $knownhosts
    Write-Verbose "Added $fingerprint to $knownhosts"
}

#>



<#
#Install Onprem Agent
Write-Verbose 'Install onprem agent on EC2 Windows Instance'
$data = Get-WinEC2Password $obj.'InstanceId'
$secpasswd = ConvertTo-SecureString $data.Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("Administrator", $secpasswd)
$connectionUri = "http://$($obj.'PublicIpAddress'):80/"

$obj.'ActivationId' =  SSMInstallAgent -ConnectionUri $connectionUri -Credential $cred -Region $region -DefaultInstanceName $Name

#Onprem Run Command
Write-Verbose 'Onprem Run Command on EC2 Windows Instance'
$filter = @{Key='ActivationIds'; ValueSet=$Obj.'ActivationId'}
$mi = (Get-SSMInstanceInformation -InstanceInformationFilterList $filter).InstanceId

$startTime = Get-Date
$command = SSMRunCommand -InstanceIds $mi -SleepTimeInMilliSeconds 1000 `
    -Parameters @{commands='ipconfig'}

$obj.'OnpremCommandId' = $command
$obj.'OnpremRunCommandTime' = (Get-Date) - $startTime
SSMDumpOutput $command
#>