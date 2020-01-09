# BadCoderz
### Find unoptimized addons and KILL the devs who made them



[Workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=1955436281)

[English video](https://www.youtube.com/watch?v=TVT5k3CHPQQ)

[Video in french for my fellows baguettes](https://youtu.be/nNvq3CKccic) (Oudated since the video doesn't show GMA path support)


**_How it it different from a profiler ?_**

A profiler doesn't tell you if code is shit so you don't know if there is a good reason for a code to be "slow", here BadCoderz highlights you the shit code of your server and explains you why it's shit.

![](https://i.imgur.com/gyO07pu.png) Finds un-optimized code and bottlenecks

![](https://i.imgur.com/gyO07pu.png) Supports code ran in hooks, GM functions, Entities and Panels

![](https://i.imgur.com/gyO07pu.png) Exports reports in TXT format to work with your team

![](https://i.imgur.com/gyO07pu.png) Detailed call stack history

![](https://i.imgur.com/gyO07pu.png) **Even shows the absolute path with GMAs** (Gmod doesn't natively support it)

![](https://i.imgur.com/gyO07pu.png) Code preview

![](https://i.imgur.com/gyO07pu.png) Ingame advices and hook/function documentation (Right click on it opens the wiki page)

![](https://i.imgur.com/gyO07pu.png) Compatibility with [GLib](https://github.com/notcake/glib) allowing you to decompile functions generated with CompileString or RunString (you need to download GLib if you want to use it)

1.  Download BadCoderz
2.  Identify the addons coded like shit
3.  Do something about it :
4.  Remove the addon
5.  Fix it
6.  Send the report to the dev so he can fix it
7.  (Optional) Smash the dev's head on the ground
8.  Keep your players because your server now has much better performances and less shitty code

BadCoderz isn't exactly a profiler, a profiler is only measuring how much time the CPU spend on each function, without telling you if the CPU has a good reason to do so.

A profiler can flag a function as "heavy/slow" without knowing if it's actually optimized.

BadCoderz uses a database of known mistakes (function and contexts) to find the unoptimized code in your addons/gamemode.

_So, how does it work exactly ?_

Simply open BadCoderz using the `badcoderz` command.

Then you can start scanning for unoptimized code on the Client or on the Server (or even both at the same time)

https://www.youtube.com/embed/CxLTw-b6ObY

In this video i downloaded 7 hud from the workshop, and as expected the code was total shit.

The BF4 hud, for example re-reads the textures from the disk on each frame.

If you put your mouse over the Function name it tells you what the function does (fetched from the wiki on the fly) and explains you why it's wrong to use it in this context.

Right clicking on the function name opens the wiki page. (Same with the hook).

![](https://i.imgur.com/iK4wZCE.png)

Bellow we can see the places (in the code) where the function was called.

It also shows you the call stack.

Hover the one of the call stack line and it will show you a preview of the code

![](https://i.imgur.com/VcTb2ZW.png)

_Wait, do i need to understand Lua to use it ?_

Not at all, but it's obviously much better to know how Lua and gmod works, but with common sense you can easily find which addon is coded like shit.

[You can also export the Clientside/Serverside report to .txt and share it with your team/the dev of the addon.](https://pastebin.com/TGd1HNJ8)

![](https://i.imgur.com/OvCscUW.png)

Obviously, there might be some "false positive" detections, but with common sense and with the stack call history, you should be fine.

_I got a short memory, can you explain me quickly the difference between a profiler and this ?_

A profiler find CPU intensive functions without knowing if they are actually coded like shit, this addon find all the function coded like shit.

Then you can actually blame the dev who coded it for making shit code.

Most of the people who use fprofiler actually don't know what they're doing.

Optimized doesn't mean being fast, optimized means being efficient.

_I still got a short memory, who can use this addon ?_

Here is a non-exhaustive list :

*   Server owner : His server is lagging, his players are leaving or complaining, he want to fire his server dev, but since he is his brother-in-law he need evidences.

*   Server owner 2 : His server is lagging and he want to find what addon is coded like ass.

*   Junior Lua dev releasing his first addon : He want to be sure he didn't do anything that would destroy the server performances.

_Anything else i should know ?_

Keep in mind this is a technical tool, it's meant to be used with a brain and at least one eye.


If you want your staff to help you, export a report and send it to them.

The addon is using debug functions, so it's not compatible with SecureGmod

Thanks :

[RE Lexi](https://steamcommunity.com/profiles/76561198090218596) for the banner

Threebow for [TDLib](https://github.com/Threebow/tdlib)

[Metastruct](https://github.com/Metastruct) for the [html lua editor](https://github.com/Metastruct/lua_editor)
