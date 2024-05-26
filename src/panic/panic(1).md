# panic



| -                          | -                  | can_unwind | force_no_backtrace |
| -------------------------- | ------------------ | ---------- | ------------------ |
| panic_fmt                  | fmt::Arguments<'_> | true       | false              |
| panic_nounwind_fmt         | fmt::Arguments<'_> | false      |                    |
| panic                      | &'static           | true       | false              |
| panic_nounwind             | &'static           | false      | false              |
| panic_nounwind_nobacktrace | &'static           | false      | true               |
| panic_str                  | &str               | true       | false              |
| panic_explicit             |                    |            |                    |
| unreachable_display        |                    |            |                    |
| panic_display              | &fmt::Display      |            |                    |

