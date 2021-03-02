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

![image-20210302142803004](/Users/kimhojoon/Library/Application Support/typora-user-images/image-20210302142803004.png)

구조체로 선언된 Point는 우선 point1과 point2에 대한 공간은 Stack에 이미 할당이 되어있습니다. 또한 Point는 구조체이므로, x와 y가 Stack 내부에 들어있는 모습을 볼 수 있습니다. 



![image-20210302143605045](/Users/kimhojoon/Library/Application Support/typora-user-images/image-20210302143605045.png)

다음은 각각 point1 인스턴스와 point2 인스턴스가 생성된 후의 Stack을 나타낸 그림입니다. 우선 이미 할당되어 있던 point1에 대한 공간에 x값과 y값을 각각 0으로 초기화 시켜줍니다. 이후 point2는 point1을 복제(copy)하여 point2의 공간에 할당됩니다. 

point1과 point2는 독립적인 인스턴스임을 명심해야 합니다! 그렇기에 아래줄에 있는 

```swift
point2.x = 5
```

코드를 실행하면 다음 그림과 같이 point2의 x에 대해서만 값의 변경이 일어납니다. 

<img src="/Users/kimhojoon/Library/Application Support/typora-user-images/image-20210302143839067.png" alt="image-20210302143839067" style="zoom:33%;" />

이후 point1과 point2에 대한 사용을 끝내면, deallocate되고 난 후의 Stack은 아래의 그림과 같은 모습이겠죠!

<img src="/Users/kimhojoon/Library/Application Support/typora-user-images/image-20210302144057305.png" alt="image-20210302144057305" style="zoom:33%;" />

아까 Stack에서 설명한 것 처럼, Stack의 Pointer를 증가시켜주면서, point1, point2에 대한 공간을 deallocate해줍니다. 

![image-20210302144253641](/Users/kimhojoon/Library/Application Support/typora-user-images/image-20210302144253641.png)

이번에는 class를 사용한 Point입니다. Struct로 만들었을 때와는 다르게 point1과 point2에 대한 공간이 다른것을 볼 수 있습니다. 저 공간은 바로 Heap에 있는 Point를 가르키기 위한 Reference를 저장할 공간입니다. 

![image-20210302145057270](/Users/kimhojoon/Library/Application Support/typora-user-images/image-20210302145057270.png)

point1을 생성합니다! 어떤일이 벌어지는지 보이시나요? 우선 point1에서 사용될 Point에 대한 공간을 찾기 위해서 우리의 Swift는 Heap을 lock시킵니다. 그리고선 열심히! 사용하지 않고, 적절한 사이즈를 가진 블록을 찾아서 그곳에 x는 0, y는 0으로 초기화된 Point 공간을 할당하게 됩니다. 그리고 point1은 Heap의 메모리 주소를 참조할 수 있게 됩니다. 

Struct와 비교하여 보면 Point에 대한 공간에 더 많은 공간이 할당된 것을 볼 수 있습니다. 이것은 Swift가 우리를 위해 추가적으로 관리해 주는 공간이라고 볼 수 있습니다. 

![image-20210302145853389](/Users/kimhojoon/Library/Application Support/typora-user-images/image-20210302145853389.png)

이번에는 point2를 생성합니다! 이전의 구조체와는 다르게 point1 전체를 copy하지는 않습니다. 대신에, point1의 reference를 copy하게 됩니다. 즉, point1과 point2는 Heap메모리에 같은 주소를 참조하고 있게 됩니다. 그렇기 때문에 point2의 x값을 바꾸면 point1의 x값 또한 같이 바뀌게 되는것입니다. 

이후 point1과 point2의 사용이 끝나고 deallocate해주면

<img src="/Users/kimhojoon/Library/Application Support/typora-user-images/image-20210302150145833.png" alt="image-20210302150145833" style="zoom:33%;" />

이러한 형태가 됩니다. Heap을 lock하고, 사용한 블록을 적절한 위치에 reinsert하는 과정이 되겠죠? 그 과정이 끝난 후에 Stack을 pop하여 나머지 point1과 point2에 대한 메모리도 해제해줄 수 있게 됩니다. 