# NSLayoutConstraint + KeyPath

A very lightweight DSL for autolayout for your swift applications, exposed as a set of extension.


Don't want to include a dependency into your project? This implementation is under 200 LOC. So go ahead and copy paste the contents of [this](https://raw.githubusercontent.com/DanielCardonaRojas/KeyPathAutoLayout/master/KeypathAutolayout/NSLayoutConstraint%2BKeyPath.swift) file as NSLayoutConstraint+KeyPath.swift into your project.
This implementation is under 200 LOC.

Want to learn more first inspiration came from [this](https://www.objc.io/blog/2018/10/30/auto-layout-with-key-paths/) objc.io article 



## Features

- Completely extensible (just add more constraint relations as an extension of ```[Constraint]```)
- Easy reuse, create a group of Constraints and reuse applying to any other 2 views.
- Almost identical to what you've already been doing with programmatic constraints. (Will still need to addSubview and set autoRezisingMask to false)



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

NSLayoutConstraint.activating([
	leftBox.relativeTo(centeredBox, positioned: .toLeft(spacing: 40) + .equallySized() + .centerY()),
	centeredBox.relativeTo(container, positioned: .centered),
	rightBox.relativeTo(centeredBox, positioned: .toRight(spacing: 50) + .equallySized() + .centerY()),
	centeredBox.constrainedBy(.height(30) + .aspectRatio(1.0))
])
```

**Insetting**

![](inset.png)
```swift
let b1 = box(.red)
container.addSubview(b1)

NSLayoutConstraint.activating([
	b1.relativeTo(container, positioned: .inset(by: 7.0)),
])
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

        NSLayoutConstraint.activating([
            b1.relativeTo(container, positioned: [
                equal(\.centerXAnchor),
                equal(\.topAnchor, constant: 10)
            ]),
            b1.constrainedBy(.height(30) + .aspectRatio(1.0)),
            b2.relativeTo(b1, positioned: equallySizedUnder),
            b3.relativeTo(b2, positioned: equallySizedUnder)
        ])
```
