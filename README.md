# Custom Operator Definition

Define custom operators using the syntax:

```lua
define_operator('OPERATOR', 'EXPRESSION')
```

### Example:

```lua
define_operator('@', '(arg[1] + arg[2]) * 2')
```
