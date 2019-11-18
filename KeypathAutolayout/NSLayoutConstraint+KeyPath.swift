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
fileprivate func equal<L, Axis>(_ to: KeyPath<UIView, L>, constant: CGFloat = 0.0) -> Constraint where L: NSLayoutAnchor<Axis> {
    return Constraint { view1, view2 in
        view1[keyPath: to].constraint(equalTo: view2[keyPath: to], constant: constant)
    }
}

fileprivate func equal<L, Axis>(_ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>, constant: CGFloat = 0) -> Constraint where L: NSLayoutAnchor<Axis> {
    return Constraint { view1, view2 in
        view1[keyPath: from].constraint(equalTo: view2[keyPath: to], constant: constant)
    }
}

// MARK: - Constraint Primitives: Dimensions
fileprivate func equalToConstant<L>(_ keyPath: KeyPath<UIView, L>, constant: CGFloat) -> Constraint where L: NSLayoutDimension {
    return Constraint { view1, _ in
        view1[keyPath: keyPath].constraint(equalToConstant: constant)
    }
}

fileprivate func equal<L>(_ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>, constant: CGFloat = 0, multiplier: CGFloat = 1) -> Constraint where L: NSLayoutDimension {
    return Constraint { view1, view2 in
        let dim1 = view1[keyPath: from]
        let dim2 = view2[keyPath: to]
        return dim1.constraint(equalTo: dim2, multiplier: multiplier, constant: constant)
    }
}

fileprivate func equal<L>(_ from: KeyPath<UIView, L>, constant: CGFloat = 0, multiplier: CGFloat = 1) -> Constraint where L: NSLayoutDimension {
    return Constraint { view1, view2 in
        let dim1 = view1[keyPath: from]
        let dim2 = view2[keyPath: from]
        return dim1.constraint(equalTo: dim2, multiplier: multiplier, constant: constant)
    }
}

// MARK: - Common Configurations
extension Constraint.Configuration {
    public static func inset(by padding: CGFloat) -> [Constraint] {
        .inset(by: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
    }

    public static func top(margin: CGFloat = 0) -> [Constraint] {
        [equal(\.topAnchor, constant: margin)]
    }


    public static func bottom(margin: CGFloat = 0) -> [Constraint] {
        [equal(\.bottomAnchor, constant: -margin)]
    }

    public static func left(margin: CGFloat = 0) -> [Constraint] {
        [equal(\.leftAnchor, constant: margin)]
    }

    public static func right(margin: CGFloat = 0) -> [Constraint] {
        [equal(\.rightAnchor, constant: -margin)]
    }

    // MARK: Safe Layout guide
    public static func safeTop(margin: CGFloat = 0) -> [Constraint] {
        [equal(\.safeTopAnchor, constant: margin)]
    }

    public static func safeBottom(margin: CGFloat = 0) -> [Constraint] {
        [equal(\.safeBottomAnchor, constant: margin)]
    }

    public static func safeLeft(margin: CGFloat = 0) -> [Constraint] {
        [equal(\.safeLeftAnchor, constant: margin)]
    }

    public static func safeRight(margin: CGFloat = 0) -> [Constraint] {
        [equal(\.safeRightAnchor, constant: margin)]
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

    public static func equalWidth(constant: CGFloat = 0, multiplier: CGFloat = 1) -> [Constraint] {
        [equal(\.widthAnchor, constant: constant, multiplier: multiplier)]
    }

    public static func height(constant: CGFloat = 0, multiplier: CGFloat = 1) -> [Constraint] {
        [equal(\.heightAnchor, constant: constant, multiplier: multiplier)]
    }

    public static func width(constant: CGFloat = 0, multiplier: CGFloat = 1) -> [Constraint] {
        [equal(\.widthAnchor, constant: constant, multiplier: multiplier)]
    }
    // MARK: - Self applied
    public static func constantHeight(_ height: CGFloat) -> [Constraint] {
        [equalToConstant(\.heightAnchor, constant: height)]
    }

    public static func constantWidth(_ constant: CGFloat = 0, multiplier: CGFloat = 1 ) -> [Constraint] {
        [equalToConstant(\.widthAnchor, constant: constant)]
    }

    public static func aspectRatio(_ ratio: CGFloat) -> [Constraint] {
        [equal(\.heightAnchor, \.widthAnchor, constant: 0, multiplier: ratio)]
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

extension UIView {
    var safeTopAnchor: NSLayoutYAxisAnchor {
        return safeAreaLayoutGuide.topAnchor
    }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        return safeAreaLayoutGuide.topAnchor
    }

    var safeLeftAnchor: NSLayoutXAxisAnchor {
        return safeAreaLayoutGuide.leftAnchor
    }
    var safeRightAnchor: NSLayoutXAxisAnchor {
        return safeAreaLayoutGuide.rightAnchor
    }
}

