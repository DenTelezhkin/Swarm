<p align="center">
  <img src="logo.png" height=100/>
</p><br>

![CI](https://github.com/DenTelezhkin/Swarm/workflows/CI/badge.svg)
[![codecov.io](https://codecov.io/github/DenTelezhkin/Swarm/coverage.svg?branch=main)](https://codecov.io/github/DenTelezhkin/TRON?branch=main)
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
