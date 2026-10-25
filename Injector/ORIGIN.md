# Origin of `Injector/`

Written by Project Monolith. It replaces the loader `AVRT/` of ProjectLegacy, which hooked the
renderer initialisation and therefore needed engine addresses. This version needs none.

How it works: the build produces `DXGI.dll`. Placed next to the game executable, Windows loads it
instead of the system `dxgi.dll`. It forwards `CreateDXGIFactory`, `CreateDXGIFactory1` and
`CreateDXGIFactory2` to the real `System32\dxgi.dll` (`Exports.def`) and, after a short delay,
loads `Server.dll` (server executable) or `Client.dll` (client executable) into the same process.
It does not open, read or write other processes, installs no driver and changes no files.

| File | Origin |
|---|---|
| `dllmain.cpp`, `Exports.def` | Project Monolith |
| `framework.h`, `pch.h`, `pch.cpp`, `Injector.vcxproj*` | Visual Studio project template, adjusted |
