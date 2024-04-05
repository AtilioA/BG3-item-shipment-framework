[center][img]https://images2.imgbox.com/c6/71/dZxn8Tgv_o.png[/img][/center]
[center][img]https://images2.imgbox.com/dd/0f/7aJF2WJ3_o.png[/img][/center][b]The Item Shipment Framework (ISF for short) allows mod authors to directly ship vanilla or modded items into the camp chest or player inventories[/b]. It is an [b]alternative to the popular Tutorial Chest and Trader Inventory[/b] item shipment approaches. It should serve as a way for users to interact with these items more reliably and less confusingly.

When users first load into the game with this mod installed, all four potential camp chests will receive the Item Shipment Framework Mailbox. This mailbox is the main location where mod authors will send their items to users, however, authors can additionally choose to place items directly into the inventory of the host player of the game session.

Users will also find the Item Shipment Framework Utilities scroll case inside the mailbox, which houses various utility items that trigger commands for the framework. You can see a list of the Utility Items and how they function in the images section of this mod page.

[center][img]https://images2.imgbox.com/5f/d6/A4bkY2iZ_o.png[/img][/center][list]
[*]In the [url=https://github.com/LaughingLeader/BG3ModManager]Baldur's Gate 3 Mod Manager[/url], enable the Script Extender by clicking on the 'Tools' tab at the top left of the program and selecting 'Download and Extract the Script Extender'. Alternatively,[size=2][size=2] press CTRL+SHIFT+ALT+T while BG3MM's window is focused;[/size][/size]
[*][url=https://www.nexusmods.com/baldursgate3/mods/7676]Volition Cabinet[/url]﻿ is a requirement for this mod, so make sure it is installed. Its load order should not matter;
[*]Import this mod's .zip file into the Mod Manager, and drag the mod from the right panel of the Mod Manager to the left panel;
[*]Drag this mod to the bottom of your load order, as it needs to be placed below any mods that rely on this framework;
[*]Save and export your load order. The ISF will now automatically pick up any mods that use the framework.
[/list]When you load a save with the mod for the first time, the ISF will automatically create an [font=Courier New][color=#93c47d][b]av_item_shipment_framework_config.json[/b][/color][/font] file with sane default options into your Script Extender folder. If you, however, want to change any of its settings, here are instructions:[spoiler]You can easily navigate to the JSON user configuration file on Windows by pressing WIN+R and entering:
[quote][code]explorer %LocalAppData%\Larian Studios\Baldur's Gate 3\Script Extender\AVItemShipmentFramework[/code][/quote]Open the JSON file with any text editor, even regular Notepad will work. Here's what each option inside does
(order doesn't matter):

[font=Courier New]"GENERAL"[/font]:
    [font=Courier New]    "enabled"[/font]: Toggle this to [font=Courier New]true[/font] to activate the mod, or set it to false if you wish to deactivate it without removing it. Enabled by default.

[font=Courier New]"FEATURES"[/font]:
    [font=Courier New]    "notifications"[/font]: A section for notification settings.
        [font=Courier New]        "enabled"[/font]: Set to [font=Courier New]true[/font] to enable in-game notifications when you receive items. Enabled by default.
        [font=Courier New]        "ping_chest"[/font]: If set to [font=Courier New]true[/font], camp chests will be pinged when receiving items. Enabled by default.
        [font=Courier New]        "vfx"[/font]: If set to [font=Courier New]true[/font], a VFX will be emitted from your character when camp chests receive items. Enabled by default.
    [font=Courier New]    "spawning"[/font]:
        [font=Courier New]        "allow_during_tutorial"[/font]: Set to [font=Courier New]false[/font] to disable spawning new items or entities during tutorial sections. Disabled by default.

[font=Courier New]"DEBUG"[/font]:
    [font=Courier New]    "level"[/font]: Adjust the verbosity of debug logs. A setting of 0 disables debug logs,
 1 provides minimal logging, and 2 enables detailed, verbose logs. 0 by
default.
After saving your changes while the game is running, load a save to reflect your changes.[/spoiler][center][img]https://images2.imgbox.com/d6/78/Q3L97Io0_o.png[/img][/center][color=#9fc5e8][size=4][b]GENERAL INFORMATION[/b][/size][/color]

[b]The Item Shipment Framework is a simple and modular tool that allows mod authors to ship items to their users[/b]. In this section, you'll learn about the ISF, what it can do, and how easy it is to integrate your mods into the framework. Whether you're developing a new mod or updating one with an existing user base, integrating it into the ISF follows the same process. [b]For mods that already have an existing user base, integrating with ISF is user-friendly, as it ensures that players will not receive duplicates for items they already possess[/b]. This is achievable due to the series of checks that the ISF can perform.

[b]The framework provides a JSON configuration example file for mod integration, with comments detailing each setting[/b]. Due to (harmless) linting errors with said comments in standard JSON, both JSON and JSONC formats are supported by the ISF and are parsed in the same way, with or without comments.

[b]ISF doesn't force mods into a mandatory dependency with the Script Extender[/b]. The configuration file will be picked up in case users have ISF installed, but will simply remain inert otherwise. [b]Therefore, if your mod is designed to function without the Script Extender, integrating with the ISF will not change this[/b].

[color=#9fc5e8][size=4][b]HOW TO INTEGRATE YOUR MODS[/b][/size][/color]

If you are happy with the default settings provided by the ISF, you can follow the simple guide below to integrate your mod.

If you, however, would prefer to customize the settings of the framework config and learn more about how the ISF functions. We have a [url=https://github.com/AtilioA/BG3-item-shipment-framework/wiki]Wiki hosted on GitHub[/url] that goes over every setting available to you as a mod author and examples of multiple different use cases.

[list]
[*]Download the Item Shipment Framework integration config JSON ([font=Courier New][color=#93c47d][b]ItemShipmentFrameworkConfig.json[/b][/color][/font]) from the Files section of this mod page;
[*]Place it into the same directory as your mod's [b][font=Courier New][color=#93c47d]meta.lsx[/color][/font][/b] file, then open it using a text editor of your choice. We recommend Notepad++, or Visual Studio Code;
[*]Replace the three dots in the "TemplateUUID" section of the file with your item or container's unique UUID, then save the file;
[*]You're done! You have implemented Item Shipment Framework support into your mod, and you can now ship it to your users.
[/list][b]DISCLAIMER[/b]: Mod authors should [b]NOT[/b] add the ISF as a dependency in their meta.lsx file. It needs to be loaded last, and doing so could prevent that. Authors should only add it as a requirement on their mod's Nexus page.

[b][color=#9fc5e8][size=4]EXAMPLE MODS WHICH USE THE FRAMEWORK[/size][/color][/b]

Each of these mods showcases different use cases for the framework and may be freely used as a resource for creating your mods.

[list]
[*]All Camp Clothes in the Camp Chest
[*]All Dyes in the Camp Chest
[*]Debug Book in the Camp Chest
[*]Ethel's Hair in the Camp Chest
[*]Infinite Supply Packs
[/list][center][img]https://images2.imgbox.com/59/78/tZCsT1l5_o.png[/img][/center][url=https://www.nexusmods.com/users/13669385]Aetherpoint[/url]: Item creation, graphic design, English localization, and framework documentation.

[url=https://www.nexusmods.com/users/9505990]Volitio[/url]: Script Extender implementation, Brazilian Portuguese and French localizations.

[center][img]https://images2.imgbox.com/a8/0e/pfpESuWX_o.png[/img][/center][quote]"﻿[i]If I can see further, it is by standing on the shoulders of giants". [/i]Creating this framework would've been a  herculean task without the foundational work of  [url=https://www.nexusmods.com/baldursgate3/users/21094599]Focus[/url]﻿ and [url=https://www.nexusmods.com/baldursgate3/users/244952?tab=user+files]Nells[/url]﻿/[url=https://github.com/BG3-Community-Library-Team/]Community Library team[/url]﻿ from which I learned from and continue to build upon. I will be forever grateful for their open-source contributions to the Baldur's Gate 3 modding scene. Of course, none of this would be possible without the work put into Script Extender by [url=https://github.com/Norbyte/]Norbyte[/url]﻿.
Also thank you to all the authors that tested ISF and provided feedback during the beta! [url=https://www.nexusmods.com/baldursgate3/users/176915637?tab=user+files]Belinn[/url]﻿, [url=https://www.nexusmods.com/baldursgate3/users/14040560?tab=user+files]jerinski[/url]﻿, [url=https://www.nexusmods.com/users/89809?tab=user+files]wesslen[/url]﻿, [url=https://www.nexusmods.com/baldursgate3/users/137730728?tab=user+files]Armarui[/url]﻿, and others that shared support!
- Volitio[/quote][center][img]https://images2.imgbox.com/c4/b5/wfgcEnOw_o.png[/img][/center]If you'd like to support either of us directly, you may do so by following these links:

[b][size=3][url=https://ko-fi.com/aetherpoint]Aetherpoint's Ko-fi[/url][/size][/b]

[b][size=3][url=https://ko-fi.com/volitio]Volitio's Ko-fi[/url][/size][/b]
