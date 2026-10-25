# Origin of `Server/`

| File / folder | Origin |
|---|---|
| `dllmain.cpp` | **Mixed.** Starts from ProjectLegacy `Server/dllmain.cpp` (commit `52a3e06`, AGPL-3.0). About 6 % of the current non-trivial lines are unchanged from it; the rest is Project Monolith. |
| `dllmain.h`, `framework.h`, `pch.h`, `pch.cpp`, `Server.vcxproj*` | ProjectLegacy / Visual Studio project template, adjusted |
| `json/`, `jsoncpp.cpp` | JsonCpp, third party (MIT / Public Domain), unchanged |
| `MinHook/` | MinHook, third party (BSD 2-Clause), unchanged; only the `.lib` that is actually linked is kept |
| `SDKv45/`, `SDKv45.hpp`, `PropertyFixup.hpp`, `NameCollisions.inl`, `UnrealContainers.h` | **Not in the repository.** Generated headers (Dumper-7), fetched by `fetch_sdk.bat` |

## What in `dllmain.cpp` comes from ProjectLegacy

- Hook setup with MinHook (`Hooking::InitHooking`), `ProcessEvent` hook, game-thread queue.
- Listen-server start (`Networking::Listen`) and the replication loop
  (`Networking::ServerReplicateActors*`, `EChannelType`, `EConnectionState`). The loop mirrors the
  structure and naming of Unreal Engine 4's `UNetDriver::ServerReplicateActors_*` functions in a
  strongly simplified form. Project Monolith shortened it (removed v34 paths) and fixed a memory
  leak; it did not write it.
- Login and post-login hooks (`LoginHook`, `GameModeMOBAPostLogin`, `ApproveLoginHook`), basic
  ability and gameplay-cue glue.
- 45 of the 47 entries in `namespace PLOffsets`.

## What Project Monolith added

- The bot macro brain (F1-F9, F4 commander emulation: lanes, objectives, bosses, recall,
  positioning), shadow-bot decks, bot spawning and difficulty.
- Boss stat tuning, deck filter, hero/skin/role options, server configuration (`server.json`).
- Crash guards (SEH wrappers) and diagnostics.
- Further engine addresses found by our own reverse engineering for interoperability:
  `AIBOT_UPDATE_NEARBY_ALLY`, `UWORLD_DESTROY_ACTOR` and 23 addresses used directly in the code.

The published `dllmain.cpp` contains no source comments; they were removed for the release
(code unchanged, verified token by token).
