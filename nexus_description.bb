[center][img]https://images2.imgbox.com/c6/71/dZxn8Tgv_o.png[/img][/center]
[center][img]https://images2.imgbox.com/dd/0f/7aJF2WJ3_o.png[/img][/center]Aether & Volitio's Item Shipment Framework (ISF for short) allows mod authors to directly ship their modded items into the camp chest or player inventories. It is intended as an alternative to the popular Tutorial Chest item shipment approach which many authors have used.

It should serve as a way for users to more conveniently interact with these mods in a more reliable and less confusing way. Additionally, ISF takes the burden off mod authors by handling the complexities of item delivery, allowing checks such as whether the item has already been given to the player, or if they already possess it in their party, camp chests, etc.

[center][img]https://images2.imgbox.com/5f/d6/A4bkY2iZ_o.png[/img][/center]1. In the [url=https://github.com/LaughingLeader/BG3ModManager]Baldur's Gate 3 Mod Manager[/url], enable the Script Extender by clicking on the 'Tools' tab at the top left of the program, and then by selecting 'Download and Extract the Script Extender'. Alternatively,[size=2][size=2] press CTRL+SHIFT+ALT+T while BG3MM's window is focused;[/size][/size]

2. [url=https://www.nexusmods.com/baldursgate3/mods/7676]Volition Cabinet[/url]﻿ is a requirement for this mod, so make sure it is installed. Its load order should not matter;

3. Import this mod's .zip file into the Mod Manager, and drag the mod from the right panel of the Mod Manager, to the left panel;

4. Drag this mod to the bottom of your load order, as it needs to be placed below any mods that rely on this framework;

5. Save and export your load order. ISF will now automatically pick up any mods that use the framework.

[b][size=4]Configuration (optional)
[/size][/b]
When you load a save with the mod for the first time, it will automatically create an[font=Courier New] av_item_shipment_framework_config[/font][size=2][size=2][font=Courier New].json[/font] file with sane default options, but if you want to change anything, here are the instructions:

[spoiler]

You can easily navigate to the JSON user configuration file on Windows by pressing WIN+R and entering
[quote][size=2][size=2][code]explorer %LocalAppData%\Larian Studios\Baldur's Gate 3\Script Extender\AVItemShipmentFramework
[/code][/size][/size][/quote][/size][/size][size=2][size=2]
[size=2][size=2]Open the JSON file with any text editor, even regular Notepad will work. Here's what each option inside does
(order doesn't matter):[/size][/size][size=2][size=2]
[/size][/size][/size][/size][size=2][size=2]
[font=Courier New]"GENERAL"[/font]:
    [font=Courier New]    "enabled"[/font]: Toggle this to [font=Courier New]true[/font] to activate the mod, or set it to false if you wish to deactivate it without removing it. Enabled by default.

[font=Courier New]"FEATURES"[/font]:
    [font=Courier New]    "notifications"[/font]: A section for notification settings.
        [font=Courier New]        "enabled"[/font]: Set to [font=Courier New]true[/font] to enable in-game notifications when you receive items. Enabled by default.
        [font=Courier New]        "ping_chest"[/font]: If set to [font=Courier New]true[/font], camp chests will be pinged when receiving items. Enabled by default.
        [font=Courier New]        "vfx"[/font]: If set to [font=Courier New]true[/font][size=2][size=2], a VFX will be emitted from your character when camp chests receive items. Enabled by default.[/size][/size]
    [font=Courier New]    "spawning"[/font]:
        [font=Courier New]        "allow_during_tutorial"[/font]: Set to [font=Courier New]false[/font] to disable spawning new items or entities during tutorial sections. Disabled by default.

[font=Courier New]"DEBUG"[/font]:
    [font=Courier New]    "level"[/font]: Adjust the verbosity of debug logs. A setting of 0 disables debug logs, 1 provides minimal logging, and 2 enables detailed, verbose logs. 0 by default.
[size=2][size=2][size=2][size=2]
[size=2][size=2][size=2][size=2][size=2][size=2]After saving your changes while the game is running, load a save to reflect your changes.[/size][/size][/size][/size][/size][/size][/size][/size][/size]

[/spoiler]

[center][img]https://images2.imgbox.com/d6/78/Q3L97Io0_o.png[/img][/center]The Item Shipment Framework is a very easy-to-use and modular tool with sane defaults that allows mod authors to more effectively give items to their users.
In this section, you'll learn about the ISF, what it can do, and how easy it is to integrate your mods into the framework.
Whether you're developing a new mod or updating one with an existing userbase, integrating it with ISF follows the same process.

[size=4][b]GENERAL INFORMATION[/b][/size]

Placeholder

[size=4][b]HOW TO INTEGRATE YOUR MODS[/b][/size]

Placeholder

[b]EXAMPLE MODS WHICH USE THE FRAMEWORK[/b][/size]

Placeholder

TODO: Mod authors should not add ISF as a dependency in the meta.lsx file. It needs to be loaded last and doing so could prevent that. Only add it as a requirement on your mod's Nexus page.
TODO: 'migration' for existing mods can be done because of the available checks that can be performed by ISF, so players won't have to receive duplicates (unless they never got it from tutorial chest, for example)

[/size][/size][size=5][b]Compatibility[/b][/size][size=2]
TODO: investigate uninstall-friendliness

[center][img]https://images2.imgbox.com/59/78/tZCsT1l5_o.png[/img][/center][url=https://www.nexusmods.com/users/13669385]Aetherpoint[/url] - RootTemplates, item creation, graphic design, English localization, and framework documentation.

[url=https://www.nexusmods.com/users/9505990]Volitio[/url] - Script Extender portions of this mod. It could not have been made without him.


[/size][size=4][b]Special Thanks[/b][/size][size=2]
[/size]Volitio: [quote]﻿[i]If I can see further, it is by standing on the shoulders of giants. [/i]Creating this framework would've been an  herculean task without the foundational work of  [url=https://www.nexusmods.com/baldursgate3/users/21094599]Focus[/url]﻿ and [url=https://www.nexusmods.com/baldursgate3/users/244952?tab=user+files]Nells[/url]﻿/[url=https://github.com/BG3-Community-Library-Team/]Community Library team[/url]﻿ from which I learned from and continue to build upon. I will be forever grateful for their open-source contributions to the Baldur's Gate 3 modding scene.[/quote]

[center][img]https://images2.imgbox.com/c4/b5/wfgcEnOw_o.png[/img][/center]If you'd like to directly support either of us, you may do so by following these links:

[b][size=3][url=https://ko-fi.com/aetherpoint]Aetherpoint's Ko-fi[/url][/size][/b]

[b][size=3][url=https://ko-fi.com/volitio]Volitio's Ko-fi[/url][/size][/b]
