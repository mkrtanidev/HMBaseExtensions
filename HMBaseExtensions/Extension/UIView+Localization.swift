import UIKit

@objc protocol Localizable {
    func localize()
}

open class LocalizedLabel: UILabel, Localizable {
    func localize() {
        if self.attributedText != nil {
            let attr = self.attributedText?.attributes(at: 0, effectiveRange: nil)
            let attrString = NSAttributedString.init(string: LanguageManager.localizedstring(self.attributedText!.string), attributes: attr)
            self.attributedText = attrString
        } else {
            self.text = LanguageManager.localizedstring(self.text.valueOr(""), comment: "")
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        localize()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        localize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        localize()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUITextDirection(_ input: Int) -> UITextDirection {
    return UITextDirection(rawValue: input)
}
