# About Core Image

## Core Image란?

CoreImage는 정적인 이미지들, 비디오 이미지들을 실시간에 가깝게(near real-time) 처리하도록 디자인된 이미지 프로세싱과 분석 기술이다.

GPU 또는 CPU rendering path를 사용하여 Core Graphics, Core Video, Image I/O 프레임워크들과 같은 *이미지 데이터 타입들*에서 작동한다.

// Image..

Core Image는 여러 API들을 제공하여 쉽게 활용할 수 있고, 자세한 Low-level에서 일어나는 graphics processing은 숨긴다.

그래서 Core Image를 사용한다면, Metal을 활용하여 GPU를 컨트롤하거나, 멀티코어 프로세싱의 이점을 활용하기 위해 CPU를 컨트롤 하는 일은 없어도 된다. (Core Image가 다 해줌!)

Core Image 프레임워크가 제공하는 것들

- 내장 이미지 프로세싱 필터에 대한 접근
- 기능 탐지 기능
- 자동 이미지 향상(enhancement) 지원
- 여러개의 필터를 이어서(chain) 새로운 custom 필터를 만들 수 있다.
- GPU에서 돌아가는 custom 필터 제작
- 피드백 기반 이미지 프로세싱 기능

## Core Image is Efficient and Easy to Use for Processing and Analyzing Images

## Query Core Image to Get a List of Filters and Their Attributes

## Core Image Can Achieve Real-Time Video Performance

## Use an Image Accumulator to Support Feedback-Based Processing

## Create and Distribute Custom Kernels and Filters

[apple docs](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_intro/ci_intro.html#//apple_ref/doc/uid/TP30001185)
