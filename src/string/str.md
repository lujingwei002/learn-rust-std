# str



## 重点

- 底层是[u8]数组。

- str是一个utf8编码的字符串。



## count

## lossy

```rust
#![feature(utf8_chunks)]

use std::str::Utf8Chunks;

// An invalid UTF-8 string
let bytes = b"foo\xF1\x80bar";

// Decode the first `Utf8Chunk`
let chunk = Utf8Chunks::new(bytes).next().unwrap();

// The first three characters are valid UTF-8
assert_eq!("foo", chunk.valid());

// The fourth character is broken
assert_eq!(b"\xF1\x80", chunk.invalid());
```



aa

```rust
#![feature(utf8_chunks)]

use std::str::Utf8Chunks;

fn from_utf8_lossy<F>(input: &[u8], mut push: F) where F: FnMut(&str) {
    for chunk in Utf8Chunks::new(input) {
        push(chunk.valid());

        if !chunk.invalid().is_empty() {
            push("\u{FFFD}");
        }
    }
}
```



## utf8编码
