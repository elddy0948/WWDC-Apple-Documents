# WWDC17 Engineering for Testability

# Testable App Code

How a test suite could help during the development of my app.

How it could provide confidence, that the code i was writing was working the way it was supposed to. How it could help patch regressions in my code as my app grew and changed over time. And how it could serve as executable documentation for my code.

## Structure of a Unit Test

```swift
func testArraySorting() {
	let input = [1, 7, 6, 3, 10]
	let output = input.sorted() 
	XCTAssertEqual(output, [1, 3, 6, 7, 10])
}
```

정렬되지 않은 input 배열과, 그 input 배열은 `sorted()`메서드를 호출한다. 그리고 return된 배열을 output에 넣고 그것을 `XCTAssertEqual()` 을 사용하여 예상한 결과와 같은지 본다.

이 과정을 종합해 본다면

- Prepare input : 테스트에서 필요로하는 input state나 value를 선언합니다.
- Run the code being tested : 테스트 될 코드를 호출합니다.
- Verify output : 반환된 output이 옳은지 asserting합니다.

이 과정은 Arrange Act Assert Pattern이라고 나타내어지기도 합니다.  하지만 위의 예시와는 다르게 대부분의 앱의 코드에서는 sorting algorithm 와는 다른 모습을 하고있죠.

## Characteristics of Testable Code

그럼에도 불구하고, 이 정렬 메서드에는 몇가지 우리 앱의 코드를 더욱 더 testable하게 만들 수 있는 특징들이 있습니다.

- Control over inputs : 특히 Testable한 코드는 클라이언트에게 실행될 모든 input들을 제어할 수 있는 방법을 제공합니다.
- Visibillity into outputs : 클라이언트가 어떤 output이 생성될 지 점검할 수 있는 방법을 제공합니다.
- No hidden state : 또한 나중에 code의 행동에 영향을 미칠 수 있는 internal state 에 의존하는 것 또한 피할 수 있습니다.

## Testability Techniques

이 두가지 기술들을 통해 위에서 살펴보았던 3가지 특징들을 가질 수 있고, 그것의 Testability를 증진시킬 수 있습니다.

- Protocols and parameterization
- Separating logic and effects

## Protocols and Parameterization

How to introduce protocols and parameterization into a piece of code.

첫번째 예시 코드를 보겠습니다.

```swift
@IBAction func openTapped(_ sender: Any) {
	let mode: String
	switch segmentedControl.selectedSegmentIndex {
		case 0: mode = "view"
		case 1: mode = "edit"
		default: fatalError("Impossible case")
	}
	let url = URL(string: "myappscheme://open?id=\\(document.identifier)&mode=\\(mode)")!

	if UIApplication.shared.canOpenURL(url) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
	} else { 
		handleURLError()
	} 
}
```

이벤트 핸들러가 Open Button이 눌러졌을 때 이 메서드를 실행시킬 것입니다.

이것을 테스트 하는 방법에는 두가지 방법이 있죠! 첫번째는 UI test가 될 것입니다. app을 실행시켜서 직접 Open 버튼을 누르는 것이죠. 하지만 UI test를 진행할 시 단점이 있습니다. 우선 실행하는데에 시간이 좀 걸릴 것입니다. 특이하게 만약 내가 많은 여러가지 document를 다른 open mode로 열려고 한다면 시간이 많이 걸리겠죠.

그러나 제일 큰 문제는 UI test는 iOS switch app들에 요청 할 URL이 잘 생성되었는지 검증할 방법이 없습니다.

그래서 Unit test가 이 상황에 가장 알맞다고 생각이 드네요! 그럼 Unit test를 작성해 볼까요?!

```swift
func testOpensDocumentURLWhenButtonIsTapped() {
	let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Preview") as! PreviewViewController
}
```

먼저! 우리는 test하고자 하는 view controller의 인스턴스가 필요합니다. 이 부분에서는 UI가 Storyboard로 만들어졌기 때문에 위와 같이 가져오도록 합니다.

```swift
controller.loadViewIfNeeded()
controller.segmentedControl.selectedSegmentIndex = 1
```

다음에는 control property를 채우기 위해서 우리는 view를 load할 필요가 있겠죠! 그래서 view data로 채워지고 난 후에 open mode를 위해 설정을 해줍니다.

```swift
controller.document = Document(identifier: “TheID")
controller.openTapped(controller.button)
```

작업할 document를 등록하고, 이러한 setup이 다 끝나고나면 test될 메서드를 호출합니다. 바로 `openTapped()` 이죠! 그런데 이제 어떤 코드를 작성해야할까요? 어떠한 Assertion을 할 지 명확하지가 않습니다.

실행문으로 돌아가보겠습니다. 우선 첫번째로 View Controller에만 속해있는 것이 메서드들을 테스트하기 더 어렵게 만듭니다.  작업할 view controller 인스턴스를 갖기 위해 몇개의 hoop들을 지나와야 하죠.

그리고 바로 이 부분!

```swift
switch segmentedControl.selectedSegmentIndex {
```

우리는 지금 input state를 view에게서 직접 당겨오고 있습니다. 이것은 test 할 때 view를 load하도록 강제하고 있죠. and then indirectly provide the input by setting a property on some sub-view.

```swift
UIApplication.shared
```

제일 큰 문제는 여기입니다. UIApplication의 shared인스턴스의 사용입니다. 여기서 반환되는 `canOpenURL(url)` 의 호출은 메서드의 다른 input에게 영향을 줄 수 있습니다.

이러한 Global system state를 사용하면서부터 이 쿼리에 의 결과에 대한 Control을 test를 할 수 있는 programmatic한 방법이 존재하지 않습니다.

`open(url, options: [:], completionHandler: nil)` Unit test는 이 코드에서 URL을 열 때 발생할 수 있는 Side effect를 관찰할 수 있는 좋은 방법도 존재하지 않습니다.

실제로 이 `openTapped(_ sender: Any)` 메서드를 실행하면, 테스트를 진행중인 앱은 Background로 보내질 것이고, 이를 다시 Foreground로 불러올 수 있는 방법은 존재하지 않죠. 이 코드의 testability를 향상시킬 수 있는 방법에 대해서 알아보겠습니다.

### Improve Testability

우리는 먼저 이 메서드를 view controller로 부터 꺼낼 수 있습니다.

```swift
class DocumentOpener {
 enum OpenMode: String {
	 case view
	 case edit
 }
 func open(_ document: Document, mode: OpenMode) {
	 let modeString = mode.rawValue
	 let url = URL(string: "myappscheme://open?id=\\(document.identifier)&mode=\\(modeString)")!
	 if UIApplication.shared.canOpenURL(url) {
		 UIApplication.shared.open(url, options: [:], completionHandler: nil)
	 } else {
		 handleURLError()
	 }
 }
}
```

Document Open에 관련된 로직과 행동을 캡슐화한 새로운 `DocumentOpener` 클래스를 생성합니다.

```swift
func open(_ document: Document, mode: OpenMode)
```

`OpenMode`와 `Document`를 파라미터로 넘겨주면서 test시 indirectly하게 값들을 전달해줄 수 있는 메서드가 만들어졌습니다.

이제 `UIApplication.shared` 를 사용하는 문제가 남았습니다.

우선 메서드 내에서 직접적으로 접근하는 방식을 없애도록 합니다. 클래스에 이니셜라이저로 두어서 우리가 그 UIApplication 인스턴스를 전달할 수 있게 만드는 방법이 있겠죠.

```swift
class DocumentOpener {
 let application: UIApplication
 init(application: UIApplication = UIApplication.shared) {
	 self.application = application
 }
 /* … */
}
```

그리고 위의 코드처럼 default 값을 줄 수도 있습니다. 그리고 open 메서드로 내려가보면,

```swift
class DocumentOpener {
 /* … */
 func open(_ document: Document, mode: OpenMode) {
	 let modeString = mode.rawValue
	 let url = URL(string: "myappscheme://open?id=\\(document.identifier)&mode=\\(modeString)")!

	 if application.canOpenURL(url) {
		 application.open(url, options: [:], completionHandler: nil)
	 } else {
		 handleURLError()
	 }
 }
}
```

이제 더이상 `UIApplication.shared` 를 사용하지 않고, `application` 으로 대체할  수 있게 됩니다.

UIApplication을 서브클래싱하여 canOpenURL과 open 메서드를 오버라이드하여 사용하는 방법을 떠올릴 수 있겠지만, UIApplication은 Singleton형태가 강제되어 있습니다.

```swift
protocol URLOpening {
	func canOpenURL(_ url: URL) -> Bool
	func open(_ url: URL, options: [String: Any], completionHandler: ((Bool) -> Void)?)
}

extension UIApplication: URLOpening {
}
```

Protocol을 만들어보면 UIApplication의 메서드와 동일한 형태의 2개의 메서드를 가지게 만듭니다. 그리고 우리는 `UIApplication`이 `URLOpening` 이라는 프로토콜을 구현하게 하고 싶습니다. 그렇기에 `extension` 을 활용하여 `UIApplication`이 `URLOpening` 프로토콜을 준수하게 만들었습니다.

기존에 UIApplication에 구현되어 있는 메서드와 protocol의 메서드가 **정확히 일치**하기 때문에 extension에 프로토콜 준수를 위한 다른 코드를 작성할 필요는 없습니다.

이제 DocumentOpener 클래스로 돌아와서 프로토콜을 활용하여 더이상 UIApplication 자체를 필요로하지 않게 만들어 볼 수 있습니다.

우선 프로퍼티와 이니셜라이저를 URLOpening프로토콜을 준수하는 어떠한 실행문도 받아들일 수 있게 바꿔줍니다.

```swift
class DocumentOpener {
  let urlOpener: URLOpening
	init(urlOpener: URLOpening = UIApplication.shared) {
	  self.urlOpener = urlOpener
  }
	/* … */
}
```

이니셜라이저에 `UIApplication.shared` 를 default 값으로 여전히 남겨놓았습니다. 이는 나중에 view controller에서 사용할 때에 편리함을 위해서 남겨두는 것입니다.

마지막으로 기존에 application으로 사용되었던 부분을 urlOpener로 바꿔주면 됩니다.

```swift
class DocumentOpener {
 func open(_ document: Document, mode: OpenMode) {
	 let modeString = mode.rawValue
	 let url = URL(string: "myappscheme://open?id=\\(document.identifier)&mode=\\(modeString)")!

	 if urlOpener.canOpenURL(url) {
		 urlOpener.open(url, options: [:], completionHandler: nil)
	 } else {
		 handleURLError()
	 }
	}
}
```

이제 테스트로 돌아와보면 기존에 UIApplication은 우리가 테스트시 필요한 Control을 제공해주지 못해서 URLOpening 프로토콜을 상속한 Mock을 만들어 봅니다. 그리고 `canOpenURL` 과 `open` 에 대한 sub-implementation을 추가해줍니다.

```swift
class MockURLOpener: URLOpening {
	 var canOpen = false
	 var openedURL: URL?

	 func canOpenURL(_ url: URL) -> Bool {
		 return canOpen
	 }

	 func open(_ url: URL,
	 options: [String: Any],
	 completionHandler: ((Bool) -> Void)?) {
		 openedURL = url
	 }
}
```

우선 `canOpenURL` 은 input처럼 동작을 합니다. 그래서 이 test는 이 input을 어떻게 Control 할것인지를 구현해 줄 필요가 있죠. 그래서 이 input을 담아줄 property인 `canOpen` 을 선언하고 반환해 줍니다.

그리고 `open` 메서드는 Document Opener의 output처럼 동작하게 됩니다. 테스트는 이 메서드로 패스된 어떤 URL에 대해서 접근이 가능한지 알아보는 테스트입니다. 그래서 `openedURL` 이라는 프로퍼티를 생성하여 URL을 저장해줍니다. 나중에 읽을 수 있게 말이죠.

자! 이제 테스트를 작성해보러 가겠습니다. 우선 우리는 아까 만들어 두었던 `MockURLOpener`의 인스턴스를 생성합니다. 그리고 그곳에 만들어 두었던 input으로 사용될 `canOpen` 프로퍼티에 접근해줍니다.

그리고 우리는 documentOpener 인스턴스를 생성하여 urlOpener를 넘겨줍니다. 모든 세팅이 끝나면 이제 `open` 메서드를 호출합니다. document와 open mode를 전달하여 줍니다. 그리고 MockURLOpener의 openURL 프로퍼티와 예상했던 URL이 같은지 Assert해줍니다.

```swift
func testDocumentOpenerWhenItCanOpen() {
	 let urlOpener = MockURLOpener()
	 urlOpener.canOpen = true
	 let documentOpener = DocumentOpener(urlOpener: urlOpener)
	 documentOpener.open(Document(identifier: "TheID"), mode: .edit)
	 XCTAssertEqual(urlOpener.openedURL, URL(string: "myappscheme://open?id=TheID&mode=edit"))
}
```

이런 테스트 코드가 작성될 수 있겠죠!

이 리팩토링 과정을 정리해본다면

- Reduce references to shared instances : 직접적으로 UIApplication의 싱글턴 인스턴스를 사용하던 것을 빼주고
- Accept parameterized input : 그것을 parameterized input으로 대체해 주었습니다. 이를 defendency injection이라고도 합니다.
- Introduce a protocol : 이전에 의존하였던 concrete class로부터 프로토콜을 사용하여 코드를 분리시켰습니다.
- Creating a testing implementation

## Separating Logic and Effects

다음은 Effects로부터 Logic을 분리시켜 testability를 향상시키는 방법에 대해서 보도록 하겠습니다.

이번 예시는 OnDiskCache 클래스입니다. 이것은 이전에 서버에서 다운로드 한 적이 있는 Asset들에 대해서 앱에서 빠르게 찾아서 가져올 수 있게 할 때 사용하는 것입니다.

```swift
class OnDiskCache {
	 struct Item {
	 let path: String
	 let age: TimeInterval
	 let size: Int
	 }
	 var currentItems: Set<Item> { /* … */ }
	 /* … */
}
```

프로퍼티는 위의 코드와 같습니다. 그리고 메서드도 확인해 보겠습니다.

```swift
class OnDiskCache {
 /* … */
	 func cleanCache(maxSize: Int) throws {
		 let sortedItems = self.currentItems.sorted { $0.age < $1.age }
		 var cumulativeSize = 0
	
		 for item in sortedItems {
			 cumulativeSize += item.size
			 if cumulativeSize > maxSize {
				 try FileManager.default.removeItem(atPath: item.path)
			 }
		 }
	 }
}
```

`cleanCache`라는 메서드입니다. cache를 cleanUp 하는 역할을 가진 메서드이죠. 이 메서드를 주기적으로 호출해주면서 Cache가 File System에서 너무 많은 공간을 차지하지 않겠다는 보장을 하기위한 것입니다.

이 메서드를 어떻게 테스트할 수 있을까요?

우선 인풋, 인풋은 어떤게 올 수 있을까요? cleanCache 메서드에서 파라미터로 받고 있는 `maxSize`가 우선 인풋이 될 수 있겠죠! 두번째 인풋은 최근에 Cache에 저장된 아이템들의 리스트입니다. `currentItems`이죠. 하지만 이 currentItems는 File Manager를 통해서 가져올 수 있는 목록입니다. 즉 지금 테스트에서 필요로 하는 인풋은 File System으로 부터 얻어지는 것입니다. 의존관계가 생기는 것이죠.

그리고 cleanCache 메서드는 반환 값이 없습니다. 그래서 아웃풋이 데이터가 될 수 없죠. Rather, it's the side effect of a certain set of files having been removed from the disc.

이러한 File System에 대한 의존 때문에 이 메서드를 위한 테스트는 File Manager의 File System을 다루어야 한다는 것입니다.

그래서 Setup으로는 임시 디렉토리를 생성해야하고, 특정한 사이즈의 파일들로 채워 넣어야 합니다. 그리고 Timestamp를 줘서 input을 제공하게 만들어 줘야 합니다.

아웃풋을 검증하기 위해서는 어떤 파일이 아직 있는지를 확인하기 위해서 File System을 반환해 줄 필요가 있습니다.

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/c8e567d3-9ffa-4247-ab05-5fe1ddd8c62b/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/c8e567d3-9ffa-4247-ab05-5fe1ddd8c62b/Untitled.png)

이를 해결할 수 있는 방법 중 하나는 앞서 살펴보았던 Protocol 과 Parameterization 기술을 사용하는 것입니다. 하지만 이런 방법을 사용하더라도 우리가 테스트 하려는 코드는 결국 File Manager에 의해서 중재되고 있습니다.

We could take our clean cache method and factor out the logic responsible for deciding while files should be removed, the cleanupPolicy, which you can then interact with more directly.

```swift
protocol CleanupPolicy {
	func itemsToRemove(from items: Set<OnDiskCache.Item>) -> Set<OnDiskCache.Item>
}
```

우선 명확하게 테스트를 위해 사용하기 위한 API를 정의하기 위해서, CleanupPolicy Protocol을 정의해야 합니다. 여기서 `itemsToRemove` 라는 메서드를 가지는데 인풋으로 item의 Set를 받고, item의 Set를 반환해 줍니다. 여기서 반환되는 item의 Set는 제거된 후의 items입니다.

```swift
struct MaxSizeCleanupPolicy: CleanupPolicy {
	 let maxSize: Int

	 func itemsToRemove(from items: Set<OnDiskCache.Item>) -> Set<OnDiskCache.Item> {
		 var itemsToRemove = Set<OnDiskCache.Item>()
		 var cumulativeSize = 0
		 let sortedItems = allItems.sorted { $0.age < $1.age }

		 for item in sortedItems {
			 cumulativeSize += item.size

			 if cumulativeSize > maxSize {
				 itemsToRemove.insert(item)
			 }
		 }
	 return itemsToRemove
	 }
}
```

우선 max size 인풋을 받을 프로퍼티인 `maxSize` 를 선언합니다. 다음은 Protocol에서 필요로 하는 `itemsToRemove` 메서드를 선언해 줍니다. 다음은 메서드로 전달된 item들을 점검하고, `itemsToRemove` 라는 프로퍼티를 선언하여 제거 할 item들을 build-up합니다. 그리고 마지막에 메서드가 종료될 때 이것을 리턴해 줍니다.

다음은 Set를 채우기 위해 item들을 최신순으로 정렬하여 `sortedItems` 에 담아줍니다. 그리고 각각의 item size를 모두 더해줍니다. 그러다가 maximum size에 도달하면 그 뒤에 아이템들은 제거대상이 됩니다. `itemsToRemove` Set에 담아줍니다.

이렇게 코드를 만들면 아까전 보다 Data input과 output이 명확해 지는것을 확인할 수 있습니다.

```swift
func testMaxSizeCleanupPolicy() {
	 let inputItems = Set([
		 OnDiskCache.Item(path: "/item1", age: 5, size: 7),
		 OnDiskCache.Item(path: "/item2", age: 3, size: 2),
		 OnDiskCache.Item(path: "/item3", age: 9, size: 9)
	 ])
	 let outputItems = MaxSizeCleanupPolicy(maxSize: 10).itemsToRemove(from: inputItems)
	 XCTAssertEqual(outputItems, [OnDiskCache.Item(path: "/item3", age: 9, size: 9)])
}
```

이제 Test를 작성할 수 있습니다. 우선 항상 처음에는 input이 있어야겠죠! `inputItems`를 생성해줍니다. MaxSizeCleanupPolicy에 대한 인스턴스를 생성해줍니다. 그리고 메서드를 바로 호출하여서 필요한 값들을 넘겨줍니다. 그 반환값을 `outputItems` 에 저장합니다. 그리고 그 값과 예상한 값이 일치하는지 Asserting합니다. 테스트 코드가 완성되었습니다!

```swift
class OnDiskCache {
 /* … */
	 func cleanCache(policy: CleanupPolicy) throws {
		 let itemsToRemove = policy.itemsToRemove(from: self.currentItems)
		 for item in itemsToRemove {
			 try FileManager.default.removeItem(atPath: item.path)
		 }
	 }
}
```

그럼 이제 OnDiskCache 클래스의 cleanCache 메서드는 다음과 같이 수정될 수 있겠죠!

이 테스트를 진행하면서 우리는 File Manager에 대한 Protocol을 구현하고 testable한 코드를 구현함으로서 매우 독립적인 unit test를 작성할 수 있게 하였습니다.

그리고 이 예시에서 우리는 Side Effects를 활용하여 Business Logic 과 Algorithms를 타입들로 분리하는 방법을 알아보았습니다.

- Extract algorithms : we looked at how to extract business logic and algorithms into separate types, away from the code, using side effects.
- Functional style with value types : the algorithms tend to take on a rather functional style, using value types to describe the inputs and the outputs.
- Thin layer on top to execute effects : We're left with a small amount of code that perform side effects based on the computer data.

# Scalable Test Code

앞서 우리는 앱의 코드를 testable하게 만들 수 있는 몇가지 기술들을 살펴보았습니다. 이번에는 이 코드를 scalable하게 만들 수 있는 방법에 대해 알아보려고 합니다. (Code Coverage에 관한 이야기인가? 🧐 )

우선 테스트 코드를 Scalable하게 만들기 위해서는 테스트를 빠르게, 읽기 쉽게, modularized할 수 있는 몇가지 메서드에 대해서 살펴보아야 합니다.

- Balance between UI and unit tests
- Code to help UI tests scale
- Quality of test code

## Striking the right balance between UI and unit tests

View my distribution of tests as a Pyramid. 테스트를 Pyramid형태로 보는 것.

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/d6845e04-84b2-46d2-99c3-39a669b5390b/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/d6845e04-84b2-46d2-99c3-39a669b5390b/Untitled.png)

맨 꼭대기를 UI Test, 제일 아래를 Unit Test라고 볼 수 있습니다. 이 피라미드 형태를 잘 보면 **Unit Test는 UI Test보다 훨씬 많겠죠!** 그 이유는 **Unit Test의 속도가 UI Test보다 훨씬 빠르기 때문**이죠! 물론 UI Test와 Unit Test 사이에 **Integration Test** 또한 존재합니다. 하지만 오늘 세션에서는 UI Test와 Unit Test에 대해서 다룬다고 합니다!

그리고 반대편에는 Maintenance(유지) Costs도 피라미드 형태로 나타낼 수 있습니다. 일반적으로 UI Test의 Maintenance Cost가 높습니다. 그 이유는 UI Test중에는 많은 일들이 일어날 가능성이 있기 때문이죠. 반면에 Unit Test는 적은 Maintenance cost가 발생합니다. 그래서 Unit test가 실패하면 그 즉시 어느 부분이 잘못되었다는 것을 알 수 있죠.

물론 모든 UI Test와 Unit Test가 이 피라미드에 해당한다고 말할 수는 없죠! 이 피라미드 형태는 단지 Good Approximation(근사치)라고 할 수 있습니다. 그래서 이 두가지의 테스트를 고려할 때 두가지 테스트 각각의 강점을 파악해야 합니다.

- Unit tests great for testing small, hard-to-reach code paths : Unit test는 작은 단위의 코드를 테스트 하거나, 테스트 하는 부분을 코드로 접근하지 않으면 안되는 상황일 때 유리합니다.
- UI tests are better at testing integration of larger pieces : 반면에 UI test는 함께 동작하는 거대한 코드에 대한 테스트를 할 때 유리합니다.

물론 Unit test가 UI test에서는 불가능한 앱의 모든 소스코드에 접근할 수 있다는 측면을 기억해야합니다.

UI Test에 초점을 맞춰서 테스트 코드의 퀄리티를 높일 수 있는 몇가지 방법에 대해서 알아보도록 하겠습니다. 앞으로 알려줄 방법을 통해 테스트 코드를 작성해 나가면 테스트의 Scale을 넓힐 수 있을 것입니다.

## Code to Help UI Tests Scale

- Abstracting UI element queries
- Creating objects and utility functions
- Utilizing keyboard shortcuts

### Abstracting UI element queries

```swift
app.buttons["blue"].tap()
app.buttons["red"].tap()
app.buttons["yellow"].tap()
app.buttons["green"].tap()
app.buttons["purple"].tap()
app.buttons["orange"].tap()
app.buttons["pink"].tap()
```

View Controller에 위와 같은 여러개의 버튼이 있습니다. 그리고 버튼들은 모두 같은 View 계층에 있죠. 다른것이라면 버튼의 이름이 다릅니다. 이 부분을 7번 작성하는 것 보다, 메서드로 묶어보도록 하겠습니다.

```swift
func tapButton(_ color: String) {
	 app.buttons[color].tap()
}
tapButton("blue")
tapButton("red")
tapButton("yellow")
tapButton("green")
tapButton("purple")
tapButton("orange")
tapButton("pink")
```

이렇게 만들어질 수 있겠죠! 그러나 좀 더 발전시켜 보겠습니다. 메서드가 이름만 다르게 들어가서 여러번 호출되는 부분이 거슬리죠! 그 이름들을 배열로 만들어서 넣고, 반복문을 돌리도록 해보겠습니다.

```swift
let colors = ["blue", "red", "yellow", "green", "purple", "orange", "pink"]
for color in colors {
	 tapButton(color)
}
```

좋아요! 유지 관리 부분에서도 훨씬 좋은 코드가 되었습니다. 나중에 새로운 버튼을 추가할 때에는 그냥 새로운 버튼의 이름만 배열에 추가해주면 만들어 지는 것입니다.

- Store Parts of queries in a variable
- Wrap complex queries in utility methods
- Reduces noise and clutter in UI test

UI Test의 특성상 우리는 이러한 쿼리를 많이 발생시키는 것을 문제 삼아야 합니다. 그래서 만약 같은 쿼리를 여러번 사용하고 있다면, 그것을 변수로 저장할 필요가 있습니다. 그게 정말 작은 부분일지라도 말이죠. 어디에 저장해두어야 합니다. 또한 아주 비슷한 쿼리가 있다면, 그것을 Helper 메서드를 활용하여 생성하는 것을 고려해보아야 합니다.

그럼 코드가 더욱 Clean해지고, Readable해집니다.

그래서 Scaling our test suite부분에서 본다면, 적은 라인의 코드, 고심해서 만들어낸 Helper 메서드들이 빠르고 쉬운 새로운 테스트를 만들 수 있게 도와줄 것입니다. 이것이 Abstracting UI element queries였습니다.

### Creating objects and utility functions

예시 코드를 보면서 살펴보겠습니다.

```swift
func testGameWithDifficultyBeginnerAndSoundOff() {

	 app.navigationBars["Game.GameView"].buttons["Settings"].tap()
	 app.buttons["Difficulty"].tap()
	 app.buttons["beginner"].tap()
	 app.navigationBars.buttons["Back"].tap()
	 app.buttons["Sound"].tap()
	 app.buttons["off"].tap()
	 app.navigationBars.buttons["Back"].tap()
	 app.navigationBars.buttons["Back"].tap()

	 // test code
}
```

이 코드는 Scalable code의 좋은 예가 아니라고 할 수 있습니다. 이 코드는 작성한 사람은 알아볼 수 있는 코드이지만, 나중에 다른 사람, 코드를 처음 보는 사람이 보게된다면 이게 무슨 동작을하는 코드인지 모르겠죠!

그리고 이런 테스트 코드를 작성한다면, UI에 조금 변경이 생기면 테스트 코드가 잘 동작하지 않을 가능성이 큽니다.

이를 고치기 위해서, Helper 메서드들로 추상화 해보겠습니다.

```swift
func setDifficulty(_ difficulty: String) {
	 app.buttons["Difficulty"].tap()
	 app.buttons[difficulty].tap()
	 app.navigationBars.buttons["Back"].tap()
}

func setSound(_ sound: String) {
	 app.buttons["Sound"].tap()
	 app.buttons[sound].tap()
	 app.navigationBars.buttons["Back"].tap()
}
```

이렇게 Difficulty를 설정하는 메서드와 Sound를 설정하는 메서드로 나누어볼 수 있겠죠. 더 좋게 만들어볼 수 있을까요? difficulty와 sound를 enum으로 만들어볼 수 있죠! 난이도는 정해져있고, sound도 on/off로 정해져있기 때문이죠!

```swift
enum Difficulty {
	 case beginner
	 case intermediate
	 case veteran
}
enum Sound {
	 case on
	 case off
}
func setDifficulty(_ difficulty: String) {
	 // code
}
func setSound(_ sound: String) {
	 // code
}
```

이런 코드가 완성이됩니다! 이제 아까전에 봤던 코드로 돌아가 보겠습니다.

```swift
func testGameWithDifficultyBeginnerAndSoundOff() {

	 app.navigationBars["Game.GameView"].buttons["Settings"].tap()
	 setDifficulty(.beginner)
	 setSound(.off)
	 app.navigationBars.buttons["Back"].tap()

	 // test code

}
```

와우~ 확실하게 줄어들었어요! 읽기도 편해졌습니다! 나머지 부분도 개선해보고 싶은데 계속 가보겠습니다!

```swift
class GameApp: XCUIApplication {
	 enum Difficulty { /* cases */ }
	 enum Sound { /* cases */ }

	 func setDifficulty(_ difficulty: Difficulty) { /* code */ }

	 func setSound(_ sound: Sound) { /* code */ }

	 func configureSettings(difficulty: Difficulty, sound: Sound) {
		 app.navigationBars["Game.GameView"].buttons["Settings"].tap()
		 setDifficulty(difficulty)
		 setSound(sound)
		 app.navigationBars.buttons["Back"].tap()
	 }
}
```

`GameApp` 이라는 클래스를 선언하고, 그안에 `Difficulty`와 `Sound` enum을 선언합니다. 그리고 아까 작성했던 `setDifficulty` 메서드와 `setSound` 메서드를 가져오고, `configureSettings` 라는 메서드를 추가합니다.

그럼! 이제 테스트 코드에서는 호출 하나면 해결이 되겠죠!

```swift
func testGameWithDifficultyBeginnerAndSoundOff() {
	 GameApp().configureSettings(difficulty: .beginner, sound: .off)
	 // test code
}
```

전보다 훨씬 Readable한 테스트가 만들어졌습니다. 이제 나중에 Setting을 사용하는 테스트를 만들 일이 있으면, 간단하게 코드 한줄로 해결할 수 있게 되었습니다. 그리고 다른 Setting 부분을 사용하는 테스트를 만들고 싶다면, 메서드를 수정하고 업데이트만 하면 끝나게 됩니다.

### (이제까지 와서 Scale이라는 의미를 생각해 보았는데! Code Coverage라고 처음에 생각했지만 확장성에 더 가까운 것 같다. )

테스트를 Scale하려고할 때 가장 중요한 부분 중 하나는 나중에 put into a library suite할 수 있는 추상화를 생성하는 것이다. 이를 함으로써

- Encapsulate common testing workflows : 공통적인 작업흐름을 캡슐화 할 수 있고 그것이 여러개의 테스트에도 적용될 수 있게 한다.
- Cross-platform code sharing : 다른 플랫폼들에 test code를 공유할 수 있다는 의미이기도하다.
- Improves maintainability : 그리고 당연히 코드를 공유함으로써 유지 보수 측면에서도 향상시킬 수 있는 것이다.

그리고 하나 더 보여주고 싶은 부분은 2017년에 새로운 Xcode의 기능인 `XCTContent.runActivity` 를 활용하는 방법이다.

```swift
class GameApp: XCUIApplication { NEW
	 enum Difficulty { /* cases */ }
	 enum Sound { /* cases */ }
	 func setDifficulty(_ difficulty: Difficulty) { /* code */ }
	 func setSound(_ sound: Sound) { /* code */ }

	 func configureSettings(difficulty: Difficulty, sound: Sound) {
		 XCTContext.runActivity(named: “Configure Settings: \\(difficulty), \\(sound)”) { _ in
			 app.navigationBars["Game.GameView"].buttons["Settings"].tap()
			 setDifficulty(difficulty)
			 setSound(sound)
			 app.navigationBars.buttons[“Back"].tap()
		 }
	 }
}
```

이것을 활용하면 우리가 테스트를 실행시켰을 때 우리가 만들었던 top level에서 일어나는 액션까지 모두 로그로 기록하는 것이 아니라, 원하는 곳만 묶어서 로그로 남길 수 있다.

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/7597d9dd-9e60-4d53-aa69-c7e4cf3f3978/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/7597d9dd-9e60-4d53-aa69-c7e4cf3f3978/Untitled.png)

## Utilizing keyboard shortcuts (macOS UI Tests)