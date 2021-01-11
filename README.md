# Simplify-Shop
Kristshop which only requires one krist address, without a domain.

# Important notice
This shop will soon be phased out for Simplify Shop V2! I've just got to make some finishing touches to V2, which hopefully won't take too long to complete.

Once the new shop is up, this shop will still run, though it will display a notification that V2 is available.

=========================================================

### (This tutorial and the shop itself assumes you are running this on **SwitchCraft**)

## Updating the shop
The shop has a built in auto-updater (as of v1.0), which is run each time upon startup.  If it detects an update you may choose to update it, or not (By pressing 'Y' for yes, or 'N' for no).
The updater will wait 30 seconds for a response, and if there is none, will skip the update.  This is to prevent the shop from getting "stuck" at startup.

## Using the shop
The shop requires 4 things from you to run.
1. Your **KRISTWALLET** password.
2. The **KRIST ADDRESS** that corresponds with your **KRISTWALLET** password (kxxxxxxx).
3. the **CUSTOMIZATION FILE**.
4. the **ITEM DATA FILE**.

The shop also requires some other files like k.lua, and etc.
To set up these requirements, run the shop once.  All required files will be created.

### The KRISTWALLET password and the KRIST ADDRESS
Both of these are stored in a single file.  The shop retrieves the password and address by using a `dofile("filename")`.
So long as the file returns them in the following format, it will work:
```lua
return "String_Password","String_Krist_Address"
```

### The CUSTOMIZATION FILE
Upon running the program, a file named "fatShopCustomization" will be created.  It is a serialized lua table, with values for a large amount of things.
You can play around with these values to see what each does.

If you get something wrong, a built-in check will notify you of the error at startup.

#### Alternatively.....
You can also run `<shopfilename> setup` to get the basic requirements set up.
The setup argument asks you for the following:
1. Your kristwallet password
2. If the krist address associated with the password is the right one
3. What type of storage you will use
4. and more minor things

### The ITEM DATA FILE
Upon running the program, a file named "fatItemData" will be created. It is a serialized lua table, with 3 items placed within.

Each item is organized like so:
```
{
  display = "string_name_to_display_on_screen",
  find = "minecraft:string_item_to_find",
  damage = NUMBER_item_damage,
  price = NUMBER_price_in_krist,
}
```
If there is an error in one of the items, a built in check will notify you of the error at startup.

### Extra "dot" files
There are three "dot" files in total;
1. `.privKey`,
2. `.monitor`,
3. `.turtle`.

Only the dot-file, "privKey" is a required file, the other two are only required if multiple monitors or turtles are connected to your network.  For `.monitor` and `.turtle`, simply write the name of the monitor or turtle that you want to be connected to.
Example:
If your monitor is named, "monitor_123", the content of `.monitor` would simply be:
```
monitor_123
```

## Using the shop itself
Since there is no domain, and the shop itself only runs with one krist address, an item must be 'selected' before it can be purchased.
To select an item, simply right-click on one of the items on the monitor.  Depending on the state of your `selection` table in your `fatShopCustomization` file, the selected item will change color and appear in the Information Box.  Once the item is there, simply do as you would with any other shop, and run the command:

```
/pay KRISTADDRESS AMOUNT
```

## Logging

The shop has a logger which it uses to locally store logs.  You can choose what types of data to log, and where.

### Types:

#### Info
This should only be enabled if you want to see WHERE an error is occuring, or if you are absolutely crazy.
Enabling doInfoLogging will spam your log files so full of crap that your computer will probably overflow in 2 hours.
Sample info logs:
```
[INFO]: Connected to websocket
[INFO]: MOTD: Welcome to Krist! Lemmmy is Yemmel
[INFO]: Subscribed to transactions
[INFO]: Redraw
[INFO]: Redraw
[INFO]: Redraw
[INFO]: Redraw
[INFO]: Redraw
[INFO]: Redraw
[INFO]: Redraw
[INFO]: Redraw
[INFO]: Redraw
[INFO]: Redraw
```

#### Warn
Warns are a step above Infos.  They mean "Something bad happened, but we can skip over it".

Sample warn logs:
```
[INFO]: Connected to websocket
[INFO]: MOTD: Welcome to Krist! Lemmmy is Yemmel
[INFO]: Subscribed to transactions
[INFO]: Redraw
[WARN]: Chest "LolNotAChest" seemingly is not connected to the network! Skipping it.
```

#### Severe
Severe is error.  When something needs to be fixed (such as the customization file being incorrect), you will get a severe notification.

Sample severe logs:

```
[INFO]: Connected to monitor monitor_bla
[INFO]: Items found in data: 16
[INFO]: Checking customization file
[SEVERE]: useBothChestTypes: expected boolean, got nil
[INFO]: Attempting to fix customization file
[INFO]: Potential fix for customization file. Rebooting.
```
Terminating the program also causes severes.

#### Purchase
What do you think this is?
Whenever someone purchases something from the shop, it generates a "purchase" log.

Sample purchase log:

```
[INFO]: Payment to: kxxxxxxxxx (we are kxxxxxxxxx)
[INFO]: Payment being processed.
[PURCHASE]: minecraft:diamond:0[2] for 6.
[INFO]: Sent refund
[PURCHASE]: Sent refund of 1 due to overpay.
```
**minecraft:diamond** -- The item that was sold

**:0** -- The damage value of the item

**[2]** -- The amount sold

**for 6** -- How much it costed.
