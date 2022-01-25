#NAME: monitorScripts.ps1
#SYNOPSIS: monitorScripts.ps1
#DESCRIPTION:
# In diesem Script wird ein bestimmter Ordner der über die sich öffnende Konsole angegeben werden muss überwacht.
# Es werde alle changes (rename, create, delete, update) in einem Logfile das pro Tag asugestellt wird angegeben, was einem beim Arbeitsjournal schreiben helfen kann.
#PARAMETER:
# keine
#
#AUTOREN: @NINO.NUFRIO
#VERSION: 1.0.5
#DATUM: 25.01.2022

### Set needed methodes + variables
    function Get-PathToObservedDirecotyNN {
        ### Example for input: "E:\BBW\Module\sem5\cavouti\scripts\"
        return Read-Host -Prompt 'Input the absolute path to the directory that must be observed'
    }

    function Get-BasePathToLogsDirecotyNN {
        ### Example for input: "E:\BBW\Module\sem5\cavouti\logs\"
        return Read-Host -Prompt 'Input the absolute path to the directory that the logs must be'
    }
    
    function Get-IncludeSubdirectoriesNN {
        $includeSubdirectories = Read-Host -Prompt 'Should it observe all the sub directorie? (yes/no)'
        if ( $includeSubdirectories -eq 'yes') {
            return $true
        } else {
            return $false
        }
    }

### Get basePath from user input
    $basePathToLogsDirecoty = Get-BasePathToLogsDirecotyNN

### Set folder to watch + subfolder YES/NO
    $filewatcher = New-Object System.IO.FileSystemWatcher
    
    #Get directory to observe from user input
    $pathToObservedDirecoty = Get-PathToObservedDirecotyNN
    $filewatcher.Path = $pathToObservedDirecoty
    $filewatcher.Filter = "*.*"
    
    #Get if u should include subdirecotories to observation from  user input
    $includeSubdirectories = Get-IncludeSubdirectoriesNN
    $filewatcher.IncludeSubdirectories = $includeSubdirectories
    $filewatcher.EnableRaisingEvents = $true

### Set action when event is triggered
    $writeaction = {
                #Load changetype of change
                $changeType = $Event.SourceEventArgs.ChangeType
                #Get path from change
                $path = $Event.SourceEventArgs.FullPath
                #Get date of change
                $dateTime = Get-Date

                #Process the values for creating the logfile
                $year = (Get-Date -UFormat %Y)
                $weak = (Get-Date -UFormat %V)
                $dayName = (Get-Date -UFormat %A) 

                #Concat logline
                $logline = "$changeType at $dateTime on $path"
                #Concat path to logfile
                $pathToLogFile = $basePathToLogsDirecoty + $year + '\w' + $week + '\' + $dayName + '-Logs.txt'
                mkdir -p ($basePathToLogsDirecoty + $year + '\w' + $week + '\')
      
                #Write logline to logfile
                Add-content $pathToLogFile -Value $logline
              }

### Set which events must be watched 
    Register-ObjectEvent $filewatcher "Created" -Action $writeaction
    Register-ObjectEvent $filewatcher "Changed" -Action $writeaction
    Register-ObjectEvent $filewatcher "Deleted" -Action $writeaction
    Register-ObjectEvent $filewatcher "Renamed" -Action $writeaction
    while ($true) {sleep 5}
