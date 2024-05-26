# error



Error一般配合Result来使用，表示出现了意料之外的错误，但不是致命的，程序可以决定是否继续运行。

```rust
pub trait Error: Debug + Display {
    fn source(&self) -> Option<&(dyn Error + 'static)> {
        None
    }
    fn description(&self) -> &str {
        "description() is deprecated; use Display"
    }
    fn provide<'a>(&'a self, request: &mut Request<'a>) {}
}

impl dyn Error {
     pub fn sources(&self) -> Source<'_> {
        Source { current: Some(self) }
    }
}
```

sources利用source方法构建一条错误链。provide可以在Error中附加一些信息。
