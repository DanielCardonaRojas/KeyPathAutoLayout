//
//  KeyPathAutoLayout.swift
//  Spotit
//
//  Created by Daniel Cardona Rojas on 14/11/19.
//  Copyright © 2019 Daniel Cardona Rojas. All rights reserved.
//

import UIKit

// MARK: - Applying Constraints
extension UIView {
    public func relativeTo(
        _ view: UIView, positioned constraints: [Constraint],
        relation: Constraint.Relation = .equal, priority: UILayoutPriority = .required
    ) -> [NSLayoutConstraint] {
        let constraints = Constraint.resolveConstraints(
            self, view, relation: relation, constraints: constraints)
        constraints.forEach({ $0.priority = priority })
        return constraints
    }

    public func constrainedBy(
        _ constraints: [Constraint], relation: Constraint.Relation = .equal,
        priority: UILayoutPriority = .required
    )
        -> [NSLayoutConstraint]
    {
        let constraints = Constraint.resolveConstraints(
            self, self, relation: relation, constraints: constraints)
        constraints.forEach({ $0.priority = priority })
        return constraints
    }
}

// MARK: - Constraints on Collections
extension Array where Element: UIView {
    public func equalIn(_ dimensionConstraints: [Constraint]) -> [NSLayoutConstraint] {
        var constraints = [[NSLayoutConstraint]]()

        if count == 1 { return [] }

        for k in 1...(count - 1) {
            let previousField = self[k - 1]
            let currentField = self[k]
            constraints.append(
                currentField.relativeTo(previousField, positioned: dimensionConstraints))
        }

        return constraints.flatMap({ $0 })

    }
    /**
     Create constraints to space items in a column

     - Parameter crossAxis: The cross axis aligment used, e.g .centerX() + .width(), .left(), .right()
     - Returns: A list of constraints ready to be activated


     */
    public func column(
        crossAxis: [Constraint], spacing: CGFloat, mainAxis: [Constraint] = .height()
    ) -> [NSLayoutConstraint] {
        let equallySizedAndBelow: [Constraint] = crossAxis + mainAxis + .below(spacing: spacing)
        var constraints = [[NSLayoutConstraint]]()

        if count == 1 { return [] }

        for k in 1...(count - 1) {
            let previousField = self[k - 1]
            let currentField = self[k]
            constraints.append(
                currentField.relativeTo(previousField, positioned: equallySizedAndBelow))
        }

        return constraints.flatMap({ $0 })
    }

    public func row(crossAxis: [Constraint], spacing: CGFloat, mainAxis: [Constraint] = .height())
        -> [NSLayoutConstraint]
    {
        let spaced: [Constraint] = crossAxis + mainAxis + .toRight(spacing: spacing)
        var constraints = [[NSLayoutConstraint]]()

        if count == 1 { return [] }

        for k in 1...(count - 1) {
            let previousField = self[k - 1]
            let currentField = self[k]
            constraints.append(currentField.relativeTo(previousField, positioned: spaced))
        }

        return constraints.flatMap({ $0 })
    }
}

extension Constraint.Configuration {
    public func bypassWhen(_ bool: Bool) -> [Constraint] {
        if bool {
            return []
        } else {
            return self
        }
    }

}

// MARK: - Constraint
public class Constraint {
    public enum Relation {
        case equal, greaterThanOrEqual, lessThanOrEqual
    }

    typealias ConstraintBuilder = (UIView, UIView, Relation) -> NSLayoutConstraint

    public typealias Configuration = [Constraint]
    private var constraint: ConstraintBuilder

    init(_ constraint: @escaping ConstraintBuilder) {
        self.constraint = constraint
    }

    public func callAsFunction(_ params: (UIView, UIView, Relation)) -> NSLayoutConstraint {
        let layoutConstraint = constraint(params.0, params.1, params.2)
        return layoutConstraint
    }

    @discardableResult
    public func resolve(_ view1: UIView, _ view2: UIView, _ relation: Relation)
        -> NSLayoutConstraint
    {
        let layoutConstraint = constraint(view1, view2, relation)
        return layoutConstraint
    }

    @discardableResult
    static func resolveConstraints(
        _ view1: UIView, _ view2: UIView, relation: Relation, constraints: [Constraint]
    )
        -> [NSLayoutConstraint]
    {
        let layoutConstraints = constraints.map { (c: Constraint) -> NSLayoutConstraint in
            let layoutConstraint = c.resolve(view1, view2, relation)
            return layoutConstraint
        }

        return layoutConstraints
    }

    public static func paired<Anchor, AnchorType>(
        _ keyPath: KeyPath<UIView, Anchor>,
        _ otherKeyPath: KeyPath<UIView, Anchor>? = nil,
        constant: CGFloat = 0,
        multiplier: CGFloat? = nil,
        priority: UILayoutPriority? = nil
    ) -> Constraint where Anchor: NSLayoutAnchor<AnchorType> {

        return Constraint { view, otherView, constraintRelation in

            var partialConstraint: NSLayoutConstraint
            let otherKeyPath = otherKeyPath ?? keyPath

            switch constraintRelation {
            case .equal:
                partialConstraint = view[keyPath: keyPath].constraint(
                    equalTo: otherView[keyPath: otherKeyPath], constant: constant)
            case .greaterThanOrEqual:
                partialConstraint = view[keyPath: keyPath].constraint(
                    greaterThanOrEqualTo: otherView[keyPath: otherKeyPath], constant: constant)
            case .lessThanOrEqual:
                partialConstraint = view[keyPath: keyPath].constraint(
                    lessThanOrEqualTo: otherView[keyPath: otherKeyPath], constant: constant)
            }

            return NSLayoutConstraint.adjust(
                from: partialConstraint,
                withMultiplier: multiplier,
                priority: priority)

        }

    }

    public static func unpaired<Anchor>(
        _ keyPath: KeyPath<UIView, Anchor>,
        constant: CGFloat = 0,
        multiplier: CGFloat? = nil,
        priority: UILayoutPriority? = nil
    ) -> Constraint where Anchor: NSLayoutDimension {
        return Constraint { view, _, constraintRelation in
            var partialConstraint: NSLayoutConstraint

            switch constraintRelation {
            case .equal:
                partialConstraint = view[keyPath: keyPath].constraint(equalToConstant: constant)
            case .greaterThanOrEqual:
                partialConstraint = view[keyPath: keyPath].constraint(
                    greaterThanOrEqualToConstant: constant)
            case .lessThanOrEqual:
                partialConstraint = view[keyPath: keyPath].constraint(
                    lessThanOrEqualToConstant: constant)
            }

            return NSLayoutConstraint.adjust(
                from: partialConstraint,
                withMultiplier: multiplier,
                priority: priority)
        }
    }

    public static func equal<L, Axis>(_ to: KeyPath<UIView, L>, constant: CGFloat = 0.0)
        -> Constraint where L: NSLayoutAnchor<Axis>
    {
        return paired(
            to, constant: constant, multiplier: nil, priority: nil)
    }

    public static func equal<L>(
        _ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>, constant: CGFloat = 0,
        multiplier: CGFloat? = nil
    ) -> Constraint where L: NSLayoutDimension {
        return paired(
            from, to, constant: constant, multiplier: multiplier,
            priority: nil)
    }
}

// MARK: - Function Builder
@_functionBuilder
public struct ConstraintBuilder {
    public static func buildBlock(_ configurations: [NSLayoutConstraint]...) -> [NSLayoutConstraint]
    {
        return configurations.flatMap({ $0 })
    }
}

extension NSLayoutConstraint {

    public static func activate(@ConstraintBuilder _ content: () -> [NSLayoutConstraint]) {
        let cons = content()
        NSLayoutConstraint.activate(cons)
    }

    public static func activating(_ constraints: [[NSLayoutConstraint]]) {
        let cons = constraints.flatMap { $0 }
        NSLayoutConstraint.activate(cons)
    }

    static func adjust(
        from constraint: NSLayoutConstraint,
        withMultiplier multiplier: CGFloat? = nil,
        priority: UILayoutPriority?
    ) -> NSLayoutConstraint {
        var constraint = constraint
        if let multiplier = multiplier {
            constraint = NSLayoutConstraint(
                item: constraint.firstItem as Any,
                attribute: constraint.firstAttribute,
                relatedBy: constraint.relation,
                toItem: constraint.secondItem,
                attribute: constraint.secondAttribute,
                multiplier: multiplier,
                constant: constraint.constant)
        }

        if let priority = priority {
            constraint.priority = priority
        }

        return constraint
    }
}

// MARK: - Common Configurations
extension Constraint.Configuration {
    public static func inset(by padding: CGFloat) -> [Constraint] {
        .inset(by: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
    }

    public static func top(margin: CGFloat = 0) -> [Constraint] {
        [.equal(\.topAnchor, constant: margin)]
    }

    public static func bottom(margin: CGFloat = 0) -> [Constraint] {
        [.equal(\.bottomAnchor, constant: -margin)]
    }

    public static func left(margin: CGFloat = 0) -> [Constraint] {
        [.equal(\.leftAnchor, constant: margin)]
    }

    public static func right(margin: CGFloat = 0) -> [Constraint] {
        [.equal(\.rightAnchor, constant: -margin)]
    }

    // MARK: Safe Layout guide
    public static func safeTop(margin: CGFloat = 0) -> [Constraint] {
        [.equal(\.safeTopAnchor, constant: margin)]
    }

    public static func safeBottom(margin: CGFloat = 0) -> [Constraint] {
        [.equal(\.safeBottomAnchor, constant: -margin)]
    }

    public static func safeLeft(margin: CGFloat = 0) -> [Constraint] {
        [.equal(\.safeLeftAnchor, constant: margin)]
    }

    public static func safeRight(margin: CGFloat = 0) -> [Constraint] {
        [.equal(\.safeRightAnchor, constant: -margin)]
    }

    public static func inset(by edgeInsets: UIEdgeInsets) -> [Constraint] {
        [
            .equal(\.topAnchor, constant: edgeInsets.top),
            .equal(\.rightAnchor, constant: -abs(edgeInsets.right)),
            .equal(\.leftAnchor, constant: abs(edgeInsets.left)),
            .equal(\.bottomAnchor, constant: -abs(edgeInsets.bottom)),
        ]
    }

    public static var centered: [Constraint] {
        [.equal(\.centerYAnchor), .equal(\.centerXAnchor)]
    }

    // MARK: Siblings
    public static func toLeft(spacing: CGFloat = 0) -> [Constraint] {
        [
            .paired(
                \.rightAnchor, \.leftAnchor, constant: -spacing,
                multiplier: nil, priority: nil)
        ]
    }

    public static func toRight(spacing: CGFloat = 0) -> [Constraint] {
        [.paired(\.leftAnchor, \.rightAnchor, constant: spacing)]
    }

    public static func below(spacing: CGFloat = 0) -> [Constraint] {
        [.paired(\.topAnchor, \.bottomAnchor, constant: spacing)]
    }

    public static func above(spacing: CGFloat = 0) -> [Constraint] {
        [.paired(\.bottomAnchor, \.topAnchor, constant: -spacing)]
    }

    public static func centerY(offset: CGFloat = 0) -> [Constraint] {
        [.equal(\.centerYAnchor, constant: offset)]
    }

    public static func centerX(offset: CGFloat = 0) -> [Constraint] {
        [.equal(\.centerXAnchor, constant: offset)]
    }

    public static func equallySized() -> [Constraint] {
        [.equal(\.widthAnchor), .equal(\.heightAnchor)]
    }

    public static func height(constant: CGFloat = 0, multiplier: CGFloat = 1) -> [Constraint] {
        [.paired(\.heightAnchor, constant: constant, multiplier: multiplier)]
    }

    public static func width(constant: CGFloat = 0, multiplier: CGFloat = 1) -> [Constraint] {
        [.paired(\.widthAnchor, constant: constant, multiplier: multiplier)]
    }
    // MARK: Self applied
    public static func constantHeight(_ height: CGFloat) -> [Constraint] {
        [.unpaired(\.heightAnchor, constant: height)]
    }

    public static func constantWidth(_ constant: CGFloat = 0, multiplier: CGFloat = 1)
        -> [Constraint]
    {
        [.unpaired(\.widthAnchor, constant: constant)]
    }

    public static func aspectRatio(_ ratio: CGFloat) -> [Constraint] {
        [.equal(\.heightAnchor, \.widthAnchor, constant: 0, multiplier: ratio)]
    }
}

// MARK: - Anchor shorthands
extension UIView {
    var safeTopAnchor: NSLayoutYAxisAnchor {
        return safeAreaLayoutGuide.topAnchor
    }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        return safeAreaLayoutGuide.bottomAnchor
    }

    var safeLeftAnchor: NSLayoutXAxisAnchor {
        return safeAreaLayoutGuide.leftAnchor
    }
    var safeRightAnchor: NSLayoutXAxisAnchor {
        return safeAreaLayoutGuide.rightAnchor
    }
}
