
<img align="left" width="200" height="200" src="icon.png">
  
# Swarm
Swarm is fast, simple and modular web-scrapping solution written in Swift.

<br><br><br>

## Features

- [x] Simple API
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

## Credits 

Icon created by: 

<a href="https://www.freepik.com/vectors/cartoon">Cartoon vector created by brgfx - www.freepik.com</a>
