import UIKit

final class LoadingCollectionViewCell: UICollectionViewCell {
	private let loadingView = UIActivityIndicatorView(style: .large)
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViewHierarchy()
		setupViews()
		setupConstraints()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		loadingView.stopAnimating()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure() {
		loadingView.startAnimating()
	}
}

extension LoadingCollectionViewCell {
	private func setupViewHierarchy() {
		contentView.addSubview(loadingView)
	}
	
	private func setupViews() {
		loadingView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	private func setupConstraints() {
		let loadingViewHeightConstraint = loadingView.heightAnchor.constraint(equalToConstant: Constants.loadingViewHeight)
		loadingViewHeightConstraint.priority = .defaultLow
		NSLayoutConstraint.activate([
			loadingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			loadingView.topAnchor.constraint(equalTo: contentView.topAnchor),
			loadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			loadingViewHeightConstraint
		])
	}
	
	private enum Constants {
		static let loadingViewHeight: CGFloat = 500
	}
}
