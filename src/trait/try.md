# try

## ?操作符

可以用来快速的解开Result里的值，如果是Err的话就立刻返回。

```rust
fn test() ->Result<i32, Error> {
    let r:Result<i32, Error> = Ok(1);
    let v = r?;
    Ok(0)
}
```

Option也可以

```rust
fn test() ->Option<i32> {
    let r:Option<i32> = Some(1);
    let v = r?;
    Some(0)
}
```

## 解糖

try操作符相当于什么操作，先看Try和FromResidual特征。

```rust

pub enum ControlFlow<B, C = ()> {
    Continue(C),
    Break(B),
}

pub trait FromResidual<R = <Self as Try>::Residual> {
    fn from_residual(residual: R) -> Self;
}

pub trait Try: FromResidual {
   
    type Output;
    type Residual;

    fn from_output(output: Self::Output) -> Self;

    fn branch(self) -> ControlFlow<Self::Residual, Self::Output>;
}
```

大家可能觉得奇怪，为什么会分成FromResidual和Try两个特征，后面会通过例子讲解。先看看try相当于什么操作。用上面的Result作为例子。Result实现了Try和FromResidual特征。

```rust
fn test() ->Result<i32, Error> {
    let r:Result<i32, Error> = Ok(1);
    let cf = r.branch();
    let v = match cf {
        ControlFlow::Continue(a) => a,
        ControlFlow::Break(r) => return Result::<i32, Error>::from_residual(r),
    };
    Ok(0)
}
```

加如我需要返回Result<(), Error>可以吗。可以通过FromResidual特征更改Output类型，重新组合出一个Try。

```rust
fn test() ->Result<(), Error> {
    let r:Result<i32, Error> = Ok(1);
    let cf = r.branch();
    let v = match cf {
        ControlFlow::Continue(a) => a,
        ControlFlow::Break(r) => return Result::<(), Error>::from_residual(r),
    };
    Ok(())
}
```

>  事实上，调用哪个from_residual方法是根据函数的返回值来决定的。





再看看array模块中的一个例子

```rust
#[inline]
fn try_from_fn_erased<T, R>(
    buffer: &mut [MaybeUninit<T>],
    mut generator: impl FnMut(usize) -> R,
) -> ControlFlow<R::Residual>
where
    R: Try<Output = T>,
{
    let mut guard = Guard { array_mut: buffer, initialized: 0 };

    while guard.initialized < guard.array_mut.len() {
        let item = generator(guard.initialized).branch()?;

        // SAFETY: The loop condition ensures we have space to push the item
        unsafe { guard.push_unchecked(item) };
    }

    mem::forget(guard);
    ControlFlow::Continue(())
}
```

注意看，上面是`generator(guard.initialized).branch()?;`，而不是`generator(guard.initialized)?;`，上面我们已经知道branch()方法是要返回`ControlFlow`的，事实上`ControlFlow`也实现了Try特征，因此也能使用?操作符。generator有可能返回Result，也有可能返回Option，因此需要调用branch转换为ControlFlow，使try_from_fn_erased的返回值可以统一。
