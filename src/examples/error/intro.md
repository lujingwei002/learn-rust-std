# error

## kind

```rust
pub struct TryFromFloatSecsError {
    kind: TryFromFloatSecsErrorKind,
}

impl TryFromFloatSecsError {
    const fn description(&self) -> &'static str {
        match self.kind {
            TryFromFloatSecsErrorKind::Negative => {
                "can not convert float seconds to Duration: value is negative"
            }
            TryFromFloatSecsErrorKind::OverflowOrNan => {
                "can not convert float seconds to Duration: value is either too big or NaN"
            }
        }
    }
}

#[stable(feature = "duration_checked_float", since = "1.66.0")]
impl fmt::Display for TryFromFloatSecsError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        self.description().fmt(f)
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
enum TryFromFloatSecsErrorKind {
    // Value is negative.
    Negative,
    // Value is either too big to be represented as `Duration` or `NaN`.
    OverflowOrNan,
}
```

