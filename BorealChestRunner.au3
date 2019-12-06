#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include "../GWA2.au3"
#include "../SimpleInventory.au3"
#include "../Extras.au3"
AUTOITSETOPTION("TrayIconDebug", 1)

Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)


#cs
    ~Farms Chest from Boreal Station

    Build:

    1. Dwarven Stability
    2. Dash
    3. "I AM UNSTOPPABLE" (Optional, select in GUI)

    Weapons & Equipment:
    Any Armor
    Any Staff w/ 20% Enchant

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
Global $BotRunning = False
Global $BotInitialized = False
Global $WeAreDead = False

Global $Seconds = 0
Global $Minutes = 0
Global $Hours = 0
Global $BOREAL_STATION = 675
Global $ICE_CLIFF_CHASM = 499

Global $GoldsCount = 0
Global $TreasureTitle = 0
Global $LuckyTitle = 0
Global $UnluckyTitle = 0
Global $Runs  = 0
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

    $Purge   = GUICtrlCreateCheckbox("Purge",			28, 70, 80, 17)
    $Render  = GUICtrlCreateCheckbox("Render",			28, 85, 80, 17)
        GUICtrlSetOnEvent(-1, "ToggleRendering")

    $HardMode= GUICtrlCreateCheckbox("Hard Mode",		120, 70, 80, 17)
    $UseIAU  = GUICtrlCreateCheckbox("Use IAU", 		120, 85, 80, 17)

    $Run_Time = GUICTRLCREATELABEL("00:00:00", 120, 40, 85, 20, BITOR($SS_CENTER, $SS_CENTERIMAGE))
        GUICtrlSetFont(-1, 9, 700, 0)

    GUICtrlCreateGroup("Treasure", 5, 110, 65, 35, BitOr(1, $BS_CENTER))
    Global Const $LBL_TreasureTitle = GUICtrlCreateLabel($TreasureTitle, 10, 125, 55, 15, BitOr(1, $BS_CENTER))

    GUICtrlCreateGroup("Lucky", 80, 110, 65, 35, BitOr(1, $BS_CENTER))
    Global Const $LBL_LuckyTitle = GUICtrlCreateLabel($LuckyTitle, 85, 125, 55, 15, BitOr(1, $BS_CENTER))

    GUICtrlCreateGroup("Unlucky", 150, 110, 65, 35, BitOr(1, $BS_CENTER))
    Global Const $LBL_UnluckyTitle = GUICtrlCreateLabel($UnluckyTitle, 155, 125, 55, 15, BitOr(1, $BS_CENTER))

    Global $STATUS = GUICtrlCreateLabel("Ready to Start", 30, 155, 160, 17, $SS_Center)
    GUICtrlCreateGroup("", -99, -99, 1, 1)

    $Start = GUICtrlCreateButton("Start", 30, 176, 160, 35, $SS_Center)
    GUICtrlSetFont (-1,9, 800); bold
    GUICtrlSetOnEvent(-1, "GuiButtonHandler")
    GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
    GUICtrlSetState($HardMode, $GUI_CHECKED)
    GUICtrlSetState($UseIAU, $GUI_CHECKED)
    GUISetState(@SW_SHOW)
#EndRegion GUI


While 1
    If Not $Botrunning Then
        Sleep(50)
        ContinueLoop
    EndIf

    GUICtrlSetData($LBL_TreasureTitle, GetTreasureTitle())
    GUICtrlSetData($LBL_LuckyTitle, GetLuckyTitle())
    GUICtrlSetData($LBL_UnluckyTitle, GetUnLuckyTitle())
    GUICtrlSetData($LBL_Picks, GetLockpicksCount())

    TravelToOutpost()
    If Not $BotInitialized Then
        Out("Initializing")
        AdlibRegister("TimeUpdater", 1000)
        AdlibRegister("VerifyConnection", 5000)
        $TimerTotal = TimerInit()

        SwitchMode(GUICtrlRead($HardMode) == $GUI_CHECKED)
        Setup()
        $BotInitialized = True
    EndIf

    $Runs += 1
    Out("Begin Run Number " & $Runs)
    GUICtrlSetData($LBL_Runs, $Runs)

    GoOut()
    ChestRun()
    HandlePause()
    If InventoryIsFull() Then
        Inventory()
        MoveTo(6509, -26221)
        MoveTo(5546, -27878)
        MoveTo(5673, -27460)
        RndSleep(1000)
    EndIf
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
        GUICtrlSetState($Input, $GUI_DISABLE)
        GUICtrlSetData($Start, "Pause")
        $BotRunning = True
        SetMaxMemory()
    EndIf
EndFunc ;GuiButtonHandler

#Region Chestrun
Func TravelToOutpost()
    If GetMapID() == $BOREAL_STATION Then Return
    Out("Travelling to Boreal Station")

    TravelTo($BOREAL_STATION)
EndFunc ;TravelToOutpost

Func Setup()
    LoadSkillTemplate("OwET0YIWV6usrgmktAkAAAAAAAA")
    Out("Setup resign")
    MoveTo(5520, -27828)
    Move(4700, -27817)
    WaitMapLoading($ICE_CLIFF_CHASM)
    Move(5480, -27913)
    WaitMapLoading($BOREAL_STATION)
EndFunc ;Setup

Func GoOut()
    Out("Going Out")
    Move(4637, -27817)
    WaitMapLoading($ICE_CLIFF_CHASM)
EndFunc ;GoOut

Func ChestRun()
    Local $me = GetAgentByID(-2)
    $WeAreDead = False
    AdlibRegister("CheckDeath", 1000)
    AdlibRegister("Running", 1000)
    Out("Starting Run")

    If DllStructGetData(GetSkillbar(), 'Recharge1') = 0 And DllStructGetData($me, 'EnergyPercent') >= 0.10 And $WeAreDead = False Then
        UseSkill(1, 0)
        RndSleep(800)
    EndIf

    Out("Waypoint 1")
    If Not $WeAreDead Then MoveTo(2900, -25000)

    Out("Waypoint 2")
    If Not $WeAreDead Then MoveTo(-858, -19407)

    Out("Waypoint 3")
    If Not $WeAreDead Then MoveTo(-3478, -18092)
    If Not $WeAreDead Then DoChest()

    Out("Waypoint 4")
    If Not $WeAreDead Then MoveTo(-5432, -15037)
    If Not $WeAreDead Then DoChest()

    Out("Waypoint 5")
    If Not $WeAreDead Then MoveTo(-5744, -11911)
    If Not $WeAreDead Then DoChest()

    Out("Waypoint 6")
    If Not $WeAreDead Then MoveTo(-3863, -11372)
    If Not $WeAreDead Then DoChest()

    AdlibUnRegister("CheckDeath")
    AdlibUnRegister("Running")
    Out("Going back")
    Do
        Resign()
        RndSleep(8000)
    Until GetIsDead()

    ReturnToOutpost()
    WaitMapLoading($BOREAL_STATION)
EndFunc ;ChestRun

Func Running()
    If DllStructGetData(GetSkillbar(), 'Recharge2') == 0 And not $WeAreDead Then
        UseSkillEx(1) ;Dwarven Stability
        UseSkillEx(2) ;Dash
    EndIf
    If GetHasCondition() And GetChecked($UseIAU) Then UseSkillEx(3)
    UseSkillEx(4) ;Dash
    If DllStructGetData(GetAgentByID(), 'HP') < 0.8 Then UseSkillEx(5)
EndFunc ;Running

Func DoChest()
    Local $TimeCheck = TimerInit()
    TargetNearestItem()
    If DllStructGetData(GetCurrentTarget(), 'Type') <> 512 Then Return
    Out("Opening Chest")

    GoSignpost(-1)
    $chest = GetCurrentTarget()
    $oldCoordsX = DllStructGetData($chest, "X")
    $oldCoordsY = DllStructGetData($chest, "Y")

    Do
        Sleep(1000)
    Until CheckArea($oldCoordsX, $oldCoordsY) Or TimerDiff($TimeCheck) > 10000 Or $WeAreDead

    OpenChest()
    RndSleep(1000)
    PickupLootEx2()
EndFunc ;DoChest

Func PickupLootEx2($iMaxDist = 3000, $bCanPickup = True)
	$lMe = GetAgentByID(-2)
	For $i = 1 To GetMaxAgents()
		$aAgent = GetAgentByID($i)
		If Not GetIsMovable($aAgent) Then ContinueLoop
		$aItem = GetItemByAgentID($i)
		$aItemX = DllStructGetData($aAgent, "x")
		$aItemY = DllStructGetData($aAgent, "y")
		If ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $aItemX, $aItemY) < $iMaxDist Then
			MoveTo($aItemX, $aItemY)
			TolSleep(300)
			Do
				PickUpItem($aItem)
			Until Not GetAgentExists($aAgent)
			$lDeadlock = TimerInit()
			While GetAgentExists($aAgent)
				Sleep(50)
				If GetIsDead(-2) Then Return
				If TimerDiff($lDeadlock) > 25000 Then ExitLoop
			Wend
		EndIf
	Next
EndFunc ;PickupLootEx
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
    If GetIsDead() Then
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
    If GetIsDead() Then Return
    If Not IsRecharged($lSkill) Then Return

    Local $lDeadlock = TimerInit()
    UseSkill($lSkill, $lTgt)

    Do
        RndSleep(50)
        If GetIsDead() Then Return
    Until (Not IsRecharged($lSkill)) Or (TimerDiff($lDeadlock) > $aTimeout)
    RndSleep(200)
EndFunc

Func GoMerchant()
    GoToNPC(GetNearestNPCToCoords(7319, -24874))
    RndSleep(550)
EndFunc

Func VerifyConnection()
    If GetMapLoading() == 2 Then Disconnected()
EndFunc ;VerifyConneciton
#EndRegion Funcs
