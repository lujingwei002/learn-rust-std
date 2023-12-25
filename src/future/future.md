# future

## Poll

Poll是一个`enum`，有两种状态，`Ready`和`Pending`，类似于`Result`，也实现了`Try`特征。

### ready!

类似于`?`，如果是`Pending`就直接返回。

```rust
pub macro ready($e:expr) {
    match $e {
        $crate::task::Poll::Ready(t) => t,
        $crate::task::Poll::Pending => {
            return $crate::task::Poll::Pending;
        }
    }
}

pub fn do_poll(cx: &mut Context<'_>) -> Poll<()> {
    let mut fut = future::ready(42);
    let fut = Pin::new(&mut fut);
    // 如果是Pending就直接返回
    let num = ready!(fut.poll(cx));
    // ... use num
    Poll::Ready(())
}
```

## Future

### 创建Future

```rust
let go = async {
    32
}
```

这样就可以创建一个实现了Future特征的对象，类型是`impl Future`。

### async创建的对象是在栈中的

因为没有实现`Unpin`特征，因此不能直接调用poll方法。

```rust
fn send<T : Future+Unpin>(m: T) {
}
fn main () {
    let go = async {
        32
    };
    send(go);
}
```

将future移到堆中，就可以安全的pinned了

```rust
fn send<T : Future+Unpin>(m: T) {
}

fn main () {
    let go = async {
        32
    };
    let g1 = Box::pin(go);
    send(g1);
}
```

因为Box实现了`Unpin`特征

```rust
impl<T: ?Sized, A: Allocator> Unpin for Box<T, A> where A: 'static {}
```

