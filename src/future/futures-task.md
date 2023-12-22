# futures-task



## LocalFutureObj

- 因为不依赖std，这个结构结果等效于`Box<dyn Future<Output = T> + 'a>`



## FutureObj

- 因为不依赖于std，这个结构结果等效于`Box<dyn Future<Output = T> + Send 'a>`

## UnsafeFutureObj

- 可以用来创建FutureObj和LocalFutureObj的，实现这个特征的都可以。

- Box实现了UnsafeFutureObj特征，因为可以用来创建FutureObj

  ```rust
  unsafe impl<'a, T, F> UnsafeFutureObj<'a, T> for Box<F>
  where
      F: Future<Output = T> + 'a,
  {
      fn into_raw(self) -> *mut (dyn Future<Output = T> + 'a) {
          Box::into_raw(self)
      }
  
      unsafe fn drop(ptr: *mut (dyn Future<Output = T> + 'a)) {
          drop(Box::from_raw(ptr.cast::<F>()))
      }
  }
  ```

  

  ```rust
  pub trait SpawnExt: Spawn {
      fn spawn<Fut>(&self, future: Fut) -> Result<(), SpawnError>
      where
          Fut: Future<Output = ()> + Send + 'static,
      {
          self.spawn_obj(FutureObj::new(Box::new(future)))
      }
  }
  ```
