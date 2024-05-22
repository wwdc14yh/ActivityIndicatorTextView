// The Swift Programming Language
// https://docs.swift.org/swift-book
// Created by y H on 2024/5/21.

import UIKit
import Combine

public final class ActivityIndicatorTextView: UIView {
    public typealias DotsProviderClosure = (_ offset: Int) -> Content

    public struct Font {
        public enum Style: String {
            case boldItalic, regular, bold, italic
            public var rawValue: String {
                let string = String(describing: self)
                return "Menlo-" + String(string.prefix(1).capitalized + string.dropFirst())
            }
        }

        public var style: Style
        public var size: CGFloat
        private var customFont: UIFont?
        public init(style: Style = .regular, size: CGFloat = UIFont.systemFontSize) {
            self.style = style
            self.size = size
            customFont = nil
        }

        public static func custom(font: UIFont) -> Self {
            var value = self.init()
            value.customFont = font
            return value
        }

        fileprivate func _fetchUIFont() -> UIFont? {
            return customFont ?? UIFont(name: style.rawValue, size: size)
        }
    }

    public static func calculateIntrinsicContentSize(with placeholder: Content, dotsProvider: DotsProvider, font: Font, spacing: CGFloat) -> CGSize {
        var placeholderSize: CGSize {
            placeholder
                .attributedString(font: font._fetchUIFont())
                .boundingRect(
                    with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
                    options: [.usesLineFragmentOrigin],
                    context: nil
                ).size
        }
        var dotsMaxSize: CGSize {
            var dots = [Content]()
            for i in 0 ..< dotsProvider.count {
                dots.append(dotsProvider.dot(offset: i))
            }
            print(dots)
            return dots
                .map { $0.attributedString(font: font._fetchUIFont())
                    .boundingRect(
                        with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
                        options: [.usesLineFragmentOrigin],
                        context: nil
                    ).size
                }
                .reduce(CGSize.zero) { $0.width > $1.width ? $0 : $1 }
        }
        let sizes = [placeholderSize, dotsMaxSize]
        let maxHeight = sizes.map(\.height).reduce(0) { $0 > $1 ? $0 : $1 }
        let totalWidth = sizes.map(\.width).reduce(0) { $0 + $1 }
        return CGSize(width: totalWidth + spacing, height: maxHeight)
    }

    public enum DefaultDots: CaseIterable {
        case case1, case2, case3, case4, case5, case6, case7, case8

        var staticDotsProvider: [Content] {
            switch self {
            case .case1:
                return ["⠈", "⠐", "⠠", "⢀", "⡀", "⠄", "⠂", "⠁"].map { Content.string($0) }
            case .case2:
                return ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"].map { Content.string($0) }
            case .case3:
                return ["▖", "▘", "▝", "▗"].map { Content.string($0) }
            case .case4:
                let mark = "🌐"
                let targetCount = 3
                let padding = " "
                var strings: [String] = []
                for i in 0 ... targetCount {
                    var string = (0 ... targetCount).map { _ in padding }
                    string[i] = mark
                    strings.append(string.reduce("") { $0 + $1 })
                }
                for i in 0 ... targetCount {
                    let index = targetCount - i
                    var string = (0 ... targetCount).map { _ in padding }
                    string[index] = mark
                    strings.append(string.reduce("") { $0 + $1 })
                }
                return strings.map { Content.string($0) }
            case .case5:
                return ["🕛", "🕑", "🕒", "🕓", "🕔", "🕕", "🕖", "🕗", "🕘", "🕙", "🕚"].map { Content.string($0) }
            case .case6:
                return ["🌕", "🌖", "🌗", "🌘", "🌑", "🌒", "🌓", "🌔"].map { Content.string($0) }
            case .case7:
                return "⣾⣽⣻⢿⡿⣟⣯⣷".reversed().map { .string(String($0)) }
            case .case8:
                return [".", "..", "..."].map { .string(String($0)) }
            }
        }
    }

    public enum DotPosition {
        case leftCenter, leftBottom, leftTop, rightCenter, rightBottom, rightTop
        var isLeft: Bool {
            switch self {
            case .leftBottom, .leftCenter, .leftTop: return true
            default: return false
            }
        }
    }

    public enum Content {
        case attributedText(NSAttributedString)
        case string(String)

        var isString: Bool {
            if case .string = self {
                return true
            }
            return false
        }

        func attributedString(font: UIFont?, fouceNil: Bool = false) -> NSAttributedString {
            switch self {
            case let .attributedText(nSAttributedString):
                return nSAttributedString
            case let .string(string):
                var attributes: [NSAttributedString.Key: Any] = [:]
                if !fouceNil {
                    attributes[.font] = font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
                }
                return NSAttributedString(string: string, attributes: attributes)
            }
        }
    }

    public enum DotsProvider {
        case `static`([Content])
        case dynamic(count: Int, closure: DotsProviderClosure)
        case `default`(DefaultDots)
        case progress(start: String?, fill: String, empty: String, end: String?, lead: String?, reachLead: String?, extra: ((Int, Int) -> String)? = nil, count: Int)

        var count: Int {
            switch self {
            case let .static(array):
                return array.count
            case let .dynamic(count, _):
                return count
            case let .default(defaultDots):
                return defaultDots.staticDotsProvider.count
            case let .progress(_, _, _, _, _, _, _, count: count):
                return count
            }
        }

        func dot(offset: Int) -> Content {
            switch self {
            case let .static(array):
                return array[offset]
            case let .dynamic(_, closure):
                return closure(offset)
            case let .default(defaultDots):
                return defaultDots.staticDotsProvider[offset]
            case let .progress(start, fill, empty, end, lead, reachLead, extra, count):
                var contents: [String] = []
                for index in 0 ..< count {
                    if offset > index {
                        contents.append(fill)
                    } else {
                        contents.append(empty)
                    }
                }
                if let lead {
                    contents[offset] = lead
                }
                if offset == count - 1, let reachLead {
                    contents[offset] = reachLead
                }
                if let start {
                    contents.insert(start, at: 0)
                }
                if let end {
                    contents.append(end)
                }
                if let extra {
                    let extraString = extra(offset, count - 1)
                    contents.append(extraString)
                }
                let target = contents.reduce("") { $0 + $1 }
                return .string(target)
            }
        }
    }

    /// 循環頻率
    public var interval: CGFloat

    /// 占位符
    public var placeholder: Content {
        didSet {
            _updateConfig()
        }
    }

    /// 循環的點
    public var dotsProvider: DotsProvider

    public var dotsPosition: DotPosition {
        didSet {
            _updateConfig()
        }
    }

    /// 間隔
    public var spacing: CGFloat

    public var font: Font {
        didSet {
            _updateConfig()
        }
    }

    public var color: UIColor {
        didSet {
            _updateConfig()
        }
    }

    public var currentStep: Int {
        set {
            _currentStep = newValue
            if isRuning { stopActivityIndicator() }
            _setCurrentStep(with: newValue)
        }
        get { _currentStep }
    }
    
    public var progress: CGFloat = 0 {
        didSet {
            let step = Int(floor(progress * CGFloat(dotsProvider.count - 1)))
            currentStep = step
        }
    }

    public var isRuning: Bool { _timerAnyCancellable != nil }

    public override var intrinsicContentSize: CGSize {
        let sizes = [_placeholderSize, _dotsMaxSize]
        let maxHeight = sizes.map(\.height).reduce(0) { $0 > $1 ? $0 : $1 }
        let totalWidth = sizes.map(\.width).reduce(0) { $0 + $1 }
        return CGSize(width: totalWidth + spacing, height: maxHeight)
    }

    private var _currentStep = 0
    private lazy var _timer = Timer.publish(every: interval, on: RunLoop.main, in: .common).autoconnect()
    private lazy var _placeholderLabel = UILabel()
    private lazy var _edgeLabel = UILabel()
    private var _placeholderSize: CGSize {
        placeholder
            .attributedString(font: font._fetchUIFont())
            .boundingRect(
                with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
                options: [.usesLineFragmentOrigin],
                context: nil
            ).size
    }

    private var _dotsMaxSize: CGSize {
        var dots = [Content]()
        for i in 0 ..< dotsProvider.count {
            dots.append(dotsProvider.dot(offset: i))
        }
        return dots
            .map { $0.attributedString(font: _font).boundingRect(
                with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
                options: [.usesLineFragmentOrigin],
                context: nil
            ).size }
            .reduce(CGSize.zero) { $0.width > $1.width ? $0 : $1 }
    }
    private var _timerAnyCancellable: AnyCancellable?
    private let _now: Date = .init()
    private var _font: UIFont? { font._fetchUIFont() }

    public init(
        placeholder: Content,
        dotsProvider: DotsProvider = .default(.case2),
        dotsPosition: DotPosition = .rightBottom,
        spacing: CGFloat = 0,
        interval: CGFloat = 0.2,
        font: Font = Font(),
        color: UIColor = .label
    ) {
        self.placeholder = placeholder
        self.dotsProvider = dotsProvider
        self.dotsPosition = dotsPosition
        self.spacing = spacing
        self.interval = interval
        self.font = font
        self.color = color
        super.init(frame: .zero)
        _setup()
        _updateConfig()
    }

    public required init?(coder _: NSCoder) {
        fatalError()
    }

    public func startActivityIndicator() {
        _timerAnyCancellable = _timer.sink { [weak self] in
            guard let self else { return }
            _handlerTask(with: $0)
        }
    }

    public func stopActivityIndicator() {
        _timerAnyCancellable?.cancel()
        _timerAnyCancellable = nil
    }

    public override func sizeThatFits(_: CGSize) -> CGSize {
        return intrinsicContentSize
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let startOriginY: CGFloat
        let subviews = dotsPosition.isLeft ? subviews.reversed() : subviews
        let subviewSizes = dotsPosition.isLeft ? [_dotsMaxSize, _placeholderSize] : [_placeholderSize, _dotsMaxSize]
        let fristSize = dotsPosition.isLeft ? _dotsMaxSize : _placeholderSize
        let maxHeight = subviewSizes.reduce(0.0, { $0 < $1.height ? $1.height : $0 })
        switch dotsPosition {
        case .leftCenter, .rightCenter:
            startOriginY = maxHeight / 2 - fristSize.height / 2
        case .leftBottom, .rightBottom:
            startOriginY = maxHeight - fristSize.height
        case .leftTop, .rightTop:
            startOriginY = 0
        }
        var offset: CGFloat = .zero
        for index in subviews.indices {
            let view = subviews[index]
            let viewSize = subviewSizes[index]
            view.frame = CGRect(origin: CGPoint(x: offset, y: startOriginY), size: viewSize)
            offset += viewSize.width + spacing
        }
    }

    private func _setup() {
        addSubview(_placeholderLabel)
        addSubview(_edgeLabel)
        _setCurrentStep(with: 0)
    }

    private func _setCurrentStep(with currentStep: Int) {
        guard currentStep < dotsProvider.count else { return }
        let dot = dotsProvider.dot(offset: currentStep)
        _edgeLabel.attributedText = dot.attributedString(font: _font)
    }

    private func _handlerTask(with time: Date) {
        let count = dotsProvider.count
        let tick: Int = .init(time.timeIntervalSince(_now) / interval) - 1
        let index: Int = tick % count
        let dot = dotsProvider.dot(offset: index)
        _edgeLabel.attributedText = dot.attributedString(font: _font)
        _currentStep = index
    }

    private func _updateConfig() {
        _placeholderLabel.font = _font
        _placeholderLabel.textColor = color
        _placeholderLabel.attributedText = placeholder.attributedString(font: _font)

        _edgeLabel.font = _font
        _edgeLabel.textColor = color

        setNeedsLayout()
        layoutIfNeeded()
    }

    deinit {
        stopActivityIndicator()
        _timer.upstream.connect().cancel()
    }
}
