//
//  ViewController.swift
//  Examples
//
//  Created by y H on 2024/5/22.
//

import UIKit
import UIComponent
import ActivityIndicatorTextView
import UIComponentActivityIndicatorTextView

class ViewController: UIViewController {
    
    let componentView = ComponentView()
    
    let slider = UISlider()
    
    var component: any Component {
        VStack(spacing: 15, justifyContent: .center, alignItems: .start) {
            for c in ActivityIndicatorTextView.DefaultDots.allCases {
                ActivityIndicatorText(
                    placeholder: .string("Loading"),
                    dotsProvider: .default(c),
                    spacing: 3,
                    interval: 0.12,
                    color: .secondaryLabel
                )
                .update { $0.startActivityIndicator() }
            }
            ActivityIndicatorText(
                placeholder: .string("Loading"),
                dotsProvider: .progress(start: nil, fill: " ", empty: " ", end: nil, lead: "🛫", reachLead: nil, count: 10),
                spacing: 3,
                ignoresIndicatorContentSize: true,
                interval: 0.1,
                font: .init(style: .regular),
                color: .secondaryLabel
            )
            .update { view in
                view.startActivityIndicator()
            }
            ViewComponent(generator: self.slider)
                .maximumValue(1)
                .minimumValue(0)
                .size(width: 200, height: 31)
            ActivityIndicatorText(
                placeholder: .string("Downloading"),
                dotsProvider: .progress(start: "🌎", fill: "·", empty: " ", end: "🌑", lead: "🚀", reachLead: "🏁", extra: {
                    "\(String(format: "%.1f", ((CGFloat($0) / CGFloat($1)) * 100.0)))% "
                }, count: 15),
                dotsPosition: .leftCenter,
                spacing: 3,
                interval: 0.15,
                font: .init(style: .regular),
                color: .secondaryLabel
            )
            .id("rock.progress")
        }
        .inset(left: 20)
        .size(width: .fill)
    }
    
    override func loadView() {
        self.view = componentView
        slider.addTarget(self, action: #selector(self.valueChange), for: .valueChanged)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        // Do any additional setup after loading the view.
    }
    
    @objc func valueChange() {
        guard let activityIndicatorView = componentView.visibleView(id: "rock.progress") as? ActivityIndicatorTextView else { return }
        activityIndicatorView.progress = CGFloat(slider.value)
        if activityIndicatorView.progress == 1 {
            activityIndicatorView.placeholder = .string("Done.")
        } else {
            activityIndicatorView.placeholder = .string("Downloading")
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        reloadComponent()
    }
    
    func reloadComponent() {
        componentView.component = component
    }

}

