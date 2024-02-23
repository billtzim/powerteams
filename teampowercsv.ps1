#2) Για όσους επιθυμούν να κάνουν ενέργειες μέσω του Windows PowerShell, παραθέτω μερικές αρχικές πληροφορίες:
#- Θα χρειαστεί να εγκαταστήσετε το module: MicrosoftTeams (https://www.powershellgallery.com/packages/MicrosoftTeams/)
#- Κάνετε connect-MicrosoftTeams με τον λογαριασμό teleconf....@o365.uth.gr
#- Κατόπιν διαχειρίζεστε τις ομάδες Teams στις οποίες είστε Owner, με εντολές του module: https://docs.microsoft.com/en-us/powershell/module/teams/?view=teams-ps
#ΕΦΙΣΤΩ ΠΡΟΣΟΧΗ στη χρήση εντολών που δεν ξεκινούν από Get- (πχ. Add- Set- , Remove- κτλ) καθώς επεμβαίνουν σε ρυθμίσεις στα Teams.
#Οι εντολές Get- έχουν χαρακτήρα "Read-Only", πχ.:
#get-Team -User teleconf....@o365.uth.gr | Format-Table -Property DisplayName
#ή
#Get-Team | Group-Object description | Format-Table -Property groupid,displayname,description -AutoSize | Out-File -FilePath c:\UThMsTeams.txt


# Path to your CSV file
$csvFile = "d:\tests\powercsv\courses_codes_econ.csv"

# Read CSV file
$lines = Import-Csv -Path $csvFile

# Create a form
$form = New-Object System.Windows.Forms.Form
$form.Text = "CSV Line Selector"
$form.Size = New-Object System.Drawing.Size(600,400)

# Create a ListBox to display the lines
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(400,320)
$listBox.SelectionMode = "MultiExtended"

# Add lines from CSV to ListBox
foreach ($line in $lines) {
    $listBox.Items.Add($line) | Out-Null
}

# Create a Button to execute command with selected lines as parameters
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(420,40)
$button.Size = New-Object System.Drawing.Size(150,23)
$button.Text = "Run Command"
$button.Add_Click({
    $selectedLines = @()
    foreach ($item in $listBox.SelectedItems) {
        $selectedLines += $item
    }
    $parameters = $selectedLines -join " "
    # Replace the following command with your actual PowerShell command
    Write-Host "Your PowerShell command with parameters: YourCommand $parameters"
})

# Add controls to the form
$form.Controls.Add($listBox)
$form.Controls.Add($button)

# Show the form
$form.ShowDialog() | Out-Null
