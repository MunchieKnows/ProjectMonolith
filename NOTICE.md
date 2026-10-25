# NOTICE

Project Monolith
Copyright (C) 2025-2026 Project Monolith contributors

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License version 3 as published by the Free Software Foundation
(see `LICENSE.txt`). It is distributed WITHOUT ANY WARRANTY.

## Based on ProjectLegacy

This project is a modified version of **ProjectLegacy** by SyST3MDeV:

- Repository: https://github.com/SyST3MDeV/ProjectLegacy
- Base commit: `52a3e0626f6207ff90ab51d94b597a31a56a38d1` (2024-11-08)
- License: GNU Affero General Public License v3 (`LICENSE.txt`, unchanged)

Project Monolith changed and extended the base substantially (AGPL-3.0 §5a). The changes are
listed per folder in the `ORIGIN.md` files, and in short below.

| Area | Status |
|---|---|
| `Server/dllmain.cpp` | Based on ProjectLegacy. Hook framework, listen-server setup, replication loop, login hooks and most `PLOffsets` come from ProjectLegacy. Bot AI, map/match flow, boss tuning, deck filter, crash guards and further reverse-engineered addresses were added by Project Monolith. About 94 % of the current non-trivial lines are new. |
| `Client/dllmain.cpp` | Based on ProjectLegacy. Deck/role/skin options, card ability fixes, crash guards and diagnostics added. Unused stubs removed. |
| `Injector/` | Rewritten by Project Monolith (DXGI proxy). ProjectLegacy used a different shim (`AVRT/`). |
| `tools/`, launchers (`*.bat`), documentation | Project Monolith. |

## Not included: generated SDK headers

The build needs C++ headers that describe the game's classes (`Server/SDKv45/`, `Client/SDKv45/`
and four companion files per side). They were generated with **Dumper-7**
(https://github.com/Encryqed/Dumper-7) from the game and are derived from it. They are **not part
of this repository**. `fetch_sdk.bat` downloads them from ProjectLegacy at the base commit above
and verifies them by checksum. `UnrealContainers.h` within that set is from
https://github.com/Fischsalat/UnrealContainers.

## Third-party components shipped in this repository

| Component | Location | License |
|---|---|---|
| MinHook (Tsuda Kageyu), incl. Hacker Disassembler Engine (Vyacheslav Patkov) | `Server/MinHook/`, `Client/MinHook/` (header + one prebuilt `.lib`) | BSD 2-Clause |
| JsonCpp (Baptiste Lepilleur and The JsonCpp Authors) | `Server/json/`, `Server/jsoncpp.cpp`, `Client/json/`, `Client/jsoncpp.cpp` | MIT / Public Domain |

The full license texts are in `THIRD_PARTY_LICENSES.md`.

## Trademarks

Project Monolith is an independent, non-commercial community project. It is **not affiliated
with, endorsed, sponsored or approved by Epic Games, Inc.** "Paragon", "Unreal" and "Unreal
Engine" are trademarks or registered trademarks of Epic Games, Inc. They are used here only to
describe compatibility. This repository contains no game files, game assets or game binaries.

Project Monolith is not commercial: the authors accept no donations or payments.
