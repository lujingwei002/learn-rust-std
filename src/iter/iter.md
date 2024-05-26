# 迭代器



## sources

| -             | -                                       | -    |
| ------------- | --------------------------------------- | ---- |
| Empty         |                                         |      |
| Once          | 生成一个元素                            |      |
| OnceWith      | 生成一个元素                            |      |
| Repeat        | 生成重复元素，需要实现clone特征         |      |
| RepeatN       | 生成N个重复元素，需要实现clone特征      |      |
| RepeatWith    | 生成~~重复~~元素，**不需要**clone特征。 |      |
| FromFn        |                                         |      |
| FromCoroutine |                                         |      |
| Successors    |                                         |      |

## Once

```rust
use std::iter;

fn main() {
    // one is the loneliest number
    let mut one = iter::once(1);
    assert_eq!(Some(1), one.next());
    // just one, that's all we get
    assert_eq!(None, one.next());
}
```

## OnceWith

```rust
use std::iter;

fn main() {
    // one is the loneliest number
    let mut one = iter::once_with(|| 1);
    assert_eq!(Some(1), one.next());
    // just one, that's all we get
    assert_eq!(None, one.next());
}
```

## Repeat

```rust
use std::iter;

fn main() {
    // the number four 4ever:
    let mut fours = iter::repeat(4);

    assert_eq!(Some(4), fours.next());
    assert_eq!(Some(4), fours.next());
    assert_eq!(Some(4), fours.next());
    assert_eq!(Some(4), fours.next());
    assert_eq!(Some(4), fours.next());

    // yup, still four
    assert_eq!(Some(4), fours.next());
}
```

## RepeatN

```rust
#![feature(iter_repeat_n)]
use std::iter;

fn main() {
    // four of the number four:
    let mut four_fours = iter::repeat_n(4, 4);

    assert_eq!(Some(4), four_fours.next());
    assert_eq!(Some(4), four_fours.next());
    assert_eq!(Some(4), four_fours.next());
    assert_eq!(Some(4), four_fours.next());

    // no more fours
    assert_eq!(None, four_fours.next());
}
```

## RepeatWith

```rust
use std::iter;

// let's assume we have some value of a type that is not `Clone`
// or which we don't want to have in memory just yet because it is expensive:
#[derive(PartialEq, Debug)]
struct Expensive;

fn main() {
    // a particular value forever:
    let mut things = iter::repeat_with(|| Expensive);

    assert_eq!(Some(Expensive), things.next());
    assert_eq!(Some(Expensive), things.next());
    assert_eq!(Some(Expensive), things.next());
    assert_eq!(Some(Expensive), things.next());
    assert_eq!(Some(Expensive), things.next());
}
```

元素不重复也可以

```rust
use std::iter;

fn main() {
    // From the zeroth to the third power of two:
    let mut curr = 1;
    let mut pow2 = iter::repeat_with(|| { let tmp = curr; curr *= 2; tmp })
                        .take(4);

    assert_eq!(Some(1), pow2.next());
    assert_eq!(Some(2), pow2.next());
    assert_eq!(Some(4), pow2.next());
    assert_eq!(Some(8), pow2.next());

    // ... and now we're done
    assert_eq!(None, pow2.next());
}
```

## FromCoroutine

```rust
#![cfg_attr(bootstrap, feature(generators))]
#![cfg_attr(not(bootstrap), feature(coroutines))]
#![feature(iter_from_coroutine)]

fn main() {
    let it = std::iter::from_coroutine(|| {
        yield 1;
        yield 2;
        yield 3;
    });
    let v: Vec<_> = it.collect();
    assert_eq!(v, [1, 2, 3]);
}
```

## Successors

```rust
use std::iter::successors;

fn main() {
    let powers_of_10 = successors(Some(1_u16), |n| n.checked_mul(10));
    assert_eq!(powers_of_10.collect::<Vec<_>>(), &[1, 10, 100, 1_000, 10_000]);
}
```

