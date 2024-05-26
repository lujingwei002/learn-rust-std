# CStr

## 定义

```rust
pub struct CStr {
    inner: [c_char],
}
```

最后一个字段是DST，因此CStr也是是一个DST对象。

## Example

```rust
use std::ffi::CStr;
use std::os::raw::c_char;

extern "C" { fn my_string() -> *const c_char; }

unsafe {
    let slice = CStr::from_ptr(my_string());
    println!("string buffer size without nul terminator: {}", slice.to_bytes().len());
}
```

