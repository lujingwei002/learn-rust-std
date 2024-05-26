# any

## 'static

```rust
pub trait Any: 'static {
    fn type_id(&self) -> TypeId;
}
```

`: 'static`的约束什么的，举个例子。



## impl dyn Any + Send

dyn Any + Send的作用是将方法转发到dyn Any

```rust
impl dyn Any + Send {
    pub fn is<T: Any>(&self) -> bool {
        <dyn Any>::is::<T>(self)
    }
    pub fn downcast_ref<T: Any>(&self) -> Option<&T> {
        <dyn Any>::downcast_ref::<T>(self)
    }
    pub fn downcast_mut<T: Any>(&mut self) -> Option<&mut T> {
        <dyn Any>::downcast_mut::<T>(self)
    }
	pub unsafe fn downcast_ref_unchecked<T: Any>(&self) -> &T {
        unsafe { <dyn Any>::downcast_ref_unchecked::<T>(self) }
    }
    pub unsafe fn downcast_mut_unchecked<T: Any>(&mut self) -> &mut T {
        unsafe { <dyn Any>::downcast_mut_unchecked::<T>(self) }
    }
}
```

为什么要有这个实现，假设我们有个方法，参数是&(dyn Any + Sync)，就会报错。因为没有实现dyn Any + Sync。

```rust
fn is_string(s: &(dyn Any + Sync)) {
    if s.is::<String>() {
        println!("It's a string!");
    } else {
        println!("Not a string...");
    }
}
```

```bash
error[E0599]: no method named `is` found for reference `&(dyn Any + Sync + 'static)` in the current scope
  --> src\main.rs:13:10
   |
13 |     if s.is::<String>() {
   |          ^^ method not found in `&dyn Any + Sync`
```



## Auto traits

The [`Send`](https://doc.rust-lang.org/std/marker/trait.Send.html), [`Sync`](https://doc.rust-lang.org/std/marker/trait.Sync.html), [`Unpin`](https://doc.rust-lang.org/std/marker/trait.Unpin.html), [`UnwindSafe`](https://doc.rust-lang.org/std/panic/trait.UnwindSafe.html), and [`RefUnwindSafe`](https://doc.rust-lang.org/std/panic/trait.RefUnwindSafe.html) traits are *auto traits*. Auto traits have special properties.

If no explicit implementation or negative implementation is written out for an auto trait for a given type, then the compiler implements it automatically according to the following rules:

- `&T`, `&mut T`, `*const T`, `*mut T`, `[T; n]`, and `[T]` implement the trait if `T` does.
- Function item types and function pointers automatically implement the trait.
- Structs, enums, unions, and tuples implement the trait if all of their fields do.
- Closures implement the trait if the types of all of their captures do. A closure that captures a `T` by shared reference and a `U` by value implements any auto traits that both `&T` and `U` do.

For generic types (counting the built-in types above as generic over `T`), if a generic implementation is available, then the compiler does not automatically implement it for types that could use the implementation except that they do not meet the requisite trait bounds. For instance, the standard library implements `Send` for all `&T` where `T` is `Sync`; this means that the compiler will not implement `Send` for `&T` if `T` is `Send` but not `Sync`.

Auto traits can also have negative implementations, shown as `impl !AutoTrait for T` in the standard library documentation, that override the automatic implementations. For example `*mut T` has a negative implementation of `Send`, and so `*mut T` is not `Send`, even if `T` is. There is currently no stable way to specify additional negative implementations; they exist only in the standard library.

Auto traits may be added as an additional bound to any [trait object](https://doc.rust-lang.org/reference/types/trait-object.html), even though normally only one trait is allowed. For instance, `Box<dyn Debug + Send + UnwindSafe>` is a valid type.

```rust
fn is_string(s: &(dyn Eq + Display)) {

}
```

```rust
error[E0225]: only auto traits can be used as additional traits in a trait object
  --> src\main.rs:12:28
   |
12 | fn is_string(s: &(dyn Eq + Display)) {
   |                       --   ^^^^^^^ additional non-auto trait
   |                       |
   |                       first non-auto trait
   |
   = help: consider creating a new trait with all of these as supertraits and using that trait here instead: `trait NewTrait: Eq + std::fmt::Display {}`
   = note: auto-traits like `Send` and `Sync` are traits that have special properties; for more information on them, visit <https://doc.rust-lang.org/reference/special-types-and-traits.html#auto-traits>

```

