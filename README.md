# Compress log files with Powershell 5.X

Author : Bilgin Işık

Attention : 
Because Compress-Archive relies upon the Microsoft .NET Framework API System.IO.Compression.ZipArchive to compress files, 
the maximum file size that you can compress by using Compress-Archive is currently 2 GB. This is a limitation of the underlying API.

Requirements : 
Compress-Archive works with only PS Version 5.x and .Net Framework 4.5 or greater. 
PS Version greater than 5


Example usage of script :

Path is mandotory.

.\compress-logs.ps1 -Path C:\TempLogs
.\compress-logs.ps1 -Path C:\TempLogs -Filter log,txt,console >> Default is "log,txt"
.\compress-logs.ps1 -Path C:\TempLogs -DaysBack 15 >> Default is 5
.\compress-logs.ps1 -Path C:\TempLogs -ArchiveName LogArchive >> Default is "Logs"

You can combine the parameters.  
