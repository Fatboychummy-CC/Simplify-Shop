# Simplify-Shop
Kristshop which only requires one krist address, without a domain.


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
