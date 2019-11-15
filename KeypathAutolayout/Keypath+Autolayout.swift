//
//  KeyPathAutoLayout.swift
//  Spotit
//
//  Created by Daniel Cardona Rojas on 14/11/19.
//  Copyright © 2019 Daniel Cardona Rojas. All rights reserved.
//

import UIKit

public class Constraint {
    typealias ConstraintBuilder = (UIView, UIView) -> NSLayoutConstraint
    public typealias Configuration = [Constraint]
    private var constraint: ConstraintBuilder

    init(_ constraint: @escaping ConstraintBuilder) {
        self.constraint = constraint
    }

    @discardableResult
    func resolve(_ view1: UIView, _ view2: UIView) -> NSLayoutConstraint {
        let layoutConstraint = constraint(view1, view2)
        return layoutConstraint
    }

    @discardableResult
    static func resolveConstraints(_ view1: UIView, _ view2: UIView, constraints: [Constraint]) -> [NSLayoutConstraint] {
        let layoutConstraints = constraints.map { (c: Constraint) -> NSLayoutConstraint in
            let layoutConstraint = c.resolve(view1, view2)
            return layoutConstraint
        }

        return layoutConstraints
    }
}

extension NSLayoutConstraint {
    public static func activating(_ constraints: [[NSLayoutConstraint]]) {
        let cons = constraints.flatMap({ $0 })
        NSLayoutConstraint.activate(cons)
    }
}


// MARK: - Constraint Primitives: Axis
public func equal<L, Axis>(_ to: KeyPath<UIView, L>, constant: CGFloat = 0.0) -> Constraint where L: NSLayoutAnchor<Axis> {
    return Constraint { view1, view2 in
        view1[keyPath: to].constraint(equalTo: view2[keyPath: to], constant: constant)
    }
}

public func equal<L, Axis>(_ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>, constant: CGFloat = 0) -> Constraint where L: NSLayoutAnchor<Axis> {
    return Constraint { view1, view2 in
        view1[keyPath: from].constraint(equalTo: view2[keyPath: to], constant: constant)
    }
}

// MARK: - Constraint Primitives: Dimensions
public func equalToConstant<L>(_ keyPath: KeyPath<UIView, L>, constant: CGFloat) -> Constraint where L: NSLayoutDimension {
    return Constraint { view1, _ in
        view1[keyPath: keyPath].constraint(equalToConstant: constant)
    }
}

public func equal<L>(_ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>, multiplier: CGFloat = 1, constant: CGFloat = 0) -> Constraint where L: NSLayoutDimension {
    return Constraint { view1, view2 in
        let dim1 = view1[keyPath: from]
        let dim2 = view2[keyPath: to]
        return dim1.constraint(equalTo: dim2, multiplier: multiplier, constant: constant)
    }
}

// MARK: - Common Configurations
extension Constraint.Configuration {
    public static func bottomRight(rightMargin: CGFloat = 0, bottomMargin: CGFloat = 0) -> [Constraint] {
        [equal(\.bottomAnchor, constant: -bottomMargin),
         equal(\.rightAnchor, constant: -rightMargin),
        ]
    }

    public static func bottomLeft(leftMargin: CGFloat = 0, bottomMargin: CGFloat = 0) -> [Constraint] {
        [
            equal(\.bottomAnchor, constant: -bottomMargin),
            equal(\.leftAnchor, constant: leftMargin),
        ]
    }

    public static func topLeft(leftMargin: CGFloat = 0, topMargin: CGFloat = 0) -> [Constraint] {
        [
            equal(\.topAnchor, constant: topMargin),
            equal(\.leftAnchor, constant: leftMargin),
        ]
    }
    public static func topRight(rightMargin: CGFloat = 0, topMargin: CGFloat = 0) -> [Constraint] {
        [
            equal(\.topAnchor, constant: topMargin),
            equal(\.rightAnchor, constant: -rightMargin),
        ]
    }

    public static func inset(by padding: CGFloat) -> [Constraint] {
        .inset(by: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
    }

    public static func inset(by edgeInsets: UIEdgeInsets) -> [Constraint] {
        [
            equal(\.topAnchor, constant: edgeInsets.top),
            equal(\.rightAnchor, constant: -abs(edgeInsets.right)),
            equal(\.leftAnchor, constant: abs(edgeInsets.left)),
            equal(\.bottomAnchor, constant: -abs(edgeInsets.bottom)),
        ]
    }

    public static var centered: [Constraint] {
        [
            equal(\.centerYAnchor),
            equal(\.centerXAnchor),
        ]
    }

    public static func toLeft(spacing: CGFloat = 0) -> [Constraint] {
        [equal(\.rightAnchor, \.leftAnchor, constant: -spacing)]
    }

    public static func toRight(spacing: CGFloat = 0) -> [Constraint] {
        [equal(\.leftAnchor, \.rightAnchor, constant: spacing)]
    }

    public static func below(spacing: CGFloat = 0) -> [Constraint] {
        [equal(\.topAnchor, \.bottomAnchor, constant: spacing)]
    }

    public static func above(spacing: CGFloat = 0) -> [Constraint] {
        [equal(\.bottomAnchor, \.topAnchor, constant: -spacing)]
    }

    public static func equallySized() -> [Constraint] {
        [equal(\.widthAnchor), equal(\.heightAnchor)]
    }

    public static func centerY(offset: CGFloat = 0) -> [Constraint] {
        [equal(\.centerYAnchor, constant: offset)]
    }

    public static func centerX(offset: CGFloat = 0) -> [Constraint] {
        [equal(\.centerXAnchor, constant: offset)]
    }

    // MARK: - Self applying combinators
    public static func height(_ height: CGFloat) -> [Constraint] {
        [equalToConstant(\.heightAnchor, constant: height)]
    }

    public static func width(_ height: CGFloat) -> [Constraint] {
        [equalToConstant(\.widthAnchor, constant: height)]
    }

    public static func aspectRatio(_ ratio: CGFloat) -> [Constraint] {
        [equal(\.heightAnchor, \.widthAnchor, multiplier: ratio, constant: 0)]
    }
}


// MARK: - Generic
extension UIView {
    func relativeTo(_ view: UIView, positioned constraints: [Constraint]) -> [NSLayoutConstraint] {
        return Constraint.resolveConstraints(self, view, constraints: constraints)
    }

    func constrainedBy(_ constraints: [Constraint]) -> [NSLayoutConstraint] {
        return Constraint.resolveConstraints(self, self, constraints: constraints)
    }
}

// MARK: - Self referencing combinators
extension UIView {
    public func heightToWidthRatio(_ ratio: CGFloat) -> NSLayoutConstraint {
        let ratioConstraint = equal(\.heightAnchor, \.widthAnchor, multiplier: ratio).resolve(self, self)
        return ratioConstraint
    }

    public func widthToHeightRatio(_ ratio: CGFloat) -> NSLayoutConstraint {
        let ratioConstraint = equal(\.heightAnchor, \.widthAnchor, multiplier: ratio).resolve(self, self)
        return ratioConstraint
    }

    public var squared: NSLayoutConstraint {
        return widthToHeightRatio(1.0)
    }

    public func constantHeight(_ height: CGFloat) -> NSLayoutConstraint {
        return heightAnchor.constraint(equalToConstant: height)
    }

    public func constantWidth(_ width: CGFloat) -> NSLayoutConstraint {
        return widthAnchor.constraint(equalToConstant: width)
    }

}
