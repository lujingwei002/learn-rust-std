# 编码



## ascii

| -                                 | -        |
| --------------------------------- | -------- |
| 0..=0x1F \| 0x7F                  | 控制字符 |
| 0x9                               | `\t`     |
| 0xD                               | `\r`     |
| 0xA                               | `\n`     |
| 0x5C                              | `/`      |
| 0x27                              | `'`      |
| 0x22                              | `"`      |
| 0x30..=0x39                       | 0..=9    |
| 0x41..=0x5A                       | A..=Z    |
| 0x61..=0x7A                       | a..=z    |
| `\t` | `\n` | `\c` | ` ` | `\x0C` | 空白字符 |

常用接口

| -                         | -                |
| ------------------------- | ---------------- |
| u8::is_ascii_control      | 是否控制字符     |
| u8::is_ascii_whitespace   | 是否空白字符     |
| u8::is_ascii_alphabetic   | 是否字母         |
| u8::is_ascii_uppercase    | 是否大写字母     |
| u8::is_ascii_lowercase    | 是否小写字母     |
| u8::is_ascii_alphanumeric | 是否数字或者字母 |
| u8::is_ascii_digit        | 是否数字         |



## unicode

取值范围是 **0到U+10FFFF**。
并不是连续分配的，而是按空间一块块分配的。实际上有些编号从未分配字符。其中比较大块的是**U+D800-U+DFFF**,共**2048**个。

## UTF16

- UTF16是用两个字节表示一个码点。但U+10000到U+10FFFF需要3个节点。于是就用上面提到的**没用到的码点**(U+D800-U+DFFF)来进行编码。有两个码点表示一个范围在U+10000到U+10FFFF的字符。

- U+10FFFF减U+10000 等级 U+FFFFF 最多有20位，每10位用一个码点表示，需要两个码点。
  第1个码点范围是U+D800到U+DBFF 第2个码点范围是U+DC00到U+DFFFF， 范围都是0x2FF, 刚好10位

### 编码

```
虎的emoji是U+1F405
减去0x10000, 得到0xF405， 即二进制 111101 0000000101
每10位用一个码点，得到二进制 111101和 0000000101。十六进3D和5
与D800 DC00相加 得到 D83D 和 DC05，组合在一起是 D8 3D DC 05
```

代码在core/src/char/methods.rs

```rust
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



### 解码

```
解码进程与相反，每次读2个字节，在读到 D8 3D 这个字节序列时
因为它位于 D800 到 DBFF 之间，解码器就会知道它是代理对起始字符
会把它和下一个字符组合起来，按上述方法的逆过程还原成 U+1F405 码点。
```

代码在core/src/char/decode.rs

```rust
impl<I: Iterator<Item = u16>> Iterator for DecodeUtf16<I> {
    type Item = Result<char, DecodeUtf16Error>;

    fn next(&mut self) -> Option<Result<char, DecodeUtf16Error>> {
        let u = match self.buf.take() {
            Some(buf) => buf,
            None => self.iter.next()?,
        };

        if !u.is_utf16_surrogate() {
            // SAFETY: not a surrogate
            Some(Ok(unsafe { char::from_u32_unchecked(u as u32) }))
        } else if u >= 0xDC00 {
            // a trailing surrogate
            Some(Err(DecodeUtf16Error { code: u }))
        } else {
            let u2 = match self.iter.next() {
                Some(u2) => u2,
                // eof
                None => return Some(Err(DecodeUtf16Error { code: u })),
            };
            if u2 < 0xDC00 || u2 > 0xDFFF {
                // not a trailing surrogate so we're not a valid
                // surrogate pair, so rewind to redecode u2 next time.
                self.buf = Some(u2);
                return Some(Err(DecodeUtf16Error { code: u }));
            }

            // all ok, so lets decode it.
            let c = (((u & 0x3ff) as u32) << 10 | (u2 & 0x3ff) as u32) + 0x1_0000;
            // SAFETY: we checked that it's a legal unicode value
            Some(Ok(unsafe { char::from_u32_unchecked(c) }))
        }
    }
}
```

### 相关接口

| -                       | -                                                   |
| ----------------------- | --------------------------------------------------- |
| u16::is_utf16_surrogate | 是否unicode surrogate code point，即0xD800..=0xDFFF |
| char::decode_utf16      | 解码utf16序列，将IntoIterator<Item = u16>转换为char |
| char::encode_utf16_raw  | 编码成Utf16，将单个unicode转换为u16序列             |

## UTF8

UTF8是一种变长编码。是自表达的。把字节序列的二进制表示从左往右排开，用最左边1的数量表示该字符所具有的字节数，直到遇到第一个0为止。比如

- 如果第一个字节是0xxxxxxx，表示该字符只有1字节。
- 如果第一个字节是110xxxxx，表示该字符有2字节。
- 如果第一个字节是1110xxxx，表示该字符有3字节。
- 如果第一个字节是11110xxx，表示该字符有4字节。

| 码点的位数 | 码点起值 | 码点终值 | 字节序列 | 字节1    | 字节2    | 字节3    | 字节4    |
| ---------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- |
| 7          | U+0000   | U+007F   | 1        | 0xxxxxxx |          |          |          |
| 11         | U+0080   | U+07FF   | 2        | 110xxxxx | 10xxxxxx |          |          |
| 16         | U+0800   | U+FFFF   | 3        | 1110xxxx | 10xxxxxx | 10xxxxxx |          |
| 21         | U+10000  | U+10FFFF | 4        | 11110xxx | 10xxxxxx | 10xxxxxx | 10xxxxxx |
|            |          |          |          |          |          |          |          |


### 解码

例子

```rust
pub unsafe fn next_code_point<'a, I: Iterator<Item = &'a u8>>(bytes: &mut I) -> Option<u32> {
    // Decode UTF-8
    let x = *bytes.next()?;
    if x < 128 {
        return Some(x as u32);
    }
    // 得到x的低5位
    let init = utf8_first_byte(x, 2);
    let y = unsafe { *bytes.next().unwrap_unchecked() };
    // 2字节的情况， 第1字节的低4位 + 第2字节的低6位
    let mut ch = utf8_acc_cont_byte(init, y);
    if x >= 0xE0 {
        let z = unsafe { *bytes.next().unwrap_unchecked() };
        let y_z = utf8_acc_cont_byte((y & CONT_MASK) as u32, z);
        // 3字节的情况， 第1字节的低4位 + 第2字节的低6位 + 第字节的低6位
        ch = init << 12 | y_z;
        if x >= 0xF0 {
             // 4字节的情况， 第1字节的低3位 + 第2字节的低6位 + 第字节的低6位 + 第字节的低6位
            let w = unsafe { *bytes.next().unwrap_unchecked() };
            ch = (init & 7) << 18 | utf8_acc_cont_byte(y_z, w);
        }
    }
    Some(ch)
}
```

> 虎的emoji：码点为 U+1F405 
>
> 转换为二进制，11111010000000101从末尾开始按6位分组 
>
> 得到 11111 010000 000101第一部分为5位，开头插入1110的话就9位了，一个字节放不下，所以前面得补一个字节，用4字节表示。 
>
> 字节中间和末尾空隙填充0，然后每个尾随字节前面都补10 
>
> 也就是 11110000 10011111 10010000 10000101 
>
> 转换成十六进制，得到 F0 9F 90 85 

```
虎：码点为 U+864E
转换为二进制，1000011001001110
从末尾开始按6位分组，1000 011001 001110需要3字节，
开头插入1110，中间插入两个10，得到 11101000 10011001 10001110转换为十六进制，得到 E8 99 8E
```


### 校验

- 去掉U+D800到U+DFFF
- 比如，3字节和4字节会有重叠的部分
  - 3字节最多可以编码16位，所以4字节情况下要排除16位的情况，最小值要是0xF0，0b1001xxxx 0b10xxxxxx 0b10xxxxxx。

| 字节数 |          | 字节1                   | 字节2       | 字节3    | 字节5    |
| ------ | -------- | ----------------------- | ----------- | -------- | -------- |
| 1      |          | 0..=0x7F                |             |          |          |
| 2      | 110xxxxx | 0b11000000..=0b11011111 | 0..=0x80    |          |          |
| 3      | 1110xxxx | 0xE0                    | 0xA0..=0xBF | 0..=0x80 |          |
|        |          | 0xE1..=0xEC             | 0x80..=0xBF | 0..=0x80 |          |
|        |          | 0xED                    | 0x80..=0x9F | 0..=0x80 |          |
|        |          | 0xEE..=0xEF             | 0x80..=0xBF | 0..=0x80 |          |
| 4      | 11110xxx | 0xF0                    | 0x90..=0xBF | 0..=0x80 | 0..=0x80 |
|        |          | 0xF1..=0xF3             | 0x80..=0xBF | 0..=0x80 | 0..=0x80 |
|        |          | 0xF4                    | 0x80..=0x8F | 0..=0x80 | 0..=0x80 |





## 

## 常用转换接口

|      |        | -                         | -                                |
| ---- | ------ | ------------------------- | -------------------------------- |
|      |        | u8::is_utf8_char_boundary | 是否Utf8边界字符,即大于等于-0x40 |
| char | [u8]   | char::encode_utf8_raw     | unicode转为utf8                  |
| char | str    | char::encode_utf8         | unicode转为utf8                  |
| char | [u16]  | char::encode_utf16        | unicode转为utf16                 |
| char | [u16]  | char::encode_utf16_raw    | unicode转为utf16                 |
| [u8] | str    | str::from_utf8            | [u8]转为utf8                     |
| str  | [u16]  | str::encode_utf16         | utf8转为utf16                    |
| str  | [char] | str::chars                | utf8转为unicode                  |

