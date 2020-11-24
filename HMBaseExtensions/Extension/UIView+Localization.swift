import UIKit

#if canImport(RxCocoa)
import RxCocoa
import RxSwift

extension Reactive where Base: LocalizedLabel {
    /// Bindable sink for `text` property.
    public var localizedText: UIBindingObserver<Base, String?> {
        return UIBindingObserver(UIElement: self.base) { label, localizedText in
            label.localizedText = localizedText
        }
    }
}
#endif

@objc protocol Localizable {
    func localize()
}

open class LocalizedLabel: UILabel, Localizable {
    public func localize() {
        if self.attributedText != nil {
            let attr = self.attributedText?.attributes(at: 0, effectiveRange: nil)
            let attrString = NSAttributedString.init(string: LanguageManager.localizedstring(self.attributedText!.string), attributes: attr)
            self.attributedText = attrString
        } else {
            self.localizedText = LanguageManager.localizedstring(self.text.valueOr(""), comment: "")
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        localize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        localize()
    }
    
    public var localizedText: String? {
        didSet {
            guard let localizedText = localizedText else {
                text = nil
                return
            }
            if localizedText.contains("<b>") {
                let str = htmlToAttributedString(string: localizedText, font: font, color: textColor, alignment: textAlignment)
                self.attributedText = str
            } else {
                self.text = localizedText
            }
        }
    }
}

open class LocalizedButton: UIButton, Localizable {
    func localize() {
        if self.currentAttributedTitle != nil {
            let attr = self.currentAttributedTitle?.attributes(at: 0, effectiveRange: nil)
            let attrString = NSAttributedString.init(string: LanguageManager.localizedstring(self.currentAttributedTitle!.string), attributes: attr)
            self.setAttributedTitle(attrString, for: .normal)
        } else {
            self.setTitle(LanguageManager.localizedstring(self.currentTitle ?? ""), for: .normal)
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        localize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        localize()
    }
}

open class LocalizedTextField: UITextField, Localizable {
    func localize() {
        if let placeholder = self.placeholder {
            self.placeholder = LanguageManager.localizedstring(placeholder, comment: "")
        }
        if let text = self.text {
            self.text = LanguageManager.localizedstring(text, comment: "")
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        localize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        localize()
    }
}

open class LocalizesBarButtonItem: UIBarButtonItem, Localizable {
    func localize() {
        if let title = self.title {
            self.title = LanguageManager.localizedstring(title, comment: "")
        }
    }
    
    public override init() {
        super.init()
        localize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        localize()
    }
}

open class LinkTextView: UITextView {
    //    public override var canBecomeFirstResponder: Bool {
    //        return false
    //    }
    
    override public var selectedTextRange: UITextRange? {
        get {
            return nil
        }
        set { }
    }
    
    override open func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) {
            gestureRecognizer.isEnabled = false
        }
        return super.addGestureRecognizer(gestureRecognizer)
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        guard let pos = closestPosition(to: point) else { return false }
        
        guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: convertToUITextDirection(UITextLayoutDirection.left.rawValue)) else { return false }
        
        let startIndex = offset(from: beginningOfDocument, to: range.start)
        
        return attributedText.attribute(NSAttributedString.Key.link, at: startIndex, effectiveRange: nil) != nil
    }
}

open class LocalizedSegmentControl: UISegmentedControl, Localizable {
    func localize() {
        for i in 0..<numberOfSegments {
            if let key = titleForSegment(at: i) {
                setTitle(LanguageManager.localizedstring(key), forSegmentAt: i)
            }
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        localize()
    }
    
    override public init(items: [Any]?) {
        super.init(items: items)
        localize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        localize()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUITextDirection(_ input: Int) -> UITextDirection {
    return UITextDirection(rawValue: input)
}

fileprivate func htmlToAttributedString(string : String, font: UIFont, color: UIColor, alignment: NSTextAlignment) -> NSAttributedString{
    var attribStr = NSMutableAttributedString()
    var csstextalign = "left"
    switch alignment {
    case .center:
        csstextalign = "center"
    case .right:
        csstextalign = "right"
    case .justified:
        csstextalign = "justify"
    default: break
    }

    do {//, allowLossyConversion: true
        let modifiedString = "<style>body{font-family: '\(font.fontName)'; font-size:\(font.pointSize)px; text-align: \(csstextalign);}</style>\(string)";
        attribStr = try NSMutableAttributedString(data: modifiedString.data(using: .utf8)!,
                                                  options:  [.documentType: NSAttributedString.DocumentType.html,
                                                             .characterEncoding: String.Encoding.utf8.rawValue],
                                                  documentAttributes: nil)
        let textRangeForFont : NSRange = NSMakeRange(0, attribStr.length)
        attribStr.addAttributes([.foregroundColor : color], range: textRangeForFont)
    } catch {
        print(error)
    }

    return attribStr
}
