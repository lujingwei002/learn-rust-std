# iter::try_process

为Result实现FromIterator特征

```rust
#[stable(feature = "rust1", since = "1.0.0")]
impl<A, E, V: FromIterator<A>> FromIterator<Result<A, E>> for Result<V, E> {
    /// Takes each element in the `Iterator`: if it is an `Err`, no further
    /// elements are taken, and the `Err` is returned. Should no `Err` occur, a
    /// container with the values of each `Result` is returned.
    ///
    /// Here is an example which increments every integer in a vector,
    /// checking for overflow:
    ///
    /// ```
    /// let v = vec![1, 2];
    /// let res: Result<Vec<u32>, &'static str> = v.iter().map(|x: &u32|
    ///     x.checked_add(1).ok_or("Overflow!")
    /// ).collect();
    /// assert_eq!(res, Ok(vec![2, 3]));
    /// ```
    ///
    /// Here is another example that tries to subtract one from another list
    /// of integers, this time checking for underflow:
    ///
    /// ```
    /// let v = vec![1, 2, 0];
    /// let res: Result<Vec<u32>, &'static str> = v.iter().map(|x: &u32|
    ///     x.checked_sub(1).ok_or("Underflow!")
    /// ).collect();
    /// assert_eq!(res, Err("Underflow!"));
    /// ```
    ///
    /// Here is a variation on the previous example, showing that no
    /// further elements are taken from `iter` after the first `Err`.
    ///
    /// ```
    /// let v = vec![3, 2, 1, 10];
    /// let mut shared = 0;
    /// let res: Result<Vec<u32>, &'static str> = v.iter().map(|x: &u32| {
    ///     shared += x;
    ///     x.checked_sub(2).ok_or("Underflow!")
    /// }).collect();
    /// assert_eq!(res, Err("Underflow!"));
    /// assert_eq!(shared, 6);
    /// ```
    ///
    /// Since the third element caused an underflow, no further elements were taken,
    /// so the final value of `shared` is 6 (= `3 + 2 + 1`), not 16.
    #[inline]
    fn from_iter<I: IntoIterator<Item = Result<A, E>>>(iter: I) -> Result<V, E> {
        iter::try_process(iter.into_iter(), |i| i.collect())
    }
}
```

