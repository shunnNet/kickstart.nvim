`vim.keymap.set(mode, lhs, rhs, opt)`

## opt
- noremap: "no remap". Recommend: true (always)
- silent: Recommend: true

### noremap
remap will recursively match rhs

for example:

vim.keymap.set('n', "a", 'j')
vim.keymap.set('n', "b", 'a')

if remap, press b will map to a -> j, which may cause problem sometimes.

### silent
should not print command the keymap do.

this may be annoying...


## rhs
Example of rhs

- `<cmd>VimCommand<CR>`
- `:write<CR>`
- `<Esc>`: Press Esc
- `function() ... end`: lua function
- `builtin.find_files`: plugin function
- `builtin.find_files`: plugin function
- `builtin.find_files`: plugin function
- `builtin.find_files`: plugin function


| 1 | 2|
| -- | -- |
|123l|`1`23|



```ts
const a  = 1234
function () {
    console.log(2131231231)
}
```


