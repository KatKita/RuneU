# Rune Scripts in Roblox

In Roblox, all `.rne` files are represented as `StringValue` objects.

Each `StringValue` must follow these rules:
- The `Value` property contains the Rune source code.
- The `Name` property contains the filename without the `.rne` extension.

Example:

For a file named `main.rne`:

```text
StringValue
Name: main
Value: <Rune code here>
