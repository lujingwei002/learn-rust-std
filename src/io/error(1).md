# 错误



## Error



```rust
pub struct Error {
    repr: Repr,
}
pub(super) struct Repr(NonNull<()>, PhantomData<ErrorData<Box<Custom>>>);
```

## Repr

repr可以看成是一个union

```rust
union Repr {
    &SimpleMessage
    Simple
    Custom
    Os
}

struct SimpleMessage {
    kind: ErrorKind,
    message: &'static str,
}

type Simple ErrorKind

type Os RawOsError



```

| -             | tag  | -           | -    |
| ------------- | ---- | ----------- | ---- |
| SimpleMessage | 0b00 |             |      |
| Simple        | 0b11 | ErrorKind   |      |
| Custom        | 0b01 | Box<Custom> |      |
| Os            | 0b10 | RawOsError  |      |

