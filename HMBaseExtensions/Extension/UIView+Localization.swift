import UIKit

public class LocalizedLabel: UILabel {
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        if self.attributedText != nil {
            let attr = self.attributedText?.attributes(at: 0, effectiveRange: nil)
            let attrString = NSAttributedString.init(string: LanguageManager.localizedstring(self.attributedText!.string), attributes: attr)
            self.attributedText = attrString
        } else {
            self.text = LanguageManager.localizedstring(self.text.valueOr(""), comment: "")
        }
    }
    
}

public class LocalizedButton: UIButton {
    override public func awakeFromNib() {
        super.awakeFromNib()
        //        let UIControlStates: [UIControlState] = [.normal, .highlighted, .disabled, .selected, .focused, .application, .reserved]
        //        for state in UIControlStates {
        //            self.setTitle(LanguageManager.localizedString(self.title(for: state).valueOr(""), comment: ""), for: state)
        //        }
        if self.currentAttributedTitle != nil {
            let attr = self.currentAttributedTitle?.attributes(at: 0, effectiveRange: nil)
            let attrString = NSAttributedString.init(string: LanguageManager.localizedstring(self.currentAttributedTitle!.string), attributes: attr)
            self.setAttributedTitle(attrString, for: .normal)
        } else {
            self.setTitle(LanguageManager.localizedstring(self.currentTitle ?? ""), for: .normal)
        }
    }
}

public class LocalizedTextField: UITextField {
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.placeholder = LanguageManager.localizedstring(self.placeholder.valueOr(""), comment: "")
        self.text = LanguageManager.localizedstring(self.text.valueOr(""), comment: "")
    }
}

public class LocalizesBarButtonItem: UIBarButtonItem {
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.title = LanguageManager.localizedstring(self.title.valueOr(""), comment: "")
    }
}

public class LinkTextView: UITextView {
    //    public override var canBecomeFirstResponder: Bool {
    //        return false
    //    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        guard let pos = closestPosition(to: point) else { return false }
        
        guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: convertToUITextDirection(UITextLayoutDirection.left.rawValue)) else { return false }
        
        let startIndex = offset(from: beginningOfDocument, to: range.start)
        
        return attributedText.attribute(NSAttributedString.Key.link, at: startIndex, effectiveRange: nil) != nil
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUITextDirection(_ input: Int) -> UITextDirection {
    return UITextDirection(rawValue: input)
}
