# future

## future

```mermaid
classDiagram
	Future	<|.. core_Ready
	Future	<|.. core_Pending
	Future	<|.. core_PollFn
	class Future {
		poll()
	}
	class core_Ready {
		Option~T~
	}
	class core_Pending {
		
	}
	class core_PollFn {
		F
	}
```

## context

```mermaid
classDiagram
	Context --o Waker
	Waker --* RawWaker
	Unpin <|.. Waker
	Send <|.. Waker
	Sync <|.. Waker
	class Unpin {
	
	}
	class Send {
		<<interface>>
	}
	class Sync {
		<<interface>>
	}
	class Context {
		&waker
		waker()
		from_waker()
	}
	
	class Waker {
		RawWaker waker 
		wake()
		wake_by_ref()
		from_raw(RawWaker) waker

	}
	class RawWaker {
		<<interface>>
		data *const
		vtable &'static RawWakerVTable
	}
	
```

- RawWaker就相当`&dyn RawWaker`，由对象指针和虚函数表组成。所以要不同的Waker，就需要创建不同的RawWaker。



## alloc

```mermaid
classDiagram

	Wake ..|> RawWaker : 生成


	class Waker {
	
		from(Arc~Wake+Send+Sync+'static~) Waker
	}
	
	class RawWaker {
		<<interface>>
	}
	class Wake {
		<<interface>>
		wake()
		wake_by_ref()
	}
```

- 用实现了Wake+Send+Sync+'static的结构创建Waker





## futures-task

```mermaid
classDiagram
	WakerRef --* Waker
	ArcWake ..|> RawWaker : 生成
	Send <|.. ArcWake
	Sync <|.. ArcWake
	class WakerRef {
		waker: ManuallyDrop~Waker~
	}
	class Waker {
	
	}
	class Send {
		<<interface>>
	}
	class Sync {
		<<interface>>
	}
	class RawWaker {
		<<interface>>
	}
	class ArcWake {
		<<interface>>
	}
```

- 用实现了Wake+Send+Sync+'static的结构创建Waker
