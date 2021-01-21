# Human Interface Guidelines (Tables)

https://developer.apple.com/design/human-interface-guidelines/ios/views/tables/

## Tables

A table presents data as a scrolling, single-column list of rows that can be divided into sections or groups.

테이블은 데이터를 single-column 형식의 리스트에 있는 row들로 스크롤링 가능한 형태로 나타낸다. 섹션 혹은 그룹으로 나누어서 표현하는 방법도 가능하다.

Use a table to display large or small amounts of information cleanly and efficiently in the form of a list.

테이블은 많거나 작은 양의 정보를 리스트 형식으로 깔끔하고 효과적으로 표현할 때 사용한다.

Generally speaking, tables are ideal for text-based content, and often appear as a means of navigation on one side of a split view, with related content shown on the opposite side.

일반적으로, 테이블은 텍스트를 기반으로 한 콘텐츠에 이상적이며, 종종 스플릿 뷰의 한쪽 에서 네비게이션 수단으로도 나타나고 반대쪽에는 콘텐츠와 관련된 것을 표시해 주기도 한다. 



iOS는 3가지의 테이블 스타일을 제공한다 : plain, grouped, and inset grouped



### Plain

Rows can be separated into labeled sections, and an optional index can appear vertically along the right edge of the table. 

Row는 Label로 표시된 Section으로 구분 할 수 있고, 테이블의 오른쪽 가장자리에 index를 수직으로 나타낼 수 있습니다. 

A header can appear before the first item in a section, and a footer can appear after the last item.

Header는 Section의 첫번째 아이템이 나오기 전에 표시될 수 있으며, Footer는 Section의 마지막 아이템 이후에 표시될 수 있습니다. 



### Grouped

Rows are displayed in groups, which can be preceded by a header and followed by a footer. 

Row가 그룹으로 표시됩니다. 앞에 Header를 붙이고, 그룹의 끝에서는 Footer를 붙일 수 있습니다. 

This style of table always contains at least one group and each group always contains at least one row. 

**Grouped 스타일의 테이블은 항상 최소한 하나의 그룹을 포함하고 있으며, 각 그룹은 항상 최소한 하나의 Row를 가지고 있어야 합니다.** 

A grouped table doesn’t include an index.

Grouped 테이블은 Index를 포함하지 않습니다. 



### Inset Grouped

Rows are displayed in groups that have rounded corners and are inset from the edges of the parent view.

Row들은 각 그룹이 Rounded Corner를 가지고, 부모 View에 Edge들이 속박(?) 되어있는 형식으로 나타내어 진다.

This style of table always contains at least one group and each group always contains at least one row and can be preceded by a header and followed by a footer.

앞서 살펴보았던 Grouped 스타일과 마찬가지로 이 스타일의 테이블은 항상 최소 하나의 그룹을 포함하고 있어야 하며, 각 그룹은 하나 이상의 Row를 포함하고 있어야 한다. Header를 붙일 수 있고, 그룹의 끝에는 Footer를 붙여줄 수 있다. 

An inset grouped table doesn’t include an index.

Grouped와 마찬가지로 Inset Grouped 테이블도 index를 가질 수 없다. 

The inset grouped style works best in a regular width environment.

Inset Grouped 스타일은 Regular Width Environment(Cell 의 Width가 화면을 꽉 채우지 않는 환경을 말하는 것 같다. 즉, 좌우의 여유가 조금 있는 환경)에서 가장 적절하게 사용된다. 

Because there's less space in a compact environment, an inset grouped table can cause text wrapping, especially when content is localized.

왜냐하면 Compact(조밀, 작은)한 환경에서는 공간이 작으며, 특히나 콘텐츠가 Localized한 경우에 Inset Grouped 테이블이 Text Wrapping을 발생 시킬 수 있기 때문이다. 



### Think about table width 

Thin tables can cause truncation and wrapping, making them hard to read and scan quickly at a distance.

Thin(얇은?) 테이블은 잘림이나 래핑을 발생시켜 빨리 읽거나 Scan하기 힘들게 합니다. 

Wide tables can also be difficult to read and scan, and can take away space from content.

Wide(넓은?) 테이블 또한 읽거나 Scan하기 힘듭니다. 그리고 콘텐츠를 위한 공간 또한 가져가버립니다. 



### **Begin showing table content quickly.**

Don’t wait for extensive table content to load before showing something.

무언가를 보여주기 전에 광범위한 테이블 콘텐츠를 Load할 때 까지 기다리지 마세요!

Fill onscreen rows with textual data immediately and show more complex data—such as images—as it becomes available.

화면의 Row에 텍스트 데이터를 즉시 채우고, 이미지와 같은 Complex한 데이터를 사용할 수 있게 되면 화면에 표시하게 됩니다. 

This technique gives people useful information right away and increases the perceived responsiveness of your app.

이 기술은 사람들에게 유용한 정보를 즉시 제공하고, 앱의 인식 반응성을 향상시킵니다. 

In some cases, showing stale, older data may make sense until fresh, new data arrives.

경우에 따라서는, 새로운 데이터가 도착하기 전 까지 오래된 데이터를 표시해주고 있을 수도 있다. 



### **Communicate progress as content loads.**

If a table’s data takes time to load, show a progress bar or spinning activity indicator to reassure people that your app is still running.

만약 테이블의 데이터가 load되는 시간이 있다면, Progress Bar를 보여주거나, Spinning 효과를 주어서 사용자에게 앱이 아직 돌아가고 있다는 것을 알려주어 사용자를 안심시켜주어야 한다. 



### **Keep content fresh.**

Consider updating your table’s content regularly to reflect newer data. 

새로운 데이터를 반영하기 위해 테이블의 콘텐츠를 정기적으로 업데이트 하는것에 대해서 고려해야 합니다. 

Just don’t change the scrolling position. 

그냥 Scrolling Position만 바꾸지 마십시오!

Instead, add the content to the beginning or end of the table, and let people scroll to it when they’re ready. 

대신에, 콘텐츠를 처음이나, 마지막 테이블에 추가하여, 사용자가 준비가 되었을 때 사용자가 내용을 스크롤 할 수 있게 합니다. 

Some apps display an indicator when new data has been added, and provide a control for jumping right to it. 

어떤 앱들은 새로운 데이터가 추가되었다는 표시를 해주고, 그 새로운 데이터로 바로 이동할 수 있는 방법을 제공합니다. 

It’s also a good idea to include a refresh control, so people can manually perform an update at any time.

Refresh 기능을 제공하는 것도 좋은 방법 중 하나입니다. 사람들이 언제든지 수동으로 업데이트를 할 수 있게 합니다. 



### **Avoid combining an index with table rows containing right-aligned elements.**

An index is controlled by performing large swiping gestures.

Index는 큰 스와이핑 제스처에 의해 컨트롤 됩니다. 

If other interactive elements reside nearby, such as disclosure indicators, it may be difficult to discern the user’s intent when a gesture occurs and the wrong element may be activated.

만약 다른 상호작용 요소가 주변에서 발생하는 경우, 제스처에 대한 사용자의 의도를 식별하기 어렵고, 잘못된 요소가 활성화 될 수 있기 때문이다. 



### Table Rows

You use standard table cell styles to define how content appears in table rows.

표준 테이블 Cell 스타일을 사용해서 콘텐츠가 테이블의 Row에 표시되는 방식을 정의할 수 있습니다. 

- Basic (Default)
  - Basic Cell 스타일에서는 Optional 이미지가 Row의 왼쪽부분에 있고 다음에 좌측정렬이 되어있는 Title이 따라옵니다. 아이템들을 표시할 때 보조 정보를 필요로 하지 않을 때 좋은 옵션입니다. 
- Subtitle
  - 좌측 정렬된 Title이 위에 있고 그 아래에 좌측 정렬된 Subtitle이 있는 형식입니다. 이 스타일은 Row가 시각적으로 비슷할 때 좋습니다. Subtitle을 추가하면 다른 Row와 구별하는 것을 도와줄 수 있습니다.
- Right Detail(Value 1)
  - 하나의 Row 라인 안에 좌측 정렬된 Title과 우측정렬된 Subtitle이 나타나 있는 형식입니다.
- Left Detail(Value 2)
  - Right Detail과 반대의 개념으로 하나의 Row 라인에 좌측 정렬된 Subtitle과 우측 정렬된 Title이 나타나 있는 형식입니다. 

All standard table cell styles also allow graphical elements, such as a checkmark or disclosure indicator.

모든 기본 테이블 Cell 스타일들은 체크 마크나 Disclosure Indicator와 같은 그래픽 요소 또한 허용합니다. 

Of course, adding these elements decreases the space available for titles and subtitles.

물론 이러한 요소를 추가한다면 Title과 Subtitle이 들어갈 공간은 줄어들게 됩니다. 



#### **Keep text succinct to avoid clipping.**

Truncated words and phrases are hard to scan and decipher.

잘린 단어나 구문은 Scan 하거나 해석 하기가 어렵습니다.

Text truncation is automatic in all table cell styles, but it can present more or less of a problem depending on which cell style you use and where truncation occurs.

텍스트를 잘라내는 기능은 모든 테이블 Cell 스타일에서 자동적으로 일어나지만, Cell 스타일이나 어떤 곳에서 잘림이 발생하느냐에 따라 문제가 발생할 수 있습니다. 



#### **Consider using a custom title for a Delete button.**

If a row supports deletion and it helps provide clarity, replace the system-provided Delete title with a custom title.

만약 Row가 삭제를 지원하고, 그것을 명확하게 제공하는 것을 돕기 위해서, 시스템에서 제공하는 Delete 타이틀을 커스텀 Title로 바꾸는 것이 좋습니다. 



### **Provide feedback when a selection is made.**

People expect a row to highlight briefly when its content is tapped. 

사용자가 콘텐츠를 탭 했을 때 Row가 간결한 Highlight를 기대합니다.

Then, people expect a new view to appear or something to change, such as a checkmark appearing, that indicates a selection has been made.

그런 다음, 사람들은 새로운 View가 나타나거나 체크마크가 나타나는 것 같이 자신이 선택한 것이 선택되었음을 나타내주기를 기대할 수도 있습니다. 



### **Design a custom table cell style for nonstandard table rows.**

Standard styles are great for use in a variety of common scenarios, but some content or your overall app design may call for a heavily customized table appearance.

표준 스타일들은 다양한 일반적인 상황에서 사용하기에 매우 좋지만, 일부 컨텐츠 또는 전체 앱 디자인에서 보면 Customized 테이블이 필요할 수 있습니다.

To learn how to create your own cells, see Customizing Cells in Table View Programming Guide for iOS.