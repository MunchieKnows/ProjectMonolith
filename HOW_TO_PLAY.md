# How to Play

You need your own, legitimately obtained copy of the game client (v45). This project does not
provide it and does not link to it.

## 1. Build (once)

1. **Download the source code:** on the GitHub page of this project click the green
   **Code** button → **Download ZIP**. **Extract** the ZIP into a folder of your choice
   (right-click → *Extract All*), for example `C:\ProjectMonolith`. Do not run anything from
   inside the ZIP. Developers can use `git clone` instead.
2. Install **Visual Studio 2022** or the free **Build Tools for Visual Studio 2022**
   (https://visualstudio.microsoft.com/downloads/) with the workload
   **"Desktop development with C++"**. You only need to do this once.
3. In the extracted folder, double-click **`build.bat`**. It downloads the SDK headers (first
   time only), then builds everything. Wait until it says **BUILD SUCCEEDED**.
4. Afterwards the `x64\v45\` folder contains **`Server.dll`**, **`Client.dll`** and **`DXGI.dll`**.

If the build fails, scroll up in the window to the first error message and post it in the bug
channel. (Alternative for developers: run `fetch_sdk.bat`, then build `ProjectMonolith.sln` in
Visual Studio with `v45` / `x64`.)

## 2. Install (once)

1. Go to the game's binary folder: `OrionGame\Binaries\Win64\` (the folder that contains
   `OrionClient-Win64-Shipping.exe`).
2. Copy these files into that folder:
   - the three DLLs: `Server.dll`, `Client.dll`, `DXGI.dll`
   - the three scripts: `server_launcher.bat`, `client_launcher.bat`, `deckbuilder.bat`
3. Make a copy of `OrionClient-Win64-Shipping.exe` in the same folder and rename the copy to
   **`OrionClient-Win64-Shipping-Server.exe`**. The loader uses the file name to decide whether
   it starts the server or the client.

If everything is right, the `Win64` folder now contains these new files:

```text
OrionClient-Win64-Shipping-Server.exe
Server.dll
Client.dll
DXGI.dll
server_launcher.bat
client_launcher.bat
deckbuilder.bat
```

## Playing solo against bots

There is no single-player mode: even alone you **host a server and join it yourself**,
both on the same PC.

1. Start **`server_launcher.bat`** and choose the bot settings. Wait for the update error
   message, press **F8**, and wait until the log shows
   `IpNetDriver listening on port 7777` (details in "Host a game" below).
2. Start **`client_launcher.bat`** and choose **`localhost`** as the server.
   The game starts and joins your own server.
3. Once you are in, press **F1**. This fills all other slots with bots. **Wait about 15 seconds**
   until the server log shows

   `[HOST] 10 Sekunden vergangen: Smarte Lanes an ... Bots automatisch zugewiesen!`

   (the bots now have their lanes). Only then press **F9** to start the match.

## 3. Host a game

This is also the first part of playing alone against bots (see above).

1. **Start `server_launcher.bat`.** It walks you through the settings:
   - bot difficulty per team (1-6),
   - optional bot stat multipliers (enemy and friendly bots),
   - optional boss stats for Orb Prime and Fangtooth (max HP, attack, health regen),
   - optional bot move-speed boost.

   It saves the settings to `server.json` and starts the server automatically.
2. **Wait until the update error message appears** in the game window / log, then **press F8**.
3. **Wait a few seconds** while the server code is loaded. As soon as the log shows

   ```text
   LogNet: GameNetDriver IpNetDriver_0 IpNetDriver listening on port 7777
   ```

   other players can join with your IP address (local network, public IP or a VPN such as
   Radmin VPN).

   You can see players joining in the server's log window. At the moment the log shows the
   **hero** a player picked, not the player name (player names will be added in a later update).
   Heroes appear under their internal names, for example `Price` is Murdock:

   ```text
   LogNet: Server connection received: ActorChannelFailure
   LogOrion: [UOrionMcpItemDefinition::BroadcastOnLoadComplete] HeroData_Price fully loaded
   LogOrion: [UOrionMcpItemDefinition::BroadcastOnLoadComplete] Skin_Price_Buy_T2_polar_Strike fully loaded
   ```

4. **When all players have joined, press F1.** This fills all free slots with bots.
   **Wait about 15 seconds** until the server log shows

   `[HOST] 10 Sekunden vergangen: Smarte Lanes an ... Bots automatisch zugewiesen!`

   (the bots now have their lanes).
5. **Press F9 to start the match.** Loading the assets and the HUD takes a few seconds.
   If you want to play players vs. players without bots, skip step 4 and press F9 directly.

**Important:**
- Press F1 and F9 only **after all players have joined**, and press F9 only after the
  "Smarte Lanes ... zugewiesen" message (the server does not check this for you).
- About 50 seconds into the match the server loads the complete bot code. The server has high
  latency for a few seconds during this. That is normal.
- Players connecting over the internet need UDP port **7777** to be reachable on the host
  (port forwarding or a VPN).
- The server has no login: anyone who knows your IP and port can join.

## 4. Join a game

1. **Start `client_launcher.bat`.**
2. **Set your in-game username.** It is saved and can be changed at any time on the next start.
3. **Enter the server address:** `localhost` if the server runs on the same PC, otherwise the
   host's local IP, public IP or VPN IP (port 7777 is added automatically).
4. **Pick your hero** by number, then the **skin**, the **role** and the **team**.
5. The game starts automatically and joins the server.

## 5. Cards and decks

All ~120 cards are unlocked from the start and available in the match. If you want your own
deck, run `deckbuilder.bat` **before the match starts**. It saves `deck.json`, which the client
sends to the server. Without `deck.json` you get all cards.
