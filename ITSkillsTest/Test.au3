#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>

Global $iniFile = "settings.ini"
Global $iniFilePath = @ScriptDir & "\" & $iniFile

Global $resultsFile = "results.txt"
Global $resultsFilePath = @ScriptDir & "\" & $resultsFile

Global $printerPageTitle, $biosVersion, $iSeconds
Global $photoName = "photo.jpg"

If FileExists($iniFilePath) = False Then ;Checks if settings.ini exists. If not, creates it and opens the program once it exists.
	ProgressOn(@ScriptName, "Creating Settings file....", "0%")
	create_ini()
	For $i = 10 To 100 Step 10
		Sleep(200)
		ProgressSet($i, $i & "%")
	Next
	ProgressSet(100, "Done", "Complete")
	Do
		Sleep(100)
	Until FileExists($iniFilePath) = True
	ProgressOff()
	MsgBox(4,"Setup","Values must be configured. Refer to comments in ini.")
	ShellExecute($iniFilePath)
Else
	Sleep(10)
EndIf

If FileExists($resultsFilePath) = False Then ;Checks if results.txt exists. If not, creates it
	_FileCreate($resultsFile)
EndIf

ini_read()

If $printerPageTitle = "" Or $biosVersion = "" Or $iSeconds = "" or $photoName = "" Then
	If MsgBox(4+16, "ini problem", "At least one value inside the settings.ini file is blank. The test will not be completable." & @CRLF & @CRLF & _
								"Click yes to exit and open the settings file, or click no to continue anyway") = 6 Then
	ShellExecute($iniFilePath)
	Exit 369
	EndIf
EndIf

HotKeySet("^!+r", "Reveal") ; Ctrl + Alt + Shift + R

Global $ipv4 = "wrongwrongwrongwrong"
Global $printerpage = False
Global $sharedphoto = False
Global $strFail = "✕"
Global $strPass = "✓"
Global $outOfTime = False
Global $numChallenges = 6
Global $xClicks = 0
Global $clickmsg = ""
Global $exitAssess = False
Global $lowOnTime = 60 ; Seconds remaining before "lowtime" sound cue plays
$introMsg = "Welcome to the hands-on skills assessment!" & @CRLF & @CRLF & "You will have 17 minutes to complete 6 tasks."  & @CRLF & @CRLF & _
			"When a task is complete, the relative red X will turn into a green check mark." & @CRLF & @CRLF & "Click OK to start the timer and begin the assessment."

MsgBox(64, "", $intromsg)
SndPlay("yes")

#Region GUI_MAIN
$GUI_MAIN = GUICreate("IT Test", 396, 291, @DesktopWidth/2-290, @DesktopHeight/2-200)

$lab1 = GUICtrlCreateLabel("Enter the device name for this computer:", 16, 16, 160, 33)
$inPCname = GUICtrlCreateInput("", 16, 56, 125, 21)
$lab_pf1 = GUICtrlCreateLabel($strFail, 155, 48, 45, 32)
$Group1 = GUICtrlCreateGroup("", 6, 4, 195, 85)

$Label2 = GUICtrlCreateLabel("Connect the computer to the internet to reveal this question", 16, 112, 160, 33)

$Input2 = GUICtrlCreateInput("", 16, 152, 125, 21)
$lab_pf2 = GUICtrlCreateLabel($strFail, 155, 144, 45, 32)
$Group2 = GUICtrlCreateGroup("", 6, 96, 195, 85)
$Label3 = GUICtrlCreateLabel("On PC3, boot into BIOS to obtain the BIOS version and enter it below", 16, 200, 180, 33)
$Input3 = GUICtrlCreateInput("", 16, 240, 125, 21)
$lab_pf3 = GUICtrlCreateLabel($strFail, 155, 232, 45, 32)
$Group3 = GUICtrlCreateGroup("", 6, 186, 195, 85)

$Label7 = GUICtrlCreateLabel("Connect this computer to the internet.", 220, 20, 116, 34)
$lab_pf4 = GUICtrlCreateLabel($strFail, 350, 18, 45, 34)
$Group4 = GUICtrlCreateGroup("", 208, 4, 180, 55)

$Label5 = GUICtrlCreateLabel("Add the HP LaserJet printer to this PC and then open it's web interface for configuration.", 216, 80, 128, 80)
$lab_pf5 = GUICtrlCreateLabel($strFail, 350, 90, 45, 32)
$Group5 = GUICtrlCreateGroup("", 208, 65, 180, 80)

$Label8 = GUICtrlCreateLabel("SAFELY close the scam popup on PC2, network share the desktop folder, and open the photo inside on this PC.", 216, 162, 125, 70)
$lab_pf6 = GUICtrlCreateLabel($strFail, 350, 175, 45, 32)
$Group5 = GUICtrlCreateGroup("", 208, 146, 180, 90)

$timer = GUICtrlCreateLabel("00:00", 275, 245, 116, 30)
GUICtrlSetFont(-1, 20, 800)

For $i = 1 to 6		;makes all pass/fail labels bold
	GUICtrlSetFont(Eval("lab_pf" & $i), 20, 900)
Next

GUISetState(@SW_SHOW)
#EndRegion GUI_MAIN

Check()
AdlibRegister("Check", 500)
AdlibRegister("UpdateTimer", 1000)
AdlibRegister("Check2", 2000)

#Region Main Loop
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Disable()
			$xClicks += 1
			If $xClicks >= 2 Then $clickMsg = "You've tried exiting " & $xClicks & " times so far"
			If MsgBox(19, "Confirmation", "Are you super sure you'd like to exit?" & @CRLF & $clickMsg) = 6 Then
				$exitAssess = True
				Assessment()
				Exit
			EndIf
			Enable()
	EndSwitch
	sleep(50)
WEnd
#EndRegion Main Loop

#Region Functions
Func Check() ;Adlibbed
	For $i = 1 to 6
		If GUICtrlRead(Eval("lab_pf" & $i)) == $strPass Then
			GUICtrlSetColor(Eval("lab_pf" & $i), 0x228C22) ; Green color
		ElseIf GUICtrlRead(Eval("lab_pf" & $i)) == $strFail Then
			GUICtrlSetColor(Eval("lab_pf" & $i), 0xFF0000) ; Red color
		EndIf
	Next

	; Check if device name input is correct
	If StringLower(GUICtrlRead($inPCname)) == StringLower(@ComputerName) Then
		GUICtrlSetData($lab_pf1, $strPass)
	Else
		GUICtrlSetData($lab_pf1, $strFail)
	EndIf

	; Check if ipv4 input is correct
	If NetworkConnected() And GUICtrlRead($Input2) == $ipv4 Then
		GUICtrlSetData($lab_pf2, $strPass)
	Else
		GUICtrlSetData($lab_pf2, $strFail)
	EndIf

	; Check if BIOS version input is correct
	If GUICtrlRead($Input3) == $BIOSVersion Then
		GUICtrlSetData($lab_pf3, $strPass)
	ElseIf GUICtrlRead($Input3) <> $BIOSVersion Then
		GUICtrlSetData($lab_pf3, $strFail)
	EndIf

	; Check if Network Connection is online
	If NetworkConnected() Then
		GUICtrlSetData($lab_pf4, $strPass)
		GUICtrlSetData($Label2, "Obtain the ipv4 address of this device and enter it here:")
	Else
		GUICtrlSetData($lab_pf4, $strFail)
		GUICtrlSetData($Label2, "Connect the computer to the internet to reveal this question")
	EndIf

	; Check if Printer Settings page has been opened
	If $printerpage == True Then
		GUICtrlSetData($lab_pf5, $strPass)
	Else
		GUICtrlSetData($lab_pf5, $strFail)
	EndIf

	; Check if photo.jpg has been opened
	If $sharedphoto = True Then
		GUICtrlSetData($lab_pf6, $strPass)
	Else
		GUICtrlSetData($lab_pf6, $strFail)
	EndIf

	; Check if all of the pass/fail labels are set to pass
	If GUICtrlRead($lab_pf1) = $strPass And _
		GUICtrlRead($lab_pf2) = $strPass And _
		GUICtrlRead($lab_pf3) = $strPass And _
		GUICtrlRead($lab_pf4) = $strPass And _
		GUICtrlRead($lab_pf5) = $strPass And _
		GUICtrlRead($lab_pf6) = $strPass Then Assessment()
EndFunc

Func CountPasses()
    Local $count = 0

    ; Array of label IDs
    Local $labels[6] = [$lab_pf1, $lab_pf2, $lab_pf3, $lab_pf4, $lab_pf5, $lab_pf6]

    ; Loop through each label
    For $i = 0 To UBound($labels) - 1
        If GUICtrlRead($labels[$i]) = $strPass Then
            $count += 1
        EndIf
    Next

    Return $count
EndFunc

Func Assessment()
	SndPlay("tada")
	For $i = 1 to $numChallenges
		Assign("pf" & $i, "FAIL")
	Next

	If GUICtrlRead($lab_pf1) = $strPass Then $pf1 = "PASS"
	If GUICtrlRead($lab_pf2) = $strPass Then $pf2 = "PASS"
	If GUICtrlRead($lab_pf3) = $strPass Then $pf3 = "PASS"
	If GUICtrlRead($lab_pf4) = $strPass Then $pf4 = "PASS"
	If GUICtrlRead($lab_pf5) = $strPass Then $pf5 = "PASS"
	If GUICtrlRead($lab_pf6) = $strPass Then $pf6 = "PASS"

	Local $msg1 = "Thank you for completing the skills assessment!"

	If $exitAssess = True Then
		$exitMsg = "**PROGRAM EXITED** --- "
	Else
		$exitMsg = ""
	EndIf

	If $outOfTime = True Then
		Local $msg2 = "You ran out of time"
		Local $hook1 = "Ran out of time"
	Else
		Local $msg2 = "Finished with " & GUICtrlRead($timer) & " to spare"
		Local $hook1 = GUICtrlRead($timer) & " remaining"
	EndIf

	If CountPasses() == $numChallenges Then
		Local $msg3 = "All challenges completed"
		Local $hook2 = "100%"
	Else
		Local $msg3 = CountPasses() & " out of " & $numChallenges & " completed"
		Local $hook2 = CountPasses() & "/" & $numChallenges
	EndIf

	Local $msg4 = "Click OK to close the program"
	Local $hook3 = "X button clicks: " & $xClicks
	Local $message = $exitMsg & $hook1 & " --- " & $hook2 & " --- " & $hook3

	Local $msg2_1 = "Device Name: " & $pf1
	Local $msg2_2 = "ipv4: " & $pf2
	Local $msg2_3 = "Bios: " & $pf3
	Local $msg2_4 = "internet: " & $pf4
	Local $msg2_5 = "printer: " & $pf5
	Local $msg2_6 = "net share: " & $pf6

	Local $message2 = $msg2_1 & ", " & $msg2_2 & ", " & $msg2_3 & ", " & $msg2_4 & ", " & $msg2_5 & ", " & $msg2_6

	FileWrite($resultsFile, _DateAndTime() & @CRLF)
	FileWrite($resultsFile, $message & @CRLF)
	FileWrite($resultsFile, $message2 & @CRLF)
	FileWrite($resultsFile, "" & @CRLF)
	FileWrite($resultsFile, "" & @CRLF)
	MsgBox(48, "Complete", $msg1 & @CRLF & @CRLF & $msg2 & @CRLF & @CRLF & $msg3 & @CRLF & @CRLF & $msg4)
	Exit 1
EndFunc

;~ Func SendWebhook($arg)
;~ 	Local $Url = "https://discord.com/api/webhooks/1316251002940162068/h7GjgSQ8abXAFkM4yHwEujErYBilZOhoSmcKeb18wdW-PV-GBPufsn318dltpQ1EAzhu"
;~     Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
;~     Local $Packet = '{"content": "' & $arg & '"}'
;~     $oHTTP.open('POST',$Url)
;~     $oHTTP.setRequestHeader("Content-Type","application/json")
;~     $oHTTP.send($Packet)
;~ EndFunc

Func Check2() ;adlibbed every 2 seconds
	IsActiveChromeTabOpen($printerPageTitle)
	IsSharedPhotoOpen($photoName)
EndFunc

Func NetworkConnected()
	Local $pingResult = Ping("8.8.8.8") ; Ping Google's DNS server
    If $pingResult > 0 Then
		If $ipv4 = "wrongwrongwrongwrong" Then GetIPv4Address()
        Return True
    Else
        Return False
    EndIf
EndFunc

Func GetIPv4Address()
    ; Run the ipconfig command and capture the output
    Local $sOutput = Run(@ComSpec & " /c ipconfig", @SystemDir, @SW_HIDE, $STDOUT_CHILD)
    Local $sData = ""

    ; Capture the entire output of ipconfig
    While True
        $sData &= StdoutRead($sOutput)
        If @error Then ExitLoop
    WEnd

    ; Use a regular expression to capture only the IPv4 address
    Local $aMatches = StringRegExp($sData, "(?i)IPv4 Address[^\r\n]*:\s*([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)", 3)

    ; Check if there are matches and return the first valid IPv4 address
    If IsArray($aMatches) And UBound($aMatches) > 0 Then
		Global $ipv4 = $aMatches[0]
        Return $aMatches[0] ; Return the matched IP address
    Else
        Return "No IPv4 address found"
    EndIf
EndFunc

Func IsActiveChromeTabOpen($searchTitle)
    Local $hWnd = WinGetHandle("[CLASS:Chrome_WidgetWin_1]")

    If $hWnd Then
        Local $sTitle = WinGetTitle($hWnd)
        If StringInStr($sTitle, $searchTitle) > 0 Then
			Global $printerpage = True
            Return True
        EndIf
    EndIf

	ConsoleWrite("hWnd = " & $hWnd &  " " & VarGetType($hWnd) & @CRLF)
	ConsoleWrite("sTitle = " & $sTitle &  " " & VarGetType($sTitle) & @CRLF)
	ConsoleWrite("searchTitle = " & $searchTitle & " " & VarGetType($searchTitle) & @CRLF)
	ConsoleWrite("printerPageTitle = " & $printerPageTitle & " " & VarGetType($printerPageTitle) & @CRLF)

    Return False
EndFunc

Func IsSharedPhotoOpen($searchTitle2)
	    Local $hWnd = WinGetHandle("photo.jpg")

    If $hWnd Then
        Local $sTitle = WinGetTitle($hWnd)
        If StringInStr($sTitle, $searchTitle2) > 0 Then
			Global $sharedphoto = True
            Return True
        EndIf
    EndIf

    Return False
EndFunc

;~ Func IsSharedPhotoOpen($searchTitle2)
;~ 	If WinExists("photo.jpg") Then
;~ 		Return True
;~ 		Global $sharedphoto = True
;~ 	Else
;~ 		Return False
;~ 	EndIf
;~ EndFunc

Func IsLANConnected()
    ; Run the ipconfig command and store the output
    Local $sOutput = Run(@ComSpec & " /c ipconfig", "", @SW_HIDE, $STDOUT_CHILD)
    Local $sResult = ""

    ; Read the output
    While 1
        Local $sLine = StdoutRead($sOutput)
        If @error Then ExitLoop
        $sResult &= $sLine
    WEnd

    ; Close the run process
    ProcessClose($sOutput)

    ; Check for Ethernet connection in the output
    If StringInStr($sResult, "Ethernet adapter") And StringInStr($sResult, "IPv4 Address") Then
        Return True
    EndIf

    Return False
EndFunc

Func UpdateTimer()
    ; Ensure $iSeconds is defined globally and decrements properly
    $iSeconds -= 1 ; Decrement the seconds counter

	If $iSeconds = $lowOnTime Then
		SndPlay("lowtime")
		LowTime()
	EndIf

    If $iSeconds < 0 Then
        ; Handle timer expiration (optional, e.g., stop updating or show a message)
		$outOfTime = True
        GUICtrlSetData($timer, "00:00")
		Assessment()
        Return
    EndIf

    Local $iMinutes = Floor($iSeconds / 60) ; Calculate minutes
    Local $iRemainingSeconds = Mod($iSeconds, 60) ; Calculate remaining seconds

    ; Format time as mm:ss
    Local $sTime = StringFormat("%02d:%02d", $iMinutes, $iRemainingSeconds)

    ; Update the label with the formatted time
    GUICtrlSetData($timer, $sTime)
EndFunc

Func LowTime()
	Global $oTimer = TimerInit()
	$mPos = MouseGetPos()
	ToolTip("1 minute remaining", $mPos[0], $mPos[1])
	LowTime_t()
	AdlibRegister("LowTime_t", 100)
EndFunc

Func LowTime_t()
	$mPos = MouseGetPos()
	ToolTip("1 minute remaining", $mPos[0], $mPos[1])
	If TimerDiff($oTimer) >= 1000 Then
		ToolTip("")
		AdlibUnRegister("LowTime_t")
	EndIf
EndFunc

Func Disable()
	GUICtrlSetState($inPCname, $GUI_DISABLE)
	GUICtrlSetState($Input2, $GUI_DISABLE)
	GUICtrlSetState($Input3, $GUI_DISABLE)
	Global $blackBox = GUICtrlCreateLabel("", 0, 0, 396, 291)
	GUICtrlSetState($blackBox, $GUI_DISABLE)
EndFunc

Func Enable()
	GUICtrlSetState($inPCname, $GUI_ENABLE)
	GUICtrlSetState($Input2, $GUI_ENABLE)
	GUICtrlSetState($Input3, $GUI_ENABLE)
	GUICtrlDelete($blackBox)
EndFunc

Func Reveal()
	GUICtrlSetData($inPCName, @ComputerName)
	GUICtrlSetData($Input2, GetIPv4Address())
	GUICtrlSetData($Input3, $BIOSVersion)
	$printerpage = True
	$sharedphoto = True
EndFunc

Func _DateAndTime()
    Local $aDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    Local $sDay = $aDays[@WDAY - 1] ; @WDAY returns 1-7, so subtract 1 for array index
    Local $sDate = StringFormat("%02d/%02d/%d", @MON, @MDAY, @YEAR)
    Local $iHour = @HOUR, $sPeriod = "AM"
    If $iHour >= 12 Then
        $sPeriod = "PM"
        If $iHour > 12 Then $iHour -= 12
    ElseIf $iHour = 0 Then
        $iHour = 12
    EndIf
    Local $sTime = StringFormat("%d:%02d %s", $iHour, @MIN, $sPeriod)
    Return $sDay & ", " & $sDate & ", " & $sTime
EndFunc

Func SndPlay($arg)
    If $arg = "tada" Then
        SoundPlay(@WindowsDir & "\media\tada.wav")
    ElseIf $arg = "lowtime" Then
        SoundPlay(@WindowsDir & "\media\Windows Battery Critical.wav")
    ElseIf $arg = "no" Then
        SoundPlay(@WindowsDir & "\media\Windows Notify.wav")
    ElseIf $arg = "yes" Then
        SoundPlay(@WindowsDir & "\Media\Windows Unlock.wav")
    Else
        MsgBox(0,"SndPlay() arg error", 'arg must be "tada", "lowtime", "yes", "no"')
    EndIf
EndFunc
#EndRegion Functions

#Region ini functions
#Region ini Functions
Func ini_read()
	ConsoleWrite("!ini read" & @CRLF)
	Global $search = FileFindFirstFile($iniFilePath)
	Global $sFileName = FileFindNextFile($search)
	If $search = -1 Then
		SoundPlay("Error")
		MsgBox($MB_SYSTEMMODAL + $MB_ICONERROR, "Error", "settings.ini not found" & @CRLF & "The script needs to be in the same folder as the settings file, use a shortcut or something" & @CRLF & @CRLF & "CODE: 111")
		Exit 111
	EndIf
	Global $printerPageTitle = IniRead($sFileName, "variables", "printerpagetitle", "Default")
	Global $biosVersion = IniRead($sFileName, "variables", "biosversion", "Default")
	Global $iSeconds = IniRead($sFileName, "variables", "timelimit", "Default")
EndFunc

Func create_ini()
	_FileCreate($iniFile)
	$testfile = ($iniFilePath)
	FileWrite($testfile, "[variables]" & @CRLF)
	FileWrite($testfile, "printerpagetitle=" & @CRLF)
	FileWrite($testfile, ";the full, exact window title of the printer configuration page" & @CRLF)
	FileWrite($testfile, " " & @CRLF)

	FileWrite($testfile, "biosversion=" & @CRLF)
	FileWrite($testfile, ";the BIOS version of PC3" & @CRLF)
	FileWrite($testfile, " " & @CRLF)

	FileWrite($testfile, "timelimit=" & @CRLF)
	FileWrite($testfile, ";time limit amount in seconds" & @CRLF)
	FileWrite($testfile, " " & @CRLF)
EndFunc
#EndRegion
