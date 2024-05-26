# 构造函数

Rust中没用构造函数，但看标准库中可以看到很多`new`，`from`开头的关联方法。可以理解为它都是构造对象的函数。

由于Rust没有重载，所以有很多new方法和from方法，比如new，new_in，new_uninit，new_zeroed，from，from_utf8等等。

但和c++的构造函数不一样，new，from的返回值可以自定义的，比如可以返回result，或者option表示失败。



From特征也可以算是构造函数，但from关联方法不一样，返回值是固定的，不能返回result表示失败，如果想表示失败，可以用TryFrom特征。
