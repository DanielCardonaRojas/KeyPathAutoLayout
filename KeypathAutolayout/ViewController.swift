//
//  ViewController.swift
//  KeypathAutolayout
//
//  Created by Daniel Cardona Rojas on 15/11/19.
//  Copyright © 2019 Daniel Cardona Rojas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .fill
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        displayExamples()
    }

    private func displayExamples() {
        let example1Container = container(name: "Ex1")
        let example2Container = container(name: "Ex2")
        let example3Container = container(name: "Ex3")

        view.addSubview(example1Container)
        view.addSubview(example2Container)
        view.addSubview(example3Container)

        let fillHorizontal = [
            equal(\.centerXAnchor),
            equal(\.widthAnchor, constant: -40)
        ]

        let equallySizedUnder = .equallySized() + .centerX() + .below(spacing: 40)

        NSLayoutConstraint.activating([
            example1Container.constrainedBy(.height(60)),
            example1Container.relativeTo(view, positioned: fillHorizontal + [equal(\.topAnchor, constant: 60)]),
            example2Container.relativeTo(example1Container, positioned: equallySizedUnder),
            example3Container.relativeTo(example2Container, positioned: equallySizedUnder),
        ])

        // Call examples
        exampleInset(container: example1Container)
        exampleSibling(container: example2Container)
        exampleCorners(container: example3Container)
    }

    func box(_ color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.accessibilityIdentifier = "BOX"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func label(_ text: String, color: UIColor) -> UILabel {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = text
        lbl.textColor = .black
        lbl.backgroundColor = color
        return lbl
    }

    func container(name: String) -> UIView {
        let view = UIView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.backgroundColor = .lightGray
        view.accessibilityIdentifier = "CONTAINER \(name)"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func exampleCorners(container: UIView) {
        let label1 = label("TopLeft", color: .yellow)
        let label2 = label("BottomRight", color: .cyan)

        container.addSubview(label1)
        container.addSubview(label2)

        NSLayoutConstraint.activating([
            label1.relativeTo(container, positioned: .topLeft()),
            label2.relativeTo(container, positioned: .bottomRight(rightMargin: 20))
        ])
    }


    func exampleInset(container: UIView) {
        let b1 = box(.red)
        let b2 = box(.cyan)
        container.addSubview(b1)
        container.addSubview(b2)
        
        NSLayoutConstraint.activating([
            b1.relativeTo(container, positioned: .inset(by: 7.0)),
            b2.relativeTo(container, positioned: .topLeft(topMargin: 10)),
            b2.constrainedBy(.aspectRatio(1.0) + .height(30))
        ])
    }

    func exampleSibling(container: UIView) {
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
    }
}

