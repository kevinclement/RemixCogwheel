# Remix Cogwheel

Addon for cogwheel automation in the World of Warcraft Remix: Mists of Pandaria event.

Cogwheels in this event are gems that go into a cogwheel slot in your boots.  You can equip one, and they give you an extra movement abilty like Sprint.  Turns out, when you use the gem it will go on cooldown but it's not shared with other cogwheel gems.  Therefore, you can cast one, take it out of your boots, put in another one, cast it, and so on.  Doing that manually is tedious, so I wrote this addon to automate it.  It presents a single button you can click on that uses the cogwheel and then swaps.

![Demo](https://raw.githubusercontent.com/kevinclement/RemixCogwheel/main/media/demo.gif)

## Options

You can configure what order you want the gems executed in using the options dialog.
- Reorder: click and drag the icon to reorder
- Enable/Disable: right click the icon to disable or enable the gem use

![Options](https://raw.githubusercontent.com/kevinclement/RemixCogwheel/main/media/options.png)

## Macro Equip
![Macro](https://raw.githubusercontent.com/kevinclement/RemixCogwheel/main/media/macro.png)

I also exposed a little bit of script to allow creating a macro to equip a specific gem.  This allows you to add it to your actionbars or oPie for specific 'always on' gems like Trailblazer.

```
#showtooltip Trailblazer
/script _G["RC"]:SwapInGem(217989)
/click RemixCogwheelButton
```

