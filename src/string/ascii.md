# ascii

## escape

实现在escape.rs里

| -                                    | -                                |
| ------------------------------------ | -------------------------------- |
| `b'\t'`                              | `\` `t`                          |
| `b'\r'`                              | `\` `r`                          |
| `b'\n'`                              | `\` `n`                          |
| `b'\\'`                              | `\` `\`                          |
| `b'\''`                              | `\` `'`                          |
| `b'\"'`                              | `\` `"`                          |
| `b'\0'..=b'\x1F' | b'\x7F'` 控制字符 | `\` `x` `byte >> 4` `byte & 0xf` |

## as

| -                     | -     |
| --------------------- | ----- |
| AsciiChar::to_u8      | u8    |
| AsciiChar::to_u8      | char  |
| AsciiChar::as_str     | &str  |
| [AsciiChar]::as_str   | &str  |
| [AsciiChar]::as_bytes | &[u8] |

