# Simplify-Shop
Kristshop which only requires one krist address, without a domain.

### (This tutorial and the shop itself assumes you are running this on **SwitchCraft**)

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

## Using the shop itself
Since there is no domain, and the shop itself only runs with one krist address, an item must be 'selected' before it can be purchased.
To select an item, simply right-click on one of the items on the monitor.  Depending on the state of your `selection` table in your `fatShopCustomization` file, the selected item will change color and appear in the Information Box.  Once the item is there, simply do as you would with any other shop, and run the command:

```
/pay KRISTADDRESS AMOUNT
```

