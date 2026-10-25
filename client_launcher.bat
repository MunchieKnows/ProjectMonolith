@echo off
setlocal EnableDelayedExpansion
title Project Monolith - CLIENT Launcher
cd /d "%~dp0"

REM ===========================================================================
REM  Project Monolith Client Launcher  (with input validation)
REM  - Builds/edits config.json (read by Client DLL)
REM  - Launches: OrionClient-Win64-Shipping.exe -epicportal
REM
REM  PLACEMENT: copy this .bat next to OrionClient-Win64-Shipping.exe
REM             (OrionGame\Binaries\Win64\)
REM ===========================================================================

set "CONFIG=%~dp0config.json"
set "CLIENTEXE=OrionClient-Win64-Shipping.exe"

echo ============================================================
echo            PROJECT MONOLITH  -  CLIENT LAUNCHER
echo ============================================================
echo.
echo  INPUT FORMAT NOTES:
echo   - Menu choices: type the number shown, then press Enter.
echo   - Username: letters, digits, _ and - only (no spaces / no ! ^^).
echo   - External IP: IPv4 like 26.123.45.67  (port :7777 auto-added).
echo ============================================================
echo.

REM ---------------------------------------------------------------------------
REM  1) USERNAME  (robust JSON read - no pipe, LiteralPath, errors silenced)
REM ---------------------------------------------------------------------------
set "CURNAME="
if exist "%CONFIG%" (
    for /f "usebackq tokens=* delims=" %%i in (`powershell -NoProfile -Command "try{(ConvertFrom-Json (Get-Content -Raw -LiteralPath '%CONFIG%')).displayname}catch{}" 2^>nul`) do set "CURNAME=%%i"
)
if not defined CURNAME set "CURNAME=player1"

echo Current username in config.json: !CURNAME!
echo.
:askUN
set "UNCHOICE="
set /p "UNCHOICE=Username  [1] keep current  [2] enter new  : "
if "!UNCHOICE!"=="1" goto unOK
if not "!UNCHOICE!"=="2" (
    echo   ^>^> Invalid choice. Enter 1 or 2.
    goto askUN
)
:askNewName
set "NEWNAME="
set /p "NEWNAME=Enter new username: "
if not defined NEWNAME (
    echo   ^>^> Username cannot be empty.
    goto askNewName
)
echo(!NEWNAME!| findstr /r /c:"^[A-Za-z0-9_-][A-Za-z0-9_-]*$" >nul
if errorlevel 1 (
    echo   ^>^> Invalid. Only letters, digits, underscore and dash allowed.
    goto askNewName
)
set "CURNAME=!NEWNAME!"
:unOK
set "NAME=!CURNAME!"
echo  -^> Username: !NAME!
echo.

REM ---------------------------------------------------------------------------
REM  2) IP
REM ---------------------------------------------------------------------------
:askIP
set "IPCHOICE="
set /p "IPCHOICE=Server  [1] localhost (127.0.0.1:7777)  [2] external IP  : "
if "!IPCHOICE!"=="1" (
    set "IP=127.0.0.1:7777"
    goto ipOK
)
if not "!IPCHOICE!"=="2" (
    echo   ^>^> Invalid choice. Enter 1 or 2.
    goto askIP
)
:askExt
set "EXTIP="
set /p "EXTIP=Enter external IPv4 (e.g. 26.123.45.67  or  ip:port): "
if not defined EXTIP (
    echo   ^>^> Cannot be empty.
    goto askExt
)
echo !EXTIP!| find ":" >nul
if errorlevel 1 (
    call :ValidIPv4 "!EXTIP!"
    if "!ERR!"=="1" (
        echo   ^>^> Invalid IPv4. Use x.x.x.x  e.g. 26.123.45.67
        goto askExt
    )
    set "IP=!EXTIP!:7777"
    goto ipOK
)
for /f "tokens=1,2 delims=:" %%h in ("!EXTIP!") do (
    set "EH=%%h"
    set "EP=%%i"
)
call :ValidIPv4 "!EH!"
if "!ERR!"=="1" (
    echo   ^>^> Invalid IPv4 part. Use x.x.x.x:port
    goto askExt
)
echo(!EP!| findstr /r /c:"^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo   ^>^> Invalid port. Digits only.
    goto askExt
)
set "IP=!EH!:!EP!"
:ipOK
echo  -^> IP: !IP!
echo.

REM ---------------------------------------------------------------------------
REM  3) HERO  (clear name shown, console name written to config.json)
REM ---------------------------------------------------------------------------
set "HRO[1]=Murdock|Price"
set "HRO[2]=Gadget|Gadget"
set "HRO[3]=Grux|Grux"
set "HRO[4]=Muriel|Muriel"
set "HRO[5]=Rampage|Rampage"
set "HRO[6]=Sparrow|Sparrow"
set "HRO[7]=Steel|Steel"
set "HRO[8]=Twinblast|TwinBlast"
set "HRO[9]=Kwang|Kwang"
set "HRO[10]=FengMao|ArcBlade"
set "HRO[11]=Crunch|Crunch"
set "HRO[12]=Dekker|Totem"
set "HRO[13]=Gideon|RiftMage"
set "HRO[14]=Howitzer|HyperBreach"
set "HRO[15]=Kallari|Kurohane"
set "HRO[16]=Sevarog|Hammer"
set "HRO[17]=IggyScorch|Pyro"
set "HRO[18]=GrimExe|Coil"
set "HRO[19]=Riktor|Chains"
set "HRO[20]=Khaimera|Tomahawk"
set "HRO[21]=Greystone|Sword"
set "HRO[22]=Fey|Venus"
set "HRO[23]=Nagash|WarDrum"
set "HRO[24]=LtBelicia|Tacticia"
set "HRO[25]=Countess|Vamp"
set "HRO[26]=Wukong|Wukong"
set "HRO[27]=Tera|Justice"
set "HRO[28]=Aurora|Ice"
set "HRO[29]=Shinbi|Mudang"
set "HRO[30]=Morigesh|Mambo"
set "HRO[31]=Revenant|Revenant"
set "HRO[32]=Yin|Femme"
set "HRO[33]=Zinx|Medic"
set "HRO[34]=Serath|FallenAngel"
set "HRO[35]=Drongo|Shrapnel"
set "HRO[36]=Wraith|Ghost"
set "HRO[37]=Phase|Phase"
set "HCOUNT=37"

echo Choose your hero:
echo ------------------------------------------------------------
for /l %%n in (1,1,%HCOUNT%) do (
    for /f "tokens=1 delims=|" %%a in ("!HRO[%%n]!") do (
        set "PAD=  %%n"
        set "PAD=!PAD:~-3!"
        echo   !PAD!^) %%a
    )
)
echo ------------------------------------------------------------
:askHero
set "HSEL="
set /p "HSEL=Enter hero number (1-%HCOUNT%): "
set "PICK=!HRO[%HSEL%]!"
if "!PICK!"=="" (
    echo   ^>^> Invalid. Enter a number from 1 to %HCOUNT%.
    goto askHero
)
for /f "tokens=1,2 delims=|" %%a in ("!PICK!") do (
    set "HCLEAR=%%a"
    set "HCONSOLE=%%b"
)
echo  -^> Hero: !HCLEAR!  ^(config name: !HCONSOLE!^)
echo.

REM ---------------------------------------------------------------------------
REM  4) SKIN  (0 = Default -> no skin key; else full skin object name)
REM      Per-hero skin lists are hardcoded as :SKIN_<console> labels near
REM      the end of this file. Server resolves by exact (case-insensitive)
REM      object-name match; missing/invalid -> hero DefaultSkin.
REM ---------------------------------------------------------------------------
set "SKNCNT=0"
goto SKIN_!HCONSOLE!
:SKINBACK
echo Skin for !HCLEAR!:
echo ------------------------------------------------------------
echo     0^) Default ^(hero default skin^)
for /l %%n in (1,1,!SKNCNT!) do (
    set "PAD=  %%n"
    set "PAD=!PAD:~-3!"
    echo   !PAD!^) !SKN[%%n]!
)
echo ------------------------------------------------------------
:askSkin
set "SKSEL="
set /p "SKSEL=Enter skin number (0-!SKNCNT!): "
set "SKINPART="
if "!SKSEL!"=="0" ( set "SKLBL=Default" & goto skinOK )
set "SKVAL=!SKN[%SKSEL%]!"
if "!SKVAL!"=="" (
    echo   ^>^> Invalid. Enter a number from 0 to !SKNCNT!.
    goto askSkin
)
set "SKINPART=, "skin": "!SKVAL!""
set "SKLBL=!SKVAL!"
:skinOK
echo  -^> Skin: !SKLBL!
echo.

REM ---------------------------------------------------------------------------
REM  5) ROLE  (default = no role key = hero-based auto-detect)
REM ---------------------------------------------------------------------------
echo Lane / Role:
echo   [0] Default (auto-detect by hero - no role key)
echo   [1] Offlane   [2] Mid   [3] Carry   [4] Support   [5] Jungle
:askRole
set "RCHOICE="
set /p "RCHOICE=Select (0-5): "
set "ROLEPART="
if "!RCHOICE!"=="0" goto role0
if "!RCHOICE!"=="1" goto role1
if "!RCHOICE!"=="2" goto role2
if "!RCHOICE!"=="3" goto role3
if "!RCHOICE!"=="4" goto role4
if "!RCHOICE!"=="5" goto role5
echo   ^>^> Invalid. Enter 0 to 5.
goto askRole
:role0
set "RLBL=default (auto-detect)"
goto roleOK
:role1
set "ROLEPART=, "role": "0""
set "RLBL=Offlane"
goto roleOK
:role2
set "ROLEPART=, "role": "1""
set "RLBL=Mid"
goto roleOK
:role3
set "ROLEPART=, "role": "2""
set "RLBL=Carry"
goto roleOK
:role4
set "ROLEPART=, "role": "3""
set "RLBL=Support"
goto roleOK
:role5
set "ROLEPART=, "role": "4""
set "RLBL=Jungle"
goto roleOK
:roleOK
echo  -^> Role: !RLBL!
echo.

REM ---------------------------------------------------------------------------
REM  5) TEAM   (server DLL mapping: team "2" -> Red , "1" -> Blue)
REM ---------------------------------------------------------------------------
:askTeam
set "TCHOICE="
set /p "TCHOICE=Team  [2] RED (team=2)  [1] BLUE (team=1)  : "
if "!TCHOICE!"=="2" ( set "TEAM=2" & set "TEAMLBL=RED"  & goto teamOK )
if "!TCHOICE!"=="1" ( set "TEAM=1" & set "TEAMLBL=BLUE" & goto teamOK )
echo   ^>^> Invalid. Enter 1 or 2.
goto askTeam
:teamOK
echo  -^> Team: !TEAMLBL! ^(team=!TEAM!^)
echo.

REM ---------------------------------------------------------------------------
REM  WRITE config.json
REM ---------------------------------------------------------------------------
> "%CONFIG%" echo {"ip": "!IP!", "displayname": "!NAME!", "hero": "!HCONSOLE!", "team": "!TEAM!"!ROLEPART!!SKINPART!}

echo ============================================================
echo  config.json written:
type "%CONFIG%"
echo.
echo ============================================================
echo.

if not exist "%~dp0%CLIENTEXE%" (
    echo WARNING: %CLIENTEXE% not found in this folder.
    echo Place this .bat next to the client executable.
    echo.
    pause
    exit /b 1
)

echo Launching client...
start "" "%~dp0%CLIENTEXE%" -epicportal -log
echo Done.
timeout /t 3 >nul
endlocal
exit /b 0

REM ===========================================================================
REM  PER-HERO SKIN LISTS  (hardcoded from F6 [SKIN-DUMP], all 397 [SAFE])
REM  Each block sets SKN[1..N] + SKNCNT then jumps back to :SKINBACK.
REM  Server resolves by exact case-insensitive object-name match.
REM ===========================================================================
:SKIN_Price
set "SKN[1]=ChallengerSkin_Price"
set "SKN[2]=MasterSkin_Price"
set "SKN[3]=PriceSkin_Default"
set "SKN[4]=RivalSkin_Price"
set "SKN[5]=Skin_Price_Buy_T1_5_Wasteland"
set "SKN[6]=Skin_Price_Buy_T1_Executioner"
set "SKN[7]=Skin_Price_Buy_T1_Halloween"
set "SKN[8]=Skin_Price_Buy_T2_Green_Carbon"
set "SKN[9]=Skin_Price_Buy_T2_Snakebite"
set "SKN[10]=Skin_Price_Buy_T2_polar_Strike"
set "SKN[11]=Skin_Price_Buy_Tier2_BioFreak"
set "SKN[12]=Skin_Price_Buy_Tier2_BlueBioFreak"
set "SKN[13]=Skin_Price_Buy_Tier2_GreenBioFreak"
set "SKN[14]=Skin_Price_Gift_A_SpecialForces"
set "SKN[15]=Skin_Price_Gift_CS_Monarch"
set "SKN[16]=Skin_Price_Tier1_5_Shogun"
set "SKNCNT=16"
goto SKINBACK

:SKIN_Gadget
set "SKN[1]=ChallengerSkin_Gadget"
set "SKN[2]=GadgetSkin_Default"
set "SKN[3]=GadgetSkin_Shellshock"
set "SKN[4]=GadgetSkin_Shellshock_RP1"
set "SKN[5]=GadgetSkin_Shellshock_RP2"
set "SKN[6]=MasterSkin_Gadget"
set "SKN[7]=RivalSkin_Gadget"
set "SKN[8]=Skin_Gadget_Buy_A_Camo"
set "SKN[9]=Skin_Gadget_Buy_T1_Winter2016"
set "SKNCNT=9"
goto SKINBACK

:SKIN_Grux
set "SKN[1]=ChallengerSkin_Grux"
set "SKN[2]=GruxSkin_Default"
set "SKN[3]=MasterSkin_Grux"
set "SKN[4]=RivalSkin_Grux"
set "SKN[5]=STAR_Skin_Grux_Buy_T1_Tribal"
set "SKN[6]=STAR_Skin_Grux_Challenger"
set "SKN[7]=STAR_Skin_Grux_Halloween"
set "SKN[8]=STAR_Skin_Grux_Master"
set "SKN[9]=STAR_Skin_Grux_Rival"
set "SKN[10]=Skin_Grux_Buy_A_Tribal"
set "SKN[11]=Skin_Grux_Buy_T1_Halloween"
set "SKN[12]=Skin_Grux_Buy_Tier2_Beetle"
set "SKN[13]=Skin_Grux_Buy_Tier2_Qilin"
set "SKN[14]=Skin_Grux_Buy_Tier_1_5_Chestplate"
set "SKN[15]=Skin_Grux_Drop_Tier2_BlackBeetle"
set "SKN[16]=Skin_Grux_Drop_Tier2_GoldBeetle"
set "SKN[17]=Skin_Grux_Drop_Tier3_MagmaBeetle"
set "SKNCNT=17"
goto SKINBACK

:SKIN_Muriel
set "SKN[1]=ChallengerSkin_Muriel"
set "SKN[2]=MasterSkin_Muriel"
set "SKN[3]=MurielSkin_Default"
set "SKN[4]=RivalSkin_Muriel"
set "SKN[5]=Skin_Muriel_Buy_A_Copper"
set "SKN[6]=Skin_Muriel_Buy_T1_Amethyst"
set "SKN[7]=Skin_Muriel_Buy_T3_DarkAngel"
set "SKN[8]=Skin_Muriel_Earn_T1_Midnight"
set "SKNCNT=8"
goto SKINBACK

:SKIN_Rampage
set "SKN[1]=ChallengerSkin_Rampage"
set "SKN[2]=MasterSkin_Rampage"
set "SKN[3]=RampageSkin_Default"
set "SKN[4]=RivalSkin_Rampage"
set "SKN[5]=Skin_Rampage_Buy_A_Bloodrage"
set "SKN[6]=Skin_Rampage_Buy_T1_Redneck"
set "SKN[7]=Skin_Rampage_Buy_Tier2_Elemental"
set "SKN[8]=Skin_Rampage_Buy_Tier2_Elemental_Copper"
set "SKN[9]=Skin_Rampage_Buy_Tier2_Elemental_Ent"
set "SKN[10]=Skin_Rampage_Buy_Tier2_Elemental_Ice"
set "SKN[11]=Skin_Rampage_Tier1_5_Armored"
set "SKNCNT=11"
goto SKINBACK

:SKIN_Sparrow
set "SKN[1]=ChallengerSkin_Sparrow"
set "SKN[2]=MasterSkin_Sparrow"
set "SKN[3]=RivalSkin_Sparrow"
set "SKN[4]=SparrowSkin_Default"
set "SKN[5]=SparrowSkin_WildWestRP1"
set "SKN[6]=SparrowSkin_WildWestRP2"
set "SKN[7]=SparrowSkin_Wild_West"
set "SKN[8]=Skin_Sparrow_Buy_A_AutumnFire"
set "SKN[9]=Skin_Sparrow_Buy_T1_5_Raven"
set "SKN[10]=Skin_Sparrow_Buy_T1_5_Tough"
set "SKN[11]=Skin_Sparrow_Buy_T1_Halloween"
set "SKN[12]=Skin_Sparrow_Buy_T2_Rogue"
set "SKN[13]=Skin_Sparrow_Buy_T2_Rogue_RP1"
set "SKN[14]=Skin_Sparrow_Buy_T2_Rogue_RP2"
set "SKN[15]=Skin_Sparrow_Gift_CS_Monarch"
set "SKNCNT=15"
goto SKINBACK

:SKIN_Steel
set "SKN[1]=BuySkin_Steel_A_CarbonFiber"
set "SKN[2]=BuySkin_Steel_T1_Aegis"
set "SKN[3]=ChallengerSkin_Steel"
set "SKN[4]=MasterSkin_Steel"
set "SKN[5]=RivalSkin_Steel"
set "SKN[6]=Skin_Steel_CS_Gift_Cobalt"
set "SKN[7]=Skin_Steel_T1_Buy_Diesel"
set "SKN[8]=Skin_Steel_T1_Buy_PolyTech"
set "SKN[9]=Skin_Steel_T3_Buy_Mayan"
set "SKN[10]=Skin_Steel_T3_Buy_MayanStone"
set "SKN[11]=Skin_Steel_T3_Buy_MayanWarpaint"
set "SKN[12]=SteelSkin_Default"
set "SKNCNT=12"
goto SKINBACK

:SKIN_TwinBlast
set "SKN[1]=ChallengerSkin_Twinblast"
set "SKN[2]=MasterSkin_Twinblast"
set "SKN[3]=RivalSkin_Twinblast"
set "SKN[4]=Skin_TwinBlast_Buy_T2_ActionMovie"
set "SKN[5]=Skin_TwinBlast_Buy_T2_ActionMovie_Boss"
set "SKN[6]=Skin_Twinblast_Buy_A_Wasteland"
set "SKN[7]=Skin_Twinblast_Buy_T1_Energized"
set "SKN[8]=Skin_Twinblast_Buy_T1_Halloween"
set "SKN[9]=Skin_Twinblast_Buy_T2_ShadowOps"
set "SKN[10]=Skin_Twinblast_Buy_T2_ShadowOps_Carbon"
set "SKN[11]=Skin_Twinblast_Buy_T2_ShadowOps_Gilded"
set "SKN[12]=Skin_Twinblast_Buy_T2_ShadowOps_RedWhite"
set "SKN[13]=Skin_Twinblast_Buy_T2_SummerTime"
set "SKN[14]=Skin_Twinblast_Buy_T2_SummerTime_RP1"
set "SKN[15]=TwinBlastSkin_Default"
set "SKNCNT=15"
goto SKINBACK

:SKIN_Kwang
set "SKN[1]=Challengerskin_Kwang"
set "SKN[2]=KwangSkin_Default"
set "SKN[3]=MasterSkin_Kwang"
set "SKN[4]=RivalSkin_Kwang"
set "SKN[5]=SKin_Kwang_Buy_T1_SilverGhost"
set "SKN[6]=SKin_Kwang_Buy_T1_rosewood"
set "SKN[7]=Skin_Kwang_Buy_T1_Sunburst"
set "SKN[8]=Skin_Kwang_Buy_T2_Manbun"
set "SKN[9]=Skin_Kwang_Buy_T2_Manbun_RP1"
set "SKN[10]=Skin_Kwang_Buy_T2_Manbun_RP2"
set "SKN[11]=Skin_Kwang_Buy_T2_Zombie"
set "SKNCNT=11"
goto SKINBACK

:SKIN_ArcBlade
set "SKN[1]=ArcBladeSkin_Default"
set "SKN[2]=ChallengerSkin_ArcBlade"
set "SKN[3]=MasterSkin_Arcblade"
set "SKN[4]=RivalSkin_Arcblade"
set "SKN[5]=STAR_Skin_Arcblade_Challenger"
set "SKN[6]=STAR_Skin_Arcblade_Master"
set "SKN[7]=STAR_Skin_Arcblade_Rival"
set "SKN[8]=Skin_Arcblade_Buy_A_InnerFire"
set "SKN[9]=Skin_Arcblade_Buy_T1_DarkReaper"
set "SKN[10]=Skin_Arcblade_Buy_T1_Winter2016"
set "SKN[11]=Skin_Arcblade_Buy_T2_RG-BoneCollector"
set "SKN[12]=Skin_Arcblade_Buy_T2_RG-Horns"
set "SKN[13]=Skin_Arcblade_Buy_T2_RG-Undertow"
set "SKN[14]=Skin_Arcblade_Buy_T2_RP1_RoyalGuard"
set "SKN[15]=Skin_Arcblade_Buy_T2_RP2_RoyalGuard"
set "SKN[16]=Skin_Arcblade_Buy_T2_RoyalGuard"
set "SKNCNT=16"
goto SKINBACK

:SKIN_Crunch
set "SKN[1]=ChallengerSkin_Crunch"
set "SKN[2]=MasterSkin_Crunch"
set "SKN[3]=RivalSkin_Crunch"
set "SKN[4]=Skin_Crunch_Buy_T1_GoldenGloves"
set "SKN[5]=Skin_Crunch_Buy_T1_Siege"
set "SKN[6]=Skin_Crunch_Buy_T1_Titanium"
set "SKN[7]=Skin_Crunch_Buy_T1_Valentines2017"
set "SKN[8]=Skin_Crunch_Buy_T3_Black_Site"
set "SKN[9]=Skin_Crunch_Buy_T3_Crash_Site"
set "SKN[10]=Skin_Crunch_Buy_T3_Crash_Site_RP1"
set "SKN[11]=Skin_Crunch_Default"
set "SKNCNT=11"
goto SKINBACK

:SKIN_Totem
set "SKN[1]=ChallengerSkin_Totem"
set "SKN[2]=MasterSkin_Totem"
set "SKN[3]=RivalSkin_Totem"
set "SKN[4]=Skin_Totem_Buy_A_Static"
set "SKN[5]=Skin_Totem_Buy_T1_Arctic"
set "SKN[6]=Skin_Totem_Buy_T1_Valentines2017"
set "SKN[7]=Skin_Totem_Gift_CS_Monarch"
set "SKN[8]=TotemSkin_Default"
set "SKNCNT=8"
goto SKINBACK

:SKIN_RiftMage
set "SKN[1]=ChallengerSkin_Riftmage"
set "SKN[2]=MasterSkin_RiftMage"
set "SKN[3]=RiftMageSkin_Default"
set "SKN[4]=RivalSkin_Riftmage"
set "SKN[5]=Skin_Riftmage_Buy_T2_Tough"
set "SKN[6]=Skin_Riftmage_Buy_Tier1_Halloween"
set "SKN[7]=Skin_Riftmage_Buy_Tier1_Inquisitor"
set "SKN[8]=Skin_Riftmage_Buy_Tier2_Undertow"
set "SKN[9]=Skin_Riftmage_Drop_Tier2_Undertow_Carnivale"
set "SKN[10]=Skin_Riftmage_Drop_Tier2_Undertow_GoldSkull"
set "SKNCNT=10"
goto SKINBACK

:SKIN_HyperBreach
set "SKN[1]=BuySkin_Hyperbreach_A_Hotrod"
set "SKN[2]=BuySkin_Hyperbreach_A_Wasteland"
set "SKN[3]=ChallengerSkin_Hyperbreach"
set "SKN[4]=HyperBreachSkin_Default"
set "SKN[5]=MasterSkin_Hyperbreach"
set "SKN[6]=RivalSkin_Hyperbreach"
set "SKN[7]=Skin_Hyperbreach_Buy_T2_WhiteDome"
set "SKN[8]=Skin_Hyperbreach_Drop_T2_LoveMachine"
set "SKNCNT=8"
goto SKINBACK

:SKIN_Kurohane
set "SKN[1]=BuySkin_Kurohane_A_Purple"
set "SKN[2]=ChallengerSkin_Kurohane"
set "SKN[3]=KurohaneSkin_Default"
set "SKN[4]=MasterSkin_Kurohane"
set "SKN[5]=RivalSkin_Kurohane"
set "SKN[6]=Skin_Kurohane_Buy_T1_Winter2016"
set "SKN[7]=Skin_Kurohane_Buy_T2_Rogue"
set "SKN[8]=Skin_Kurohane_Buy_T2_Rogue_RP1"
set "SKN[9]=Skin_Kurohane_Buy_T2_Rogue_RP2"
set "SKN[10]=Skin_Kurohane_T1_5_Tough"
set "SKN[11]=Skin_Kurohane_T1_5_Wasteland"
set "SKN[12]=Skin_Kurohane_T1_Buy_RedDeath"
set "SKNCNT=12"
goto SKINBACK

:SKIN_Hammer
set "SKN[1]=ChallengerSkin_Hammer"
set "SKN[2]=HammerSkin_Default"
set "SKN[3]=MasterSkin_Hammer"
set "SKN[4]=RivalSkin_Hammer"
set "SKN[5]=STAR_Skin_Hammer_Challenger"
set "SKN[6]=STAR_Skin_Hammer_Master"
set "SKN[7]=STAR_Skin_Hammer_Rival"
set "SKN[8]=STAR_Skin_Hammer_T1_Buy_GrandOracle"
set "SKN[9]=STAR_Skin_Hammer_T1_RedEmperor"
set "SKN[10]=Skin_Hammer_T1_Buy_GrandOracle"
set "SKN[11]=Skin_Hammer_T1_Buy_MaskedReaper"
set "SKN[12]=Skin_Hammer_T1_Earn_RedEmporer"
set "SKNCNT=12"
goto SKINBACK

:SKIN_Pyro
set "SKN[1]=ChallengerSkin_Pyro"
set "SKN[2]=MasterSkin_Pyro"
set "SKN[3]=RivalSkin_Pyro"
set "SKN[4]=STAR_Skin_Pyro_Challenger"
set "SKN[5]=STAR_Skin_Pyro_Master"
set "SKN[6]=STAR_Skin_Pyro_Rival"
set "SKN[7]=Skin_Pyro_Buy_T1_Tribal"
set "SKN[8]=Skin_Pyro_Buy_T1_Winter2016"
set "SKN[9]=Skin_Pyro_Buy_T3_Phoenix"
set "SKN[10]=Skin_Pyro_Buy_T3_Robot"
set "SKN[11]=Skin_Pyro_Buy_T3_Robot_RP1"
set "SKN[12]=Skin_Pyro_Buy_T3_Robot_RP2"
set "SKN[13]=Skin_Pyro_Buy_Tier1_Fireball"
set "SKN[14]=Skin_Pyro_Default"
set "SKNCNT=14"
goto SKINBACK

:SKIN_Coil
set "SKN[1]=ChallengerSkin_Coil"
set "SKN[2]=CoilSkin_Default"
set "SKN[3]=MasterySkin_Coil"
set "SKN[4]=RivalSkin_Coil"
set "SKN[5]=Skin_Coil_Buy_T1_5_Wasteland"
set "SKN[6]=Skin_Coil_Buy_T1_MetallicGreen"
set "SKN[7]=Skin_Coil_Buy_T1_RazorRed"
set "SKNCNT=7"
goto SKINBACK

:SKIN_Chains
set "SKN[1]=ChainsSkin_BadSanta"
set "SKN[2]=ChainsSkin_Default"
set "SKN[3]=ChallengerSkin_Chains"
set "SKN[4]=MasterSkin_Chains"
set "SKN[5]=RivalSkin_Chains"
set "SKN[6]=Skin_Chains_Buy_A_BronzeWarden"
set "SKNCNT=6"
goto SKINBACK

:SKIN_Tomahawk
set "SKN[1]=STAR_Skin_Tomahawk_Buy_T1_Halloween"
set "SKN[2]=STAR_Skin_Tomahawk_Buy_T1_PitViper"
set "SKN[3]=STAR_Skin_Tomahawk_Buy_T1_SunTiger"
set "SKN[4]=STAR_Skin_Tomahawk_Buy_T1_WhiteTiger"
set "SKN[5]=STAR_Skin_Tomahawk_Challenger"
set "SKN[6]=STAR_Skin_Tomahawk_Def"
set "SKN[7]=STAR_Skin_Tomahawk_Master"
set "SKN[8]=STAR_Skin_Tomahawk_Rival"
set "SKN[9]=Skin_Tomahawk_Buy_T1_Halloween"
set "SKN[10]=Skin_Tomahawk_Buy_T1_PitViper"
set "SKN[11]=Skin_Tomahawk_Buy_T1_SunTiger"
set "SKN[12]=Skin_Tomahawk_Buy_T1_WhiteTiger"
set "SKN[13]=Skin_Tomahawk_Buy_T2_GruxPelt"
set "SKN[14]=Skin_Tomahawk_Buy_T2_GruxPelt_RP1"
set "SKN[15]=TomahawkSkin_Challenger"
set "SKN[16]=TomahawkSkin_Default"
set "SKN[17]=TomahawkSkin_Mastery"
set "SKN[18]=TomahawkSkin_Rival"
set "SKNCNT=18"
goto SKINBACK

:SKIN_Sword
set "SKN[1]=Skin_Sword_Buy_T1_Spaceknight"
set "SKN[2]=Skin_Sword_Buy_T1_Spaceknight_RP1"
set "SKN[3]=Skin_Sword_Buy_T1_Spaceknight_RP2"
set "SKN[4]=Skin_Sword_T1_Buy_DragonLord"
set "SKN[5]=Skin_Sword_T1_Buy_WhiteTiger"
set "SKN[6]=Skin_Sword_T2_99Tough"
set "SKN[7]=Skin_Sword_T2_99Tough_RP1"
set "SKN[8]=Skin_Sword_T2_99Tough_RP2"
set "SKN[9]=SwordSkin_Challenger"
set "SKN[10]=SwordSkin_Default"
set "SKN[11]=SwordSkin_Master"
set "SKN[12]=SwordSkin_Rival"
set "SKNCNT=12"
goto SKINBACK

:SKIN_Venus
set "SKN[1]=STAR_Skin_Venus_Buy_T1_Autumnal_RP1"
set "SKN[2]=STAR_Skin_Venus_Challenger"
set "SKN[3]=STAR_Skin_Venus_Def"
set "SKN[4]=STAR_Skin_Venus_Master"
set "SKN[5]=STAR_Skin_Venus_Rival"
set "SKN[6]=Skin_Venus_Buy_T2_Autumnal"
set "SKN[7]=Skin_Venus_Buy_T2_Autumnal_RP1"
set "SKN[8]=Skin_Venus_Buy_T2_Autumnal_RP2"
set "SKN[9]=Skin_Venus_Buy_T2_CelestialButterfly"
set "SKN[10]=Skin_Venus_Buy_T2_RoseButterfly"
set "SKN[11]=Skin_Venus_Buy_Tier1_Angelic"
set "SKN[12]=Skin_Venus_Buy_Tier1_Nightshade"
set "SKN[13]=Skin_Venus_Buy_Tier1_Rainbow"
set "SKN[14]=VenusSkin_Challenger"
set "SKN[15]=VenusSkin_Default"
set "SKN[16]=VenusSkin_Mastery"
set "SKN[17]=VenusSkin_Rival"
set "SKNCNT=17"
goto SKINBACK

:SKIN_WarDrum
set "SKN[1]=STAR_Skin_WarDrum_Buy_Tier1_Ginger"
set "SKN[2]=STAR_Skin_Wardrum_Buy_T1_BlueBeat"
set "SKN[3]=STAR_Skin_Wardrum_Challenger"
set "SKN[4]=STAR_Skin_Wardrum_Def"
set "SKN[5]=STAR_Skin_Wardrum_Master"
set "SKN[6]=STAR_Skin_Wardrum_Rival"
set "SKN[7]=Skin_WarDrum_Buy_Tier1_Ginger"
set "SKN[8]=Skin_WarDrum_Buy_Tier3_Scarecrow"
set "SKN[9]=Skin_WarDrum_Buy_Tier3_Scarecrow_RP1"
set "SKN[10]=Skin_WarDrum_Challenger"
set "SKN[11]=Skin_WarDrum_Default"
set "SKN[12]=Skin_WarDrum_Master"
set "SKN[13]=Skin_WarDrum_Rival"
set "SKN[14]=Skin_Wardrum_Buy_T1_BlueBeat"
set "SKNCNT=14"
goto SKINBACK

:SKIN_Tacticia
set "SKN[1]=ChallengerSkin_Tacticia"
set "SKN[2]=MasterSkin_Tacticia"
set "SKN[3]=RivalSkin_Tacticia"
set "SKN[4]=Skin_Tacticia_Buy_T1_Halloween"
set "SKN[5]=Skin_Tacticia_Buy_T2_HeavyArmor"
set "SKN[6]=Skin_Tacticia_Buy_Tier1_ShadowCommander"
set "SKN[7]=Skin_Tacticia_Buy_Tier1_YellowHazard"
set "SKN[8]=TacticiaSkin_Default"
set "SKN[9]=TacticiaSkin_Zombie"
set "SKNCNT=9"
goto SKINBACK

:SKIN_Vamp
set "SKN[1]=ChallengerSkin_Vamp"
set "SKN[2]=MasterSkin_Vamp"
set "SKN[3]=RivalSkin_Vamp"
set "SKN[4]=STAR_Skin_Vamp_Buy_T1_Carnivale"
set "SKN[5]=STAR_Skin_Vamp_Buy_T1_GoldenMasque"
set "SKN[6]=STAR_Skin_Vamp_Buy_T1_RedHex"
set "SKN[7]=STAR_Skin_Vamp_Buy_T2_Shogun"
set "SKN[8]=STAR_Skin_Vamp_Challenger"
set "SKN[9]=STAR_Skin_Vamp_Def"
set "SKN[10]=STAR_Skin_Vamp_Master"
set "SKN[11]=STAR_Skin_Vamp_Rival"
set "SKN[12]=Skin_Vamp_Buy_T1_Carnivale"
set "SKN[13]=Skin_Vamp_Buy_T1_GoldenMasque"
set "SKN[14]=Skin_Vamp_Buy_T1_RedHex"
set "SKN[15]=Skin_Vamp_Buy_T2_Shogun"
set "SKN[16]=VampSkin_Default"
set "SKNCNT=16"
goto SKINBACK

:SKIN_Wukong
set "SKN[1]=Skin_Wukong_Buy_T2_Halloween"
set "SKN[2]=Skin_Wukong_Buy_T3_Future"
set "SKN[3]=Skin_Wukong_Buy_T3_GreatSage"
set "SKN[4]=Skin_Wukong_Buy_T3_PolarStrike"
set "SKN[5]=Skin_Wukong_Challenger"
set "SKN[6]=Skin_Wukong_Default"
set "SKN[7]=Skin_Wukong_Fury"
set "SKN[8]=Skin_Wukong_Master"
set "SKN[9]=Skin_Wukong_Rival"
set "SKN[10]=Skin_Wukong_Royalty"
set "SKNCNT=10"
goto SKINBACK

:SKIN_Justice
set "SKN[1]=JusticeSkin_Buy_Tier1_5_DragonHorn"
set "SKN[2]=JusticeSkin_Buy_Tier1_5_Gryphon"
set "SKN[3]=JusticeSkin_Challenger"
set "SKN[4]=JusticeSkin_Cyber"
set "SKN[5]=JusticeSkin_Default"
set "SKN[6]=JusticeSkin_Master"
set "SKN[7]=JusticeSkin_Rival"
set "SKNCNT=7"
goto SKINBACK

:SKIN_Ice
set "SKN[1]=STAR_Skin_Ice_Buy_T1_Geode"
set "SKN[2]=STAR_Skin_Ice_Challenger"
set "SKN[3]=STAR_Skin_Ice_Def"
set "SKN[4]=STAR_Skin_Ice_Master"
set "SKN[5]=STAR_Skin_Ice_Rival"
set "SKN[6]=Skin_Ice_Buy_T15_PorcelainFlower"
set "SKN[7]=Skin_Ice_Buy_T1_5_Winter"
set "SKN[8]=Skin_Ice_Buy_T1_Geode"
set "SKN[9]=Skin_Ice_Challenger"
set "SKN[10]=Skin_Ice_Default"
set "SKN[11]=Skin_Ice_LichQueen"
set "SKN[12]=Skin_Ice_LichQueen_Emerald"
set "SKN[13]=Skin_Ice_Master"
set "SKN[14]=Skin_Ice_Rival"
set "SKNCNT=14"
goto SKINBACK

:SKIN_Mudang
set "SKN[1]=MudangSkin_Challenger"
set "SKN[2]=MudangSkin_Default"
set "SKN[3]=MudangSkin_Master"
set "SKN[4]=MudangSkin_Rival"
set "SKN[5]=Skin_Mudang_Buy_T1_Dynasty"
set "SKNCNT=5"
goto SKINBACK

:SKIN_Mambo
set "SKN[1]=MamboSkin_Challenger"
set "SKN[2]=MamboSkin_DarkHeart"
set "SKN[3]=MamboSkin_Default"
set "SKN[4]=MamboSkin_Mastery"
set "SKN[5]=MamboSkin_Rival"
set "SKN[6]=STAR_Skin_Mambo_Challenger"
set "SKN[7]=STAR_Skin_Mambo_Master"
set "SKN[8]=STAR_Skin_Mambo_Rival"
set "SKN[9]=Skin_Mambo_Buy_T3_Frost"
set "SKN[10]=Skin_Mambo_Buy_T3_NorthernMystic_Antlers"
set "SKNCNT=10"
goto SKINBACK

:SKIN_Revenant
set "SKN[1]=Skin_Revenant_Buy_T3_Winter"
set "SKN[2]=Skin_Revenant_Buy_T_1_5_Raven"
set "SKN[3]=Skin_Revenant_Challenger"
set "SKN[4]=Skin_Revenant_Chronos"
set "SKN[5]=Skin_Revenant_Default"
set "SKN[6]=Skin_Revenant_Master"
set "SKN[7]=Skin_Revenant_Rival"
set "SKNCNT=7"
goto SKINBACK

:SKIN_Femme
set "SKN[1]=FemmeSkin_Challenger"
set "SKN[2]=FemmeSkin_Default"
set "SKN[3]=FemmeSkin_Master"
set "SKN[4]=FemmeSkin_Rival"
set "SKN[5]=Skin_Femme_Buy_T1_WindGauntlet"
set "SKN[6]=Skin_Femme_Buy_T2_Halloween"
set "SKNCNT=6"
goto SKINBACK

:SKIN_Medic
set "SKN[1]=Skin_Medic_Challenger"
set "SKN[2]=Skin_Medic_Default"
set "SKN[3]=Skin_Medic_Master"
set "SKN[4]=Skin_Medic_NightPrism"
set "SKN[5]=Skin_Medic_PlacidPearl"
set "SKN[6]=Skin_Medic_Rival"
set "SKNCNT=6"
goto SKINBACK

:SKIN_FallenAngel
set "SKN[1]=FallenAngelSkin_Default"
set "SKN[2]=Skin_FallenAngel_Buy_T1_FutureAngelic"
set "SKN[3]=Skin_FallenAngel_Buy_T1_GoldandRed"
set "SKN[4]=Skin_FallenAngel_Buy_T1_Tough"
set "SKN[5]=Skin_FallenAngel_Buy_T1_Valentines2017"
set "SKN[6]=Skin_FallenAngel_Buy_T1_Zombie"
set "SKN[7]=Skin_FallenAngel_Challenger"
set "SKN[8]=Skin_FallenAngel_Master"
set "SKN[9]=Skin_FallenAngel_Rival"
set "SKNCNT=9"
goto SKINBACK

:SKIN_Shrapnel
set "SKN[1]=ShrapnelSkin_Challenger"
set "SKN[2]=ShrapnelSkin_Default"
set "SKN[3]=ShrapnelSkin_Master"
set "SKN[4]=ShrapnelSkin_Rival"
set "SKN[5]=Skin_Shrapnel_Buy_T15_Cyclops"
set "SKN[6]=Skin_Shrapnel_Buy_T15_Teddy"
set "SKNCNT=6"
goto SKINBACK

:SKIN_Ghost
set "SKN[1]=GhostSkin_Challenger"
set "SKN[2]=GhostSkin_Default"
set "SKN[3]=GhostSkin_Master"
set "SKN[4]=GhostSkin_Rival"
set "SKN[5]=Skin_Ghost_Buy_T15_Martian"
set "SKN[6]=Skin_Ghost_Buy_T15_Scalloped"
set "SKN[7]=Skin_Ghost_Buy_T1_PolyTech"
set "SKNCNT=7"
goto SKINBACK

:SKIN_Phase
set "SKN[1]=PhaseSkin_Challenger"
set "SKN[2]=PhaseSkin_Default"
set "SKN[3]=PhaseSkin_Master"
set "SKN[4]=PhaseSkin_Rival"
set "SKN[5]=Skin_Phase_Buy_T1_Kitty"
set "SKN[6]=Skin_Phase_Buy_T1_Pandapack"
set "SKNCNT=6"
goto SKINBACK

REM ===========================================================================
REM  SUBROUTINES
REM ===========================================================================
:ValidIPv4
REM  %~1 = candidate ; sets ERR=0 if valid dotted IPv4, else ERR=1
set "_ip=%~1"
echo(%_ip%| findstr /r /c:"^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" >nul
if errorlevel 1 ( set "ERR=1" ) else ( set "ERR=0" )
goto :eof
