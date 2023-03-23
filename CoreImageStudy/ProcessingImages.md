# Processing Images

Processing images == Applying filters
'image filter'는 인풋 이미지들을 pixel by pixel로 검사하면서(examine) 알고리즘적으로(algorithmically) 어떤 이펙트를 적용하여 아웃풋 이미지를 생성하는 소프트웨어입니다.

Core Image에서 이미지 프로세싱은 `CIFilter`(필터)와 `CIImage`(인풋 아웃풋) 클래스에 의존합니다.

필터를 적용하고, 결과를 보여주거나(Display) 내보내기(Export)위해서는 Core Image와 다른 시스템 프레임워크 간의 통합을 하거나, `CIContext`클래스를 사용하여 자체 *rendering workflow*를 만드는 방법이 있습니다.

## OverView

간단한 예시를 살펴보겠습니다.

```swift
let context = CIContext() // 1

let thresholdFilter = CIFilter.colorThreshold() // 2
thresholdFilter.inputImage = image
thresholdFilter.threshold = 0.2

guard let result = thresholdFilter.outputImage else { fatalError() } // 3

let cgImage = context.createCGImage(result, from: result.extent) // 4
```

1. `CIContext`를 default 옵션을 사용하여 선언해주었습니다. `CIContext` 없이도 알아서 렌더링을 위해 시스템에서 만들어 주지만, `CIContext`를 따로 만들어서 사용한다면, rendering process와 rendering에 관련된 자원들에 대한 더 정밀한 컨트롤이 가능해집니다. Context는 무거운 객체입니다. 그래서 가능한 빨리 생성하고, 이미지를 프로세스 할 때마다 재사용 하는것을 추천합니다.

2. `CIFilter`를 사용하여 이미지에 필터를 주는 코드입니다. 저기서 `inputImage`에 들어가는 `image`는 `CIImage`로 프로세스 될 이미지를 나타냅니다.

3. `result`는 `thresholdFilter`의 아웃풋 이미지입니다. 이 `result`에 breakpoint를 걸고 다음 줄을 실행하면 이미지를 확인할 수 있습니다.
  ![image01](./images/image01.png)
  ![image02](./images/image02.png)

4. 아웃풋 이미지를 Core Graphics 이미지로 생성해주고, 이 `cgImage`를 Display 하거나 Save 합니다.

## Images are the Input and Output of Filters

Core Image 필터는 Core Image 이미지를 처리(process), 제공(produce)합니다.

`CIImage`인스턴스는 이미지를 나타내는 *immutable*한 객체입니다. 이 `CIImage`는 직접적으로 이미지의 비트맵 데이터를 나타내지 않습니다. 대신에, 제공되는 이미지의 설계(recipe)를 제공합니다. (위에 있는 사진에서 고양이 이미지 아래에 다양한 데이터들이 적혀있는 이유 저 네모 박스 하나하나가 recipe인듯?!)

`CIImage`는 이미지 데이터를 포함하는게 아닌, *이미지를 어떻게 제공(produce)하는지를 나타내는 객체이므로*, 필터에 대한 아웃풋도 나타낼 수 있습니다.(위 이미지에서 필터가 적용된 고양이 사진이 나오는 이유!)

그래서 `CIFilter`의 `outputImage`프로퍼티에 생성된 데이터를 보면, Core Image가 해당 필터를 실행시키기 위한 과정들을 확인하고 저장해둡니다. (위의 사진의 네모 박스들과, 화살표가 그 과정인듯!) 이 과정들은 우리가 display 혹은 output을 위해 *render*요청을 했을 때, 진행됩니다.

Rendering 요청은 두가지로 나눌 수 있습니다. 우선 명시적(explicitly)으로 `CIContext`의 `render` 혹은 `draw` 메서드를 사용하는 방법입니다. 다른 하나는 암묵적(implicitly)으로 그냥 Core Image를 사용하는 프레임워크들에서 이미지를 display해주면, 알아서 렌더링 해줍니다.

그리고 Rendering Time에는 Core Image가 이미지에 2개 이상의 필터를 적용해야 하는지를 확인하고, 그렇다면, 자동으로 'recipe'를 연결하면서, 중복된 작업을 제거하는 역할도 해줍니다. 그러면서 각 픽셀이 여러번이 아닌 한번만에 처리될 수 있게 해줍니다.

## Filters Describe Image Processing Effects

`CIFilter` 클래스의 인스턴스는 mutable한 객체이고, 이미지 프로세싱 *효과(Effect)*를 나타냅니다. 또한 여러 파라미터들로, 효과의 동작을 컨트롤 할 수 있습니다.

 *중요*
 `CIFilter` 객체는 mutable하기 때문에 다른 스레드에서 공유한다면 안전하지 못합니다 각 스레드에는 그 스레드 만의 `CIFilter` 객체가 있어야합니다. 하지만, 필터의 input, output 이미지는 `CIImage` 객체이고, 이는 immutable하기 때문에 다른 스레드 끼리 사용해도 안전합니다.

## Chaining Filters for Complex Effects

모든 Core Image 필터는 output으로 `CIImage`를 제공합니다. 이 output이 다른 필터의 input이 되어 filter chain을 만듭니다. Core Image는 이런 filter chain의 적용을 최적화하여 결과를 빠르고 효율적으로 렌더링할 수 있게 합니다.

우선 `CIImage`객체는 완벽한 rendered 이미지가 아닙니다.(UIImage, CGImage와 다름) 대신, 렌더링을 위한 *recipe*가 들어있는 객체라고 할 수 있습니다. 그래서 이런 이점을 살려 Core Image는 각각의 필터를 독립적으로 실행할 필요가 없습니다. 즉, 보여지지 않을 rendering 중간 단계 (중간중간에 추가되는 필터들의 output)을 위한 픽셀 버퍼를 만들면서 시간과 메모리를 낭비할 필요가 없는것입니다.

대신에, Core Image는 하나의 operation으로 필터들을 합치고, 필터의 순서를 조작하여 더 효율적이지만 똑같은 결과물을 만들어낼 수 있습니다.

```swift
let thresholdFilter = CIFilter.colorThreshold()
thresholdFilter.inputImage = image
thresholdFilter.threshold = 0.2

let bloomFilter = CIFilter.bloom()
bloomFilter.inputImage = thresholdFilter.outputImage
bloomFilter.intensity = 0.5
bloomFilter.radius = 16.0

let sepiaToneFilter = CIFilter.sepiaTone()
sepiaToneFilter.inputImage = bloomFilter.outputImage
sepiaToneFilter.intensity = 5.0

guard let result = sepiaToneFilter.outputImage else { fatalError() }

```

위는 Filter chain의 예시입니다.

## Building Your Own Workflow with a Core Image Context

`CIContext` 클래스를 사용하여 자원들을 더 신중하게 다뤄야 할 상황이 있습니다. Core Image context를 직접 관리하면서 더 정밀하게 앱의 성능적인 측면이나, Core Image를 lower-level의 렌더링 기술과 함께 개선할 수 있게 됩니다.

Core Image context는 CPU 또는 GPU의 computing 기술, 자원, 설정값 같이 필터를 실행하고 이미지를 produce할 때 필요한 정보들을 담고 있습니다.

*important*
Core Image context는 많은 양의 자원들과 상태를 관리하고 있는 무거운(heavyweight) 객체 입니다. 그래서 반복적으로 context를 생성하고 제거하면, 성능적으로 엄청난 비용이 들게 됩니다.
그래서 여러개의 이미지 프로세싱이 필요하다고 생각된다면, 최대한 빠른 시점에서 context를 생성하고, 이를 재사용하는 방식으로 구성하는 편이 좋습니다.

### Rendering with an Automatic Context

### Real-Time Rendering with Metal
