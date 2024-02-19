# char

单个字符，表示Unicode scalar value，即排除high-surrogate 和 low-surrogate。

取值范围是0 ..= D7FF 和 E000 ..= 10FFFF。排除D800..=DFFF。

```rust
const fn char_try_from_u32(i: u32) -> Result<char, CharTryFromError> {
    if (i ^ 0xD800).wrapping_sub(0x800) >= 0x110000 - 0x800 {
        Err(CharTryFromError(()))
    } else {
        // SAFETY: checked that it's a legal unicode value
        Ok(unsafe { transmute(i) })
    }
}
```

## char换为utf8编码str

```rust
impl char {
    pub fn encode_utf8(self, dst: &mut [u8]) -> &mut str {
        // SAFETY: `char` is not a surrogate, so this is valid UTF-8.
        unsafe { from_utf8_unchecked_mut(encode_utf8_raw(self as u32, dst)) }
    }
}

pub fn encode_utf8_raw(code: u32, dst: &mut [u8]) -> &mut [u8] {
    let len = len_utf8(code);
    match (len, &mut dst[..]) {
        (1, [a, ..]) => {
            *a = code as u8;
        }
        (2, [a, b, ..]) => {
            *a = (code >> 6 & 0x1F) as u8 | TAG_TWO_B;
            *b = (code & 0x3F) as u8 | TAG_CONT;
        }
        (3, [a, b, c, ..]) => {
            *a = (code >> 12 & 0x0F) as u8 | TAG_THREE_B;
            *b = (code >> 6 & 0x3F) as u8 | TAG_CONT;
            *c = (code & 0x3F) as u8 | TAG_CONT;
        }
        (4, [a, b, c, d, ..]) => {
            *a = (code >> 18 & 0x07) as u8 | TAG_FOUR_B;
            *b = (code >> 12 & 0x3F) as u8 | TAG_CONT;
            *c = (code >> 6 & 0x3F) as u8 | TAG_CONT;
            *d = (code & 0x3F) as u8 | TAG_CONT;
        }
        _ => panic!(
            "encode_utf8: need {} bytes to encode U+{:X}, but the buffer has {}",
            len,
            code,
            dst.len(),
        ),
    };
    &mut dst[..len]
}
```

> 因为char确保值不是surrogate，所有encode_utf8_raw不用验证code的值是否正确。

## char转为utf16编码 [u16]

```rust
impl char {
    pub fn encode_utf16(self, dst: &mut [u16]) -> &mut [u16] {
        encode_utf16_raw(self as u32, dst)
    }
}

pub fn encode_utf16_raw(mut code: u32, dst: &mut [u16]) -> &mut [u16] {
    // SAFETY: each arm checks whether there are enough bits to write into
    unsafe {
        if (code & 0xFFFF) == code && !dst.is_empty() {
            // The BMP falls through
            *dst.get_unchecked_mut(0) = code as u16;
            slice::from_raw_parts_mut(dst.as_mut_ptr(), 1)
        } else if dst.len() >= 2 {
            // Supplementary planes break into surrogates.
            code -= 0x1_0000;
            *dst.get_unchecked_mut(0) = 0xD800 | ((code >> 10) as u16);
            *dst.get_unchecked_mut(1) = 0xDC00 | ((code as u16) & 0x3FF);
            slice::from_raw_parts_mut(dst.as_mut_ptr(), 2)
        } else {
            panic!(
                "encode_utf16: need {} units to encode U+{:X}, but the buffer has {}",
                char::from_u32_unchecked(code).len_utf16(),
                code,
                dst.len(),
            )
        }
    }
}
```



## utf16转[char]

```rust
impl char {
    pub fn decode_utf16<I: IntoIterator<Item = u16>>(iter: I) -> DecodeUtf16<I::IntoIter> {
        super::decode::decode_utf16(iter)
    }
}

pub struct DecodeUtf16<I>
where
    I: Iterator<Item = u16>,
{
    iter: I,
    buf: Option<u16>,
}
```



## escape_unicode

```rust
pub fn escape_unicode(self) -> EscapeUnicode {
    EscapeUnicode::new(self)
}

pub struct EscapeUnicode(escape::EscapeIterInner<10>);

pub(crate) struct EscapeIterInner<const N: usize> {
    // The element type ensures this is always ASCII, and thus also valid UTF-8.
    pub(crate) data: [ascii::Char; N],

    // Invariant: alive.start <= alive.end <= N.
    pub(crate) alive: Range<u8>,
}

pub(crate) struct EscapeIterInner<const N: usize> {
    // The element type ensures this is always ASCII, and thus also valid UTF-8.
    pub(crate) data: [ascii::Char; N],

    // Invariant: alive.start <= alive.end <= N.
    pub(crate) alive: Range<u8>,
}

impl EscapeUnicode {
    fn new(chr: char) -> Self {
        let mut data = [ascii::Char::Null; 10];
        let range = escape::escape_unicode_into(&mut data, chr);
        Self(escape::EscapeIterInner::new(data, range))
    }
}
```

> EscapeUnicode占10个字节加固一个range<u8>
>
> EscapeUnicode实现了Iterator，Item类型是char





## escape_debug

```rust
pub fn escape_debug(self) -> EscapeDebug {
    self.escape_debug_ext(EscapeDebugExtArgs::ESCAPE_ALL)
}
```

> EscapeDebugExtArgs::ESCAPE_ALL对于'和"会转义

## escape_debug_ext

```rust
pub(crate) fn escape_debug_ext(self, args: EscapeDebugExtArgs) -> EscapeDebug {
    match self {
        '\0' => EscapeDebug::backslash(ascii::Char::Digit0),
        '\t' => EscapeDebug::backslash(ascii::Char::SmallT),
        '\r' => EscapeDebug::backslash(ascii::Char::SmallR),
        '\n' => EscapeDebug::backslash(ascii::Char::SmallN),
        '\\' => EscapeDebug::backslash(ascii::Char::ReverseSolidus),
        '\"' if args.escape_double_quote => EscapeDebug::backslash(ascii::Char::QuotationMark),
        '\'' if args.escape_single_quote => EscapeDebug::backslash(ascii::Char::Apostrophe),
        _ if args.escape_grapheme_extended && self.is_grapheme_extended() => {
            EscapeDebug::from_unicode(self.escape_unicode())
        }
        _ if is_printable(self) => EscapeDebug::printable(self),
        _ => EscapeDebug::from_unicode(self.escape_unicode()),
    }
}

enum EscapeDebugInner {
    Bytes(escape::EscapeIterInner<10>),
    Char(char),
}

impl EscapeDebug {
    fn printable(chr: char) -> Self {
        Self(EscapeDebugInner::Char(chr))
    }
}

impl Iterator for EscapeDebug {
    type Item = char;

    #[inline]
    fn next(&mut self) -> Option<char> {
        match self.0 {
            EscapeDebugInner::Bytes(ref mut bytes) => bytes.next().map(char::from),
            EscapeDebugInner::Char(chr) => {
                self.clear();
                Some(chr)
            }
        }
    }
}
```

> 对于可打印字符，不转换成\u{xxxx}的形式，直接返回一个char
