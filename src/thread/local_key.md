# local key



## 例子

```rust
use std::cell::RefCell;
use std::thread;

thread_local!(static FOO: RefCell<u32> = RefCell::new(1));

# fn main() {
    
FOO.with(|f : &RefCell<u32> | {
    assert_eq!(*f.borrow(), 1);
    *f.borrow_mut() = 2;
});

// each thread starts out with the initial value of 1
let t = thread::spawn(move|| {
    FOO.with(|f| {
        assert_eq!(*f.borrow(), 1);
        *f.borrow_mut() = 3;
    });
});

// wait for the thread to complete and bail out on panic
t.join().unwrap();

// we retain our original value of 2 despite the child thread
FOO.with(|f : &RefCell<u32> | {
    assert_eq!(*f.borrow(), 2);
});
 
# }

```

## thread_local!宏

上面的例子展开后是

```rust
const FOO: ::std::thread::LocalKey<RefCell<u32>> =
{
    #[inline]
    fn __init() -> RefCell<u32> { (RefCell::new(1)) }

    #[inline]
    unsafe fn __getit(
        init: ::std::option::Option<&mut ::std::option::Option<RefCell<u32>>>,
    ) -> ::std::option::Option<&'static RefCell<u32>> {
        #[thread_local]
        static __KEY: ::std::thread::local_impl::Key<RefCell<u32>> =
            ::std::thread::local_impl::Key::<RefCell<u32>>::new();

        unsafe {
            __KEY.get(move || {
                if let ::std::option::Option::Some(init) = init {
                    if let ::std::option::Option::Some(value) = init.take() {
                        return value;
                    } else if ::std::cfg!( debug_assertions ) {
                        ::std::unreachable!("missing default value");
                    }
                }
                __init()
            })
        }
    }

    unsafe {
        ::std::thread::LocalKey::new(__getit)
    }
};
```

## std::thread::local_impl::Key

线程局部变量的生命周期将是'static，但线程结束时我们也要释放这些变量，Key的作用就是在线程结束时释放他们。看看sys::common::thread_local::fast_local::Key的实现是怎么实现的。

Key有三种状态，Unregistered(末设置值)，Registered(已设置值)，RunningOrHasRun(已释放)。Key在设置值是会注释一个析构函数。

```rust
unsafe fn try_initialize<F: FnOnce() -> T>(&self, init: F) -> Option<&'static T> {
    // SAFETY: See comment above (this function doc).
    if !mem::needs_drop::<T>() || unsafe { self.try_register_dtor() } {
        // SAFETY: See comment above (this function doc).
        Some(unsafe { self.inner.initialize(init) })
    } else {
        None
    }
}

unsafe fn try_register_dtor(&self) -> bool {
    match self.dtor_state.get() {
        DtorState::Unregistered => {
            unsafe { register_dtor(self as *const _ as *mut u8, destroy_value::<T>) };
            self.dtor_state.set(DtorState::Registered);
            true
        }
        DtorState::Registered => {
            true
        }
        DtorState::RunningOrHasRun => false,
    }
}

unsafe extern "C" fn destroy_value<T>(ptr: *mut u8) {
    let ptr = ptr as *mut Key<T>;
    if let Err(_) = panic::catch_unwind(panic::AssertUnwindSafe(|| unsafe {
        let value = (*ptr).inner.take();
        (*ptr).dtor_state.set(DtorState::RunningOrHasRun);
        drop(value);
    })) {
        rtabort!("thread local panicked on drop");
    }
}
```



```rust

```

> 注册析构函数`destroy_value`，线程结束时被调用。将状态置为`RunningOrHasRun`，并且将Option的值置为`None`。

系统实现中用thread local保存着一个析构函数列表，destory_value就是被注册在这里

```rust
static HAS_DTORS: AtomicBool = AtomicBool::new(false);

#[thread_local]
#[cfg(target_thread_local)]
static DESTRUCTORS: crate::cell::RefCell<Vec<(*mut u8, unsafe extern "C" fn(*mut u8))>> =
    crate::cell::RefCell::new(Vec::new());

pub unsafe fn register_keyless_dtor(t: *mut u8, dtor: unsafe extern "C" fn(*mut u8)) {
    match DESTRUCTORS.try_borrow_mut() {
        Ok(mut dtors) => dtors.push((t, dtor)),
        Err(_) => rtabort!("global allocator may not use TLS"),
    }
    HAS_DTORS.store(true, Relaxed);
}

unsafe fn run_keyless_dtors() {
    loop {
        let Some((ptr, dtor)) = DESTRUCTORS.borrow_mut().pop() else {
            break;
        };
        (dtor)(ptr);
    }
    DESTRUCTORS.replace(Vec::new());
}
```

我们用`std::thread::local_impl::Key`写个例子测试一下

```rust
#![feature(ptr_metadata)]
#![feature(thread_local_internals)]
#![feature(thread_local)]
use std::fmt::Display;

use std::future::IntoFuture;
use std::thread;

use std::thread::local_impl::Key;

struct User {

}

impl Drop for User {
    fn drop(&mut self) {
        println!("drop user");
    }
}
#[thread_local]
static USRE: Key<User> = Key::<User>::new();

fn main() {
   let handler = thread::spawn(||{
        unsafe {USRE.get(||User{})};
    });
    handler.join();
    println!("over");
}

```

