# poison



poison是用来记录在加锁期间，是否发生panic的。

## 记录panicking起始状态

```rust
impl Flag {
    pub fn guard(&self) -> LockResult<Guard> {
        let ret = Guard { panicking: thread::panicking() };
        if self.get() { Err(PoisonError::new(ret)) } else { Ok(ret) }
    }
}
```

> 如果当前已经是panicking状态，guard会返回Err



## 结束时，判断起始状态和当前状态

```rust
impl Flag {
    pub fn done(&self, guard: &Guard) {
        if !guard.panicking && thread::panicking() {
            self.failed.store(true, Ordering::Relaxed);
        }
    }
}
```

> guard和done要成对调用

## 在mutex中的用法

```rust
impl<T: ?Sized> Mutex<T> {
    pub fn lock(&self) -> LockResult<MutexGuard<'_, T>> {
        unsafe {
            self.inner.lock();
            MutexGuard::new(self)
        }
    }
}

impl<'mutex, T: ?Sized> MutexGuard<'mutex, T> {
    unsafe fn new(lock: &'mutex Mutex<T>) -> LockResult<MutexGuard<'mutex, T>> {
        poison::map_result(lock.poison.guard(), |guard| MutexGuard { lock, poison: guard })
    }
}

impl<T: ?Sized> Drop for MutexGuard<'_, T> {
    #[inline]
    fn drop(&mut self) {
        unsafe {
            self.lock.poison.done(&self.poison);
            self.lock.inner.unlock();
        }
    }
}
```

> lock的时候调用flag的guard，drop的时候调用flag的done方法。

## unlock

```rust
#![feature(mutex_unpoison)]

use std::sync::{Arc, Mutex};
use std::thread;

let mutex = Arc::new(Mutex::new(0));
let c_mutex = Arc::clone(&mutex);

let _ = thread::spawn(move || {
    let _lock = c_mutex.lock().unwrap();
    panic!(); // the mutex gets poisoned
}).join();

assert_eq!(mutex.is_poisoned(), true);
let x = mutex.lock().unwrap_or_else(|mut e| {
    **e.get_mut() = 1;
    mutex.clear_poison();
    e.into_inner()
});
assert_eq!(mutex.is_poisoned(), false);
assert_eq!(*x, 1);
```

> 如果lock期间发生了panic，MutexGuard的drop方法也会被调用，这时flag就被置为panic状态了。
