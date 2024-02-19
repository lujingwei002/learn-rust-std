# 适配器



|                  | -               | -                                                       | -    |
| ---------------- | --------------- | ------------------------------------------------------- | ---- |
| step_by          | StepBy          |                                                         |      |
| chain            | Chain           | 连接两个迭代器                                          |      |
| zip              | Zip             | 将两个迭代器合并，元素变成(&iter1::Item, &iter2::Item)  |      |
| intersperse      | Intersperse     | 在迭代元素中，插入元素，变成 [1,插入元素,2,插入元素,3]  |      |
| intersperse_with | IntersperseWith | 在迭代元素中，插入元素，变成 [1,插入元素,2,插入元素,3]  |      |
| map              | Map             |                                                         |      |
| flat_map         | FlatMap         | 类似map，不过闭包返回的是迭代器而不是元素。             |      |
| filter           | Filter          | 过滤元素，如果闭包返回true则保留                        |      |
| filter_map       | FilterMap       | 过滤元素，如果闭包返回Some则保留                        |      |
| enumerate        | Enumerate       |                                                         |      |
| peekable         | Peekable        | 在调用next方法前，可以用peek方法查看元素，但不会消耗它  |      |
| skip_while       | SkipWhile       | 跳过元素，直到闭包返回false。即返回true的都会被跳过。   |      |
| take_while       | TakeWhile       | 取前段元素，直到闭包返回false。即返回true的都会被保留。 |      |
| map_while        | MapWhile        | map元素，直到闭包返回None。即返回Some的都会被保留。     |      |
| skip             | Skip            | 跳过指定数量的元素                                      |      |
| take             | Take            | 取指定数量的元素                                        |      |
| scan             | Scan            | 类似fold，不过是一个adapter                             |      |
| flatten          | Flatten         | 如果元素类型是迭代器，将内部的迭代器层去掉              |      |
| map_windows      | MapWindows      |                                                         |      |
| fuse             | Fuse            |                                                         |      |
| inspect          | Inspect         |                                                         |      |

