# barrier

阻挡线程执行，直到数显达到N，再放开阻挡，让之前的线程继续执行。

## 阻挡

```rust
use std::sync::{Arc, Barrier};
use std::thread;

let n = 10;
let mut handles = Vec::with_capacity(n);
let barrier = Arc::new(Barrier::new(n));
for _ in 0..n {
    let c = Arc::clone(&barrier);
    handles.push(thread::spawn(move|| {
        println!("before wait");
        c.wait();
        println!("after wait");
    }));
}

for handle in handles {
    handle.join().unwrap();
}
```

## 分批执行

```rust
pub struct Barrier {
    lock: Mutex<BarrierState>,
    cvar: Condvar,
    num_threads: usize,
}

struct BarrierState {
    count: usize,
    generation_id: usize,
}

pub fn wait(&self) -> BarrierWaitResult {
    let mut lock = self.lock.lock().unwrap();
    let local_gen = lock.generation_id;
    lock.count += 1;
    if lock.count < self.num_threads {
        let _guard =
            self.cvar.wait_while(lock, |state| local_gen == state.generation_id).unwrap();
        BarrierWaitResult(false)
    } else {
        lock.count = 0;
        lock.generation_id = lock.generation_id.wrapping_add(1);
        self.cvar.notify_all();
        BarrierWaitResult(true)
    }
}
```

> generation_id是批次id

```rust
use std::sync::{Arc, Barrier};
use std::thread;

let n = 10;
let mut handles = Vec::with_capacity(n);
let barrier = Arc::new(Barrier::new(5));
for _ in 0..n {
    let c = Arc::clone(&barrier);
    handles.push(thread::spawn(move|| {
        println!("before wait");
        c.wait();
        println!("after wait");
    }));
}

for handle in handles {
    handle.join().unwrap();
}
```

> 会分两批次执行
