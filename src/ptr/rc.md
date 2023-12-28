# Rc



## Rc

### 重点

- Rc是用Box申请的内存。
- Rc全部释放后，就调用drop。
- Weak全部释放后，才释放内存。
- Rc是`!Send`，`!Sync`的。
- Rc实现了`Receiver`，可以做self的类型。
- Rc实现了`Unpin`特征，移动是安全的。



## UniqueRc

### 重点

- 没实现clone特征。
- 可以转换为Rc
- 也可以有多个Weak引用。
