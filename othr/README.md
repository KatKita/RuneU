# Other Libraries & Utilities

This folder contains additional libraries, utility functions, and setup scripts for **RuneU**.

These files are optional. You can add them to your Roblox project to extend RuneU with extra features, custom helper functions, or specialized modules.

---

## Rune Scripts in Roblox

In Roblox, all `.rne` files are represented as `StringValue` objects.

### Rules for `StringValue` Objects:

* **`Name`**: Must match the filename **without** the `.rne` extension.
* **`Value`**: Contains the complete Rune source code.

> **Note:** The `.rne` extension is only used outside Roblox. Inside Roblox, the object's `Name` property serves as the script filename.

#### Example

For a file named `main.rne`:

```text
StringValue
├── Name: main
└── Value: <Rune code here>

```

---

## Starter Script

`Starter.luau` is the default script for loading extended RuneU functionality. Use it as a template or reference when integrating these additional utilities into your project.

* The full source code is available in [`Starter.luau`](./Starter.luau).
