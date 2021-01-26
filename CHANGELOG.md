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

## [0.1.0](https://github.com/DenTelezhkin/Swarm/releases/tag/0.1.0)

* Initial release
