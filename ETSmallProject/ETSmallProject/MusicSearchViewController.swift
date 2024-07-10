import UIKit

class MusicSearchViewController: UIViewController {
	private let searchTitleLabel = UILabel()
	private let searchTextField = SearchTextField()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white

		setupViewHierarchy()
		setupViews()
		setupConstraints()
	}
}

extension MusicSearchViewController {
	private func setupViewHierarchy() {
		view.addSubview(searchTitleLabel)
		view.addSubview(searchTextField)
	}
	
	private func setupViews() {
		searchTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		searchTextField.translatesAutoresizingMaskIntoConstraints = false

		searchTitleLabel.text = "Search Music"
		searchTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
		
		let placeHolderAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
			.foregroundColor: UIColor.black.withAlphaComponent(0.5)
		]
		
		searchTextField.attributedPlaceholder = NSAttributedString(string: "Enter keyword here", attributes: placeHolderAttributes)
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			searchTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			searchTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
			searchTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12)
		])
		
		NSLayoutConstraint.activate([
			searchTextField.topAnchor.constraint(equalTo: searchTitleLabel.bottomAnchor, constant: 4),
			searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
			searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
			searchTextField.heightAnchor.constraint(equalToConstant: 36)
		])
	}
}

