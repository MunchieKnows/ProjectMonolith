@echo off
setlocal EnableDelayedExpansion
title Project Monolith - Deck Builder
cd /d "%~dp0"

REM ===========================================================================
REM  Project Monolith Deck Builder
REM  - Writes deck.json (read by the Client DLL -> ?deck=... sent to the server)
REM  - SEPARATE from config.json/client_launcher.bat -> no collision, no clobber.
REM  - Optional: if deck.json is missing / empty  =>  server shows ALL 120 cards.
REM
REM  PLACEMENT: put this .bat next to OrionClient-Win64-Shipping.exe
REM             (same folder as client_launcher.bat / config.json).
REM
REM  IMPORTANT: The numbers 1-120 MUST match the server table DeckFilter::CARD_TABLE
REM             (Server/dllmain.cpp) and carddump.txt. When the card list changes,
REM             keep both places in sync.
REM ===========================================================================

set "DECKJSON=%~dp0deck.json"
set "MAXCARDS=75"

REM --- Card display names, canonical order = carddump.txt = server table ---
REM Chaos (Red) 1-24
set "CARD[1]=Amplification Engineer"
set "CARD[2]=Blitzrush"
set "CARD[3]=Compensator Rig"
set "CARD[4]=Deathcrawler"
set "CARD[5]=Demolitionist"
set "CARD[6]=Dune Winds"
set "CARD[7]=Glycerin Dawn"
set "CARD[8]=Heavy Hitter"
set "CARD[9]=Hellfire Engine"
set "CARD[10]=Living Guardian"
set "CARD[11]=Nitroboost"
set "CARD[12]=Nukeblood Mutant"
set "CARD[13]=Outlander Scout"
set "CARD[14]=Overclocked Droid"
set "CARD[15]=Pressure Hunter"
set "CARD[16]=Profiteer"
set "CARD[17]=Reactor Beast"
set "CARD[18]=Red Zone"
set "CARD[19]=Riot Sapper"
set "CARD[20]=Sand Speeder"
set "CARD[21]=Shatter Golem"
set "CARD[22]=Thorned Yomi"
set "CARD[23]=Tireless Reaper"
set "CARD[24]=Unstable Cyborg"
REM Death (Black) 25-48
set "CARD[25]=Awaken the Emeric"
set "CARD[26]=Cull the Weak"
set "CARD[27]=Devastation"
set "CARD[28]=Finder of Playthings"
set "CARD[29]=Grinning Spectre"
set "CARD[30]=Guard Piercer"
set "CARD[31]=Invader Mage"
set "CARD[32]=Lord Volstok"
set "CARD[33]=Nameless Curse"
set "CARD[34]=Numbing Rogue"
set "CARD[35]=Pestilence"
set "CARD[36]=Plague Lord Mallenk"
set "CARD[37]=Possessed Spry-Kin"
set "CARD[38]=Shadow Dancer"
set "CARD[39]=Sorvukk Initiate"
set "CARD[40]=Swamp Stalker"
set "CARD[41]=Taskmaster"
set "CARD[42]=Tower Strider"
set "CARD[43]=Vampiric Blade"
set "CARD[44]=Veil Stepper"
set "CARD[45]=Warlock's Burden"
set "CARD[46]=Wicked Riposte"
set "CARD[47]=Withering Shadow"
set "CARD[48]=Woundseeker"
REM Growth (Green) 49-72
set "CARD[49]=Apex Predator"
set "CARD[50]=Awakened Ancient"
set "CARD[51]=Battle Shepherd"
set "CARD[52]=Chanting Shaman"
set "CARD[53]=Coinmaster"
set "CARD[54]=Coursing Zephyr"
set "CARD[55]=Exoskeleton"
set "CARD[56]=Flame of Zechin"
set "CARD[57]=Greenspring"
set "CARD[58]=Growth Totem"
set "CARD[59]=Highwayman"
set "CARD[60]=Mallenk Gnasher"
set "CARD[61]=One of the Tribe"
set "CARD[62]=Pack Leader"
set "CARD[63]=Pensive Shaman"
set "CARD[64]=Spry-Kin"
set "CARD[65]=Swift Hunter"
set "CARD[66]=The Mother Tree"
set "CARD[67]=Thunder Cleaver"
set "CARD[68]=Trapper"
set "CARD[69]=Tyrant"
set "CARD[70]=Unbroken Spirit"
set "CARD[71]=Vengeful Mire"
set "CARD[72]=Vital Waters"
REM Knowledge (Blue) 73-96
set "CARD[73]=Accelerator"
set "CARD[74]=Advanced Evolution"
set "CARD[75]=Arcane Dancer"
set "CARD[76]=Astral Leap"
set "CARD[77]=Atomic Soldier"
set "CARD[78]=Black Ice Routine"
set "CARD[79]=Corrosive Walker"
set "CARD[80]=Cryo Agent"
set "CARD[81]=Echelon Soldier"
set "CARD[82]=Echodrive"
set "CARD[83]=Font of Experience"
set "CARD[84]=Generator"
set "CARD[85]=Mana-Flow Acolyte"
set "CARD[86]=O.P.D. Militia"
set "CARD[87]=Power Tap"
set "CARD[88]=Rejuvenator"
set "CARD[89]=Shipyard Scavenger"
set "CARD[90]=Sleeper Agent"
set "CARD[91]=Soldier of Fortune"
set "CARD[92]=Stasis Rune"
set "CARD[93]=Static Trap"
set "CARD[94]=Supply Sergeant"
set "CARD[95]=Thaumaturge"
set "CARD[96]=Wetware Virus"
REM Order (White) 97-120
set "CARD[97]=Armored Footman"
set "CARD[98]=Brilliant Fortification"
set "CARD[99]=Crippling Glare"
set "CARD[100]=Domain of Stillness"
set "CARD[101]=Flag Bearer"
set "CARD[102]=Form of Grubbish"
set "CARD[103]=Gates of Salvation"
set "CARD[104]=Godmother Vigilant"
set "CARD[105]=Knight of Ashur"
set "CARD[106]=Lamp Lighter"
set "CARD[107]=Lightstep Vanguard"
set "CARD[108]=Mallenk's Grace"
set "CARD[109]=Mallenk's Prayer"
set "CARD[110]=Mallenk's Tribute"
set "CARD[111]=March of the Mallenk"
set "CARD[112]=Poised Aggressor"
set "CARD[113]=Protective Sentry"
set "CARD[114]=Radiant Healer"
set "CARD[115]=Sacred Alchemy"
set "CARD[116]=Song of the Sentinel"
set "CARD[117]=Stagnant Dominion"
set "CARD[118]=Vanguard Captain"
set "CARD[119]=Yomi Guardian"
set "CARD[120]=Yomi Spectre"

echo ============================================================
echo            PROJECT MONOLITH  -  DECK BUILDER
echo ============================================================
echo.
echo  Writes deck.json (which cards are shown to you in the shop).
echo  Maximum %MAXCARDS% cards. No selection / empty = ALL 120 cards.
echo.

:askMode
set "MODE="
set /p "MODE=Cards  [1] ALL 120  [2] build your own deck  : "
if "!MODE!"=="1" goto allCards
if "!MODE!"=="2" goto custom
echo   ^>^> Invalid. Please enter 1 or 2.
goto askMode

:allCards
> "%DECKJSON%" echo {"deck": ""}
echo.
echo  -^> ALL 120 cards enabled (no filter).
goto done

:custom
echo.
echo ===================  CHAOS (Red)  1-24  ===================
for /l %%n in (1,1,24) do (
    set "PAD=   %%n"
    set "PAD=!PAD:~-3!"
    echo   !PAD!^) !CARD[%%n]!
)
echo ===================  DEATH (Black)  25-48  ================
for /l %%n in (25,1,48) do (
    set "PAD=   %%n"
    set "PAD=!PAD:~-3!"
    echo   !PAD!^) !CARD[%%n]!
)
echo ===================  GROWTH (Green)  49-72  ===============
for /l %%n in (49,1,72) do (
    set "PAD=   %%n"
    set "PAD=!PAD:~-3!"
    echo   !PAD!^) !CARD[%%n]!
)
echo ===================  KNOWLEDGE (Blue)  73-96  =============
for /l %%n in (73,1,96) do (
    set "PAD=   %%n"
    set "PAD=!PAD:~-3!"
    echo   !PAD!^) !CARD[%%n]!
)
echo ===================  ORDER (White)  97-120  ==============
for /l %%n in (97,1,120) do (
    set "PAD=   %%n"
    set "PAD=!PAD:~-3!"
    echo   !PAD!^) !CARD[%%n]!
)
echo ============================================================
echo  Add a card by NUMBER (1-120), or a whole AFFINITY at once
echo  by letter:  C=Chaos  D=Death  G=Growth  K=Knowledge  O=Order
echo  0 = done.   Max %MAXCARDS% cards.
echo ============================================================

set "DECKLIST="
set "COUNT=0"

:addLoop
set "PICK="
set /p "PICK=Add card # (1-120), affinity (C/D/G/K/O), or 0 = done: "
if not defined PICK goto addLoop
if "!PICK!"=="0" goto finishCustom

REM --- Affinity bulk-add: a whole affinity (24 cards) at once ---
set "AFFL="
if /i "!PICK!"=="C" set "AFFL=C"
if /i "!PICK!"=="chaos" set "AFFL=C"
if /i "!PICK!"=="D" set "AFFL=D"
if /i "!PICK!"=="death" set "AFFL=D"
if /i "!PICK!"=="G" set "AFFL=G"
if /i "!PICK!"=="growth" set "AFFL=G"
if /i "!PICK!"=="K" set "AFFL=K"
if /i "!PICK!"=="knowledge" set "AFFL=K"
if /i "!PICK!"=="O" set "AFFL=O"
if /i "!PICK!"=="order" set "AFFL=O"
if defined AFFL (
    call :addAffinity !AFFL!
    if !COUNT! GEQ %MAXCARDS% goto finishCustom
    goto addLoop
)

REM --- Typo guard: only 1-120 (otherwise CARD[PICK] is empty) ---
set "NAME=!CARD[%PICK%]!"
if "!NAME!"=="" (
    echo   ^>^> Invalid "!PICK!". Enter 1-120, an affinity ^(C/D/G/K/O^), or 0 = done.
    goto addLoop
)
REM --- Duplicate guard ---
if defined SEL[%PICK%] (
    echo   ^>^> "!NAME!" is already in the deck.
    goto addLoop
)
set "SEL[%PICK%]=1"
if "!DECKLIST!"=="" ( set "DECKLIST=!PICK!" ) else ( set "DECKLIST=!DECKLIST!,!PICK!" )
set /a COUNT+=1
echo      + [!PICK!] !NAME!     ^(!COUNT!/%MAXCARDS%^)
if !COUNT! GEQ %MAXCARDS% (
    echo   ^>^> Maximum of %MAXCARDS% cards reached.
    goto finishCustom
)
goto addLoop

:finishCustom
if "!DECKLIST!"=="" (
    echo.
    echo  No card selected -^> default: ALL 120 cards.
    > "%DECKJSON%" echo {"deck": ""}
    goto done
)
echo.
echo  Selected ^(!COUNT!^): !DECKLIST!
> "%DECKJSON%" echo {"deck": "!DECKLIST!"}

:done
echo.
echo ============================================================
echo  deck.json written:
type "%DECKJSON%"
echo.
echo ============================================================
echo  Note: deck.json must be next to OrionClient-Win64-Shipping.exe.
echo  Delete it or choose option [1] = all 120 cards again.
echo.
pause
endlocal
exit /b 0

REM ===========================================================================
REM  SUBROUTINES
REM ===========================================================================
:addAffinity
REM  %1 = affinity letter (C/D/G/K/O). Adds all 24 cards of that affinity,
REM  skipping already-selected ones, up to MAXCARDS.
set "AL=%~1"
if "%AL%"=="C" ( set "RS=1"  & set "RE=24"  & set "ANM=CHAOS" )
if "%AL%"=="D" ( set "RS=25" & set "RE=48"  & set "ANM=DEATH" )
if "%AL%"=="G" ( set "RS=49" & set "RE=72"  & set "ANM=GROWTH" )
if "%AL%"=="K" ( set "RS=73" & set "RE=96"  & set "ANM=KNOWLEDGE" )
if "%AL%"=="O" ( set "RS=97" & set "RE=120" & set "ANM=ORDER" )
set "BEFORE=!COUNT!"
for /l %%n in (%RS%,1,%RE%) do (
    if !COUNT! LSS %MAXCARDS% if not defined SEL[%%n] (
        set "SEL[%%n]=1"
        if "!DECKLIST!"=="" ( set "DECKLIST=%%n" ) else ( set "DECKLIST=!DECKLIST!,%%n" )
        set /a COUNT+=1
    )
)
set /a JUST=COUNT-BEFORE
echo      + %ANM% affinity: !JUST! card^(s^) added     ^(!COUNT!/%MAXCARDS%^)
if !COUNT! GEQ %MAXCARDS% echo   ^>^> Maximum of %MAXCARDS% cards reached.
goto :eof
