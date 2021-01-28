## Next

### Added

* Linux support
* `ScrappableURL.userInfo` property for storing values or objects related to this scrappable URL
* `Swarm.cooldown` property, that allows to customize how cooldown is executed. For example, when using Swarm from Vapor app, which itself uses SwiftNIO for scheduling tasks, cooldown property can be setup in following way:

```swift
swarm.cooldown = { interval, closure in
    eventLoop.scheduleTask(in: TimeAmount.seconds(Int64(interval)), closure)
}
```

### Changed

* Absence of response and data is now treated as failure for network request ( request timeout ), and request is retried `configuration.delayedRequestRetries` times after `configuration.delayedRetryDelay`

### Fixed

* Action log for previous requests is now properly stored, thus allowing correct number of request retries.

## [0.1.0](https://github.com/DenTelezhkin/Swarm/releases/tag/0.1.0)

* Initial release
