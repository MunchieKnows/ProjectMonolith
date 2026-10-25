@echo off
setlocal EnableDelayedExpansion
title Project Monolith - SERVER Launcher
cd /d "%~dp0"

REM ===========================================================================
REM  Project Monolith Server Launcher  (with input validation)
REM  - Builds/edits server.json (read by Server DLL on F1 and F4 press)
REM  - Launches: OrionClient-Win64-Shipping-Server.exe -epicportal -log
REM
REM  PLACEMENT: copy this .bat next to OrionClient-Win64-Shipping-Server.exe
REM
REM  Note: boss_periodic_log_interval_sec is fixed at 60.0 (not editable here).
REM ===========================================================================

set "SCONFIG=%~dp0server.json"
set "SERVEREXE=OrionClient-Win64-Shipping-Server.exe"

echo ============================================================
echo            PROJECT MONOLITH  -  SERVER LAUNCHER
echo ============================================================
echo.
echo  INPUT FORMAT NOTES:
echo   - Menu choices: type the number shown, then press Enter.
echo   - Multipliers: a number using a DOT, e.g. 2.5 or 0.55
echo                  (NO comma, no letters). Empty = use default.
echo ============================================================
echo.

REM ---------------------------------------------------------------------------
REM  1) BUFF PATCH MASTER SWITCH
REM ---------------------------------------------------------------------------
:askBuff
set "BPCHOICE="
set /p "BPCHOICE=Bot Buff Patch  [1] ENABLE  [2] DISABLE  : "
if "!BPCHOICE!"=="1" ( set "ENABLEBUFF=true"  & goto buffSet )
if "!BPCHOICE!"=="2" ( set "ENABLEBUFF=false" & goto buffSet )
echo   ^>^> Invalid choice. Enter 1 or 2.
goto askBuff
:buffSet

set "ENEMYMULT=2.5"
set "FRIENDLYMULT=2.0"

if "!ENABLEBUFF!"=="true" goto askEnemy
echo  -^> Buff patch DISABLED
goto buffDone

:askEnemy
set "IN_E="
set /p "IN_E=Enemy buff multiplier   (Bot.Buff.*  - Enter=default 1.0): "
if not defined IN_E ( set "ENEMYMULT=2.5" & goto askFriendly )
call :ValidDecimal "!IN_E!"
if "!ERR!"=="1" (
    echo   ^>^> Invalid number. Use digits and one dot, e.g. 1.5
    goto askEnemy
)
set "ENEMYMULT=!IN_E!"
:askFriendly
set "IN_F="
set /p "IN_F=Friendly buff multiplier (Bot.Friendly.Buff.* - Enter=default 1.0): "
if not defined IN_F ( set "FRIENDLYMULT=2.0" & goto friendlyShow )
call :ValidDecimal "!IN_F!"
if "!ERR!"=="1" (
    echo   ^>^> Invalid number. Use digits and one dot, e.g. 2.0
    goto askFriendly
)
set "FRIENDLYMULT=!IN_F!"
:friendlyShow
echo  -^> Buff patch ENABLED  enemy=!ENEMYMULT!  friendly=!FRIENDLYMULT!
:buffDone
echo.

REM ---------------------------------------------------------------------------
REM  2) PER-TEAM DIFFICULTY
REM ---------------------------------------------------------------------------
set "DIF[1]=introductory"
set "DIF[2]=easy"
set "DIF[3]=intermediate"
set "DIF[4]=experienced"
set "DIF[5]=veteran"
set "DIF[6]=custom"

echo Difficulty values:
echo   [1] introductory   [2] easy          [3] intermediate
echo   [4] experienced    [5] veteran       [6] custom
echo.
:askBlue
set "BD="
set /p "BD=RED team difficulty (1-6, Enter=5 veteran): "
if not defined BD set "BD=5"
set "BLUEDIFF=!DIF[%BD%]!"
if "!BLUEDIFF!"=="" (
    echo   ^>^> Invalid. Enter a number from 1 to 6.
    goto askBlue
)
:askRed
set "RD="
set /p "RD=BLUE  team difficulty (1-6, Enter=5 veteran): "
if not defined RD set "RD=5"
set "REDDIFF=!DIF[%RD%]!"
if "!REDDIFF!"=="" (
    echo   ^>^> Invalid. Enter a number from 1 to 6.
    goto askRed
)
echo  -^> Blue: !BLUEDIFF!   Red: !REDDIFF!
echo.

REM ---------------------------------------------------------------------------
REM  3) BOSS STAT MODIFICATION  (master switch enable_boss_mod)
REM     No  -> enable_boss_mod=false : boss stays 100%% vanilla
REM            (HealthRegen + Attack + MaxHealth ALL untouched)
REM     Yes -> enable_boss_mod=true  : ask MaxHP and Attack multipliers
REM
REM  boss_stat_epsilon is an internal change-detection threshold (NOT a
REM  gameplay value, see ai_documentation.txt) - always written as the
REM  documented safe default 0.5, never prompted here.
REM ---------------------------------------------------------------------------
set "BEPS=0.5"
set "BMAXHP=1.0"
set "BATTACK=1.0"
set "BREGEN=0.5"
set "ENABLEBOSS=false"

:askBoss
set "BOSSCHOICE="
set /p "BOSSCHOICE=Modify boss stats?  [1] No (boss completely vanilla)  [2] Yes (custom)  : "
if "!BOSSCHOICE!"=="1" goto bossOK
if not "!BOSSCHOICE!"=="2" (
    echo   ^>^> Invalid choice. Enter 1 or 2.
    goto askBoss
)
set "ENABLEBOSS=true"
echo.
:askHP
set "IN_HP="
set /p "IN_HP=Boss MaxHP multiplier   (e.g. 0.5 = half HP, Enter=default 1.0): "
if not defined IN_HP ( set "BMAXHP=0.5" & goto hpOK )
call :ValidDecimal "!IN_HP!"
if "!ERR!"=="1" ( echo   ^>^> Invalid number. Use e.g. 0.5 & goto askHP )
set "BMAXHP=!IN_HP!"
:hpOK
:askAT
set "IN_AT="
set /p "IN_AT=Boss Attack multiplier  (e.g. 0.55, Enter=default 1.0): "
if not defined IN_AT ( set "BATTACK=0.55" & goto atOK )
call :ValidDecimal "!IN_AT!"
if "!ERR!"=="1" ( echo   ^>^> Invalid number. Use e.g. 0.55 & goto askAT )
set "BATTACK=!IN_AT!"
:atOK
:askRG
set "IN_RG="
set /p "IN_RG=Boss HealthRegen mult   (0.01-0.59, e.g. 0.5 = half regen, Enter=default 1.0): "
if not defined IN_RG ( set "BREGEN=0.5" & goto rgOK )
call :ValidDecimal "!IN_RG!"
if "!ERR!"=="1" ( echo   ^>^> Invalid number. Use e.g. 0.5 & goto askRG )
call :LeqHalf "!IN_RG!"
if "!ERR!"=="1" (
    echo   ^>^> Out of range. Must be 0.01-0.59 ^(kept below engine threshold^).
    goto askRG
)
set "BREGEN=!IN_RG!"
:rgOK
echo  -^> Boss-Mod ENABLED  maxhp=!BMAXHP!  attack=!BATTACK!  regen=!BREGEN!
:bossOK
if "!ENABLEBOSS!"=="false" echo  -^> Boss-Mod DISABLED (boss stays vanilla)
echo.

REM ---------------------------------------------------------------------------
REM  4) BOT MOVE-SPEED BUFF  (enable_bot_speed_buff)
REM     No  -> false : bots use native move speed
REM     Yes -> true  : ALL bots get a fixed ~1.49x move-speed boost (applied as a
REM            GE_Buff_Dragon_MoveSpeed instance; the real dragon mini-boss stays
REM            UNTOUCHED; composes fairly with combat-slows). Factor is NOT
REM            tunable - on/off only.
REM ---------------------------------------------------------------------------
set "ENABLESPEED=false"
:askSpeed
set "SPEEDCHOICE="
set /p "SPEEDCHOICE=Bot move-speed boost (fixed ~1.49x)?  [1] ENABLE  [2] DISABLE  : "
if "!SPEEDCHOICE!"=="1" ( set "ENABLESPEED=true"  & goto speedSet )
if "!SPEEDCHOICE!"=="2" ( set "ENABLESPEED=false" & goto speedSet )
echo   ^>^> Invalid choice. Enter 1 or 2.
goto askSpeed
:speedSet
if "!ENABLESPEED!"=="true" ( echo  -^> Bot speed boost ENABLED ^(~1.49x^) ) else ( echo  -^> Bot speed boost DISABLED ^(native^) )
echo.

REM ---------------------------------------------------------------------------
REM  WRITE server.json   (periodic log interval fixed at 60.0)
REM ---------------------------------------------------------------------------
(
echo {
echo     "enable_buff_patch":              !ENABLEBUFF!,
echo     "enemy_buff_multiplier":          !ENEMYMULT!,
echo     "friendly_buff_multiplier":       !FRIENDLYMULT!,
echo     "enable_bot_speed_buff":          !ENABLESPEED!,
echo     "blue_team_difficulty":           "!BLUEDIFF!",
echo     "red_team_difficulty":            "!REDDIFF!",
echo     "enable_boss_mod":                !ENABLEBOSS!,
echo     "boss_regen_mult":                !BREGEN!,
echo     "boss_maxhp_mult":                !BMAXHP!,
echo     "boss_attack_mult":               !BATTACK!,
echo     "boss_stat_epsilon":              !BEPS!,
echo     "boss_periodic_log_interval_sec": 60.0
echo }
) > "%SCONFIG%"

echo ============================================================
echo  server.json written:
type "%SCONFIG%"
echo.
echo ============================================================
echo.

if not exist "%~dp0%SERVEREXE%" (
    echo WARNING: %SERVEREXE% not found in this folder.
    echo Place this .bat next to the server executable.
    echo.
    pause
    exit /b 1
)

echo Launching server...
start "" "%~dp0%SERVEREXE%" -epicportal -log
echo Done.
timeout /t 3 >nul
endlocal
exit /b 0

REM ===========================================================================
REM  SUBROUTINES
REM ===========================================================================
:ValidDecimal
REM  %~1 = candidate ; ERR=0 if positive integer or decimal (dot), else ERR=1
set "_v=%~1"
echo(%_v%| findstr /r /c:"^[0-9][0-9]*$" /c:"^[0-9][0-9]*\.[0-9][0-9]*$" >nul
if errorlevel 1 ( set "ERR=1" ) else ( set "ERR=0" )
goto :eof

:LeqHalf
REM  %~1 = candidate ; ERR=0 only if value is within 0.01 .. 0.59 inclusive.
REM  Enforces the boss_regen_mult rule (must stay below the Fang engine
REM  threshold: 50 * mult < 30  ->  mult < 0.6). Pattern-based, exact.
REM  Accepts: 0.01-0.09 , 0.1-0.5 , 0.10-0.59 . Rejects 0, 0.0, >=0.6, 1+, etc.
set "_v=%~1"
echo(%_v%| findstr /r /c:"^0\.0[1-9]$" /c:"^0\.[1-5]$" /c:"^0\.[1-5][0-9]$" >nul
if errorlevel 1 ( set "ERR=1" ) else ( set "ERR=0" )
goto :eof
