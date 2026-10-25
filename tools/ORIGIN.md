# Origin of `tools/`

| File | Origin |
|---|---|
| `fetch_sdk.ps1` (started via `fetch_sdk.bat` in the root) | Project Monolith |
| `build.ps1` (started via `build.bat` in the root) | Project Monolith |

`build.ps1` runs `fetch_sdk.ps1`, finds MSBuild with `vswhere` (Visual Studio 2022 or Build
Tools with the C++ workload), builds `ProjectMonolith.sln` (`v45` / `x64`) and checks that the
three DLLs exist in `x64\v45\`.

`fetch_sdk.ps1` downloads the archive of ProjectLegacy at commit
`52a3e0626f6207ff90ab51d94b597a31a56a38d1` from GitHub, extracts only the generated SDK headers
into `Server\` and `Client\`, and checks them against fixed SHA-256 checksums. If a checksum does
not match, it stops and tells you not to build.
