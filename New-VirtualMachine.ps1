


#$VMHostConfiguration = $null
#$VMHostConfiguration = @{}
#https://social.technet.microsoft.com/wiki/contents/articles/34431.windows-10-enabling-vtpm-virtual-tpm.aspx


$VHDXPath = (Get-VMHost).VirtualHardDiskPath
$VMPath = (Get-VMHost).VirtualMachinePath
$VMSwitch = Get-VMSwitch

$VMName = Read-Host "Please confirm Hyper-V Virtual Machine name.."

Write-Host "Virtual Machine $VMName will be created in Default Path: $VMPath"

$vhdxfile = $VMName+".vhdx"
$diskType = Read-Host "Confirm vhdx type: [F]ixed or [D]ynamically"


foreach ($vhdx in $VHDXPath)

{
    $OSVHDDX = "$VHDXPath"+"\"+$VMName+"\"+"VHDX"+"\"+$vhdxfile
}

if ($diskType -eq "F") {
    New-VHD -Path $OSVHDDX  -Fixed -SizeBytes 90GB
}
elseif ($diskType -eq "D") {
    New-VHD -Path $OSVHDDX -Dynamic -SizeBytes 90GB
}
else {
    Write-Host "Invalid disk type selected. Please run the script again and enter either 'F' or 'D'."
}

Write-Host 90GB vhdx file created: $OSVHDDX. Enter any key to continue..

Get-VHD -Path $OSVHDDX | Select-Object Path, FileSize


$continue = Read-Host -Prompt "Do you want to continue and build a Virtual Machine? Yes[Y]/No[N]"

if ($continue -eq "N") {
  Write-Host "Exiting, No VM has been created."
  exit
}

$NewVMParams =@{
    Name = $VMname
    MemoryStartupBytes = 4096MB
    Generation = 2
    VHDPath = $OSVHDDX
    BootDevice = "NetworkAdapter"
    SwitchName = "default switch"
    Path = $VMPath
}

New-VM @NewVMParams 

Write-Host configuring virtual machine settings..
Write-Host Disabling Dynamic memory..
Set-VMMemory -VMName $VMname -DynamicMemoryEnabled $false
Write-Host Processor count set to 4..
Set-VMProcessor -VMname $VMname -count 4
Write-Host Disabling automatic checkpoints..
Set-VM -VMName $VMname -AutomaticCheckpointsEnabled $false
Write-Host Setting the automatic start action to Do Nothing..
Set-VM -VMName $VMname -AutomaticStartAction Nothing
Write-Host Attaching VMDvdDrive to virtual machine..
Add-VMDvdDrive -VMName $VMname -Path $null
Write-Host Enabling TPM..
Enable-VMTPM -VMName $VMName
Write-Host Gen 2 Hyper-V vrtual machine $VMname created..
Get-VM -VMName $VMname