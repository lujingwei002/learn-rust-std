# remutex



可重入锁，即同一个线程之前已经上过锁的话，再话lock不会被阻塞。



## 在mutext中保存当前拥有锁的进程

```rust
pub struct ReentrantMutex<T> {
    mutex: sys::Mutex,
    owner: AtomicUsize,
    lock_count: UnsafeCell<u32>,
    data: T,
}

impl<T> ReentrantMutex<T> {
    pub fn lock(&self) -> ReentrantMutexGuard<'_, T> {
        let this_thread = current_thread_unique_ptr();
        // Safety: We only touch lock_count when we own the lock.
        unsafe {
            if self.owner.load(Relaxed) == this_thread {
                self.increment_lock_count();
            } else {
                self.mutex.lock();
                self.owner.store(this_thread, Relaxed);
                debug_assert_eq!(*self.lock_count.get(), 0);
                *self.lock_count.get() = 1;
            }
        }
        ReentrantMutexGuard { lock: self }
    }
}
```

> OWNER保存着当前拥有锁的进程



## 线程id用线程局部变量的地址来模拟

```rust
pub fn current_thread_unique_ptr() -> usize {
    // Use a non-drop type to make sure it's still available during thread destruction.
    thread_local! { static X: u8 = const { 0 } }
    X.with(|x| <*const _>::addr(x))
}
```

> 返回值是X的地址

