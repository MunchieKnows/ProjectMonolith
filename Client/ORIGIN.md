# Origin of `Client/`

| File / folder | Origin |
|---|---|
| `dllmain.cpp` | **Mixed.** Starts from ProjectLegacy `Client/dllmain.cpp` (commit `52a3e06`, AGPL-3.0). About 41 % of the current non-trivial lines are unchanged from it. |
| `framework.h`, `pch.h`, `pch.cpp`, `Client.vcxproj*` | ProjectLegacy / Visual Studio project template |
| `json/`, `jsoncpp.cpp` | JsonCpp, third party (MIT / Public Domain), unchanged |
| `MinHook/` | MinHook, third party (BSD 2-Clause), unchanged; only the linked `.lib` is kept |
| `SDKv45/`, `SDKv45.hpp`, `PropertyFixup.hpp`, `NameCollisions.inl`, `UnrealContainers.h` | **Not in the repository.** Generated headers (Dumper-7), fetched by `fetch_sdk.bat` |

## From ProjectLegacy

Hook setup, `ProcessEvent` hook, UI-state and main-menu hooks, the stub that replaces the
(no longer existing) online profile initialisation, connecting to the host via `open <ip>`, and
all 8 entries in `namespace PLOffsets`.

## Added by Project Monolith

Role/skin/deck options (`config.json`, `deck.json`), card ability fixes on the client side,
SEH crash guards, diagnostics (F5/F7/F8). Two unused stubs from the base project
(`IsPakAllowedHook`, `TargetingValidHook`, never installed) were removed.
