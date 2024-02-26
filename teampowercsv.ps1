Clear-Host

Connect-MicrosoftTeams

# Define concurrent threads
$numThreads = 25

# Define the path to your CSV file (same folder)
$csvFilePath = "D:\Repositories\powerteams\simple_courses_codes_econ.csv"
#$csvFilePath = "simple_courses_codes_econ.csv" # use in Unix like systems to save in local folder, no full path required

$resultCSVFilename = "D:\Repositories\powerteams\threadedTeamsCreated.csv"
#$resultCSVFilename = "threadedTeamsCreated.csv" # use in Unix like systems to save in local folder, no full path required

$csvheader = 'GroupID,Title,Description,Owner'

$createTeam = 
{
    Param($TeamTitle = "GenericTitle", $TeamDescr = "GenericDescr", $TeamOwner = "teleconf.econ@o365.uth.gr")
    
    $group = $null
    
    $group = New-Team -DisplayName $TeamTitle -Description $TeamDescr -AllowGiphy $false -AllowDeleteChannels $false -AllowCreateUpdateRemoveTabs $false -AllowCreateUpdateRemoveConnectors $false -AllowCreateUpdateChannels $false -AllowAddRemoveApps $false

    IF($group.GroupId) {
        Add-TeamUser -GroupId $group.GroupId -User "vtzimourtos@o365.uth.gr" -Role Owner
        return $group.GroupID + ',' + $TeamTitle + ',' + $TeamDescr + ',' + $TeamOwner
    } else {
        return 'ERROR WHILE CREATING' + $delimiter + $TeamTitle + $delimiter + $TeamDescr + $delimiter + $TeamOwner
    }
}


# Read the CSV file
$teamscsv = Import-Csv -Path $csvFilePath

#define thread pool for jobs
$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $numThreads)
$RunspacePool.Open()

$Jobs = @()

ForEach($team in $teamscsv)
{

    $Job = [powershell]::Create().AddScript($createTeam).AddParameter("TeamTitle", $team.Title).AddParameter("TeamDescr", $team.Description).AddParameter("TeamOwner", $team.Owner)

    $Job.RunspacePool = $RunspacePool
    $Jobs += New-Object PSObject -Property @{
      RunNum = $_
      Job = $Job
      Result = $Job.BeginInvoke()
   }    
}

Set-Content -Path $resultCSVFilename -Value $csvheader -Encoding UTF8

ForEach ($Job in $Jobs)
{   
    # EndInvoke returns the objects from the background threads 
    $Job.Job.EndInvoke($Job.Result) | Out-File -Append -Encoding UTF8 $resultCSVFilename
}
