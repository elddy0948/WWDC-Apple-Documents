# Localization workflows in Xcode10



### Localization process overview

### Xcode localization catalog

### Localizing intent definition files



## Overview

Xcode10 전에는 만약에 프로젝트가 있는데 그 프로젝트가 앱이 지원해야하는 localization들이 있으면, 우리는 strings base localizable resources를 프로젝트에서 찾았었습니다. 

그래서 하나의 프로젝트 안에 이런식으로 형성이 되었었죠!

```
- Project.xcodeproj
-- Base.lproj
-- ja.lproj
-- ar.lporj
```

이 strings 는 소스코드, 스토리보드 파일, strings 파일, strings dictionary파일들로 정의될 수 있습니다. 그래서 우리가 이 resource들을 식별하고나면, 우리는 여기에서 strings를 추출해냅니다. 그리고 XLIFF 포멧의 파일로 **Export**하게 됩니다.  

![image](https://user-images.githubusercontent.com/40102795/112728392-73616480-8f6a-11eb-9617-efe582ffc35c.png)

이 XLIFF파일이 바로 번역가에게 보내질 파일이라고 볼 수 있겠죠. 그리고 우리가 번역이 잘 된 XLIFF파일을 다시 받으면, 그것을 우리의 프로젝트에 **Import**시킵니다. 

![image](https://user-images.githubusercontent.com/40102795/112728402-7bb99f80-8f6a-11eb-9cee-cb56bd9e37d3.png)

XLIFF파일은 우리와 같은 개발자에게 많은 이점을 가져다 줍니다. 

우선, 코드에서 localization을 해야하는 부분을 추출하는 것을 도와줍니다. 그래서 소스코드에서 어떤 언어에 대한 번역이나 추론 등을 하지 않아도 됩니다. 

또한, XLIFF파일은 localize될 content를 개발 언어와 번역본을 함께 들고 있기에, 번역가가 우리가 제공한 XLIFF파일을 사용하여 올바르게 작업할 수 있게 해줍니다. 

그리고 XLIFF파일은 여러 파일의 타입을 넘겨주고 추적하게 하는 대신에, 그 각각의 Resource들에서 strings만 추출하여 하나의 문서로 통합하는 매우 유용한 도구라고 할 수 있습니다. 



**하지만** XLIFF는 localizer들에게 시각적인 context나 기능적인 context를 제공하지 않습니다. 

그리고 프로젝트 내부에 있는 assets와 같은 resource data 또한 제공하지 않습니다. 예를들어 localizer들에게 개발 언어로 만들어진 UI를 보여준다면 스토리보드 파일을 localization하는데 정말 편리하겠죠? 

또한 생성된 XLIFF에 대한 custom metadata 또한 제공하지 않습니다. 

마지막으로 우리가 생성한 XLIFF는 사이즈나 길이의 제한을 알려줄 수 있는 요소가 존재하지 않습니다. 이것은 localizer들이 Watch나 iPhone, iPad 스크린 등에 맞춰서 어떠한 길이로 번역되면 좋을지 결정하는데에 아주 큰 도움을 줄텐데요!

정리해보면 XLIFF의 제한사항은 다음과같습니다. 

- Visual Context
- Resource Data
- Custom Metadata
- Size and Length restrictions



자 그럼 이 Context가 왜 localizer들에게 중요할까요? 예시를 하나 보여주네요!

<img src="https://user-images.githubusercontent.com/40102795/112728971-20d57780-8f6d-11eb-9a5a-ecf9220f7ac3.png" alt="image" style="zoom:50%;" />

여기 여행 앱이 하나 있습니다. 우리가 보통 여행을 예약할때 "Book" 이라는 단어를 사용하죠? "Book the Hotel", "Book the Airplane" 이런식으로 말이죠! 하지만 Book은 책이라는 의미도 가지고있습니다. 저희는 그럼 위 그림에서 Book이라는 것이 "책"이라는 의미가 아닌 "예약하다" 라는 의미를 가지고 있는지 무엇을 통해 알 수 있었나요? 

바로 네비게이션바에 보이는 'Travel Details'라는 글과, 날짜, 시작 끝, 여행객, 비용 등 시각적인 것들을 활용하여 Book이 "예약하다"라는 의미를 가지고 있다는 것을 유추할 수 있습니다. 

하지만 우리가 기존의 방식처럼 XLIFF파일만 번역가에게 보내면 그들이 보는것은 오로지 "Book"이라고 적힌 글자 뿐입니다. 어떠한 Visual Context도 없죠. 그래서 Book과 같이 단어의 의미가 여러개인 단어들은 번역하기가 힘들죠. 

이런점에서 Context는 localizer들에게 아주 중요한 요소입니다. 이런 context를 제공하면 또한 이것을 번역하면 어느정도 길이가 나오겠구나 등의 결정도 내릴 수 있습니다. 

<img src="https://user-images.githubusercontent.com/40102795/112729187-46af4c00-8f6e-11eb-8a08-9efb5a9f6696.png" alt="image" style="zoom:50%;" /><img src="https://user-images.githubusercontent.com/40102795/112729195-4e6ef080-8f6e-11eb-8deb-3cf2d6bb62cc.png" alt="image" style="zoom:50%;" />

위의 Watch를 보면 "Booking confirmed"라는 영어는 크기가 딱 맞지만 이를 번역한 프랑스어는 너무 길어서 글자가 짤리는 현상을 볼 수 있겠죠!

이로써 Context가 얼마나 중요하고 더 높은 수준의 Localization을 제공할 수 있는지를 알아보았습니다. 그래서 Xcode10에서는 바로 "**Xcode Localization Catalog"** 를 소개합니다! 👏👏👏👏



### Xcode Localization Catalog

Xcode Localization Catalog란 무엇일까요? Xcode Localization Catalog는 .**xcloc** extension을 가진 localization artifact의 새로운 타입입니다.  이것은 Xcode10 전의 버전에서 XLIFF파일을 만들때 우리는 Export를 하였죠? 이번에도 똑같습니다. Xcode10 부터는 Export시 Xcode Localization Catalog 가 생성이 됩니다. 그리고 똑같이 Import를 통해서 프로젝트에 적용됩니다.

Localization Catalog에서 주요하게 봐야할 점은 모든 localizable asset들을 지원한다는 부분입니다. 이 말은 Xcode 프로젝트 내에서 설정한 모든 localizable 한것 들은 Localization Catalog에 의해 지원이 될 것이고, 그것은 strings 파일 보다 더 많은 것을 가질 수 있습니다. 

또다른 중요한점은 바로 localizer들에게 추가적인 contextual 정보를 제공할 수 있다는 점입니다. 그래서 우리는 Xcode Localization Catalog를 XLIFF포맷 상위에 두는 것입니다. (XLIFF 파일 포맷이 없어지는 건 아님.)



그래서 앞서 보았던 예시에서 처럼 strings base인 localizable resource들만 XLIFF 포맷에 추출될 것입니다. 그리고 나머지 프로젝트에서 localizable로 마크해둔 것들은 모두 Localization Catalog가 지원해 줄 것입니다. 그리고 이것들은 xcloc파일 포맷으로 export될 것입니다. 

![image-20210328135812838](/Users/kimhojoon/Library/Application Support/typora-user-images/image-20210328135812838.png)

이러한 과정이 되겠죠! 그럼 이제 Xcode Localization Catalog 파일인 xcloc 파일 내부를 자세히 살펴보겠습니다. 

![image](https://user-images.githubusercontent.com/40102795/112742935-f23bb900-8fcd-11eb-858d-58308c1104b0.png)

하나하나 살펴보겠습니다. 우선 content.json 파일이 있습니다. 이 파일은 Export된 Localization Catalog에 대한 metadata를 담고있습니다. **Development region, Target locale, Tool info, Version** 같은 정보를 담고있습니다. 

다음은 **Localized Contents** 디렉토리가 있을 것입니다. 이 Localized Content에는 프로젝트 내에 있는 모든 localizable resources를 포함하고 있습니다. 그리고 이 디렉토리가 localizer들이 작업을 할 메인 디렉토리가 될것입니다.  그래서 Localized Contents 디렉터리에 들어가보면 XLIFF 파일도 볼 수 있습니다. 또한 같은 폴더 안에 이미지와 같은 non-strings localizable asset들을 보여줄 수 있는 .lproj파일도 있습니다. 로컬라이저들은 이러한 Localized Content를 활용하여 Interface builder파일과 같은 언어에 대한 모든 reource들을 재정의 할 수 있습니다. 

그리고 **Source Contents** 디렉토리입니다. 주로 context를 제공하는 목적으로 사용됩니다. 우리의 개발 언어로 작성된 원본파일? 같은 것이죠! 그래서 localizer로 하여금 localization에 도움을 주는 시각적인 자료들을 제공합니다. 그리고 localized string들이 여러분의 소스코드에서 왔더라도, 우리는 Source Contents에 소스코드를 만들진 않습니다. 

마지막으로 **Notes** 디렉토리입니다. 여기에서는 추가적인 contextual 정보를 담을 수 있습니다. 화면에 대한 스크린샷이나, README를 추가하여 localizer가 더 쉽게 localization 을 하게 도움을 줄 수 있죠! 

이 모든 것들이 .xcloc 즉 Xcode Localization Catalog로 통합이 되어 우리의 Xcode에 import될 것 입니다. 



### 이후에는 Siri의 ShortCut에 대한 intent definition에 대한 내용입니다. 이 부분은 저한테 이해가 조금 어려워서 시간을 두고 정리하려고 합니다! 