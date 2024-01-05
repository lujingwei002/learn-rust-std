# 适配器



| -               | -                                                       | -    |
| --------------- | ------------------------------------------------------- | ---- |
| Chain           | 连接两个迭代器                                          |      |
| Zip             | 将两个迭代器合并，元素变成(&iter1::Item, &iter2::Item)  |      |
| Intersperse     | 有迭代元素中，插入元素，变成 [1,插入元素,2,插入元素,3]  |      |
| IntersperseWith | 有迭代元素中，插入元素，变成 [1,插入元素,2,插入元素,3]  |      |
| Map             |                                                         |      |
| for_each        |                                                         |      |
| Filter          | 过滤元素，如果闭包返回true则保留                        |      |
| FilterMap       | 过滤元素，如果闭包返回Some则保留                        |      |
| Enumerate       |                                                         |      |
| Peekable        | 在调用next方法前，可以用peek方法查看元素，但不会消耗它  |      |
| SkipWhile       | 跳过元素，直到闭包返回false。即返回true的都会被跳过。   |      |
| TakeWhile       | 取前段元素，直到闭包返回false。即返回true的都会被保留。 |      |
| MapWhile        | map元素，直到闭包返回None。即返回Some的都会被保留。     |      |
| Skip            | 跳过指定数量的元素                                      |      |

