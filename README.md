<div>
<img align="left" width="300" height="300" src="icon.png">
<br><br><br>
  
# Swarm

<br>
Swarm is fast, simple and modular web-scrapping solution written in Swift.

</div><br><br><br>

## Features

- [x] Simple API
- [x] Concurrently working spider instances
- [x] Automatic request repeat and slow-down when requested by the server
- [x] Customizable network layer (defaults to `URLSession`)
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

