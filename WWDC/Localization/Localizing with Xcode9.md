# WWDC17 - Localizing with Xcode9

전 세계에서 많은 사람들이 우리들이 만든 앱을 찾고 있을수도 있습니다. 하지만 우리가 만든 앱이 그들의 언어로 작성되어있지 않다면? 스페인 개발자가 제작한 멋진 앱이 있는데 스페인어를 할줄 모르는 저는 사용할 수가 없겠죠! 

이번 세션에서는 Xcode가 이러한 현상을 해결하기 위해 새로운 언어들을 추가하여 우리가 만든 앱을 local하게 느껴지게, 그리고 global한 시장으로 진출할 수 있게 만들어주는 방법에 대한 소개를 해준다고 합니다! 



## Internationalization

Internationalization은 앱에 언어를 추가할때마다 그에 따른 코드를 작성할 필요 없이 다른 언어와 지역에 따라서 소프트웨어가 적응할 수 있게 해주는 과정입니다. 여기서 포인트는 앱이 어느 언어로 돌아가고 있는지는 상관이 없다는 것입니다. 

언어가 짧은 텍스트, 긴 텍스트, 높은 텍스트 또한 어떤 언어는 오른쪽에서 왼쪽으로 읽어가야하는 텍스트가 있기도 합니다. 우리의 앱은 이러한 상황에 맞게 dynamically하게 적응해야 합니다. 



### Strings Management

Internationalization의 첫번째 step은 바로 strings를 관리하는 것입니다. 

여러분의 앱에서 사용되는 string들은 번역가들을 통해서 localized 될것이고, 이 localized string은 여러분의 번역가들에게 정확한 위치에 텍스트가 보여지게 해주는 localizable content를 생성하기 쉽게 도와줄 것입니다.  **(Use NSLocalizedString to load strings in code)**

그래서 storyboard나 xib 파일에서 오는 strings는 기본적으로 localized되어 있습니다. 그래서 그것들에 대해서는 걱정할 필요가 없습니다. 

그러나 가끔 소스코드에 정의되어있는 유저들에게 보여질 strings가 분명히 있을 것입니다. (예를 들어서 label.text = "Hello" 같은 것들이죠!) 그래서 이러한 것들도 localizable하게 만들어 줘야 합니다. 이것을 하기위해서 우리는 그 문자열을 **NSLocalizedString** 으로 감싸주면 됩니다. 

게다가 format string과 localized language format을 함께 NSLocalizedString에 사용해주면 localized된 formatted string을 얻을 수 있습니다. 

```swift
//label.text = "Population"
label.text = NSLocalizedString("Population", comment: "Label preceding the population value")

label.text = NSLocalizedString("Population", tableName: "Localizable", bundle: .main, value: nil, comment: "Label preceding the population value")

let format = NsLocalizedString("%d popular languages", comment: "Number of popular languages")
label.text = String.localizedStringWithFormat(format, popularLanguages.count)
```

처음에 그저 "Population"이라는 문자열만 적혀있었지만 이것을 NSLocalizedString을 사용하여 표현할 수 있으며 comment를 작성하여 번역자로 하여금 이 context가 정확하게 무엇을 의미하는지 의미전달이 잘 될 수 있게 해줘야 합니다. 

그리고 어떤 상황에서는 framework에서 작업을 하고있거나, shared component에 작업을 하고 있다면 여러분이 지정한 table에서 해당 string을 가져와 사용할 수 있습니다. 

마지막으로 Format과 Localized String을 사용하는 방법입니다. **comment를 정확하게 적어주는 것은 정말 중요한것이라고 계속 강조하네요!**



그런 다음 런타임에 NSLocalizedString은 사용자의 기본 언어를 결정하고 그에 맞는 localizable string file을 가져옵니다. 

```swift
//Localizable.strings

/* Title label's text */
"International Facts" = "Faits Internationaux";

/* Label prompting a user to choose a territory */ 
"Territory" = "Territoire";
```

strings 파일을 열어보면 위와 같이 적혀있습니다. 좌측에는 개발언어(영어) 그리고 우측에는 그에 맞는 번역된 언어(프랑스어) 이는 프랑스 Localization 프로젝트에서 온 것이고, 이는 localizable string 모두를 포함하고 있습니다. (NSLocalizedString 으로 감싸진 것들이죠!)



### Formatting

다음으로 고려해야 할 사항은 바로 date, time, numbers 등에 대한 Format입니다. 예를들어 12-hour time format이 표준인 미국과 24-hour time format이 표준인 프랑스는 표현 방식이 달라야겠죠! (미국에서는 오후 6시 40분을 6:40 으로 나타내지만 프랑스는 18:40으로 나타냄)

하지만 우리에겐 강력한 formatter들이 존재하죠! 이러한 복잡한 format형식에 어려워 할 필요가 없습니다. 날짜를 표현할 때 우리는 이런 코드를 작성할 수 있습니다.

```swift
let formatter = DateFormatter()
formatter.dateFormat = "EEEE, MMMM d, yyyy"
let str = formatter.string(from: date)
```

하지만 이렇게 dateFormat을 고정시켜버리면 날짜를 표시하는 방법이 다른 나라에서는 불편하겠죠! 그래서 dateFormat이 아닌 dateStyle를 사용해야 합니다. 

```swift
let formatter = DateFormatter()
formatter.dateStyle = .full
let str = formatter.string(from: date)
```

이렇게 말이죠!



### User Interface

마지막으로 여러분의 User Interface에서 앱이 지원하는 모든언어가 깔끔하고 보기좋게 보여지게 하려면 이 User Interface에 대한 부분은 아주 중요합니다. 이 과정은 매우 간단합니다. 

바로 기본적인 Internationalization(base internationalization)과 auto layout을 사용하면 됩니다. 

우선 base internationalization에 대해서 이야기 해보겠습니다. 

![image](https://user-images.githubusercontent.com/40102795/112584201-bb816980-8e3a-11eb-982e-0d7928dcdf21.png)

우선 이렇게 프로젝트에서 Base Internationalization을 활성화 하면 Xcode는 당신의 프로젝트를 Destructor를 위해 수정하고, UI와 strings를 분리시킵니다. 즉, User Interface와 관련된 파일(스토리보드 파일이나 .xib파일 등)이 Base.lproj에 저장될것입니다. 그리고 스토리보드나 코드에서 가져온 NSLocalizedString으로 감싸진 문자열들은 그에 해당하는 언어의 폴더에 자동으로 들어가게 될 것입니다. 

<img width="958" alt="image" src="https://user-images.githubusercontent.com/40102795/112584828-f6d06800-8e3b-11eb-8c12-b591ecfeade7.png">

이렇게 말이죠! ru는 러시아어, en은 영어입니다! 이렇게 간단하게 Base Internationalization 을 통해서 언어를 추가할 때마다 새로운 UI를 중복해서 생성하는 대신 아주 간단하게 여러 언어에 따른 UI를 생성해낼 수 있습니다. 



그리고 Auto Layout입니다. 오토레이아웃은 아주 친근한 녀석이죠! 오토레이아웃을 이미 다른 크기의 디바이스에 유연하게 적응하기 위해서 많이 사용하고 있죠. 하지만 이 오토레이아웃은 Localization에서도 아주 중요한 기술로 사용됩니다.

오토레이아웃을 사용하여 언어마다 문자의 길이가 다른 경우나 다른 구성을 가진 문자들에 대하여 유연하게 대처할 수 있게 됩니다. 이 오토레이아웃을 테스트 하는 방법 중 하나는 바로 스토리보드에서 Preview를 활용하는 방법인데요 

<img width="303" alt="image" src="https://user-images.githubusercontent.com/40102795/112585627-87f40e80-8e3d-11eb-8941-e86c5f9978c1.png">

이렇게 Psuedolanguage를 활용하여 앱을 직접 실행시키지 않고도 현재 UI에서 언어가 바뀌면 어떻게 적용될지 확인할 수 있습니다. 



## Localization Workflow

이 Localization Workflow 부분에 대해서는 Xcode10에서 바뀌는 부분이 있으니 Xcode9에서 소개된 StringsDict와 Localization 언어를 설정하는 부분에 대해서만 살펴보겠습니다! 

우선 Localization 할 언어를 등록하는 과정은 간단합니다. 이전에 Base Internationalization을 활성화 했던 그 부분 위에 있습니다. 

![image](https://user-images.githubusercontent.com/40102795/112586159-9abb1300-8e3e-11eb-9bfb-192eda3e41c1.png)

여기서 + 버튼을 눌러서 Localization하고자 하는 언어를 선택하여 등록할 수 있습니다. 

그렇게 하면 Xcode에서 자동으로 Resource들을 (스토리보드, info.plist, strings, 등등)의 파일들을 그 언어 용으로 하나 만들어줍니다. 그래서 그 파일들에 들어가서 그 언어에 맞게 직접 번역을 한 다음에 Export 과정을 거칩니다. 이는 Xcode9 에서는 바로 XLIFF 파일을 각각 언어마다 생성해 줍니다. (Xcode10에서는 다름.) 그렇게 다시 그것을 Import해주면 Localization은 끝나게 됩니다. 

여기서! Resource들 중에 Stringsdict라는 파일 포멧이 Xcode9에서 생겼습니다. 아주 중요한 역할을 하는 녀석인데요! 한번 알아보겠습니다. 

우선 Stringsdict는 복수형 포멧을 다룰 수 있게 됩니다. Stringsdict를 사용하면서 기존에 코드로 처리해주던 복수형태의 복잡한 스트링의 형태들을 간단하게 다룰 수 있게 되었죠. 

```swift
if popularLanguages.count == 1 {
	label.text = String.localizedStringWithFormat(NSLocalizedString("1 popular language",
comment: "The list contains only one language")) 
} else {
	label.text = String.localizedStringWithFormat(NSLocalizedString("%d popular languages", 	comment: "The list contains more than one language"), popularLanguages.count)
}
```

기존에는 이렇게 작성될 수 있었겠죠. 하나의 popular language에 대해서는 1 popular language라고 표현할 수 있지만 그보다 많은 popular language에 대해서는 %d popular language's' 바로 복수형태로 표시해줘야 문법적으로 올바른 표현이 되겠죠! 

이부분은 다른 언어로 가면 더 많은 조건문이 필요할수도 있습니다. 영어야 s를 붙이거나 es를 붙이면 복수형이 완성되지만 그렇지 않은 언어도 있다고 하네요! 

<img width="1038" alt="image" src="https://user-images.githubusercontent.com/40102795/112587102-50d32c80-8e40-11eb-9c33-a8dddff65708.png">

그래서 stringsdict파일에서 이런식으로 설정해주고, 코드는 

```swift
label.text = String.localizedStringWithFormat(NSLocalizedString("%d popular languages", comment: "The list contains more than one language"), popularLanguages.count)
```



그리고 Adaptive Strings 적응 문자열이 있습니다. "Gross Domestic Products(in Billions)" 이렇게 표현될 수 있는 문자열이 있다고 봅시다. 이렇게 긴 문자열은 화면이 좁은 디바이스일 경우에는 저 Gross Donestic Products를 표시하는 옆의 숫자라거나 문자열이 잘릴수도 있습니다. 그래서 가능한 공간에 따라 저 문자열을 "GDP(in Billions)"라거나 "GDP"라고 줄여서 표현할 수도있어야 유연한 UI가 될 수 있겠죠! 이것을 손쉽게 관리해주는 것도 바로 stringsdict입니다. 

 <img width="754" alt="image" src="https://user-images.githubusercontent.com/40102795/112587759-86c4e080-8e41-11eb-8319-ef973d514ae9.png">

이렇게 할당할 수 있는 공간에 따라서 표현할 문자열을 정해줄 수 있습니다. 그리고 아래의 코드를 추가해주면 되겠죠!

```swift
label.text = NSLocalizedString("GDP", comment: "A territory's GDP (Gross Domestic Product)")
```

```swift
let widthFormattedString = string.variantFittingPresentationWidth(20)
```



### Other Resources

이미지나 오디오와 같은 파일도 Localization이 가능하다고 했었죠? 이것은 이미지 파일을 눌러 파일 인스펙터에 들어가면 볼 수 있습니다. 

<img width="190" alt="image" src="https://user-images.githubusercontent.com/40102795/112588152-40bc4c80-8e42-11eb-9b95-f1f8e81085fe.png">

여기 Localize를 선택한 후에 Localize할 언어를 선택하면 됩니다. 

<img width="343" alt="image" src="https://user-images.githubusercontent.com/40102795/112588215-592c6700-8e42-11eb-9a94-5bbe879a1bd0.png">

이후 Export와 Import는 아래의 프로젝트 파일을 선택하고 Editor에 들어가면 있습니다. 

<img width="515" alt="image" src="https://user-images.githubusercontent.com/40102795/112588327-8a0c9c00-8e42-11eb-883a-1c4a1ed3bc18.png">

Localization 과정에 대한 자세한 이야기는 Localization with Xcode10에서 더 자세히 작성해보도록 하겠습니다! 

