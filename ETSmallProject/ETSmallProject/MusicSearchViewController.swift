import UIKit
import RxCocoa

final class MusicSearchViewController: UIViewController {
	private let searchTitleLabel = UILabel()
	private let searchTextField = SearchTextField()
	private let searchButton = UIButton()
	private lazy var collectionView = makeCollectionView()
	
	private let viewModel: MusicSearchViewModel
	
	init(viewModel: MusicSearchViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white

		setupViewHierarchy()
		setupViews()
		setupConstraints()
		bindViewModel()
	}
	
	private func bindViewModel() {
		let outPut = viewModel.transform(
			input: .init(
				searchTermDriver: searchTextField.rx.text.orEmpty.asDriver(),
				searchButtonTapSignal: searchButton.rx.tap.asSignal()
			)
		)
	}
}

extension MusicSearchViewController {
	private func setupViewHierarchy() {
		view.addSubview(searchTitleLabel)
		view.addSubview(searchTextField)
		view.addSubview(searchButton)
		view.addSubview(collectionView)
	}
	
	private func setupViews() {
		searchTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		searchTextField.translatesAutoresizingMaskIntoConstraints = false
		searchButton.translatesAutoresizingMaskIntoConstraints = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		searchTitleLabel.text = MusicSearchViewModel.Constants.searchMusicTitle
		searchTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
		
		let placeHolderAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
			.foregroundColor: UIColor.black.withAlphaComponent(0.5)
		]
		
		searchTextField.attributedPlaceholder = NSAttributedString(string: MusicSearchViewModel.Constants.searchPlaceHolder, attributes: placeHolderAttributes)
		
		searchButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		searchButton.titleLabel?.textColor = UIColor.white
		searchButton.setTitle(MusicSearchViewModel.Constants.searchButtonTitle, for: .normal)
		searchButton.layer.cornerRadius = 8
		searchButton.backgroundColor = UIColor.black
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
		
		NSLayoutConstraint.activate([
			searchButton.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 12),
			searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
			searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
			searchButton.heightAnchor.constraint(equalToConstant: 42)
		])
		
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 12),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
	
	private func makeCollectionView() -> UICollectionView {
		let layout = UICollectionViewCompositionalLayout.list(
			using: UICollectionLayoutListConfiguration(
				appearance: .plain
			)
		)
		
		return UICollectionView(
			frame: .zero,
			collectionViewLayout: layout
		)
	}
}
