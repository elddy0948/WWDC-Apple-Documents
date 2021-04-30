# WWDC17 Engineering for Testability

## Testable App Code

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

Scalable test code?