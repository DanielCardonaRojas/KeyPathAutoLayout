# KeypathAutoLayout

![](https://img.shields.io/github/v/tag/DanielCardonaRojas/KeyPathAutoLayout)

A NSLayoutConstraint abstraction  allowing better reuse and easy composition of layout rules.

It's a simple Autolayout DSL  ready for any cocoa application. 


Don't want to include a dependency into your project? This implementation is contained  withing a single file. Just copy paste the contents of [this](https://raw.githubusercontent.com/DanielCardonaRojas/KeyPathAutoLayout/master/Sources/KeypathAutoLayout/NSLayoutConstraint%2BKeyPath.swift) file  into your project.

Want to learn more first inspiration came from [this](https://www.objc.io/blog/2018/10/30/auto-layout-with-key-paths/) objc.io article 


## Features

- Uses a compact Keypath API
- Completely extensible (just add more constraint rule types as an extension of ```[Constraint]```)
- Easy reuse, create a group of Constraints and reuse applying to any other 2 views.
- Almost identical to what you've already been doing with programmatic constraints. (Will still need to addSubview and set autoRezisingMask to false)
- Works with safe area layoutGuides.
- Uses function builder syntax (same that powers declarative SwiftUI)



## Examples

**Position adjacent siblings**

![](adjacent_siblings.png)
```swift
let centeredBox = box(.green)
let leftBox = box(.blue)
let rightBox = box(.cyan)

container.addSubview(centeredBox)
container.addSubview(leftBox)
container.addSubview(rightBox)

NSLayoutConstraint.activate {
    leftBox.relativeTo(centeredBox, positioned: .toLeft(spacing: 40) + .equallySized() + .centerY())
    centeredBox.relativeTo(container, positioned: .centered)
    rightBox.relativeTo(centeredBox, positioned: .toRight(spacing: 50) + .equallySized() + .centerY())
    centeredBox.constrainedBy(.constantHeight(30) + .aspectRatio(1.0))
}

```

**Insetting**

![](inset.png)
```swift
let b1 = box(.red)
container.addSubview(b1)

NSLayoutConstraint.activate {
    b1.relativeTo(container, positioned: .inset(by: 7.0))
}
```

**Easy reuse**

![](vertical_stacking.png)

```swift
let b1 = box(.green)
let b2 = box(.red)
let b3 = box(.blue)

container.addSubview(b1)
container.addSubview(b2)
container.addSubview(b3)

let equallySizedUnder = .equallySized() + .centerX() + .below(spacing: 40)

NSLayoutConstraint.activate {
    b1.relativeTo(container, positioned: .centerX() + .top(margin: 10))
    b1.constrainedBy(.constantHeight(30) + .aspectRatio(1.0))
    b2.relativeTo(b1, positioned: equallySizedUnder)
    b3.relativeTo(b2, positioned: equallySizedUnder)
}

```

**Rows and columns**

There is also built in helpers to create row and column layouts, more concisely like this:

![](vertical_stacking.png)
```swift
NSLayoutConstraint.activate {
    b1.relativeTo(container, positioned: .centerX() + .top(margin: 10))
    [b1, b2, b3].column(crossAxis: .centerX() + .width(), spacing: 10, mainAxis: .height())
}
```
