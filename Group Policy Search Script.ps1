function parseAD
{
    param (
    [string]$gu_id

    )
    $array123 =@()
    write-host "________________________________________________"
    write-host ""
    write-host "Your search for keyword $global:searchy has returned the following Group Policies...."
    write-host ""
foreach ($gu_id in $global:guidsreturned){

   write-host $gu_id "returned the following GPO name "(get-gpo -guid $gu_id -domain $global:domain).DisplayName}
   write-host ""

   write-host "________________________________________________"
    
    break
    

}


function Show-Menu
{
    param (
        

        [string]$Title = 'Found these GPO GUIDS'
        )


   Clear-Host
   Write-Host "================ $Title ================"
   Write-Host " "

  $i = 0
while ($i -lt $global:maxresults){

write-host "Your search retuened the following Group Policy GUIDs.  Search for the Group Policy friendly name???"
write-host "_______________________________________________"
write-host""


foreach ($guid in $global:guidsreturned){$returnedarr+=$guid;


Write-Host "[$i] for $guid"


    $i++


}
write-host "________________________________________________"

write-host " "

$search = read-host "Yes or No (Y/N)"

if($search -eq "y" ){

ParseAD
}
}
}





#Search functionality


#Input search string
#$global:searchy = read-hst -prompt " Enter the GPO search word to find related Group Policies"
$global:searchy = "peanut"
#$global:sysvolpath = read-host -prompt " Enter the UNC Path of your SYSVOL Domain E.G \\localhost\SYSVOL\beagleTown.co.uk"
$global:sysvolpath = "c:\windows\SYSVOL"
#$global:domain = read-host -prompt " Please enter the FQDN name of your AD Domain E.G Beagletown.co.uk"
$global:domain = "Beagletown.co.uk"

$guidarr = @()
#$guidreg = '{([^/)]+)}'

$guidreg = '(?<={)(.*)(?=})'


#Get-ChildItem c:\*.txt -Recurse | Select-String -Pattern EX

$foundinside = Get-ChildItem -path $global:sysvolpath -Recurse | Select-String -pattern $global:searchy | where {$_.path -notlike 'InputStream'} | select path
$foundinpath = Get-ChildItem -path $global:sysvolpath -Recurse | Where-Object {$_.PSIsContainer -eq $true -and $_.Name -match $global:searchy}| resolve-path # | select Providerpath
$foundingponame = get-gpo -All | where {$_.displayname -match $global:searchy} | select id

$firststring1 = $foundinside | out-string
$secondstring = $foundinpath | out-string
$thirdstring = $foundingponame 

$firststring = $firststring1 -split 'C:\\'



foreach($guid in $firststring){if ($reg = [Regex]::Matches($guid, $guidreg)){
    
           $guidarr += $reg 
            }
            
      
foreach($guid in $secondstring){if ($reg = [Regex]::Matches($guid, $guidreg)){
    
           $guidarr += $reg 
            }
            

foreach($guid in $thirdstring){
           $guidarr += $guid 
            }
            }
            }
            
   
$guidarr1 = $guidarr | foreach {
    [PSCustomObject]@{

        MyValue  = "$($_.Value)$($_.ID)"
    }   
}


            
      
$global:maxresults = ($guidarr1.myvalue | select -unique).count 
$global:guidsreturned = $guidarr1.myvalue | sort-object -Unique

show-menu


