import UIKit

final class SearchTextField: UITextField {
	private let textInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		layer.cornerRadius = 6
		layer.borderWidth = 1
		layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: textInset)
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: textInset)
	}
	
	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: textInset)
	}
}
