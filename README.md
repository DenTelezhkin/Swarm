<p align="center">
  <img src="logo.png" height=100/>
</p><br>

![CI](https://github.com/DenTelezhkin/Swarm/workflows/CI/badge.svg)
[![codecov.io](https://codecov.io/github/DenTelezhkin/Swarm/coverage.svg?branch=main)](https://codecov.io/github/DenTelezhkin/Swarm?branch=main)
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/Swarm/badge.svg)
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/Swarm/badge.svg)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg)]()

Swarm is fast, simple and modular web-scrapping solution written in Swift.

## Features

- [x] Concurrently working spider instances
- [x] Automatic request repeat and slow-down when requested by the server
- [x] Customizable network layer (defaults to `URLSession`)
- [x] Depth first / breadth first options
- [x] Cross-platform

## Quickstart

```swift
class Scrapper: SwarmDelegate {
    lazy var swarm = Swarm(startURLs: [startingURL, anotherStartingURL], delegate: self)

    init() {
        swarm.start()
    }

    func scrappedURL(_ url: VisitedURL, nextScrappableURLs: @escaping ([ScrappableURL]) -> Void) {
        if let htmlString = url.htmlString() {
            // Scrap data from htmlString

            nextScrappableURLs([ScrappableURL(url: nextURL)])
        } else {
            nextScrappableURLs([])
        }
    }

    func scrappingCompleted() {
        print("Scrapping took: \(swarm.scrappingDuration ?? 0)")
    }
}
```

## Requirements

- Xcode 11 and higher
- Swift 5 and higher
- iOS 10 / macOS 10.12 / tvOS 10.0 / watchOS 3.0

> Although, if you are doing web scrapping on an Apple Watch, your use-case must be pretty wild :)

## Installation

### Swift Package Manager(requires Xcode 11)

* Add package into Project settings -> Swift Packages

If you build a package, based on Swarm, add following code to Package.swift:

```swift
.package(url: "https://github.com/DenTelezkin/Swarm.git", .upToNextMajor(from: "0.1.0"))
```

### CocoaPods

```ruby
pod 'Swarm'
```

## Adding more urls

After initializing Swarm with starting URL's, you might add more using following method:

```swift
swarm.addURL(ScrappableURL(url: newURL, depth: desiredDepth))
```

Also, you can add more URL's to scrap a a result of `scrappedURL(_:nextScrappableURLs:)` delegate method callback:

```swift
nextScrappableURLs([ScrappableURL(url: nextURL)])
```

Please note, that there is no need to check those URL's for uniqueness, as internally URL's are stored in `Set`, and while scraping is in progress, visited URL's are saved in a log.

> Keep in mind, that calling `nextScrappableURLs` closure is required in `scrappedURL(_:nextScrappableURLs:)` delegate method, as Swarm is waiting for all such closures to be called in order to complete web-scraping.

## Configuration

`SwarmConfiguration` is an object passed during `Swarm` initialization. It has sensible defaults for all parameters, however if you need, you can modify any of them:

* Success status codes
* Delayed retry status codes
* Delayed retry delay
* Number of delayed retries before giving up
* Max auto-throttling delay (Swarm will try to adhere to "Retry-After" response header, but delay will not be larger than specified in this variable)
* Max authothrottled request retries before giving up
* Download delay (cooldown for each of the spiders)
* Max concurrent connections (max amount of spiders working in parallel, for example, for download delay 1 second, and 8 concurrent connections, equates to approximately 8 requests in a second)
* Scrapping behavior (described in next section)

## Depth or breadth?

Web-page can contain several links to follow, and depending on your agenda, you may want to go deeper or wide(e.g. do I want to get all items on the page first, and then load details on each of them, or vice-versa).

By default, Swarm operates as LIFO queue, ignoring depth entirely. You can, however, require depth first, or breadth first by setting this in `SwarmConfiguration` object:

```swift
configuration.scrappingBehavior = .depthFirst
```

In this case, when selecting next URL to scrap, `Swarm` will choose `ScrappableURL` instance with biggest `depth` value. Alternatively, if `.breadthFirst` behavior is used, least `depth` url will be prioritized.

## Network transport

By default, `Swarm` uses `Foundation.URLSession` as network transport for all network requests. You can customize how requests are sent by adopting a delegate method:

```swift
func spider(for url: ScrappableURL) -> Spider {
    let spider = URLSessionSpider(url: url)

    // Handle cookies instead of ignoring them
    spider.httpShouldHandleCookies = true
    spider.userAgent = .static("com.my_app.custom_user_agent")
    spider.requestModifier = {
            var request = $0
            // Modify URLRequest instance for each request
            request.timeoutInterval = 20
            return request
        }
    // Modify HTTP headers
    spider.httpHeaders["Authorization":"Basic dGVzdDp0ZXN0"]

    return spider
}
```

You can also implement your own network transport, if you need, by implementing simple `Spider` protocol:

```swift
public protocol Spider {
    init(url: ScrappableURL)

    func request(completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}
```

## Spider lifecycle

## Being a friendly neighborhood web-scraper



## FAQ

### I'm into some serious web-scrapping, is this framework for me?

Well, depends. This project is built with simplicity in mind, as well as working on Apple platforms first, and Linux later. It works for my use case, but if you have more complex use case, you should look at [scrapy](https://docs.scrapy.org/en/latest/), which has much more features, as well as enterprise support.

### Why don't you have a built-in mechanism for extracting data?

This again goes back to simplicity. You might like [SwiftSoup](https://github.com/scinfu/SwiftSoup) for HTML parsing or you might like [Kanna](https://github.com/tid-kijyun/Kanna) to use XPath for extracting data. Maybe you even need a headless browser to render your web-pages first. With current approach, you basically install `Swarm`, and you can use any parsing library you need(if any).

### Is there a CLI?

No, and it's not planned. Building a Mac app [is trivial nowadays](https://developer.apple.com/documentation/swiftui/app) with just several lines of code, this making a need for CLI obsolete at this moment.

### What features are planned?

Depending on interest from community and my own usage of the framework, following features might be implemented:

- [ ] Linux support
- [ ] Automatic robots.txt parsing
- [ ] Automatic sitemap parsing
- [ ] Automatic link detection with domain restrictions
- [ ] External storage for history of visited pages

## License

`Swarm` is released under the MIT license. See LICENSE for details.
