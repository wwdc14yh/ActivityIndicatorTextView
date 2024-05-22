//  Created by y H on 2024/5/22.

import UIKit
import UIComponent
import ActivityIndicatorTextView

public struct ActivityIndicatorText: Component {
    /// 循環頻率
    let interval: CGFloat
    /// 占位符
    let placeholder: ActivityIndicatorTextView.Content
    /// 循環的點
    let dotsProvider: ActivityIndicatorTextView.DotsProvider
    /// 點的對齊位置
    let dotsPosition: ActivityIndicatorTextView.DotPosition
    /// 間距
    let spacing: CGFloat
    /// 默認字體
    let font: ActivityIndicatorTextView.Font
    /// 默認顏色
    let color: UIColor

    public init(
        placeholder: ActivityIndicatorTextView.Content,
        dotsProvider: ActivityIndicatorTextView.DotsProvider = .default(.case2),
        dotsPosition: ActivityIndicatorTextView.DotPosition = .rightBottom,
        spacing: CGFloat = 0,
        interval: CGFloat = 0.2,
        font: ActivityIndicatorTextView.Font = ActivityIndicatorTextView.Font(),
        color: UIColor = .label
    ) {
        self.interval = interval
        self.placeholder = placeholder
        self.dotsProvider = dotsProvider
        self.dotsPosition = dotsPosition
        self.spacing = spacing
        self.font = font
        self.color = color
    }

    public func layout(_ constraint: Constraint) -> ActivityIndicatorTextRenderNode {
        ActivityIndicatorTextRenderNode(
            interval: interval,
            placeholder: placeholder,
            dotsProvider: dotsProvider,
            dotsPosition: dotsPosition,
            spacing: spacing,
            font: font,
            color: color,
            size: ActivityIndicatorTextView.calculateIntrinsicContentSize(
                with: placeholder,
                dotsProvider: dotsProvider,
                font: font,
                spacing: spacing
            ).bound(to: constraint)
        )
    }
}

public struct ActivityIndicatorTextRenderNode: RenderNode {
    /// 循環頻率
    let interval: CGFloat
    /// 占位符
    let placeholder: ActivityIndicatorTextView.Content
    /// 循環的點
    let dotsProvider: ActivityIndicatorTextView.DotsProvider
    /// 點的對齊位置
    let dotsPosition: ActivityIndicatorTextView.DotPosition
    /// 間距
    let spacing: CGFloat
    /// 默認字體
    let font: ActivityIndicatorTextView.Font
    /// 默認顏色
    let color: UIColor

    public let size: CGSize

    public func makeView() -> ActivityIndicatorTextView {
        ActivityIndicatorTextView(
            placeholder: placeholder,
            dotsProvider: dotsProvider,
            dotsPosition: dotsPosition,
            spacing: spacing,
            interval: interval,
            font: font,
            color: color
        )
    }
}
