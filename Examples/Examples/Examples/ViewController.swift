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
                dotsProvider: .progress(start: "🌎", fill: "·", empty: " ", end: "🌑", lead: "🚀", reachLead: "🏁", count: 15),
                spacing: 3,
                interval: 0.15,
                font: .init(style: .regular),
                color: .secondaryLabel
            )
            .update { view in
                view.startActivityIndicator()
            }
            ActivityIndicatorText(
                placeholder: .string("Loading"),
                dotsProvider: .progress(start: nil, fill: " ", empty: " ", end: nil, lead: "🛫", reachLead: nil, count: 10),
                spacing: 3,
                interval: 0.1,
                font: .init(style: .regular),
                color: .secondaryLabel
            )
            .update { view in
                view.startActivityIndicator()
            }
        }
        .inset(left: 20)
        .size(width: .fill)
    }
    
    override func loadView() {
        self.view = componentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        // Do any additional setup after loading the view.
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        reloadComponent()
    }
    
    func reloadComponent() {
        componentView.component = component
    }

}

