# Fetching Website Data into Memory

https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory#2927984

Receive data directly into memory by creating a data task from a URL session.

URL session의 data task를 생성하여 데이터를 메모리로 바로 받아올 수 있다. 



## Overview

For small interactions with remote servers, you can use the URLSessionDataTask class to receive response data into memory (as opposed to using the URLSessionDownloadTask class, which stores the data directly to the file system). 

Remote Server와 작은 interaction을 하는 경우, **URLSessionDataTask** 클래스를 사용하여 메모리에 응답 데이터를 수신할 수 있습니다.(File System에 데이터를 직접 저장하고 싶다면 **URLSessionDownloadTask** 클래스를 사용합니다.)

A data task is ideal for uses like calling a web service endpoint.

Data Task는 웹 서비스의 Endpoint를 호출하는 용도에 적합합니다.



You use a URL session instance to create the task. 

Task를 생성하기 위해서는 URL Session의 인스턴스를 생성해야 합니다.

If your needs are fairly simple, you can use the shared instance of the URLSession class. 

만약 요구할 것이 매우 간단하다면, URLSession 클래스의 shared인스턴스를 사용할 수 있습니다.

If you want to interact with the transfer through delegate callbacks, you’ll need to create a session instead of using the shared instance.

만약 데이터를 전송함에 있어서 Delegate Callbacks를 활용하여 전송할때의 상호작용이 필요하다면, Shared인스턴스 대신 Session을 생성해야 합니다.

You use a **URLSessionConfiguration** instance when creating a session, also passing in a class that implements **URLSessionDelegate** or one of its subprotocols.

URLSEssionConfiguration인스턴스를 활용하여 Session을 만들 수 있습니다. 또한 URLSessionDelegate 또는 Subprotocols 중 하나를 구현하는 클래스에도 이를 전달합니다. 

Sessions can be reused to create multiple tasks, so for each unique configuration you need, create a session and store it as a property.

Session은 여러개의 Task를 생성하기 위해 재사용될 수 있으며, 각각에 필요한 고유한 configuration에 대해 Session을 생성하여 Property로 저장해 둡니다. 



Once you have a session, you create a data task with one of the `dataTask()` methods.

Session을 한번 만들고 나면, dataTask()메서드 중 하나를 선택하여 data task를 생성합니다. 

Tasks are created in a suspended state, and can be started by calling **resume()**.

Task는 Suspended상태로 생성될 것 이고, resume() 메서드를 호출하면서 시작될 것 입니다.



## Receive Results with a Completion Handler

The simplest way to fetch data is to create a data task that uses a completion handler.

데이터를 받아오는 가장 간단한 방법은, completion handler를 사용하는 data task를 만드는 것입니다. 

With this arrangement, the task delivers the server’s response, data, and possibly errors to a completion handler block that you provide.

이러한 과정은 Task가 서버에서 온 응답, 데이터 그리고 Error의 가능성까지 Completion handler block을 통해 전달하게 됩니다. 



To create a data task that uses a completion handler, call the **dataTask(with: )** method of **URLSession**. 

completion handler를 사용한 data task를 만드려면, **URLSession의 dataTask(with: )** 메서드를 호출해야 합니다.

Your completion handler needs to do three things:

completion handler는 다음과 같은 3가지의 일을 수행해야 합니다. 

1. Verify that the `error` parameter is `nil`. If not, a transport error has occurred; handle the error and exit.

   error 파라미터가 nil인지 확인해 줍니다. 만약 nil이 아니라면 error가 발생했다는 사실을 전달하고, error를 handle한 후 종료합니다.

2. Check the `response` parameter to verify that the status code indicates success and that the MIME type is an expected value. If not, handle the server error and exit.

   Response 파라미터를 체크하여 status code가 success를 나타내고 있는지, MIME type이 원하던 값인지 체크를 하고, 그렇지 않다면 서버 error를 handle하고 종료합니다.

3. Use the `data` instance as needed.

   data 인스턴스를 필요한 곳에 사용합니다.

   

[Listing 1](https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory#2923296) shows a `startLoad()` method for fetching a URL’s contents.

아래의 코드는 URL의 콘텐츠를 Fetch해 오는 메서드인 startLoad() 입니다.

It starts by using the `URLSession` class’s shared instance to create a data task that delivers its results to a completion handler.

Completion handler를 통해 결과를 받을 data task를 URLSession 클래스의 shared인스턴스를 사용하여 생성해 줍니다. 

```swift
func startLoad() {
    let url = URL(string: "https://www.example.com/")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
```

After checking for local and server errors, this handler converts the data to a string, and uses it to populate a `WKWebView` outlet.

Local 혹은 Server의 Error를 확인한 후, 이 handler는 data를 string으로 변환하여, WKWebView outlet을 사용하는데에 쓰일 것 입니다. 

```swift
        if let error = error {
            self.handleClientError(error)
            return
        }
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
            self.handleServerError(response)
            return
        }
        if let mimeType = httpResponse.mimeType, mimeType == "text/html",
            let data = data,
            let string = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.webView.loadHTMLString(string, baseURL: url)
            }
        }
    }
    task.resume()
}
```

Of course, your app might have other uses for fetched data, like parsing it into a data model.

물론 다른 data model로 파싱하는 것과 같이 가져온 데이터를 다른 용도로도 사용할 수 있습니다.



#### Important

The completion handler is called on a different Grand Central Dispatch queue than the one that created the task. 

completion handler는 task가 만들어 진 곳과는 다른 GCD queue에서 호출되게 됩니다.

Therefore, any work that uses `data` or `error` to update the UI — like updating `webView` — should be explicitly placed on the main queue, as shown here.

그러므로, completion handler로 부터 반환되는 data나 error로 UI를 업데이트 하는 경우에는 위의 코드와 같이 main queue에서 작업해 주어야 합니다. 





### Receive Transfer Details and Results with a Delegate

For a greater level of access to the task’s activity as it proceeds, when creating the data task, you can set a delegate on the session, rather than providing a completion handler.

작업이 진행될 때 작업의 활동에 대한 접근 수준을 높이려면, data task를 생성할 때, completion handler를 사용하지 않고, session에 delegate를 설정해주는 방법이 있습니다. 



With this approach, portions of the data are provided to the **urlSession(_:dataTask:didReceive:)** method of **URLSessionDataDelegate** as they arrive, until the transfer finishes or fails with an error.

이런 방식을 통해 전송이 완료되거나 Error와 함께 실패할 때 까지, 데이터의 일부는 도착하면 **URLSessionDataDelegate**의 **urlSession(_:dataTask:didReceive:)** 메서드에 제공됩니다.

The delegate also receives other kinds of events as the transfer proceeds.

또한 delegate는 전송의 진행에 따라 다른 종류의 event도 수신합니다.



You need to create your own `URLSession` instance when using the delegate approach, rather than using the `URLSession` class’s simple `shared` instance. 

우선 delegate 방식을 사용하기 위해서는 URLSession 클래스의 shared 인스턴스 보다는 직접 정의한 URLSession 인스턴스를 사용해야 합니다.

Creating a new session allows you to set your own class as the session’s delegate, as shown in [Listing 2](https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory#2926952).

새로운 Session을 만들면 그 클래스에 session의 delegate를 등록해 줍니다. 

```swift
private lazy var session: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.waitsForConnectivity = true
    return URLSession(configuration: configuration,
                      delegate: self, delegateQueue: nil)
}()
```



[Listing 3](https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory#2919378) shows a `startLoad()` method that uses this session to start a data task, and uses delegate callbacks to handle received data and errors.

다음 코드는 이 session을 data task 실행을 위해 사용하는 startLoad() 메서드 입니다, 그리고 delegate callback을 활용하여 data와 errors를 handle하는 모습입니다.

```swift
var receivedData: Data?

func startLoad() {
    loadButton.isEnabled = false
    let url = URL(string: "https://www.example.com/")!
    receivedData = Data()
    let task = session.dataTask(with: url)
    task.resume()
}
```

This listing implements three delegate callbacks:

- **urlSession(_:dataTask:didReceive:completionHandler:)** verifies that the response has a succesful HTTP status code, and that the MIME type is `text/html` or `text/plain`. If either of these is not the case, the task is canceled; otherwise, it’s allowed to proceed.

  **urlSession(_:dataTask:didReceive:completionHandler:)** 는 response가 성공적인 HTTP status code를 통해 들어왔는지 확인해줄 수 있습니다. 그리고 MIME 타입이 text/html 인지 text/plain인지도 확인해 줍니다. 만약 이것들이 모두 해당하지 않는다면, 이 작업은 취소될 것입니다. 그렇지 않으면, 계속 진행할 것입니다.

  ```swift
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                  completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
      guard let response = response as? HTTPURLResponse,
          (200...299).contains(response.statusCode),
          let mimeType = response.mimeType,
          mimeType == "text/html" else {
          completionHandler(.cancel)
          return
      }
      completionHandler(.allow)
  }
  ```

  

- **urlSession(_:dataTask:didReceive:)** takes each `Data` instance received by the task and appends it to a buffer called `receivedData`.

  **urlSession(_:dataTask:didReceive:)** 는 receivedData라는 buffer에 작업으로부터 전달 받은 Data 인스턴스를 append 시킵니다.

  ```swift
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
      self.receivedData?.append(data)
  }
  ```

  

- **urlSession(:_task:didCompleteWithError:)** first looks to see if a transport-level error has occurred. If there is no error, it attempts to convert the `receivedData` buffer to a string and set it as the contents of `webView`.

  **urlSession(:_task:didCompleteWithError:)** 는 처음으로 전송계층의 error부터 살펴봅니다. error가 없다면, receivedData buffer를 webView 콘텐츠에 사용 될 String으로 변환시킵니다. 

  ```swift
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
      DispatchQueue.main.async {
          self.loadButton.isEnabled = true
          if let error = error {
              handleClientError(error)
          } else if let receivedData = self.receivedData,
              let string = String(data: receivedData, encoding: .utf8) {
              self.webView.loadHTMLString(string, baseURL: task.currentRequest?.url)
          }
      }
  }
  ```

  

