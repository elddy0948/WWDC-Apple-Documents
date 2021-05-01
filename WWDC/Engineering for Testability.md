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

`cleanCache`라는 메서드입니다. cache를 cleanUp 하는 역할을 가진 메서드이죠.

