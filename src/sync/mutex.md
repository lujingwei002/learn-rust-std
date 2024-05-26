# mutex

## 类似Cell，提供内部可变性

```rust
use std::sync::{Arc, Mutex};
use std::thread;

let mutex = Arc::new(Mutex::new(0));
let c_mutex = Arc::clone(&mutex);

thread::spawn(move || {
    *c_mutex.lock().unwrap() = 10;
}).join().expect("thread::spawn failed");

assert_eq!(*mutex.lock().unwrap(), 10);
```

## 值能移动的话，引用也能安全移动

```rust
unsafe impl<T: ?Sized + Send> Send for Mutex<T> {}
unsafe impl<T: ?Sized + Send> Sync for Mutex<T> {}
```

