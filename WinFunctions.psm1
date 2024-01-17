# This Module is for Windows Function like changing the Language

Function Write-Log {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True)]
    [String]$Message,

    [Parameter(Mandatory=$False)]
    [String]$File
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$($timestamp): $Message" | Out-File -FilePath $File -Append
}
function Set-Language {
    param (
        #Sprache
        [Parameter(Mandatory = $false, HelpMessage = "Set the Language and Format on Windows (de-CH, en-US etc.)")]
        [string]$DisplayLanguage = "",

        [Parameter(Mandatory = $false, HelpMessage = "Set the Keyboard Language on Windows")]
        [string]$KeyboardLanguage = "",
        [Parameter(Mandatory = $false, HelpMessage = "Set the Keyboard Layout on Windows")]
        [string]$KeyboardLayout = "",

        #Region
        [Parameter(Mandatory = $false, HelpMessage = "Set the Region on Windows")]
        [string]$Region= "Invalid", #Ivalid do while loop
        [Parameter(Mandatory = $false, HelpMessage = "Set the Reginal Format on Windows (de-CH, en-US etc.)")]
        [string]$RegionalFormat = "",

        #Format
        [Parameter(Mandatory = $false, HelpMessage = "Set the Time Format on Windows")]
        [ValidateSet("Long dd/MM/yyyy", "Short dd/MM/yy", "USLong yyyy/MM/dd", "USShort yy/MM/dd")]
        $ShortDateFormat = "",
        [Parameter(Mandatory = $false, HelpMessage = "Set the Time Format on Windows")]
        [ValidateSet("Long dd/MM/yyyy", "Short dd/MM/yy", "USLong yyyy/MM/dd", "USShort yy/MM/dd")]
        $LongDateFormat = "",
        [Parameter(Mandatory = $false, HelpMessage = "Set the Time Format on Windows")]
        [ValidateSet(".", ",")]
        $DecimalSeperator = ""
        #etc nach Kundenwunsch...
    )

    # ---------------- Variablen und Module ----------------
    Import-Module international
    $RegPath = "HKCU:\Control Panel\International"
    $ActualDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $Outputpath =  ".\" + "$ActualDate" + "changelanguage.log"

    # Write-Host - Your curent Language settings
    Write-Host "Your current Language and Format settings"
    Write-Host "Display Language: $(Get-WinUILanguageOverride).LanguageTag"
    Write-Host "Keyboard Language: $(Get-WinUserLanguageList).LanguageTag"
    Write-Host "Keyboard Layout: $(Get-WinUserLanguageList).InputMethodTips"
    Write-Host "Region: $(Get-WinHomeLocation).GeoId"
    Write-Host "Regional Format: $(Get-Culture).Name"
    Write-Host "Time Format short: $(Get-ItemProperty -Path HKCU:\Control Panel\International).sShortDate"
    Write-Host "Time Format long: $(Get-ItemProperty -Path HKCU:\Control Panel\International).sLongDate"
    Write-Host "Decimal Seperator: $(Get-ItemProperty -Path HKCU:\Control Panel\International).sDecimal"
    # Write-Log - Your curent Language settings
    Write-Log -Message "Your current Language and Format settings" -File $Outputpath
    Write-Log -Message "Display Language: $(Get-WinUILanguageOverride).LanguageTag" -File $Outputpath
    Write-Log -Message "Keyboard Language: $(Get-WinUserLanguageList).LanguageTag" -File $Outputpath
    Write-Log -Message "Keyboard Layout: $(Get-WinUserLanguageList).InputMethodTips" -File $Outputpath
    Write-Log -Message "Region: $(Get-WinHomeLocation).GeoId" -File $Outputpath
    Write-Log -Message "Regional Format: $(Get-Culture).Name" -File $Outputpath
    Write-Log -Message "Time Format short: $(Get-ItemProperty -Path HKCU:\Control Panel\International).sShortDate" -File $Outputpath
    Write-Log -Message "Time Format long: $(Get-ItemProperty -Path HKCU:\Control Panel\International).sLongDate" -File $Outputpath
    Write-Log -Message "Decimal Seperator: $(Get-ItemProperty -Path HKCU:\Control Panel\International).sDecimal" -File $Outputpath



    $CurrentLanguage = Get-WinUILanguageOverride
    $CurrentLanguage = $CurrentLanguage.LanguageTag

    Write-Host "Set the Language on Windows"
    Write-Log -Message "Set the Language on Windows" -File $Outputpath

    while ($Land -eq "Invalid"){
        $Land = Read-Host "Set Region on Windows, Native Name or English Name"
    }
    while ($RegionalFormat -eq "Invalid"){
        $RegionalFormat = Read-Host "Set Regional Format on Windows, Format: de-CH, en-US etc."
    }
    while ($Language -eq "Invalid"){
        $Language = Read-Host "Set Language on Windows, Format: de-CH, en-US etc."
    }
    while ($KeyboardLanguage -eq "Invalid"){
        $KeyboardLanguage = Read-Host "Set Keyboard Language on Windows, Format: Deutsch (Schweiz) or English (United States)"
    }
    while ($KeyboardLayout -eq "Invalid"){
        $KeyboardLayout = Read-Host "Set Keyboard Layout on Windows, Format: Deutsch (Schweiz) or English (United States)"
    }
    while ($ShortDateFormat -eq "Invalid"){
        $ShortDateFormat = Read-Host "Set Short Date Format on Windows, Format: Short dd/MM/yy"
    }
    while ($LongDateFormat -eq "Invalid"){
        $LongDateFormat = Read-Host "Set Short Date Format on Windows, Format: Long dd/MM/yyyy"
    }
    while ($DecimalSeperator -eq "Invalid"){
        $DecimalSeperator = Read-Host "Set Decimal Seperator on Windows, Format: . or ,"
    }

    # ---------------- Find GeoID ----------------
    if ($Land -ne "") {
        $FindGeoID = "false"
        while ($FindGeoID -eq "false"){
            Write-Host "Searching GeoID..."
            # Zugriff auf die CultureInfo-Klasse des .NET Frameworks, um alle Kulturen zu erhalten
            $cultures = [System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures)
            foreach ($culture in $cultures) { # Durchsuche alle Kulturen, um die entsprechende zu finden
                try {
                    $RegionInfos = New-Object System.Globalization.RegionInfo($culture.Name)
                    if ($RegionInfos.EnglishName -eq $Land -or $RegionInfos.NativeName -eq $Land) {
                        $landCode = $RegionInfos.TwoLetterISORegionName
                        break
                    }
                }
                catch {
                    continue # Ignoriere Fehler und fahre mit der nächsten Kultur fort
                }
            }
            if ($landCode) { # Überprüfe, ob ein Ländercode gefunden wurde
                # Erstelle ein RegionInfo-Objekt für den gefundenen Ländercode und speichere diesen in $GeoID
                $regionInfo = New-Object System.Globalization.RegionInfo $landCode
                $GeoID = $regionInfo.GeoId
                Write-Host "$($Land): GeoID ist $GeoID"
                $FindGeoID = "true"
            }
            else { # Falls kein Ländercode gefunden wurde, gib eine Fehlermeldung aus
                Write-Host "$($Land): Keine GeoID gefunden"
                $Land = Read-Host "Set Region on Windows, Native Name or English Name"
                $FindGeoID = "false"
            }
        }
    }
    # ---------------- Find Keyboard LCID ----------------
    if (($KeyboardLanguage -ne "") -or ($KeyboardLayout -ne "")) {
        $FindKeyboardLCID = "false"
        while ($FindKeyboardLCID -eq "false"){
            Write-Host "Searching Keyboard LCID/imeCode..."
            # Ermittle den passenden Culture-Code für die Sprache und das Layout
            $keyboardLanguageCultureCode = [System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures) | Where-Object { $_.EnglishName -eq $KeyboardLanguage -or $_.NativeName -eq $KeyboardLanguage } |
            Select-Object -ExpandProperty Name -First 1
            if ($keyboardLanguageCultureCode) { # Überprüfe, ob ein KeyboardLanguage CultureCode gefunden wurde
                $cultureInfo = New-Object System.Globalization.CultureInfo $keyboardLanguageCultureCode
                # Ermittle die KeyboardLanguageId und Zeige die KeyboardLanguageId an
                $keyboardLanguageId = "0" + $cultureInfo.KeyboardLayoutId.ToString("X")
                $FindKeyboardLanguageLCID = "true"
            }
            else {
                Write-Host "Kein LCID/imeCode für die Keyboard Sprache $KeyboardLanguage gefunde"
                $FindKeyboardLCID = "false"
                $KeyboardLanguage = Read-Host "Set Keyboard Language on Windows, Format: Deutsch (Schweiz) or English (United States)"
                $FindKeyboardLanguageLCID = "false"
            }
            $keyboardLayoutCultureCode = [System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures) | Where-Object { $_.EnglishName -eq $KeyboardLayout -or $_.NativeName -eq $KeyboardLayout } |
            Select-Object -ExpandProperty Name -First 1
            if ($keyboardLayoutCultureCode) { # Überprüfe, ob ein KeyboardLayout CultureCode gefunden wurde
                $cultureInfo = New-Object System.Globalization.CultureInfo $keyboardLayoutCultureCode
                # Ermittle die KeyboardLayoutId und Zeige die KeyboardLayoutId an
                $keyboardLayoutId = "0000" + $cultureInfo.KeyboardLayoutId.ToString("X")
                $FindKeyboardLayoutLCID = "true"
            }
            else {
                Write-Host "Kein LDIC/imeCode für das Keyborad Layout $KeyboardLayout gefunde"
                $KeyboardLayout = Read-Host "Set Keyboard Layout on Windows, Format: Deutsch (Schweiz) or English (United States)"
                $FindKeyboardLayoutLCID = "false"
            }
            if (($FindKeyboardLanguageLCID -eq "true") -and ($FindKeyboardLayoutLCID -eq "true")){
                $imeCode = $keyboardLanguageId + ":" + $keyboardLayoutId
                Write-Host "Found Keyboard LCID, imeCode is $imeCode"
                #$imeCode = $regionInfo.GeoId.ToString("X4") + ":" + $keyboardLayoutId
                $FindKeyboardLCID = "true"
            }
            else {
                $FindKeyboardLCID = "false"
            }
        }
    }

    # ---------------- Bestätigung ----------------
    # Ausgabe der gefundenen Informationen
    Write-Host "Your Input:"
    Write-Host "Language: $Language"
    Write-Host "Region: $GeoID ($Land, $($regionInfo.DisplayName))"
    Write-Host "Keyboard Language $KeyboardLanguage and Layout $KeyboardLayout : $imeCode"
    Write-Host "ShortDateFormat: $ShortDateFormat"
    Write-Host "LongDateFormat: $LongDateFormat"
    Write-Host "DecimalSeperator: $DecimalSeperator"

    # Ausgabe der gefundenen Informationen in eine Log-Datei
    Write-Log -Message "Your Input" -File $Outputpath
    Write-Log -Message "Language: $Language" -File $Outputpath
    Write-Log -Message "Region: $GeoID ($Land, $($regionInfo.DisplayName))" -File $Outputpath
    Write-Log -Message "Keyboard Language $KeyboardLanguage and Layout $KeyboardLayout : $imeCode" -File $Outputpath
    Write-Log -Message "ShortDateFormat: $ShortDateFormat" -File $Outputpath
    Write-Log -Message "LongDateFormat: $LongDateFormat" -File $Outputpath
    Write-Log -Message "DecimalSeperator: $DecimalSeperator" -File $Outputpath

    $Confirm = Read-Host "Do you want to continue? (y/n)"
    if ($Confirm -eq "y") {
        Write-Host "Continue..."
    }
    else {
        Write-Host "Exit..."
        exit
    }

    # ---------------- Implementierung ----------------
    # Region anpassen
    if ($GeoID -ne "") {
        Write-Host "Changing Region..."
        Set-WinHomeLocation -GeoId $GeoID
    }
    # Reionales Format anpassen
    if ($RegionalFormat -ne "") {
        Write-Host "Changing Regional Format..."
        Set-Culture -CultureInfo $RegionalFormat
    }
    
    if ($Language -ne "") {
        # Anzeigesprache anpassen
        Write-Host "Changing Display Language..."
        Set-WinUILanguageOverride -Language $Language
        # Bevorzugte Sprache anpassen
        Write-Host "Changing preferred Language..."
        $languageList = New-WinUserLanguageList $Language
        $languageList[0].Handwriting = 0
        # Tastaturlayout anpassen
        Write-Host "Changing Keyboard Layout..."
        $languageList[0].InputMethodTips.Clear()
        $languageList[0].InputMethodTips.Add($imeCode)
        Set-WinUserLanguageList $languagelist -Confirm:$false -Force
    }
    # Format anpassen
    Write-Host "Changing Format Settings..."
    $formatKeys = @{
        sDecimal = $DecimalSeperator
        sShortDate = $ShortDateFormat
        sLongDate = $LongDateFormat
    }
    $formatKeys.keys | ForEach-Object {
        Set-ItemProperty -Path $RegPath -Name $_ -Value $formatKeys[$_]
    }
    Write-Host "`nSuccessfully changed the language settings!"
}
function Set-Taskbar {
    param (
        $Device = ""
    )
    If($Device -eq "StandardPC"){
        #Script
    }
}
function Set-Desktop {
    param (
        $Device = ""
    )
    If($Device -eq "StandardPC"){
        #Script
    }
}
function Set-Wallpaper {
    param (
        $Device = ""
    )
    If($Device -eq "StandardPC"){
        #Script
    }
}
function Set-Startmenu {
    param (
        $Device = ""
    )
    If($Device -eq "StandardPC"){
        #Script
    }
}
