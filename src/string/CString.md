# CString



## 速览

- 底层数据结果是`Box<[u8]>`，因此内存是堆上。
- 以`b'0'`结尾，且中间不能包含`b'0'`。
- 没有编码限制。

## 检查中间有`b'0'`

```rust
pub fn new<T: Into<Vec<u8>>>(t: T) -> Result<CString, NulError> {
    trait SpecNewImpl {
        fn spec_new_impl(self) -> Result<CString, NulError>;
    }

    impl<T: Into<Vec<u8>>> SpecNewImpl for T {
        default fn spec_new_impl(self) -> Result<CString, NulError> {
            let bytes: Vec<u8> = self.into();
            match memchr::memchr(0, &bytes) {
                Some(i) => Err(NulError(i, bytes)),
                None => Ok(unsafe { CString::_from_vec_unchecked(bytes) }),
            }
        }
    }

    #[inline(always)]
    fn spec_new_impl_bytes(bytes: &[u8]) -> Result<CString, NulError> {
        let capacity = bytes.len().checked_add(1).unwrap();

        let mut buffer = Vec::with_capacity(capacity);
        buffer.extend(bytes);

        match memchr::memchr(0, bytes) {
            Some(i) => Err(NulError(i, buffer)),
            None => Ok(unsafe { CString::_from_vec_unchecked(buffer) }),
        }
    }

    impl SpecNewImpl for &'_ [u8] {
        fn spec_new_impl(self) -> Result<CString, NulError> {
            spec_new_impl_bytes(self)
        }
    }

    impl SpecNewImpl for &'_ str {
        fn spec_new_impl(self) -> Result<CString, NulError> {
            spec_new_impl_bytes(self.as_bytes())
        }
    }

    impl SpecNewImpl for &'_ mut [u8] {
        fn spec_new_impl(self) -> Result<CString, NulError> {
            spec_new_impl_bytes(self)
        }
    }
    t.spec_new_impl()
}
```

> 使用memchr::memchr判断，`[u8]`不能包含0。验证后_from_vec_uncheckec会向vec追加一个`b'0'`。
