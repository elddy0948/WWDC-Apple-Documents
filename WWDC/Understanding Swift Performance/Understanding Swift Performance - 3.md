# Understanding Swift Performance - 3

이번에는 Generic을 활용한 Performance적인 부분을 한번 살펴보도록 하겠습니다. 



```swift
// Drawing a copy
protocol Drawable {
  func draw()
}
func drawACopy(local : Drawable) {
  local.draw()
}
```

Drawable이라는 프로토콜 타입을 파라미터로 받는 drawACopy 메서드가 있습니다. 

우리가 이것을 사용할때에는 아래의 코드와 같이 사용하겠죠?

```swift
// Drawing a copy
protocol Drawable {
  func draw()
}
func drawACopy(local : Drawable) {
  local.draw()
}

let line = Line()
drawACopy(line)
//...
let point = Point()
drawACopy(point)
```

코드를 보면 항상 정해진 타입(concrete type)을 사용해야 한다는 점을 확인할 수 있습니다. Drawable 프로토콜을 채택한 타입만이 파라미터로 들어갈 수 있다는 의미이죠.

여기서 한번 생각해 볼 수 있습니다. 코드를 좀 더 Generic하게 만들어볼 수 없을까?

할 수 있습니다. 바로 Generic을 활용한 방법이죠. 다음 코드를 한번 보겠습니다. 

```swift
// Drawing a copy using a generic method
protocol Drawable {
 func draw()
}
func drawACopy<T: Drawable>(local : T) {
 local.draw()
}

let line = Line()
drawACopy(line)
// ...
let point = Point()
drawACopy(point)
```

drawACopy메서드는 이제 Drawable프로토콜을 준수하는 타입만 들어올 수 있다는 generic parameter를 받고있습니다. 나머지는 이전의 코드와 같습니다. 무엇이 달라진걸까요? 

Generic Code는 parametric polymorphism이라 불리는 Static한 형태의 다형성(polymorphism)을 지원합니다. 

```swift
func foo<T: Drawable>(local : T) {
 bar(local)
}
func bar<T: Drawable>(local: T) { … }
let point = Point()
foo(point)
```

One type per call context. 이게 무슨 의미일까요? 위의 코드를 보겠습니다. 

foo라는 함수가 있습니다. 이 함수는 Drawable 프로토콜 타입을 준수하는 타입을 받을 수 있고, 파라미터를 받아서 bar함수로 던져줍니다. bar라는 함수 역시 Drawable 프로토콜 타입을 준수하는 타입을 받을 수 있는 함수입니다. 

그다음에 point라는 상수를 만들어 foo라는 함수에 파라미터로 던져주게 됩니다. 

이 함수가 실행될때 Swift는 generic type인 T를 호출될때의 타입으로 bind하게 됩니다. 이 상황에서는 Point가 되겠네요 

```swift
foo<T = Point>(point)
```

이렇게 말이죠! foo 함수가 이 binding과정과 함께 실행이 되면, bar함수를 호출하겠죠? 

bar 역시 마찬가지로 call context 안에는 지금 가지고 있는 타입은 Point이므로,  generic parameter인 T가 Point가 됩니다. 

```swift
bar<T = Point>(local)
```

여기서 주목해야할 점은 Type이 call chain을 따라 내려가면서 substituted된다는 부분입니다. 이것이 여기서 말하는 polymorphism의 static한 형식 또는 parametric polymorphism을 뜻합니다. 

Swift가 어떻게 실행되는지 한번 확인해 보겠습니다. 

```swift
func drawACopy<T : Drawable>(local : T) {
 local.draw()
}
drawACopy(Point(…))
```

One shared implementation. 우리가 Protocol타입을 사용할 때 하나의 실행문(implementation)을 공유하게 됩니다. 그리고 이는 어떠한 타입의 메서드인지 확인해야하기 때문에 Protocol Witness Table, Values Witness Table을 사용해야 합니다.  그러나 One type per call context 덕분에 Swift는 existential container를 사용하지 않을 수 있습니다. 대신에 이 call site에서 추가적인 argument로써 Point의 VWT와 PWT를 전달합니다. 

<img src="/Users/kimhojoon/Library/Application Support/typora-user-images/image-20210307161809752.png" alt="image-20210307161809752" style="zoom:50%;" />

그래서 이 상황에서는 위와 같은 그림이 나오는 것이죠!

<img src="https://user-images.githubusercontent.com/40102795/110232436-fccfd900-7f60-11eb-883b-30666789304b.png" alt="image" style="zoom:50%;" />

그리고 이 메서드를 실행하는 동안에 파라미터에 대한 로컬 변수를 만들면 

<img src="/Users/kimhojoon/Library/Application Support/typora-user-images/image-20210307162133762.png" alt="image-20210307162133762" style="zoom:50%;" />

Swift는 Value Witness Table를 활용하여 필요한 모든 Buffer를 Heap에 할당하고 원본에서 destination으로 복사본을 만듭니다. 그리고 비슷하게 draw메서드를 호출하면

<img src="https://user-images.githubusercontent.com/40102795/110232511-6d76f580-7f61-11eb-95ba-5bd849c94036.png" alt="image" style="zoom:50%;" />

Protocol Witness Table을 사용하여 draw 메서드를 찾아내겠죠! 그리고 실행문으로 jump할 것 입니다. 여기 실행되는 과정동안에 existential container는 없었습니다. 그렇다면, 저 파라미터로 인해 생겨난 로컬 변수는 어디에 할당될까요?

<img src="https://user-images.githubusercontent.com/40102795/110232575-de1e1200-7f61-11eb-870f-17edffe1682b.png" alt="image" style="zoom:50%;" />

바로 stack에 있는 valueBuffer에 할당되겠죠! Point와 같은 작은 Value이면 valueBuffer에 그대로 들어가겠죠! Line과 같은 큰 Value는 Heap에 할당되구요! 로컬 변수와 관련한 과정은 모두 value witness table에서 이루어지겠죠! 



정말 궁금한 부분이 좀 많습니다. 앞서 살펴보았던 existential container에서 VWT, PWT, valueBuffer가 존재했었는데 우선 지금의 설명에서는 existential container를 사용하지 않는다는 것을 강조하고 있습니다. 우선 의문을 남겨두고 다음 부분을 보겠습니다.



여기까지 오면서 의문을 가질 수 있습니다. 그래서 이게 빠른거야? 이 방법이 더 나은가?

static한 polymorphism은 컴파일러로 하여금 Specialization of Generics을 최적화 가능하게 합니다. 한번 보겠습니다. 

```swift
func drawACopy<T : Drawable>(local : T) {
 local.draw()
}
drawACopy(Point(…))
```

여기 또 한번 drawACopy 함수입니다. 

여기에 Static polymorphism이 있습니다 즉, call site에서 하나의 타입만이 존재합니다. 

그렇게 Point 타입을 drawACopy의 파라미터로 하여 호출을 하면, 

```swift
func drawACopyOfAPoint(local: Point) {
	local.draw()
}
drawACopyOfAPoint(Point(...))
```

이렇게 Swift는 받아온 해당 타입을 활용해서 함수에서 Generic 매개변수를 대체하고, 해당 타입 버전의 함수의 만들어 냅니다. 

그럼 Line을 호출하면

```swift
func drawACopyOfAPoint(local : Point) {
 local.draw()
}
func drawACopyOfALine(local : Line) {
 local.draw()
}
drawACopyOfAPoint(Point(…))
drawACopyOfALine(Line(…))
```

이렇게 Line 버전의 drawACopyOfALine가 생성되게 됩니다. 두가지 버전의 함수가 생성되는 것이죠! 

잠깐! 이렇게 하면, 코드의 사이즈를 증가시킬 가능성이 있지 않나? 라는 의문을 가질 수 있을 것입니다. 하지만 컴파일러의 aggressive한 optimization가 가능하기 때문에 Swift는 오히려 코드의 사이즈를 줄일 수 있습니다. 

```swift
func drawACopyOfAPoint(local : Point) {
 local.draw()
}
func drawACopyOfALine(local : Line) {
 local.draw()
}
let local = Point()
local.draw()
drawACopyOfALine(Line(…))
```

Can be more compact after optimization.  최적화 이후에 더 소형화 될 수 있습니다. 위의 코드는 아래로 바꿀 수 있을 것이고

```swift
func drawACopyOfAPoint(local : Point) {
 local.draw()
}
func drawACopyOfALine(local : Line) {
 local.draw()
}
Point().draw()
drawACopyOfALine(Line(…))
```

이제 draw 함수는 더이상 reference하지 않습니다. 그렇기에 컴파일러는 위의 코드를 다 지워버릴 수 있죠

```swift
Point().draw()
Line().draw()
```

위의 코드들은 모두 specialization의 과정입니다. 그럼 이런 specialization은 언제 발생할까요?

```swift
//main.swift
struct Point { … }
let point = Point()
drawACopy(point)
```

Point라는 struct를 생성하여 Point의 인스턴스를 만들어서 drawACopy메서드를 호출하는 코드를 볼 수 있습니다. 

Swift는 여기서 코드를 Specialization하기 위해서 call-site의 타입을 추론할 수 있어야 합니다. 여기서는 point가 Point로 초기화 되어있으니 Swift는 이를 보고 타입 추론이 가능해집니다. 

Swift는 또한 specialization 과정에서, 사용된 타입과 Generic기능 자체를 사용할 수 있는 함수를 정의 해야합니다. 

여기서는 main.swift파일에서 안에서 정의 되어 있지만, 다른 파일로 옮겼다고 가정해봅시다. 

```swift
//Point.swift
struct Point {
 func draw() {}
}
```

```swift
//UsePoint.swift
let point = Point()
drawACopy(point)
```

이 두 파일을 개별적으로 컴파일하면 UsePoint 파일을 컴파일 하러 왔을 때 Point에 관한 정의는 더이상 유효하지 않다는 것입니다. 왜냐하면 컴파일러가 두개의 파일을 각각 컴파일 했기 때문이죠. 그러나 whole module optimization과 함께라면 

![image](https://user-images.githubusercontent.com/40102795/110233227-f8f28580-7f65-11eb-913c-aa355af28807.png)

컴파일러는 두 파일을 하나의 unit으로 보고 두개의 파일을 함께 컴파일하게 됩니다. 그러면 Point에 관한 정의를 볼 수 있게 되겠죠. 이러한 멋진 발전 덕분에 XCode 8 부터의 whole module optimization을 통한 다양한 성능 향상이 가능해 졌습니다. 

아까 그 코드로 돌아와볼까요?

```swift
// Pairs in our program
struct Pair {
 init(_ f: Drawable, _ s: Drawable) {
 first = f ; second = s
 }
 var first: Drawable
 var second: Drawable
}
let pairOfLines = Pair(Line(), Line())
//...
let pairOfPoint = Pair(Point(), Point())
```

여기서 Line의 경우에는 valueBuffer에 맞지 않기 때문에 Heap allocation이 별도로 필요했고, 별도의 indirect storage도 없기 때문에 2번의 Heap allocation이 발생하게 됩니다. 여기서 Generic을 사용한다면?!

```swift
// Pairs in our program using generic types
struct Pair<T : Drawable> {
 init(_ f: T, _ s: T) {
 first = f ; second = s
 }
 var first: T
 var second: T
}
let pairOfLines = Pair(Line(), Line())
// ...

let pairOfPoint = Pair(Point(), Point())
```

Generic으로 바꾸어봤습니다. 잘 보면 같은 타입 즉 Point, Point 혹은 Line, Line 이렇게만 들어갈 수 있다는 사실을 확인할 수 있습니다. 

우선 타입을 런타임에는 바꿀 수 없다는 것을 기억하면서 계속 보겠습니다. 

```swift
// Pairs in our program using generic types
struct Pair<T : Drawable> {
 init(_ f: T, _ s: T) {
 first = f ; second = s
 }
 var first: T
 var second: T
}
var pair = Pair(Line(), Line())
```

<img src="https://user-images.githubusercontent.com/40102795/110233387-09efc680-7f67-11eb-88be-86ce3691ec88.png" alt="image" style="zoom:50%;" />

2개의 Line 인스턴스가 Pair라는 타입에 묶여있는 모습을 볼 수 있습니다. 추가적인 Heap allocation이 필요하지 않은 상황입니다.  또한 pair.first = Point() 와 같은 것도 안됩니다. 

여기서 잘 보면 우선 Pair의 T들은 전부다 Line으로 바뀌게 되겠죠 바로 specialization 과정을 통해서요! 그렇기 때문에 existential container 가 필요없어 지고 stack에 바로바로 프로퍼티들을 저장할 수 있는 것 같네요!



### Specialized Generics - Struct Type

Performance characteristics like struct types 

- No heap allocation on copying
- No reference counting 
- Static method dispatch



### Specialized Generics - Class Type

Performance characteristics like class types

- Heap allocation on creating an instance
- Reference counting
- Dynamic method dispatch through V-Table



### Unspecialized Generics—Small Value

- No heap allocation: value fits in Value Buffer

- No reference counting 

- Dynamic dispatch through Protocol Witness Table



### Unspecialized Generics—Large Value

- Heap allocation (use indirect storage as a workaround) 

- Reference counting if value contains references 

- Dynamic dispatch through Protocol Witness Table





### Summary

Choose fitting abstraction with the least dynamic runtime type requirements 

- struct types: value semantics

- class types: identity or OOP style polymorphism

- Generics: static polymorphism

- Protocol types: dynamic polymorphism 

Use indirect storage to deal with large values