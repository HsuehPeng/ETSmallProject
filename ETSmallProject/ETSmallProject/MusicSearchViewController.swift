import UIKit

class MusicSearchViewController: UIViewController {
	private let searchTitleLabel = UILabel()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupViewHierarchy()
		setupViews()
		setupConstraints()
	}
}

extension MusicSearchViewController {
	private func setupViewHierarchy() {
		view.addSubview(searchTitleLabel)
	}
	
	private func setupViews() {
		searchTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		
		view.backgroundColor = .white
		searchTitleLabel.text = "Search Music"
		searchTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			searchTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			searchTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
			searchTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12)
		])
	}
}

