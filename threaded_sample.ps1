Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

Import-Module -Name Activedirectory
$OU_path = "OU=LabSystems,OU=COMPUTERS-OU,DC=pclabs,DC=itc,DC=auth,DC=gr"
$mysqlexePath = "F:\scripts\mysql.exe"

Clear-Host
$numThreads = 25

$wmiloggedinuser = 
{
    Param($ComputerName = "Localhost", $LabOUName = "ouname")
    
    $username = $null
    $Ping=new-object System.Net.NetworkInformation.Ping
    if ($Ping.send($ComputerName,2000).Status -eq "Success") {
        $username = Get-WmiObject -ComputerName $ComputerName -Class win32_process -Filter "name='explorer.exe'" | ForEach-Object { $_.GetOwner().User }
    }
    
    IF([string]::IsNullOrEmpty($username)) {            
        return "insert into pclabs_status values('','free','" + $ComputerName + "','" + $LabOUName + "');"
    }else{
        return "insert into pclabs_status values('','taken','" + $ComputerName + "','" + $LabOUName + "');"
    }
}

$labComputers = Get-ADComputer -Server authsrv1.pclabs.itc.auth.gr -Filter {Enabled -eq $true} -Properties Name,CanonicalName -SearchBase $OU_path

$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $numThreads)
$RunspacePool.Open()

$Jobs = @()

ForEach($computer in $LabComputers)
{
    $OUName = ($computer.CanonicalName | Out-String).replace("`n","").replace("`r","").split("/")[3]
      
    $Job = [powershell]::Create().AddScript($wmiloggedinuser).AddParameter("ComputerName", $computer.Name).AddParameter("LabOUName", $OUName)
    $Job.RunspacePool = $RunspacePool
    $Jobs += New-Object PSObject -Property @{
      RunNum = $_
      Job = $Job
      Result = $Job.BeginInvoke()
   }    
}
 
# EndInvoke returns the objects from the background threads 
$pcstatusout = "TRUNCATE pclabs_status;"

$JobCounter = 0;
$totalStatusQ = $null

ForEach ($Job in $Jobs)
{   
    #$Job.Job.EndInvoke($Job.Result) | Out-File -Append -Encoding UTF8 C:\Users\administrator.CCF2\Documents\pc_status2.csv
    $pcstatusout += $Job.Job.EndInvoke($Job.Result)
    if(($JobCounter++) % 120 -eq 0) 
    {
        $totalStatusQ += '|' + $pcstatusout
        $pcstatusout = ''
    }
}

$totalStatusQ.Substring(1).Split("|") | ForEach-Object {
    &cmd /c $mysqlexePath -s --default-character-set=utf8 -D pclabs_freepcs -h db.ccf.auth.gr -u YYYYYY -pXXXXXX -e "$pcstatusout" | Out-Null
}

$countPerLab = Get-ADComputer -Server authsrv1.pclabs.itc.auth.gr -SearchBase $OU_path -Filter {Enabled -eq $true} -Properties CanonicalName | Group-Object -NoElement {($_.CanonicalName -Split "/")[3]}

$labsOuQuery="TRUNCATE pclabs_labs;"

foreach($lab in $countPerLab)
{
    $labFullname = Get-ADOrganizationalUnit -Server authsrv1.pclabs.itc.auth.gr -Filter {Name -like $lab.Name} -Properties Description -SearchBase $OU_path

    If(-Not [string]::IsNullOrEmpty($labFullname.Description))
    {
        $labsOuQuery += "INSERT INTO pclabs_labs VALUES ('"+ $lab.Name +"','"+$labFullname.Description+"','"+$lab.Count+"');"
        #ON DUPLICATE KEY UPDATE labCapacity='"+$lab.Count+"',labFullname='"+$labFullname.Description+"';"
    }
}

&cmd /c $mysqlexePath -s --default-character-set=utf8 -D pclabs_freepcs -h db.ccf.auth.gr -u YYYYYYY -pXXXXXXX -e "$labsouquery" | Out-Null