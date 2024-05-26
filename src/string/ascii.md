# ascii

AsciiChar类型是enum，repr是u8，因此占用1个字节。取值范围是0..=127。

```rust
#[repr(u8)]
pub enum AsciiChar {
    Null = 0,
    ...
    Delete = 127,
}
```



str是utf8编译的，因此[AsciiChar]可以直接转换为str

```rust
impl [AsciiChar] {
  
    pub const fn as_str(&self) -> &str {
        let ascii_ptr: *const Self = self;
        let str_ptr = ascii_ptr as *const str;
        unsafe { &*str_ptr }
    }
}
```



AsciiChar实现了fmt::Debug特征

```rust
impl fmt::Debug for AsciiChar {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        #[inline]
        fn backslash(a: AsciiChar) -> ([AsciiChar; 4], u8) {
            ([AsciiChar::ReverseSolidus, a, AsciiChar::Null, AsciiChar::Null], 2)
        }

        let (buf, len) = match self {
            AsciiChar::Null => backslash(AsciiChar::Digit0),
            AsciiChar::CharacterTabulation => backslash(AsciiChar::SmallT),
            AsciiChar::CarriageReturn => backslash(AsciiChar::SmallR),
            AsciiChar::LineFeed => backslash(AsciiChar::SmallN),
            AsciiChar::ReverseSolidus => backslash(AsciiChar::ReverseSolidus),
            AsciiChar::Apostrophe => backslash(AsciiChar::Apostrophe),
            _ => {
                let byte = self.to_u8();
                if !byte.is_ascii_control() {
                    ([*self, AsciiChar::Null, AsciiChar::Null, AsciiChar::Null], 1)
                } else {
                    const HEX_DIGITS: [AsciiChar; 16] = *b"0123456789abcdef".as_ascii().unwrap();

                    let hi = HEX_DIGITS[usize::from(byte >> 4)];
                    let lo = HEX_DIGITS[usize::from(byte & 0xf)];
                    ([AsciiChar::ReverseSolidus, AsciiChar::SmallX, hi, lo], 4)
                }
            }
        };

        f.write_char('\'')?;
        for byte in &buf[..len as usize] {
            f.write_str(byte.as_str())?;
        }
        f.write_char('\'')
    }
}
```

|                                |                           | -                                    | -                                |
| ------------------------------ | ------------------------- | ------------------------------------ | -------------------------------- |
| AsciiChar::Null                | AsciiChar::Digit0         | `b'\t'`                              | `\` `t`                          |
| AsciiChar::CharacterTabulation | AsciiChar::SmallT         | `b'\r'`                              | `\` `r`                          |
| AsciiChar::CarriageReturn      | AsciiChar::SmallR         | `b'\n'`                              | `\` `n`                          |
| AsciiChar::LineFeed            | AsciiChar::SmallN         | `b'\\'`                              | `\` `\`                          |
| AsciiChar::ReverseSolidus      | AsciiChar::ReverseSolidus | `b'\''`                              | `\` `'`                          |
| AsciiChar::Apostrophe          | AsciiChar::Apostrophe     | `b'\"'`                              | `\` `"`                          |
|                                |                           | `b'\0'..=b'\x1F' | b'\x7F'` 控制字符 | `\` `x` `byte >> 4` `byte & 0xf` |

