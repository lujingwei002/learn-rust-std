# unsize

## 为什么需要unsize

之前提到&[i8; 2]这样的类型是`fat pointer`，可以用`from_raw_part`来构建



## 来自源码的描述

- Arrays `[T; N]` implement `Unsize<[T]>`.

- A type implements `Unsize<dyn Trait + 'a>` if all of these conditions are met:

  - The type implements Trait.
  - Trait is object safe.
  - The type is sized.
  - The type outlives 'a.

  

- Structs `Foo<..., T1, ..., Tn, ...>` implement `Unsize<Foo<..., U1, ..., Un, ...>> `where any number of (type and const) parameters may be changed if all of these conditions are met:
    
    - Only the last field of Foo has a type involving the parameters T1, ..., Tn.
    - All other parameters of the struct are equal.
    - Field<T1, ..., Tn>: Unsize<Field<U1, ..., Un>>, where Field<...> stands for the actual type of the struct's last field.

## 来自手册的描述

- `[T; n]` to `[T]`.
- `T` to `dyn U`, when `T` implements `U + Sized`, and `U` is [object safe](https://doc.rust-lang.org/reference/items/traits.html#object-safety).
- `Foo<..., T, ...>` to `Foo<..., U, ...>`, when:
  - `Foo` is a struct.
  - `T` implements `Unsize<U>`.
  - The last field of `Foo` has a type involving `T`.
  - If that field has type `Bar<T>`, then `Bar<T>` implements `Unsized<Bar<U>>`.
  - T is not part of the type of any other fields.



