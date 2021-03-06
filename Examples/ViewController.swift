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
        let example4Container = container(name: "Ex4")
        let example5Container = container(name: "Ex5")
        let containerSpacing: CGFloat = 40

        view.addSubview(example1Container)
        view.addSubview(example2Container)
        view.addSubview(example3Container)
        view.addSubview(example4Container)

        let fillHorizontal = .centerX() + .width(constant: -40)

        let equallySizedUnder = .equallySized() + .centerX() + .below(spacing: containerSpacing)

        NSLayoutConstraint.activate {
            example1Container.constrainedBy(.constantHeight(60))
            example1Container.relativeTo(view, positioned: fillHorizontal + .top(margin: 60))
            [example1Container, example2Container, example3Container].column(crossAxis: .centerX() + .width(), spacing: 40)
            example4Container.relativeTo(example3Container, positioned: .below(spacing: 20))
            example4Container.constrainedBy(.constantWidth(70) + .constantHeight(200))
        }

        // Call examples
        exampleInset(container: example1Container)
        exampleSibling(container: example2Container)
        exampleCorners(container: example3Container)
        exampleVerticalStacking(container: example4Container)
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

    func exampleVerticalStacking(container: UIView) {
        let b1 = box(.green)
        let b2 = box(.red)
        let b3 = box(.blue)

        container.addSubview(b1)
        container.addSubview(b2)
        container.addSubview(b3)

        let equallySizedUnder = .equallySized() + .centerX() + .below(spacing: 40)

        NSLayoutConstraint.activate {
            b1.relativeTo(container, positioned: .centerX() + .top(margin: 10))
            [b1, b2, b3].column(crossAxis: .centerX() + .width(), spacing: 10, mainAxis: .height())
        }
    }

    func exampleCorners(container: UIView) {
        let label1 = label("TopLeft", color: .yellow)
        let label2 = label("BottomRight", color: .cyan)

        container.addSubview(label1)
        container.addSubview(label2)

        NSLayoutConstraint.activate {
            label1.relativeTo(container, positioned: .top() + .left())
            label2.relativeTo(container, positioned: .bottom() + .right(margin: 20))
        }
    }


    func exampleInset(container: UIView) {
        let b1 = box(.red)
        container.addSubview(b1)

        NSLayoutConstraint.activate {
            b1.relativeTo(container, positioned: .inset(by: 7.0))
        }
    }

    func exampleSibling(container: UIView) {
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
    }
}

