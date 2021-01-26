# Testing Asynchronous Operations with Expectations

https://developer.apple.com/documentation/xctest/asynchronous_tests_and_expectations/testing_asynchronous_operations_with_expectations

Verify that asynchronous operations behave as expected.

예삭대로 비동기 작업이 진행되는지 확인할 수 있습니다.



## Overview

Asynchronous operations are operations that do not execute directly within the current flow of code. 

비동기 작업은 현재 코드의 흐름에서 바로 실행이 되지 않는 작업입니다.

This might be because they run on a different thread, in a delegate method, or in a callback.

이것은 delegate 메서드나 callback내에서 각각 다른 스레드 위에서 돌아가고 있기 때문일 수도 있습니다. 



To test that asynchronous operations behave as expected, you create one or more *expectations* within your test, and then *fulfill* those expectations when the asynchronous operation completes successfully.

비동기 작업이 예상했던대로 돌아가는지 테스트하기 위해서는, 하나 또는 여러개의 expectation을 테스트에 생성하여, 비동기 작업이 성공적으로 끝나면 fulfill 해줘야 하는 작업이 필요합니다. 

Your test method waits until all expectations are fulfilled or a specified timeout expires.

테스트 메서드는 모든 expectation들이 fulfill 되거나, 정해진 timeout이 끝날 때 까지 기다릴 것입니다. 



```swift
func testDownloadWebData() {
    
    // Create an expectation for a background download task.
    let expectation = XCTestExpectation(description: "Download apple.com home page")
    
    // Create a URL for a web page to be downloaded.
    let url = URL(string: "https://apple.com")!
    
    // Create a background task to download the web page.
    let dataTask = URLSession.shared.dataTask(with: url) { (data, _, _) in
        
        // Make sure we downloaded some data.
        XCTAssertNotNil(data, "No data was downloaded.")
        
        // Fulfill the expectation to indicate that the background task has finished successfully.
        expectation.fulfill()
        
    }
    
    // Start the download task.
    dataTask.resume()
    
    // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
    wait(for: [expectation], timeout: 10.0)
}	
```

Listing 1 creates a new instance of **XCTestExpectation**.

위의 코드에서 새로운 **XCTestExpectation** 인스턴스를 생성한다.

Then, it uses **URLSession**'s **dataTask(with: )** method to create a background data task that downloads the apple.com home page on a background thread.

그런 다음 URLSession의 dataTask(with: ) 메서드를 만들어 백그라운드 스레드에서 apple.com 홈페이지를 다운받을 수 있게 한다.

After starting the data task, the main thread waits for the expectation to be fulfilled, with a timeout of ten seconds.

Data Task가 시작되고 난 후 메인 스레드는 expectation이 fulfilled 될 때 까지 기다리고, timeout도 10초를 설정한다.



When the data task completes, its completion handler verifies that the downloaded data is non-nil, and fulfills the expectation by calling its **fulfill()** method to indicate that the background task completed successfully.

Data Task가 완료되면, completion handler가 다운로드된 데이터가 nil이 아닌지 확인하고, 백그라운드 Task가 완료되었다는 사실을 알리기 위해 **fulfill()**메서드를 호출하여 expectation을 fulfill 해준다.



The fulfillment of the expectation on the background thread provides a point of synchronization to indicate that the background task is complete.

백그라운드 스레드에 대한 Expectation의 Fulfillment는 백그라운드의 Task가 완료했는지를 나타내 줄 수 있습니다. 

As long as the background task fulfills the expectation within the ten second timeout, this test method will pass.

이 백그라운드 Task가 설정했던 timeout인 10초 내에 Expectation을 fulfill시킨다면, 이 테스트는 pass 할 것 이다.



There are two ways for the test to fail:

1. The data returned to the completion handler is `nil`, causing XCTAssertNotNil(_:_:file:line:)to trigger a test failure.

   data가 completion handler에게 nil을 반환하여 XCTAssertNotNil 에 걸려서 실패하는 경우.

2. The data task does not call its completion handler before the ten second timeout expires, perhaps because of a slow network connection or other data retrieval problem. As a result, the expectation is not fulfilled before the wait timeout expires, triggering a test failure.

   설정했던 timeout이 만료되는 data task, 느린 네트워크 연결이나 네트워크 문제에 의해 completion handler를 수행하지 않는 경우 실패할 수 있다.  결과적으로 expectation이 fulfilled되지 않아 failure하게 된다. 

