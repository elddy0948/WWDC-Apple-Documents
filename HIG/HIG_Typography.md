# Typography

Apple provides two type families you can use in your iOS apps.

Apple은 iOS app들에서 사용할 수 있는 두가지 타입의 패밀리를 제공한다.



## San Francisco(SF)

**San Francisco (SF).** San Francisco is a sans serif type family that includes SF Pro, SF Pro Rounded, SF Mono, SF Compact, and SF Compact Rounded. SF Pro is the system font in iOS, macOS, and tvOS; SF Compact is the system font in watchOS. Designed to match the visual clarity of the platform UIs, the system fonts are legible and neutral.

San Fransisco(SF). San Francisco는 SF Pro, SF Pro Rounded, SF Mono, SF Compact, and SF Compact Rounded를 포함하는 sans serif type family이다. 

SF Pro는 iOS, macOS, tvOS에서 사용하는 시스템 폰트이다. 

SF Compact는 watchOS에서 사용하는 시스템 폰트이다. 

각각의 플랫폼 UI의 시각적 명확성과 잘 맞도록 설계된 시스템 글꼴은 legible(읽기쉽다) 하고, neutral(중립적이다)하다.



## New York(NY)

**New York (NY).** New York is a serif typeface that provides a unique tone designed to complement the SF fonts. NY works as well in a graphic display context (at large sizes) as it does in a reading context (at text sizes).

New York(NY)는 SF fonts를 보완하도록 설계된 unique한 tone을 제공하는 serif typeface이다.

NY는 reading context(텍스트 크기)에서와 같이 graphic display context(큰 크기)에서도 잘 작동한다.



Beginning in iOS 14, the system provides the San Francisco and New York fonts in the *variable* font format.

iOS 14 버전 부터 시스템에서는 San Francisco와 New York폰트를 다양한 font 형식으로 제공한다.

This format combines different font styles together in one file, and supports interpolation between styles to create intermediate ones.

이 형식은 하나의 파일에 여러 폰트 스타일들을 함께 결합하고 있고, 중간 글꼴을 생성할 수 있게 스타일 간의 보간을 지원하고 있다.

With interpolation, typefaces can adapt to all sizes while appearing specifically designed for each size.

이 보간법을 사용한다면, 글씨체들은 각각의 사이즈에 특별하게 설계된것 처럼 보이는것과 동시에 모든 사이즈에 적용될 수 있다.



Interpolation also enables optical sizing, which refers to the creation of different typographic designs to fit different sizes.

또한 보간법은 optical sizing 또한 가능하다. 즉, 서로 다른 사이즈에 맞게 다른 typographic 디자인을 생성할 수 있다.

Both San Francisco and New York provide specific optical size variants to ensure that text can look great at any size: Text and Display for SF Pro and SF Compact, and Small, Medium, Large, and Extra Large for New York.

San Francisco와 New York은 텍스트가 어떠한 사이즈에서도 잘 보이는 것을 보장하기 위해 특정한 optical size 변형을 제공한다 : SF Pro, SF Compact에서 Small, Medium, Large를 제공하고, New York에서는 Extra Large 사이즈의 텍스트와 Display를 제공한다.

In iOS 14 and later, the system fonts support *dynamic optical sizes*, merging the discrete optical sizes like Text and Display into a single, continuous design. 

iOS 14 버전과 그 이후의 버전에서, system fonts는 dynamic optical sizes를 지원하기 시작하며 텍스트나 디스플레이와 같은 optical sizes를 하나의 연속된 디자인으로 통합하였다.

This design allows each glyph or letterform to be interpolated to produce a structure that’s precisely adapted to the point size.

이 설계를 통해 각 glyph 또는 글자 형식을 보간하여 point size에 맞게 정확하게 조정된 구조를 만들 수 있게 해준다.



Because SF Pro and NY are compatible, there are many ways you can incorporate typographic contrast and diversity into your iOS interfaces while maintaining a consistent look and feel. 

SF Pro와 NY가 호환되기 때문에, 일관된 모양의 느낌을 유지하면서 iOS 인터페이스에 typographic contrast와 다양성을 통합할 수 있는 다양한 방법이 있다.

For example, using both typefaces can help you create stronger visual hierarchies or highlight semantic differences in content.

예를들어, 두가지 서체를 모두 사용하면 강력한 시각 계층을 생성하는 것에 도움을 주거나 서로 다른 content의 의미적 차이를 강조할 수 있다.



Apple-designed typefaces support an extensive range of weights, sizes, styles, and languages, so you can design comfortable and beautiful reading experiences throughout your app.

Apple에서 디자인한 서체는 다양한 weights, sizes, styles, laguages를 지원하고 있어서 앱 전체에서 편리하고 아름다운 읽기 환경을 디자인할 수 있다.

When you use text styles with the system fonts, you also get support for Dynamic Type and the larger accessibility type sizes, which let people choose the text size that works for them. 

시스템 폰트와 함께 텍스트 스타일을 사용하면 Dynamic Type 및 더 큰 타입 역시 지원이 되기 때문에 사용자들로 하여금 원하는 텍스트 크기를 선택할 수 있다.



## SF Pro and SF Compact

The flexibility of the system fonts helps you achieve optimal legibility at every point size and gives you the breadth(넓이) and depth you need for precision typesetting throughout your app.

시스템 폰트들의 유연성은 모든 포인트 사이즈와 최적의 가독성을 달성할 수 있도록 도와주며, 앱 전체에 대한 정밀 유형 설정에 필요한 넓이와 깊이를 제공한다.



## SF Pro Rounded and SF Compact Rounded

The rounded variant of the system fonts can help you coordinate your text style with the appearance of soft or rounded UI elements, or to provide an alternative typographic voice.

시스템 폰트의 원형 변형을 사용하면 텍스트 스타일을 소프트 또는 원형 UI 요소에 맞게 조정하거나, 대체 typographic voice를 제공할 수 있다. 



## SF Mono

SF Mono is a monospaced variant of San Francisco — that is, a typeface in which all characters are equal in width. You typically use a monospaced typeface when you want to align columns of text, such as in a coding environment. For example, Xcode and Swift Playgrounds use SF Mono by default.

SF Mono는 San Francisco monospace의 변형으로, 모든 문자 너비가 동일한 서체이다. 일반적으로 coding 환경과 같은 곳에서 텍스트 열을 정렬할 대 단일 간격의 서체를 사용한다. 예를들어  Xcode와 Swift Playgrounds에서 SF Mono타입을 기본적으로 사용한다.



## New York

New York is a classical serif typeface you can use in the interface or to provide a traditional reading experience.

New York는 인터페이스나 전통적인 읽기 경험을 제공하기 위해 사용할 수 있는 classical한 serif 서체이다.