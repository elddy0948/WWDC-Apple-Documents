# Understanding Swift Performance

올바른 추상화 메커니즘을 선택하는 것은 코드를 만드는 과정, Performance적인 부분에서 많은 영향을 줍니다.

Struct를 사용하여 모델링을 할 것인지? Class를 사용하여 모델링을 할 것인지? 정말 자주하는 고민입니다!



#### 추상화를 설계하고, 추상화 mechanism을 선택할 때 어떤 부분을 고려할 수 있을까?

- 내 instance가 Stack에 할당하는게 좋을까? 아니면 Heap에 할당하는게 좋을까? (Allocation)
- 이 instance를 전달할 때 얼마나 많은 Reference Counting 오버헤드를 발생시킬까? (Reference Counting)
- instance의 메서드를 호출할 때 static하게 dispatch될까 아니면 dynamic하게 dispatch될까?(Method Dispatch)

우리는 빠른 Swift 코드를 작성하고 싶다면 동적인, 런타임에 결정되는 것들을 피해야할 필요가 있습니다. 

또한 더 나은 Performance를 위해 3가지를 적절하게 타협하여 사용할 줄도 알아야 합니다.



## Allocation

Swift는 자동으로 메모리에 allocate, deallocate를 해줍니다. 

우선 Stack을 먼저 살펴보겠습니다. 

Stack은 아주 간단한 데이터구조 입니다. Stack의 끝에 push하고, 마지막에 있는 것을 pop하여 꺼낼 수 있는 LIFO라고도 불리는 데이터구조죠!

이러한 구조를 가지고있기에 Stack에서는 Stack Pointer를 제일 끝에 둡니다. 그래서 어떠한 함수를 호출한다고 가정하면, 그 함수의 공간을 할당하기 위해서 Stack Pointer를 감소(decrement)시켜줍니다. (allocate)

또한 함수가 종료되면, Stack Pointer를 증가(increment)시켜서 해제시켜 주면서 함수를 호출하기 전의 위치로 돌아갑니다. (deallocate)

이번에는 Heap입니다. Stack보다 동적이지만, 효율적이지는 않은 데이터 구조이죠!

Heap은 dynamic lifetime에 메모리 할당을 해주는것 같은 Stack에서는 할 수 없던 기능을 제공합니다. 그렇기에 Heap은 Advanced data structure라고 할 수 있습니다. 

Heap에서 메모리 할당을 하기 위해서는 이 블록이 들어가기에 적당한 사이즈의 사용하지 않는 블록을 Search하여 그곳에 할당하는 즉, 공간을 찾는 과정이 필요합니다. 

(Stack을 사용할 때에는 그저 끝에 있는 Stack Pointer를 감소 / 증가를 통하여 공간을 할당했지만, Heap에서는 더 복잡한 방식으로 공간을 찾는거죠!)

또한 작업이 끝나고 메모리에서 해제 할 경우에는 그 메모리 블록을 적절한 위치에 Reinsert해주는 과정이 또 필요합니다. 

이러한 Stack과 Heap의 Allocate, Deallocate 과정만 비교해봐도 많은 차이가 느껴집니다..!

하지만 Heap에서 고려해야할 더 큰 비용이 더 있습니다. 바로 Thread safety overhead입니다.

여러개의 Thread에서 Heap 메모리에 allocate하기 위해 동시에 접근할 수 있기 때문에 Heap은 무결성(Integrity)을 지키기 위해서 locking이나 다른 동시성(synchronoization) 메커니즘을 활용해야 합니다. 이게 꽤 큰 비용입니다. 

이런 Stack에 할당할지, Heap에 할당할지에 대해서 관심을 기울이는 것 만으로도 앱의 성능 향상에 큰 도움을 줄 수 있습니다. 



WWDC의 예제 코드를 한번 보겠습니다. 

![image](https://user-images.githubusercontent.com/40102795/109605684-e4c71680-7b68-11eb-89e4-8db5c34c9121.png)

구조체로 선언된 Point는 우선 point1과 point2에 대한 공간은 Stack에 이미 할당이 되어있습니다. 또한 Point는 구조체이므로, x와 y가 Stack 내부에 들어있는 모습을 볼 수 있습니다. 

![image](https://user-images.githubusercontent.com/40102795/109605709-f14b6f00-7b68-11eb-9b3d-141506ac5e02.png)다음은 각각 point1 인스턴스와 point2 인스턴스가 생성된 후의 Stack을 나타낸 그림입니다. 우선 이미 할당되어 있던 point1에 대한 공간에 x값과 y값을 각각 0으로 초기화 시켜줍니다. 이후 point2는 point1을 복제(copy)하여 point2의 공간에 할당됩니다. 

point1과 point2는 독립적인 인스턴스임을 명심해야 합니다! 그렇기에 아래줄에 있는 

```swift
point2.x = 5
```

코드를 실행하면 다음 그림과 같이 point2의 x에 대해서만 값의 변경이 일어납니다. 

![image](https://user-images.githubusercontent.com/40102795/109605739-fb6d6d80-7b68-11eb-8d2e-ce537acb1fee.png)

이후 point1과 point2에 대한 사용을 끝내면, deallocate되고 난 후의 Stack은 아래의 그림과 같은 모습이겠죠!

![image](https://user-images.githubusercontent.com/40102795/109605761-02947b80-7b69-11eb-9485-89997fcc2952.png)

아까 Stack에서 설명한 것 처럼, Stack의 Pointer를 증가시켜주면서, point1, point2에 대한 공간을 deallocate해줍니다. 

![image](https://user-images.githubusercontent.com/40102795/109605781-09bb8980-7b69-11eb-9f5a-7b8c37ae05d1.png)

이번에는 class를 사용한 Point입니다. Struct로 만들었을 때와는 다르게 point1과 point2에 대한 공간이 다른것을 볼 수 있습니다. 저 공간은 바로 Heap에 있는 Point를 가르키기 위한 Reference를 저장할 공간입니다. 

![image](https://user-images.githubusercontent.com/40102795/109605800-117b2e00-7b69-11eb-9702-2238b24ecbb2.png)

point1을 생성합니다! 어떤일이 벌어지는지 보이시나요? 우선 point1에서 사용될 Point에 대한 공간을 찾기 위해서 우리의 Swift는 Heap을 lock시킵니다. 그리고선 열심히! 사용하지 않고, 적절한 사이즈를 가진 블록을 찾아서 그곳에 x는 0, y는 0으로 초기화된 Point 공간을 할당하게 됩니다. 그리고 point1은 Heap의 메모리 주소를 참조할 수 있게 됩니다. 

Struct와 비교하여 보면 Point에 대한 공간에 더 많은 공간이 할당된 것을 볼 수 있습니다. 이것은 Swift가 우리를 위해 추가적으로 관리해 주는 공간이라고 볼 수 있습니다. 

![image](https://user-images.githubusercontent.com/40102795/109605816-193ad280-7b69-11eb-8c52-463de605779c.png)

이번에는 point2를 생성합니다! 이전의 구조체와는 다르게 point1 전체를 copy하지는 않습니다. 대신에, point1의 reference를 copy하게 됩니다. 즉, point1과 point2는 Heap메모리에 같은 주소를 참조하고 있게 됩니다. 그렇기 때문에 point2의 x값을 바꾸면 point1의 x값 또한 같이 바뀌게 되는것입니다. 

이후 point1과 point2의 사용이 끝나고 deallocate해주면

![image](https://user-images.githubusercontent.com/40102795/109605838-1fc94a00-7b69-11eb-8ab9-8596d6f8e598.png)

이러한 형태가 됩니다. Heap을 lock하고, 사용한 블록을 적절한 위치에 reinsert하는 과정이 되겠죠? 그 과정이 끝난 후에 Stack을 pop하여 나머지 point1과 point2에 대한 메모리도 해제해줄 수 있게 됩니다. 

지금까지의 내용만 보면... 분명히 Class는 Struct에 비해서 많은 비용이 들어가는 것을 알 수 있습니다. 왜냐하면 Class는 Heap영역에 할당되기 때문이죠. 

하지만 Class에도 Identity, Indirect Storage와 같은 강력한 특성(Characteristics)들이 물론 있습니다! 하지만 이러한 특성들을 사용할 필요가 없다면 Struct를 사용하는 것이 더 효율적입니다. 

![image](https://user-images.githubusercontent.com/40102795/109802357-0ad0e180-7c63-11eb-84e0-a46c0c9af073.png)

또 하나의 예제 코드를 하나 보겠습니다. Message앱에 관한 코드입니다. Message앱에 말풍선을 구현하는 enum이 Color, Orientation, Tail 3가지가 있고, 여러가지 말풍선을 빠르게 읽어와야할 필요성이 있기 때문에(사용자가 스크롤을 엄청 빨리 올리는 경우...)  cache를 사용하여 그부분을 보완하고자 합니다. 

하지만 cache에 주목하면, cache의 key는 현재 String 타입입니다. String 타입을 key로 사용하는 것이 좋을까요? 그냥 "Joons"라는 문자열을 넣어도 그것이 key가 될 수 있습니다. key로 사용하기 좋은 타입이 아니죠! 또한 String은 그 문자열을 구성하는 Content들을 Heap에 저장하고 있습니다. 즉, makeBalloon 함수를 호출할 때마다 Heap영역에 접근하게 됩니다.

이것을 개선할 수 있는 방법은 뭘까요? 바로 Color와 Orientation, Tail을 하나의 구조체로 생성하는 것입니다.

```swift
struct Attributes {
	var color: Color
	var orientation: Orientation
	var tail: Tail
}
```

그럼 다음과 같이 개선할 수 있겠죠!

```swift
var cache = [Attributes: UIImage]()

func makeBalloon(_ color: Color, orientation: Orientation, tail: Tail) -> UIImage {
  let key = Attributes(color: color, orientation: orientation, tail: tail)
}
```

이렇게 만든다면 makeBalloon메서드를 호출할 때 cache에 접근해도 Heap allocation overhead를 더이상 걱정하지 않아도 됩니다. 



## Reference Counting

Swift는 Heap에 할당된 블록을 deallocate할 때 어떤 방식을 통해 deallocate해도 안전하다는 판단을 할까? 

Swift는 instance의 Heap 메모리 총 참조 횟수를 카운팅하고 있다. 그 카운팅은 해당 instance가 직접 들고있다. reference를 추가하거나, reference를 제거할 때 reference count는 증가하거나 감소한다. 만약 그 카운트가 0이면, Swift는 이 instance를 아무도 가르키고 있지 않다고 판단할 수 있으며, 안전하게 메모리에서 deallocate할 수 있습니다. 

생각해야할 것은, Reference Counting은 상당히 빈번하게 일어나는 작업이며, 단순 증가, 감소만이 아닌 다른 많은 일들이 일어난다. 대표적으로 직접 포인터를 따라가서 Reference Count를 증가, 감소 시키기 위한 몇가지의 Indirection 과정이 필요하고, Thread Safety overhead Heap allocation과정이고, 여러 Thread에서 동시에 접근할 수 있기 때문에, Reference Count를 atomically하게 증가, 감소시켜줄 필가 있습니다. 

Reference Counting이 정말 빈번하게 일어나는 작업임을 감안하면, 비용이 어마어마해질 수 밖에 없을것입니다.

```swift
class Point {
  var x, y: Double
  func draw() { ... }
}
let point1 = Point(x: 0, y: 0)
let point2 = point1
point2.x = 5
```

위에서 살펴보았던 Point 클래스 입니다. 이것이 실제 Swift가 실행할때 생성되는 코드가 어떤지 보면

```swift
class Point {
  var refCount: Int
  var x, y: Double
  func draw() { ... }
}
let point1 = Point(x: 0, y: 0)
let point2 = point1
retain(point2)
point2.x = 5
//use point1
release(point1)
//use point2
release(point2)
```

Point클래스 내부에 refCount라는 Int형식의 변수가 생겼습니다. 또한, retain과 release가 일어나는 모습을 확인할 수 있습니다. retain과 release는 각각 Reference Count를 증가, 감소 시키는 기능을 포함하고 있습니다. 

```swift
let point1 = Point(x: 0, y: 0)
```

이 부분을 실행시키면, 아래의 그림과 같은 모습이 됩니다. 

<img src="https://user-images.githubusercontent.com/40102795/109680923-4ebeda80-7bc0-11eb-8a7c-2bc5703fb8a4.png" alt="image" style="zoom:33%;" />

Heap메모리에 Point가 할당되고, Reference Count가 1 증가하게 됩니다. 왜냐하면 point1이 해당 Reference를 가리키고 있기 때문이죠!

```swift
let point2 = point1
retain(point2)
```

<img src="https://user-images.githubusercontent.com/40102795/109681398-c4c34180-7bc0-11eb-9bcf-bc4812bf380d.png" alt="image" style="zoom:33%;" />

이 두줄의 코드를 실행시키면, let point2 = point1의 부분에서 point2가 point1의 Reference를 복사하고, retain(point2)와 함께, Referecne count가 증가하게 됩니다. 

```swift
release(point1)
```

<img src="https://user-images.githubusercontent.com/40102795/109681680-11a71800-7bc1-11eb-9f82-d4467e86bbf0.png" alt="image" style="zoom:33%;" />

위의 release(point1)과 함께, point1의 reference가 사라지고, Swift는 Reference Count를 감소시킵니다. 

```swift
release(point2)
```

<img src="https://user-images.githubusercontent.com/40102795/109681948-52069600-7bc1-11eb-9403-496ff253b03e.png" alt="image" style="zoom:33%;" />

동일하게 point2도 reference가 사라지고, Swift는 Reference Count를 감소시키는 작업을 합니다. 

그렇게 Reference Count가 0이 되면, Swift는 Heap을 lock하고, 사용한 블록을 메모리로 리턴해도 안전하다는 판단을 할 수 있게 됩니다. 



구조체에서의 Reference Counting? 구조체는 Heap allocation이 일어나지 않기 때문에 Reference Count가 없습니다. Reference Counting overhead가 없는것이죠!

하지만 복잡한 구조체를 보면 아래의 코드를 보면, Label이라는 구조체 내부에 String타입의 text, UIFont타입의 font라는 프로퍼티를 가지고 있습니다.

```swift
struct Label {
  var text: String
  var font: UIFont
  func draw() {...}
}
let label1 = Label(text: "Hi", font: font)
let label2 = label1

//use label1
//use label2
```

String의 경우에는 문자열에 해당하는 content들을 Heap영역에 저장이 된다고 앞부분에서 살펴보았습니다. 이 말은, text를 사용할때 Reference Counting이 일어난다는 의미입니다. 

또한 UIFont도 class입니다. 그렇다면 font 역시 Reference Counting이 일어난다고 볼 수 있겠군요!

```swift
let label1 = Label(text: "Hi", font: font)
let label2 = label1
```

위 코드를 실행시키면 메모리 영역의 모습은 다음 그림과 같습니다. 

<img src="https://user-images.githubusercontent.com/40102795/109798396-09e98100-7c5e-11eb-9542-c7bf252b50b3.png" alt="image" style="zoom:33%;" />

text는 그 문자를 저장하고 있는 Heap 영역의 어딘가를 가르키고 있을 것이고, font역시 font가 저장되어 있는 Heap영역을 가르키고 있을 것 입니다.

그래서 Swift는 이러한 호출들을 retain과 release를 통해서 관리할 것입니다. 

```swift
let label1 = Label(text: "Hi", font: font)
let label2 = label1
retain(label2.text._storage)
retain(label2.font)
//use label1
release(label1.text._storage)
release(label1.font)
//use label2
release(label2.text._storage)
release(label2.font)
```

즉, 이 코드는 String과 UIFont에 대한 두번의 Reference Counting작업을 하게 됩니다.

아무리 Struct라고 해도, 내부에 Reference를 포함하고 있다면, 결국 Reference Counting overhead에 대한 비용을 지불해야 합니다. 내부에 가지고 있는 Reference의 개수와 비례해서 말이죠. 그래서 하나보다 많은 Reference를 가지고 있다면, Reference Counting overhead는 class보다 많은 비용을 지불해야 할 것 입니다. 

또다른 예제 코드를 보겠습니다.

```swift
struct Attachment {
  let fileURL: URL
  let uuid: String
  let mimeType: String
  
  init?(fileURL: URL, uuid: String, mimeType: String) {
    guard mimeType.isMimeType else {
      return nil
    }
    self.fileURL = fileURL
    self.uuid = uuid
    self.mimeType = mimeType
  }
}
```

이 코드는 많은 Reference Counting이 일어날 것 입니다. 이유는 fileURL의 URL 타입, uuid와 mimeType의 String타입이 모두 Heap에 접근해야 하는 타입들이죠! Attachment 인스턴스를 사용할때 한번에 Reference Counting이 3번이나 일어날 수 있다는 것을 의미합니다. 

하지만! 이것을 개선해 볼 수 있습니다. 우선 uuid를 보면, uuid는 128비트로 랜덤하게 생성된 식별자의 역할을 합니다. 그래서 uuid같은 경우에는 아무거나 uuid에 넣기를 원치 않죠 예를들어 uuid가 "joons" 가 된다거나... 그래서 Swift는 2016년에 UUID를 위한 새로운 Value Type인 UUID를 선보였죠! 그것을 사용하면 개선할 수 있겠군요!

```swift
struct Attachment {
  let fileURL: URL
  let uuid: UUID
  let mimeType: String
  
  init?(fileURL: URL, uuid: UUID, mimeType: String) {
    guard mimeType.isMimeType else {
      return nil
    }
    self.fileURL = fileURL
    self.uuid = uuid
    self.mimeType = mimeType
  }
}
```

짜잔! 이제 uuid 프로퍼티의 타입은 UUID 즉, 값타입이므로 Heap에 접근할 필요가 없어집니다. 

이번에는 mimeType을 볼까요?

```swift
guard mimeType.isMimeType else { 
  return nil
}
```

여기서 isMimeType을 보면 아래의 코드와 같이 구성이 되어있다고 하네요!

```swift
extension String {
  var isMimeType: Bool {
    switch self {
      case "image/jpeg":
	      return true
      case "image/png":
      	return true
      case "image/gif":
      	return true
      default:
      	return false
    }
  }
}
```

mimeType은 정해져있습니다. JPEG, PNG, GIF 로 말이죠 Swift에는 이미 이렇게 정해져있는 것들을 표현해주는 좋은 기능이 하나 있죠 바로 enumeration입니다. 바로 적용해보면

```swift
enum MimeType: String {
  case jpeg = "image/jpeg"
  case png = "image/png"
  case gif = "image/gif"
}
```

우선 enum으로 mimeType이 될 수 있는 후보를 정해놓으면 기존의 String타입을 사용했을 때 보다 더 Type Safety하겠죠! 또한 performance적인 측면에서도 개선되었습니다. 더이상 각각의 case들을 Heap에 저장하지 않아도 되기 때문이죠!

```swift
struct Attachment {
  let fileURL: URL
  let uuid: UUID
  let mimeType: MimeType
  
  init?(fileURL: URL, uuid: UUID, mimeType: String) {
    guard let mimeType = MimeType(rawValue: mimeType) else {
      return nil
    }
    self.fileURL = fileURL
    self.uuid = uuid
    self.mimeType = mimeType
  }
}
```

이제 Heap에 접근해야 하는 경우는 fileURL밖에 남지 않았습니다. performance적인 측면에서 정말 많은 개선이 되었죠! 더이상 uuid와 mimeType은 Heap allocation되어 있지도, Reference Counting overhead를 걱정해야 할 필요도 없어졌습니다. 



## Method Dispatch

Method를 런타임에 호출하면, Swift는 올바른 메서드를 실행시켜야합니다. 만약 **컴파일 타임에 실행시키기에 올바른 메서드인지 결정지을 수 있다면 그것을 Static Dispatch라고 부릅니다.** 그리고 런타임에 그냥 올바른 실행문으로 jump하여 실행할 수 있게 됩니다. 컴파일러가 어떤것이 실행되기에 올바른 것인지 알 수 있다는 부분에서 정말 좋은 기능입니다. 그래서 우리는 **inlining**을 활용하여 코드를 꽤 적극적으로 최적화할 수 있습니다. 

**Dynamic Dispatch는 컴파일 타임에 바로 어떤 실행문이 실행될지 결정할 수 없고, 런타임에 어떤 실행문이 맞는지 테이블을 확인하게 됩니다. (Look up implementation in table at run time) 그래서 실제로 런타임에 실행문을 찾아서 그곳으로 jump 합니다.** 그래서 Dynamic Dispatch가 Static Dispatch보다 그리 비싼 비용을 들이진 않습니다. 하나의 indirection 단계가 더 있을 뿐이죠. 하지만 Dynamic Dispatch는 컴파일러의 가시성(visibility)를 막기 때문에, 컴파일러가 Static Dispatch에서 하던 최적화 작업들을 Dynamic Dispatch에서는 할 수 없게 됩니다. (Prevents inlining and other optimizations)

```swift
struct Point {
  var x, y: Double
  func draw() {
    //Point.draw implementation
  }
}
func drawAPoint(_ param: Point) {
  param.draw()
}
let point = Point(x: 0, y: 0)
drawAPoint(point)
```

**inlining이란 무엇일까?** 위의 코드에서 drawAPoint 함수와 point.draw 메서드는 둘다 Statically dispatched입니다. Statically Dispatched의 의미는 컴파일러가 어떤 실행문을 실행시켜야할지 알 수 있다는 의미입니다.  그래서 기존의 drawAPoint(point) 부분을 그냥 point.draw()로 대체해도 상관이 없습니다. 혹은 Point.draw 실행문을 그대로 가져와 대체해도 상관이 없습니다. 어떤 draw()가 실행될지 이미 알기 때문이죠! 

위 코드를 실행시키면 런타임에서는 그냥 Stack에서 point를 구성할 수 있고, 실행문을 실행시키고, 끝낼 수 있습니다. Static Dispatch에 대한 overhead나 관련 설정은 필요하지 않습니다. Static Dispatch가 Dynamic Dispatch보다 빠를 수 밖에 없는 것입니다. 

하나의 Static Dispatch와 Dynamic Dispatch를 두고 비교를 한다면 큰 차이는 없습니다. 하지만 모든 Static Dispatch들의 chain을 두고 보면, 컴파일러는 그 Static Dispatch들의 chain에 대한 모든 Visibility를 가질 수 있습니다. 

그에반해 Dynamic Dispatch의 chain은 하나하나 모두 상위 레벨에서 block 시켜놓습니다.

따라서 컴파일러는 Static Method Dispatches chain을 콜 스택 오버헤드 없이 단일 구현으로 축소할 수 있습니다. 



**그럼 왜 Dynamic Dispatch를 사용해야 할까요?**

아래의 코드를 한번 살펴보겠습니다. 

```swift
class Drawable { func draw() {} }
class Point: Drawable {
  var x, y: Double
  override func draw() { ... }
}
class Line: Drawable {
  var x1, y1, x2, y2: Double
  override func draw() { ... }
}
var drawables: [Drawable]
for d in drawables {
  d.draw()
}
```

우선 첫번째 이유는 Polymorphism. 다형성의 힘입니다. 전통적인 OOP형식의 프로그램을 보면 위의 코드와 같이 Drawable이라는 superclass가 존재하고 Point subclass와 Line subclass를 정의할 수 있습니다. 

```swift
var drawables: [Drawable]
```

<img src="https://user-images.githubusercontent.com/40102795/109832517-c144be80-7c83-11eb-910e-ee1da2234345.png" alt="image" style="zoom:33%;" />

drawables 배열의 모습입니다. Line도 포함할 수 있고, Point도 포함할 수 있겠죠, 그리고 각각의 draw 메서드 또한 호출할 수 있을 것입니다. 이게 어떻게 동작할까요? 

Drawable과 Point, Line이 모두 클래스라서 배열 내부에는 Reference만 저장하면 끝이므로 모두 같은 사이즈를 가지고 있을 것입니다. 아래와 같은 그림이겠죠!

<img src="https://user-images.githubusercontent.com/40102795/109833187-65c70080-7c84-11eb-83b7-a3df88f6e5e3.png" alt="image" style="zoom:33%;" />

이제 draw메서드를 호출하는 부분으로 가보겠습니다.

```swift
for d in drawables {
  d.draw()
}
```

우리는 여기서 컴파일러가 왜 컴파일타임에 어떤 실행문을 실행해야 한다는 것을 결정할 수 없는지 이해할 수 있습니다. 왜냐하면 여기서 d.draw() 가 Point의 draw()가 될 수도 있고, Line의 draw()가 될 수도 있으며 그들은 다른 코드 경로를 가지고 있기 때문입니다. 어떻게 어떤것을 호출할지 결정할 수 있을까요? 

컴파일러는 클래스들에 어떤 다른 필드를 추가합니다. 그것은 클래스에 대한 타입 정보를 가르키는 필드입니다. 아래의 그림과 같이 말이죠. 

<img src="https://user-images.githubusercontent.com/40102795/109834120-3795f080-7c85-11eb-9173-0c131ccccadb.png" alt="image" style="zoom:33%;" />

그리고 이것은 static memory에 저장됩니다. 그래서 draw 메서드를 호출할때, 컴파일러가 실제로 생성하는 것은 타입들을 조회할 수 있는 타입이나 Static Memory에 있는 Virtual Method Table이라고 하는 것을 찾아봅니다. 

이 Virtual Method Table에는 실행할 실행문을 가리키는 포인터가 존재합니다. 그래서 실제로 코드는 이렇게 동작합니다.

```swift
for d in drawables {
  d.type.vtable.draw(d)
}
```

그러면 위의 그림에서 처럼 Line의 메서드를 찾고 있으므로, Line.Type의 draw: 필드는 실제 Line클래스의 override func draw(_ self: Line) 에 대한 위치를 가리키고 있습니다. 그것을 파라미터로 실제 인스턴스를 전달하면서 Line의 draw메서드를 호출하게 되는 것입니다. 



여기서 나타난것 처럼 **클래스는 기본적으로 그들의 메서드를 Dynamically Dispatch 합니다.** 이것이 자체적으로 큰 차이를 만들어내지는 않지만, 메서드 채이닝이나 다른 인라인 같은 최적화를 막을 수 있습니다. 

모든 클래스가 Dynamic Dispatch를 필요로 하지는 않습니다. 만약에 클래스의 서브클래스를 만들길 원치 않는다면, final 키워드를 활용하여 컴파일러가 이것을 확인하고 그 메서드들을 Statically dispatch 할 것 입니다. 더 나아가 컴파일러가 이 클래스를 서브클래싱 하지 않을 것이라는 추론하고 증명할 수 있다면, 기회를 보고 Dynamic Dispatch들을 대신하여 Static Dispatch해줄 것 입니다. 



## 정리

그렇기에 우리는 코드를 작성 할 때마다 이런 생각을 해야합니다. 

- 이 인스턴스가 어디에 할당될까? Stack? Heap?
- 인스턴스를 전달할 때 Reference Counting overhead가 많이 일어날까?
- 이 인스턴스로 해당 메서드를 호출하면 static dispatch일까? Dynamic dispatch일까?

만약에 우리가 이러한 dynamism을 위해 비용을 지불하지 않아도 괜찮은데도 비용을 들이고 있다면 그것은 performance 측면에서 hurt할 것입니다. 

하나의 물음이 더 있습니다. 바로 "How does one go about writing polymorphic code with structs?" 다형성을 가지는 코드를 구조체로 어떻게 작성될 것인가? 에 대한 의문이군요! 이것의 정답이 바로 **Protocol Oriented Programming**이라고 합니다!!!(멋짐)

