
#Region declarations
#include <ButtonConstants.au3>
#include <GWA2.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <SimpleInventory.au3>
#EndRegion

Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Opt("TrayIconHide", 1)


#cs
	~Farms Chest from Boreal Station

	Build:

	1. Dwarven Stability
	2. Dash
	3. "I AM UNSTOPPABLE" (Optional, select in GUI)
	4. None
	5. None
	6. None
	7. None
	8. None

	Weapons & Equipment:
	Any Armor
	Any Staff w/ 20% Enchant

	Upgrades by Zaishen/RiflemanX 3.19.19

	~Updated v1.0
	~Resized GUI
	~Added Render
	~Added PurgeHook
	~Relocated Buttons
	~Removed Time Stamp
	~Added Drop-Down Login Box
	~Added Lockpicks Remaining Counter
	~Added Treasure Hunter display counter
	~Removed unnecessary sleep times (10 seconds faster now)

	Updated v1.1
	~Corrected merch functions
	~Reduced load times (even faster now)
	~Created Radio Buttons for Store/Merch Golds
	~Reduced working inventory bags to first 3 bags
	(Will only pickup, store, merch from first 3 bags)

	Updated v1.2
	~Corrected merch functions
	~Removed unecessary functions
	~Small edits for ID/Sell function
	~Edited and upgraded Sell function
	~Removed "Buy Lockpicks" checkbox from GUI
	~Added "Bunny Boost!" Function. If selected, will use chocolate bunnies for 50% speed boost in outpost!
	~(Choc. Bunnies do not need to be in your inventory as the function will use them from your Xunlai Storage Chest)

	Updated  v1.3
	~Updates by Malinkadink 3.3.19
	~GUI: Changed version# to v1.3a
	~$TimeCheck times have been adjusted
	~Second cast of Dwarven Stability added to keep up Dash
	~DllStructGetData($item, 'AgentID') = 1 <===Adjusted for testing

	Updated  v1.3a
	~Added sleep times before and after OpenChest()

	If Not $WeAreDead Then
		Sleep(GetPing()+80)
		OpenChest()
		Sleep(GetPing()+80)
	EndIf

	4.4.19
	Updated  v1.4
	~Check Gold amount before merch
	~Deposit/Withdraw gold to maintain balance of 50k - 60k: Deposit_Platinum()
	~Adjusted CanSell function so it wont sell lockpicks, ecto, or shards by accident


	Updated  v1.5 (8.2.19) ~Zaishen
	~Updated GWA2 & Headers
	~Updated Target Chest
	~Added option to use "I AM UNSTOPABLE" skill #3
	~Changed UseSkill() function to improved UseSkillEx() function

	To Do:
	~Conduct further testing v1.5
	~Add function to keep rare skins
	~Add optional settings to keep Q9 Golds
	~Adjust GUI and add Lucky/Unlucky Title tracks display
	~Add fucntion to ID and salvage "Forget Me Not" Insignias
	~Research bug that sometimes does not pickup gold drops from last chest
	~Research bug that causes crash on pause/restart after clicking on Xunlai Chest
	~Add optional settings to keep spears, scythes or other weapons needed for heroes
	~Add optional pro build to increase survival when picking up items (especially last chest)
	~Adjust OpenChest settings so the chest is opened from max distance (This way no needed to run to chest if no golds to pickup
	~To increase speed of the run, rewrite chest function and make it go: Move(xxx-xxx) ---> CheckChest/Open Chest ---> MoveTo(xxx-xxx) ---> PickupLoot	
#ce

#Region
Global $GoldsCount = 0
Global $Seconds = 0
Global $Minutes = 0
Global $Hours = 0
Global $tRun
Global $TreasureTitle = 0
Global $BOREAL_STATION = 675

Global $Array_Store_ModelIDs[77] = [910, 2513, 5585, 6366, 6375, 22190, 24593, 28435, 30855, 31145, 36682 _ ; Alcohol
		, 21492, 21812, 22269, 22644, 22752, 28436, 36681 _ ; FruitCake, Blue Drink, Cupcake, Bunnies, Eggs, Pie, Delicious Cake
		, 6376, 21809, 21810, 21813, 36683 _ ; Party Spam
		, 6370, 21488, 21489, 22191, 26784, 28433 _ ; DP Removals
		, 15837, 21490, 30648, 31020 _ ; Tonics
		, 556, 18345, 21491, 37765, 21833, 28433, 28434, 522 _ ; CC Shards, Victory Token, Wayfarer, Lunar Tokens, ToTs, Dark Remains
		, 921, 922, 923, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 945, 946, 948, 949, 950, 951, 952, 953, 954, 955, 956, 6532, 6533] ; All Materials

Global $Runs  = 0
Global $RenderingEnabled = True
Global $BotRunning = False
Global $BotInitialized = False
Global $WeAreDead
Global $intrun = 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Global Const $skill_id_shroud = 1031
Global Const $skill_id_iau = 2356
Global Const $skill_id_wd = 450
Global Const $skill_id_mb = 2417
Global Const $de = 7
; Store skills energy cost
Global $aItem

Local $Attribute = GetItemAttribute($aItem)
Local $Requirement = GetItemReq($aItem)
Local $Damage = GetItemMaxDmg($aItem)
Local $Req = GetItemReq($aItem)
#EndRegion Globals

#Region GUI
	Global $GUI = GUICreate("Boreal v1.5", 220, 220)
	$Input = GUICtrlCreateCombo("", 08, 10, 100 , 20)
	GUICtrlSetData(-1, GetLoggedCharNames())

	GUICtrlCreateLabel("Total Runs:",  08, 35, 120, 17)
	GUICtrlCreateLabel("Kits Bought:", 08, 50, 120, 17)
	Global $LBL_Runs = GUICtrlCreateLabel($Runs, 70, 35, 50, 17)
	Global $IDKitBought  = GUICtrlCreateLabel("0", 70, 50, 50, 17)

	GUICtrlCreateGroup("Lockpicks",    120, 04, 85, 30, BITOR($GUI_SS_DEFAULT_GROUP, $BS_CENTER))
	Global $LBL_Picks = GUICtrlCreateLabel("0", 128, 17, 72, 15, $SS_Center)

	$Purge   = GUICtrlCreateCheckbox("Purge",         028, 070, 80, 17)
	$Render  = GUICtrlCreateCheckbox("Render",        028, 085, 80, 17)
	GUICtrlSetOnEvent(-1, "ToggleRendering")
	$Hardmode= GUICtrlCreateCheckbox("Hard Mode",     028, 100, 80, 17)

	GuiCtrlCreateGroup("", 120, 85, 42, 30)
	$Sell    = GUICtrlCreateRadio   ("Sell",          116, 051, 36, 17)
	$Store   = GUICtrlCreateRadio   ("Store",         160, 051, 40, 17)

	$Breaks   = GUICtrlCreateCheckbox("Take Breaks",   120, 070, 80, 17)
	$Bunny    = GUICtrlCreateCheckbox("Bunny Boost!",  120, 085, 80, 17)
	$Use_IAU  = GUICtrlCreateCheckbox("Use Skill 3 - IAU", 120, 100, 98, 17)

	;GUICtrlCreateGroup("Run Time",            090, 30, 100, 20, BitOr(1, $BS_CENTER))
	$Run_Time = GUICTRLCREATELABEL("0:00:00", 120, 33, 85, 20, BITOR($SS_CENTER, $SS_CENTERIMAGE))
	GUICTRLSETFONT(-1, 9, 700, 0)

	GUICtrlCreateGroup("Treasure Hunter", 26, 118, 170, 35, BitOr(1, $BS_CENTER))
	GUICtrlSetFont (-1,9, 800); bold

	Global Const $LBL_TreasureTitle = GUICtrlCreateLabel("Rank: " & $TreasureTitle, 46, 132, 130, 17, BitOr(1, $BS_CENTER))

	Global $STATUS = GUICtrlCreateLabel("Ready to Start", 30, 155, 160, 17, $SS_Center)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$Start = GUICtrlCreateButton("Start", 30, 176, 160, 35, $SS_Center)
	GUICtrlSetFont (-1,9, 800); bold
	GUICtrlSetOnEvent(-1, "GuiButtonHandler")
	GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
	GUICtrlSetState($Sell,     $GUI_CHECKED)
	GUICtrlSetState($Hardmode, $GUI_CHECKED)
	;GUICtrlSetState($BuyPick,  $GUI_DISABLE)
	GUISetState(@SW_SHOW)
#EndRegion GUI


While 1
	If Not $Botrunning Then Sleep(50)

	GUICtrlSetData($LBL_TreasureTitle, GetTreasureTitle())
	GUICtrlSetData($LBL_Picks, GetLockpicksCount())

	If Not $BotInitialized Then
		AdlibRegister("TimeUpdater", 1000)
		AdlibRegister("VerifyConnection", 5000)
		$TimerTotal = TimerInit()
		SwitchMode(GUICtrlRead($Hardmode) == $GUI_CHECKED)
		Setup()
		$BotInitialized = True
	EndIf
	If GetMapID() <> $BOREAL_STATION Then
		Out("Travelling: Boreal Station")
		ZoneMap($BOREAL_STATION, 0) ;Boreal Station
		WaitForLoad()
		$Runs = 0
	EndIf


	$Runs += 1
	$intrun += 1
	Out("Begin Run Number " & $Runs)
	GUICtrlSetData($LBL_Runs, $Runs)

	GoOut()
	ChestRun()
	HandlePause()
	If InventoryIsFull() Then Inventory()
	If Getchecked($Purge) Then PurgeHook()
WEnd

Func GuiButtonHandler()
	If $BotRunning Then
		GUICtrlSetData($Start, "Will Pause After Run")
		GUICtrlSetState($Start, $GUI_DISABLE)
		$BotRunning = False
	ElseIf $BotInitialized Then
		GUICtrlSetData($Start, "Pause")
		$BotRunning = True
	Else
		Out("Initializing")
		AdlibRegister("TimeUpdater", 1000)
		Local $CharName = GUICtrlRead($Input)
		If $CharName == "" Then
			If Initialize(ProcessExists("gw.exe")) = False Then
				MsgBox(0, "Error", "Guild Wars is not running.")
				Exit
			EndIf
		Else
			If Initialize($CharName) = False Then
				MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $CharName & "'")
				Exit
			EndIf
		EndIf
		;GUICtrlSetState($Checkbox2, $GUI_ENABLE)
		GUICtrlSetState($Input, $GUI_DISABLE)
		GUICtrlSetData($Start, "Pause")
		$BotRunning = True
		setmaxmemory()
	EndIf
EndFunc ;GuiButtonHandler

#Region Chestrun
Func Setup()
	Move(4637, -27817)
	WaitForLoad()
	Move(5480, -27913)
EndFunc ;Setup

Func GoOut()
	Out("Going Out")
	Move(4637, -27817)
	WaitForLoad()
EndFunc ;GoOut

Func Running()
	Local $me = GetAgentByID(-2)
	If DllStructGetData(GetSkillbar(), 'Recharge2') = 0 AND  DllStructGetData($me, 'EnergyPercent') >= 0.10 And $WeAreDead = False Then
	    UseSkillEx(1) ;Dwarven Stability
		UseSkillEx(2) ;Dash
		If GetChecked ($Use_IAU) Then UseSkillEx(3)
	EndIf
EndFunc ;Running

Func ChestRun()
	Local $me = GetAgentByID(-2)
	$WeAreDead = False
	AdlibRegister("CheckDeath", 1000)
	AdlibRegister("Running", 1000)
	
	If DllStructGetData(GetSkillbar(), 'Recharge1') = 0 AND  DllStructGetData($me, 'EnergyPercent') >= 0.10 And $WeAreDead = False Then
		UseSkill(1, 0)
		RndSleep(800)
	EndIf

	Out("Waypoint 1")
	If Not $WeAreDead Then MoveTo(Random(2876, 2942), Random(-25733, -24826))
		
	Out("Waypoint 2")
	If Not $WeAreDead Then MoveTo(Random(420, 445), Random(-20729, -20705))

	Out("Waypoint 3")
	If Not $WeAreDead Then MoveTo(Random(-3380, -3405), Random(-18020, -18060))

	TargetNearestItem()
	RndSleep(500)
	If DllStructGetData(GetCurrentTarget(), 'Type') = 512 And Not $WeAreDead Then DoChest()

	Out("Waypoint 4")
	If Not $WeAreDead Then MoveTo(Random(-4937, -4965), Random(-14877, -14911))

	TargetNearestItem()
	RndSleep(500)
	If DllStructGetData(GetCurrentTarget(), 'Type') = 512 And Not $WeAreDead Then DoChest()

	Out("Waypoint 5")
	If Not $WeAreDead Then MoveTo(Random(-5700, -5745), Random(-12425, -12453))
	TargetNearestItem()
	RndSleep(500)
	If Not $WeAreDead Then DoChest()

	AdlibUnRegister("CheckDeath")
	AdlibUnRegister("Running")
	Do
		Resign()
		RndSleep(3000)
	Until GetIsDead()

	ReturnToOutpost()
EndFunc

Func DoChest()
	Local $TimeCheck = TimerInit()
	TargetNearestItem()
	Out("Opening Chest")
	If DllStructGetData(GetCurrentTarget(), 'Type') <> 512 Then Return

	GoSignpost(-1)
	$chest = GetCurrentTarget()
	$oldCoordsX = DllStructGetData($chest, "X")
	$oldCoordsY = DllStructGetData($chest, "Y")

	Do
		Sleep(100)
	Until CheckArea($oldCoordsX, $oldCoordsY) Or TimerDiff($TimeCheck) > 5000 Or $WeAreDead

	OpenChest()
	RndSleep(1000)
	TargetNearestItem()
	$item = GetCurrentTarget()
	PickUpItem($item)

	Do
		Sleep(100)
	Until DllStructGetData($item, 'AgentID') == 1 Or TimerDiff($TimeCheck) > 16000 or $WeAreDead
EndFunc ;DoChest
#EndRegion Chestrun

#Region Funcs
Func HandlePause()
   While Not $BotRunning
	  RndSleep(100)
	  GUICtrlSetData($Start, "Resume")
	  GUICtrlSetState($Start, $GUI_ENABLE)
   WEnd
   GUICtrlSetData($Start, "Pause")
EndFunc ;HandlePause

Func _exit()
	Exit
EndFunc ;_exit

Func CheckDeath()
	If Death() = 1 Then
		$WeAreDead = True
		Out("We Are Dead")
	EndIf
EndFunc ;CheckDeath

Func TimeUpdater()
	$Seconds += 1
	If $Seconds = 60 Then
		$Minutes += 1
		$Seconds = $Seconds - 60
	EndIf
	If $Minutes = 60 Then
		$Hours += 1
		$Minutes = $Minutes - 60
	EndIf
	If $Seconds < 10 Then
		$L_Sec = "0" & $Seconds
	Else
		$L_Sec = $Seconds
	EndIf
	If $Minutes < 10 Then
		$L_Min = "0" & $Minutes
	Else
		$L_Min = $Minutes
	EndIf
	If $Hours < 10 Then
		$L_Hour = "0" & $Hours
	Else
		$L_Hour = $Hours
	EndIf
	GUICtrlSetData($Run_Time, $L_Hour & ":" & $L_Min & ":" & $L_Sec)
EndFunc ;TimeUpdater

Func Out($msg)
	GUICtrlSetData($Status, "" & $msg)
EndFunc ;Out

Func GetChecked($GUICtrl)
	Return (GUICtrlRead($GUICtrl) == $GUI_Checked)
EndFunc ;GetChecked

Func PurgeHook()
	Out("Purging Engine Hook")
	ToggleRendering()
	RndSleep(2000)
    ClearMemory()
	RndSleep(2000)
	ToggleRendering()
	RndSleep(2000)
EndFunc ;PurgeHook

Func WaitForLoad()
	Out("Loading zone")
	InitMapLoad()
	$deadlock = 0
	Do
		RndSleep(100)
		$deadlock += 100
		$load = GetMapLoading()
		$lMe = GetAgentByID(-2)

	Until $load = 2 And DllStructGetData($lMe, 'X') = 0 And DllStructGetData($lMe, 'Y') = 0 Or $deadlock > 20000

	$deadlock = 0
	Do
		RndSleep(100)
		$deadlock += 100
		$deadlock += 100
		$load = GetMapLoading()
		$lMe = GetAgentByID(-2)

	Until $load <> 2 And DllStructGetData($lMe, 'X') <> 0 And DllStructGetData($lMe, 'Y') <> 0 Or $deadlock > 30000
	Out("Load complete")
	RndSleep(3000)
EndFunc ;WaitForLoad

Func Death()
	If DllStructGetData(GetAgentByID(-2), "Effects") = 0x0010 Then
		Return 1	; Whatever you want to put here in case of death
	Else
		Return 0
	EndIf
EndFunc ;Death

Func GetLockpicksCount() 
	Local $AmountPicks = 0
	Local $aBag
	Local $aItem

	For $i = 1 To 4 
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 22751 Then $AmountPicks += DllStructGetData($aItem, "Quantity")
		Next
	Next
	Return $AmountPicks
EndFunc ;GetLockpicksCount

Func UseSkillEx($lSkill, $lTgt=-2, $aTimeout = 10000)
	Local $lme = GetAgentByID(-2)
	If GetIsDead($lme) Then Return
	If Not IsRecharged($lSkill) Then Return

	Local $lDeadlock = TimerInit()
	UseSkill($lSkill, $lTgt)

	Do
		RndSleep(50)
		If GetIsDead($lme) = 1 Then Return
	Until (Not IsRecharged($lSkill)) Or (TimerDiff($lDeadlock) > $aTimeout)

	If $lSkill > 1 Then RndSleep(750)
EndFunc

Func VerifyConnection()
    If GetMapLoading() == 2 Then Disconnected()
EndFunc ;VerifyConneciton

Func Disconnected()
	Out("Disconnected!")
	Out("Attempting to reconnect.")
	ControlSend(GETWINDOWHANDLE(), "", "", "{Enter}")
	Local $LCHECK = False
	Local $LDEADLOCK = TimerInit()
	Do
		RndSleep(20)
		$LCHECK = GETMAPLOADING() <> 2 And GETAGENTEXISTS(-2)
	Until $LCHECK Or TimerDiff($LDEADLOCK) > 60000
	If $LCHECK = False Then
		Out("Failed to Reconnect!")
		Out("Retrying.")
		ControlSend(GETWINDOWHANDLE(), "", "", "{Enter}")
		$LDEADLOCK = TimerInit()
		Do
			RndSleep(20)
			$LCHECK = GETMAPLOADING() <> 2 And GETAGENTEXISTS(-2)
		Until $LCHECK Or TimerDiff($LDEADLOCK) > 60000
		If $LCHECK = False Then
			Out("Could not reconnect!")
			Out("Exiting.")
		EndIf
	EndIf
	Out("Reconnected!")
	RndSleep(5000)
EndFunc ;Disconnected
#EndRegion Funcs
