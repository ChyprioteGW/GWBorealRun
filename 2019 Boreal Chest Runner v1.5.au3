
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

If Not $WeAreDead then
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

;Make sure running skills for 1st two skill slots! (1 = Dwarven Stability 2 = Dash)


#Region Sweets
Global $Sweet_Town_Array[10] = [15528, 15479, 19170, 21492, 21812, 22644, 30208, 31150, 35125, 36681]
Global Const $ITEM_ID_Creme_Brulee =         15528
Global Const $ITEM_ID_Red_Bean_Cake =        15479
Global Const $ITEM_ID_Mandragor_Root_Cake =  19170
Global Const $ITEM_ID_Fruitcake =            21492
Global Const $ITEM_ID_Sugary_Blue_Drink =    21812
Global Const $ITEM_ID_Chocolate_Bunny =      22644
Global Const $ITEM_ID_Jar_of_Honey = 		 31150
Global Const $ITEM_ID_Krytan_Lokum = 	 	 35125
Global Const $ITEM_ID_Delicious_Cake =	     36681
Global Const $ITEM_ID_MiniTreats_of_Purity = 30208
#EndRegion Sweets

#Region
Global $bag_slots[5] = [0, 20, 5, 10, 10]
Global $TotalSeconds = 0
Global $GoldsCount = 0
Global $Seconds = 0
Global $Minutes = 0
Global $Hours = 0
Global $MerchOpened = False
Global $g_nMyId = 0
Global $g_nStrafe = 0
Global $lastX
Global $lastY
Global $strafeGo = False
Global $leftright = 0
Global $MoveToB = True
Global $BackTrack = True
Global $tSwitchtarget
Global $tLastTarget, $tRun, $tBlock
Global $TreasureTitle = 0
Global $HWND

Global $Array_Store_ModelIDs[77] = [910, 2513, 5585, 6366, 6375, 22190, 24593, 28435, 30855, 31145, 36682 _ ; Alcohol
		, 21492, 21812, 22269, 22644, 22752, 28436, 36681 _ ; FruitCake, Blue Drink, Cupcake, Bunnies, Eggs, Pie, Delicious Cake
		, 6376, 21809, 21810, 21813, 36683 _ ; Party Spam
		, 6370, 21488, 21489, 22191, 26784, 28433 _ ; DP Removals
		, 15837, 21490, 30648, 31020 _ ; Tonics
		, 556, 18345, 21491, 37765, 21833, 28433, 28434, 522 _ ; CC Shards, Victory Token, Wayfarer, Lunar Tokens, ToTs, Dark Remains
		, 921, 922, 923, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 945, 946, 948, 949, 950, 951, 952, 953, 954, 955, 956, 6532, 6533] ; All Materials

Global $shardcount = 0
Global $winlabel = 0
Global $wins  = 0
Global $fails = 0
Global $Runs  = 0
Global $RenderingEnabled = True
Global $BotRunning = False
Global $BotInitialized = False
Global $DeadOnTheRun = 0,$tpspirit = 0, $WeAreDead
Global $intrun = 0, $pick_are_here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Global Const $skill_id_shroud = 1031
Global Const $skill_id_iau = 2356
Global Const $skill_id_wd = 450
Global Const $skill_id_mb = 2417
Global Const $ds = 3
Global Const $sf = 2
Global Const $shroud = 1
Global Const $hos = 5
Global Const $wd = 4
Global Const $iau = 6
Global Const $de = 7
Global Const $mb = 8
; Store skills energy cost
Global $skillCost[9]
Global $ATTRIB_Swordsmanship
Global $ATTRIB_Strength
Global $ATTRIB_Tactics
Global $ATTRIB_Command
Global $ATTRIB_Motivation
Global $aItem

Local $Attribute = GetItemAttribute($aItem)
Local $Requirement = GetItemReq($aItem)
Local $Damage = GetItemMaxDmg($aItem)
Local $Req = GetItemReq($aItem)

$skillCost[$ds] = 5
$skillCost[$sf] = 5
$skillCost[$shroud] = 10
$skillCost[$wd] = 4
$skillCost[$hos] = 5
$skillCost[$iau] = 5
$skillCost[$de] = 5
$skillCost[$mb] = 10
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
$LPicks = GUICtrlCreateLabel("0", 128, 17, 72, 15, $SS_Center)

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

Global Const $TreasureTitle_Lbl = GUICtrlCreateLabel("Rank: " & $TreasureTitle, 46, 132, 130, 17, BitOr(1, $BS_CENTER))

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
	If $Botrunning = true Then
		Local $Treasure = GetTreasureTitle()
		GUICtrlSetData($TreasureTitle_Lbl, GetTreasureTitle())
		GUICtrlSetData($LPicks, GetPicksCount())

		If $Runs = 0 Then
			AdlibRegister("TimeUpdater", 1000)
			AdlibRegister("VerifyConnection", 5000)
			$TimerTotal = TimerInit()
		EndIf
		If GetMapID() <> 675 Then
			Out("Travelling: Boreal Station")
			ZoneMap(675, 0) ;Boreal Station
			WaitForLoad()
			$intrun = 0
		EndIf


		$Runs = $Runs +1
		$intrun = $intrun + 1
		Out("Begin Run Number " & $Runs)
		GUICtrlSetData($Lbl_Runs, $Runs)

		GoOut()
		ChestRun()
		HandlePause()
		If InventoryIsFull() then Inventory()
		If Getchecked($Purge) Then PurgeHook()
	EndIf
	sleep(50)
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
		$BotInitialized = True
		setmaxmemory()
	EndIf
EndFunc   ;==>GuiButtonHandler

Func HandlePause()
   While Not $BotRunning
	  Sleep(100)
	  GUICtrlSetData($Start, "Resume")
	  GUICtrlSetState($Start, $GUI_ENABLE)
   WEnd
   GUICtrlSetData($Start, "Pause")
EndFunc

Func GoOut()
	Out("Switch Mode")

	SwitchMode(GUICtrlRead($Hardmode) == $GUI_CHECKED)
	RndSleep(250)

	If $intrun = 1 Then moveto(7603, -27423)
	Out("Going Out")

	Switch (Random(1, 8, 1))
		Case 1
			Move(4733.52, -27842.97)
		Case 2
			Move(4730.40, -27788.09)
		Case 3
			Move(4700.77, -27976.07)
		Case 4
			Move(4720.88, -27892.77)
		Case 5
			Move(4720.72, -27858.23)
		Case 6
			Move(4725.52, -27856.53)
		Case 7
			Move(4729.92, -27858.23)
		Case 8
			Move(4738.72, -27877.23)
	EndSwitch
	WaitForLoad()
	rndslp(5000)
	Out("Moving Back")
	If $intrun = 1 Then
		Move(4776, -27888)
		WaitForLoad()
		rndslp(5000)
		Out("Going Out")
		Switch (Random(1, 8, 1))
			Case 1
				Move(4733.52, -27842.97)
			Case 2
				Move(4730.40, -27788.09)
			Case 3
				Move(4700.77, -27976.07)
			Case 4
				Move(4720.88, -27892.77)
			Case 5
				Move(4720.72, -27858.23)
			Case 6
				Move(4725.52, -27856.53)
			Case 7
				Move(4729.92, -27858.23)
			Case 8
				Move(4738.72, -27877.23)
		EndSwitch
		WaitForLoad()
		rndslp(5000)
	EndIf
EndFunc

Func Running()    ;New function with 2nd cast of Dwarven Stability
	local $me = GetAgentByID(-2)
	If DllStructGetData(GetSkillbar(), 'Recharge2') = 0 AND  DllStructGetData($me, 'EnergyPercent') >= 0.10 And $WeAreDead = False Then
	    UseSkillEx(1, 0) ;Dwarven Stability
		UseSkillEx(2, 0) ;Dash
		If GetChecked ($Use_IAU) Then
		 UseSkillEx(3, 0) ;I Am Unstoppable
        EndIf
		;UseSkill(1, 0) ;Dwarven Stability
		;rndslp(300)
		;UseSkill(2, 0) ;Dash
	EndIf
EndFunc

Func ChestRun()
	$WeAreDead = False
	AdlibRegister("CheckDeath", 1000)
	AdlibRegister("Running", 1000)
	If Not $WeAreDead then Out("Waypoint 1")
	local $me = GetAgentByID(-2)
	If DllStructGetData(GetSkillbar(), 'Recharge1') = 0 AND  DllStructGetData($me, 'EnergyPercent') >= 0.10 And $WeAreDead = False Then
		UseSkill(1, 0)
		rndslp(800)
	EndIf

	Switch (Random(1, 5, 1))
		Case 1
			Dim $wp[2] = [2942, -25733]
		Case 2
			Dim $wp[2] = [2884.05, -25826.86]
		Case 3
			Dim $wp[2] = [2876.13, -25690.62]
		Case 4
			Dim $wp[2] = [2899.05, -25801.86]
		Case 5
			Dim $wp[2] = [2913.13, -25745.62]
	EndSwitch

	If Not $WeAreDead then MoveTo($wp[0], $wp[1])
	If Not $WeAreDead then Out("Waypoint 2")

	Switch (Random(1, 5, 1))
		Case 1
			Dim $wp[2] = [434, -20716]
		Case 2
			Dim $wp[2] = [427, -20705]
		Case 3
			Dim $wp[2] = [445, -20729]
		Case 4
			Dim $wp[2] = [420, -20710]
		Case 5
			Dim $wp[2] = [438, -20720]
	EndSwitch
	If Not $WeAreDead then MoveTo($wp[0], $wp[1])
	If Not $WeAreDead then Out("Waypoint 3")
	GUICtrlSetData($TreasureTitle_Lbl, GetTreasureTitle())

	Switch (Random(1, 5, 1))
		Case 1
			Dim $wp[2] = [-3391, -18043]
		Case 2
			Dim $wp[2] = [-3380, -18033]
		Case 3
			Dim $wp[2] = [-3399, -18055]
		Case 4
			Dim $wp[2] = [-3384, -18020]
		Case 5
			Dim $wp[2] = [-3405, -18060]
	EndSwitch
	If Not $WeAreDead then MoveTo($wp[0], $wp[1])

	If Not $WeAreDead then TargetNearestItem()
	If Not $WeAreDead then rndslp(500)
	If DllStructGetData(GetCurrentTarget(), 'Type') = 512 and $WeAreDead = False Then
		If Not $WeAreDead then DoChest()
		If Not $WeAreDead then rndslp(800)
	EndIf
	If Not $WeAreDead then Out("Waypoint 4")
	GUICtrlSetData($TreasureTitle_Lbl, GetTreasureTitle())
	Switch (Random(1, 5, 1))
		Case 1
			Dim $wp[2] = [-4950, -14890]
		Case 2
			Dim $wp[2] = [-4937, -14877]
		Case 3
			Dim $wp[2] = [-4965, -14911]
		Case 4
			Dim $wp[2] = [-4944, -14900]
		Case 5
			Dim $wp[2] = [-4959, -14906]
	EndSwitch
	If Not $WeAreDead then MoveTo($wp[0], $wp[1])

	If Not $WeAreDead then TargetNearestItem()
	If Not $WeAreDead then rndslp(500)
	If DllStructGetData(GetCurrentTarget(), 'Type') = 512 and $WeAreDead = False Then
		If Not $WeAreDead then DoChest()
		If Not $WeAreDead then rndslp(800)
	EndIf

	If Not $WeAreDead then Out("Waypoint 5")
	GUICtrlSetData($TreasureTitle_Lbl, GetTreasureTitle())
	Switch (Random(1, 5, 1))
		Case 1
			Dim $wp[2] = [-5725, -12445]
		Case 2
			Dim $wp[2] = [-5745, -12430]
		Case 3
			Dim $wp[2] = [-5700, -12442]
		Case 4
			Dim $wp[2] = [-5712, -12453]
		Case 5
			Dim $wp[2] = [-5732, -12425]
	EndSwitch
	If Not $WeAreDead then MoveTo($wp[0], $wp[1])

	If Not $WeAreDead then TargetNearestItem()
	If Not $WeAreDead then rndslp(500)
	If DllStructGetData(GetCurrentTarget(), 'Type') = 512 and $WeAreDead = False Then
		If Not $WeAreDead then DoChest()
		If Not $WeAreDead then rndslp(800)
	EndIf
    GUICtrlSetData($TreasureTitle_Lbl, GetTreasureTitle())
	AdlibUnRegister("CheckDeath")
	AdlibUnRegister("Running")
	Do
		Resign()
		rndslp(2700)
	Until GetIsDead(-2) = 1
	rndslp(3800)
	ReturnToOutpost()
	WaitForLoad()
EndFunc

Func DoChest()
	If Not $WeAreDead then Out("Opening Chest")
	If Not $WeAreDead then GoSignpost(-1)
	local $TimeCheck = TimerInit()
	If Not $WeAreDead then $chest = GetCurrentTarget()
	If Not $WeAreDead then $oldCoordsX = DllStructGetData($chest, "X")
	If Not $WeAreDead then $oldCoordsY = DllStructGetData($chest, "Y")
	If Not $WeAreDead then
		Do
			rndslp(500)
		Until CheckArea($oldCoordsX, $oldCoordsY) Or TimerDiff($TimeCheck) > 1000 Or $WeAreDead ;Previosly 9000 (9 seconds sleep)
	EndIf
	If Not $WeAreDead then rndslp(2000)

	If Not $WeAreDead then
	   Sleep(GetPing()+80)
	   OpenChest()
	   Sleep(GetPing()+80)
    EndIf

	If Not $WeAreDead then rndslp(1000)
	If Not $WeAreDead then TargetNearestItem()
	If Not $WeAreDead then rndslp(500)
	If Not $WeAreDead then $item = GetCurrentTarget()
	If Not $WeAreDead then
		Do
			If Not $WeAreDead then rndslp(500)
			If Not $WeAreDead then PickUpItem($item)
		Until DllStructGetData($item, 'AgentID') = 1 Or TimerDiff($TimeCheck) > 16000 or $WeAreDead  ;Previously 9000 (9 seconds) also 'AgentID') = 0
	EndIf
	GUICtrlSetData($LPicks, GetPicksCount())
EndFunc   ;==>DoChest

Func CheckDeath()
	If Death() = 1 Then
		$WeAreDead = True
		Out("We Are Dead")
	EndIf
EndFunc   ;==>CheckDeath

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
EndFunc

#Region funcs
Func _exit()
	Exit
EndFunc   ;==>_exit

Func Out($msg)
	GUICtrlSetData($Status, "" & $msg)
EndFunc   ;==>Out

Func Out2($msg) ;Original Function with Timestamp
	GUICtrlSetData($Status, "[" & @HOUR & ":" & @MIN & "]  " & $msg)
EndFunc   ;==>Out

Func PickUpLoot()
	Local $lMe
	Local $lBlockedTimer
	Local $lBlockedCount = 0
	Local $lItemExists = True
	For $i = 1 To GetMaxAgents()
		$lMe = GetAgentByID(-2)
		If DllStructGetData($lMe, 'HP') <= 0.0 Then Return -1
		$lAgent = GetAgentByID($i)
		If Not GetIsMovable($lAgent) Then ContinueLoop
		If Not GetCanPickUp($lAgent) Then ContinueLoop
		$lItem = GetItemByAgentID($i)
		If canpickup($lItem) Then
			Do
				PickUpItem($lItem)
				Sleep(GetPing())
				Do
					Sleep(100)
					$lMe = GetAgentByID(-2)
				Until DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0
				$lBlockedTimer = TimerInit()
				Do
					Sleep(GetPing())
					$lItemExists = IsDllStruct(GetAgentByID($i))
				Until Not $lItemExists Or TimerDiff($lBlockedTimer) > Random(7500, 10000, 1)
				If $lItemExists Then $lBlockedCount += 1
			Until Not $lItemExists Or $lBlockedCount > 5
		EndIf
	Next
EndFunc   ;==>PickUpLoot

Func CanPickUp($lItem)
	Return True
	Local $m = DllStructGetData($lItem, 'ModelId')
	Local $t = DllStructGetData($lItem, 'Type')
	Local $c = DllStructGetData($lItem, 'ExtraID')
	Local $r = GetRarity($lItem)
	Switch $m
		Case 522 ; Dark Remains
			Return True
		Case 910, 2513, 5585, 6366, 6375, 22190, 24593, 28435, 30855, 31145, 36682 _ ; Alcohol
				, 21492, 21812, 22269, 22644, 22752, 28436, 36681 _ ; FruitCake, Blue Drink, Cupcake, Bunnies, Eggs, Pie, Delicious Cake
				, 6376, 21809, 21810, 21813, 36683 _ ; Party Spam
				, 6370, 21488, 21489, 22191, 26784, 28433 _ ; DP Removals
				, 15837, 21490, 30648, 31020 _ ; Tonics
				, 556, 18345, 21491, 37765, 21833, 28433, 28434 _ ; CC Shards, Victory Token, Wayfarer, Lunar Tokens, ToTs
				, 921, 922, 923, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 946, 948, 949, 950, 951, 952, 953, 954, 955, 956, 6532, 6533 ; Materials
			Return True
		Case 945 ;Obby Shards (Never know, lol)

			Return True
		Case 2511 ; Gold
			Return True
		Case 22751 ; Lockpicks
			Return True
		Case 5971, 22280 ; Obsidian Key and Fissure Scrolls
			Return True
		Case 146 ; Dyes
			Switch $c
				Case 10, 12 ; Only Black/White
					Return True
		Case 24
					If $Req = 8 And GetItemMaxDmg($aItem) = 16 Then     ; Req8 Shields
						Return True
					ElseIf $Req = 7 And GetItemMaxDmg($aItem) = 15 Then ; Req7 Shields
						Return True
					ElseIf $Req = 6 And GetItemMaxDmg($aItem) = 14 Then ; Req6 Shields
						Return True
					ElseIf $Req = 5 And GetItemMaxDmg($aItem) = 13 Then ; Req5 Shields
						Return True
					ElseIf $Req = 4 And GetItemMaxDmg($aItem) = 12 Then ; Req4 Shields
						Return True
					EndIf
				Case 5
					Return True
			EndSwitch
	EndSwitch
	Switch $r
		Case $RARITY_GOLD            ;<============================== ADD GOLD ITEMS COUNTER LATER ====================================
			Out("Gold Item Dropped!")
			;$GoldsCount = $GoldsCount + 1
			;GUICtrlSetData($GoldsCountLBL,$GoldsCount)
			Return True
	EndSwitch
	Return True
;	Return False ; Used when you don't want to pickup everything
EndFunc   ;==>canpickup

#Region Storage
Func StoreItems()
	Out("Storing Items")
	Local $AITEM, $m, $Q, $lbag, $SLOT, $FULL, $NSLOT
	For $i = 1 To 4
		$lbag = GetBag($i)
		For $j = 1 To DllStructGetData($lbag, 'Slots')
			$AITEM = GetItemBySlot($lbag, $j)
			If DllStructGetData($AITEM, "ID") = 0 Then ContinueLoop
			$m = DllStructGetData($AITEM, "ModelID")
			$Q = DllStructGetData($AITEM, "quantity")
			For $z = 0 To (UBound($Array_Store_ModelIDs) - 1)
				If (($m == $Array_Store_ModelIDs[$z]) And ($Q = 250)) Then
					Do
						For $BAG = 8 To 12
							$SLOT = FindEmptySlot($BAG)
							$SLOT = @extended
							If $SLOT <> 0 Then
								$FULL = False
								$NSLOT = $SLOT
								ExitLoop 2
							Else
								$FULL = True
							EndIf
							Sleep(400)
						Next
					Until $FULL = True
					If $FULL = False Then
						MoveItem($AITEM, $BAG, $NSLOT)
						Sleep(GetPing() + 500)
					EndIf
				EndIf
			Next
		Next
	Next
EndFunc   ;==>StoreItems

Func StoreGolds()
	Out("Storing Golds")
	Local $AITEM, $lItem, $m, $Q, $r, $lbag, $SLOT, $FULL, $NSLOT
	For $i = 1 To 4
		$lbag = GetBag($i)
		For $j = 1 To DllStructGetData($lbag, 'Slots')
			$AITEM = GetItemBySlot($lbag, $j)
			If DllStructGetData($AITEM, "ID") = 0 Then ContinueLoop
			$m = DllStructGetData($AITEM, "ModelID")
			$r = GetRarity($lItem)
			If CanStoreGolds($AITEM) Then
				Do
					For $BAG = 8 To 12
						$SLOT = FindEmptySlot($BAG)
						$SLOT = @extended
						If $SLOT <> 0 Then
							$FULL = False
							$NSLOT = $SLOT
							ExitLoop 2
						Else
							$FULL = True
						EndIf
						Sleep(400)
					Next
				Until $FULL = True
				If $FULL = False Then
					MoveItem($AITEM, $BAG, $NSLOT)
					Sleep(GetPing() + 500)
				EndIf
			EndIf
		Next
	Next
EndFunc   ;==>StoreGolds

Func CanStoreGolds($AITEM)
	Local $m = DllStructGetData($AITEM, "ModelID")
	Local $r = GetRarity($AITEM)
	Switch $r
		Case $RARITY_GOLD
			If $m = 22280 Then
				Return False
			Else
				Return True
			EndIf
	EndSwitch
EndFunc   ;==>CanStoreGolds

Func FindEmptySlot($bagIndex)
	Local $LITEMINFO, $aslot
	For $aslot = 1 To DllStructGetData(GetBag($bagIndex), "Slots")
		Sleep(40)
		$LITEMINFO = GetItemBySlot($bagIndex, $aslot)
		If DllStructGetData($LITEMINFO, "ID") = 0 Then
			SetExtended($aslot)
			ExitLoop
		EndIf
	Next
	Return 0
EndFunc   ;==>FindEmptySlot
#EndRegion Storage


Func GetTime()
   Local $Time = GetInstanceUpTime()
   Local $Seconds = Floor($Time/1000)
   Local $Minutes = Floor($Seconds/60)
   Local $Hours = Floor($Minutes/60)
   Local $Second = $Seconds - $Minutes*60
   Local $Minute = $Minutes - $Hours*60
   If $Hours = 0 Then
	  If $Second < 10 Then $InstTime = $Minute&':0'&$Second
	  If $Second >= 10 Then $InstTime = $Minute&':'&$Second
   ElseIf $Hours <> 0 Then
	  If $Minutes < 10 Then
		 If $Second < 10 Then $InstTime = $Hours&':0'&$Minute&':0'&$Second
		 If $Second >= 10 Then $InstTime = $Hours&':0'&$Minute&':'&$Second
	  ElseIf $Minutes >= 10 Then
		 If $Second < 10 Then $InstTime = $Hours&':'&$Minute&':0'&$Second
		 If $Second >= 10 Then $InstTime = $Hours&':'&$Minute&':'&$Second
	  EndIf
   EndIf
   Return $InstTime
EndFunc


Func GetChecked($GUICtrl)
	Return (GUICtrlRead($GUICtrl)==$GUI_Checked)
EndFunc

Func PurgeHook()
	Out("Purging Engine Hook")
	Sleep(Random(2000, 2500))
	ToggleRendering()
	Sleep(Random(2000, 2500))
    ClearMemory()
	Sleep(Random(2000, 2500))
	ToggleRendering()
EndFunc

Func Rndslp($val)
	$wert = Random($val * 0.95, $val * 1.05, 1)
	If $wert > 45000 Then
		For $i = 0 To 6
			Sleep($wert / 6)
			Death()
		Next
	ElseIf $wert > 36000 Then
		For $i = 0 To 5
			Sleep($wert / 5)
			Death()
		Next
	ElseIf $wert > 27000 Then
		For $i = 0 To 4
			Sleep($wert / 4)
			Death()
		Next
	ElseIf $wert > 18000 Then
		For $i = 0 To 3
			Sleep($wert / 3)
			Death()
		Next
	ElseIf $wert >= 9000 Then
		For $i = 0 To 2
			Sleep($wert / 2)
			Death()
		Next
	Else
		Sleep($wert)
		Death()
	EndIf
 EndFunc   ;==>RndSlp

 Func WaitForLoad()
	Out("Loading zone")
	InitMapLoad()
	$deadlock = 0
	Do
		Sleep(100)
		$deadlock += 100
		$load = GetMapLoading()
		$lMe = GetAgentByID(-2)

	Until $load = 2 And DllStructGetData($lMe, 'X') = 0 And DllStructGetData($lMe, 'Y') = 0 Or $deadlock > 20000

	$deadlock = 0
	Do
		Sleep(100)
		$deadlock += 100
		$deadlock += 100
		$load = GetMapLoading()
		$lMe = GetAgentByID(-2)

	Until $load <> 2 And DllStructGetData($lMe, 'X') <> 0 And DllStructGetData($lMe, 'Y') <> 0 Or $deadlock > 30000
	Out("Load complete")
	rndslp(3000)
 EndFunc   ;==>WaitForLoad

 Func Death()
	If DllStructGetData(GetAgentByID(-2), "Effects") = 0x0010 Then
		Return 1	; Whatever you want to put here in case of death
	Else
		Return 0
	EndIf
EndFunc   ;==>Death

Func GetPicksCount();Counts Lockpicks in your inventory
	Local $AmountPicks
	Local $aBag
	Local $aItem
	Local $iw
	For $i = 1 To 4 ;change 1 To 16 if you want to count storage also or 1 to 4 for just personal inv.  Will display on GUI
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 22751 Then
				$AmountPicks += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AmountPicks
EndFunc   ; Counts Lockpicks in your inventory to include chest

Func UseSkillEx($lSkill, $lTgt=-2, $aTimeout = 10000)
	Local $lme = GetAgentByID(-2)
	If GetIsDead($lme) Then Return
	If Not IsRecharged($lSkill) Then Return

	Local $lDeadlock = TimerInit()
	UseSkill($lSkill, $lTgt)

	Do
		Sleep(50)
		If GetIsDead($lme) = 1 Then Return
	Until (Not IsRecharged($lSkill)) Or (TimerDiff($lDeadlock) > $aTimeout)

	If $lSkill > 1 Then RndSleep(750)
EndFunc
#EndRegion funcs

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