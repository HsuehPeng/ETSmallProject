import UIKit
import RxCocoa
import RxDataSources
import RxSwift

final class MusicSearchViewController: UIViewController {
	private let searchTitleLabel = UILabel()
	private let searchTextField = SearchTextField()
	private let searchButton = UIButton()
	private lazy var collectionView = makeCollectionView()
	private let loadingView = LoadingView()
	
	private let viewModel: MusicSearchViewModel
	private let disposeBag = DisposeBag()
	
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
				searchTermDriver: searchTextField.rx.text.orEmpty.asDriver().skip(1),
				searchButtonTapSignal: searchButton.rx.tap.asSignal(),
				didTapCellItemSignal: collectionView.rx.itemSelected.asSignal()
			)
		)
		
		let dataSource = RxCollectionViewSectionedReloadDataSource<MusicSearchViewModel.SectionModel>(
			configureCell: { dataSource, collectionView, indexPath, item in
				guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(MusicCollectionViewCell.self)", for: indexPath)
						as? MusicCollectionViewCell else { return UICollectionViewCell() }
				cell.configure(with: item)
				return cell
			}
		)
		
		outPut.dataSourceDriver.drive(collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
		outPut.errorAlertDriver.drive(with: self, onNext: { owner, error in
			owner.presentErrorAlert(error: error)
		}).disposed(by: disposeBag)
		
		outPut.isLoadingDriver.drive(with: self, onNext: { owner, isLoading in
			isLoading ? owner.loadingView.startLoading() : owner.loadingView.stopLoading()
			owner.loadingView.isHidden = !isLoading
		}).disposed(by: disposeBag)
	}
	
	private func presentErrorAlert(error: MusicError) {
		let alertController = UIAlertController(
			title: error.errorModel.title,
			message: error.errorModel.description,
			preferredStyle: .alert
		)
		let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(okAction)
		present(alertController, animated: true)
	}
}

extension MusicSearchViewController {
	private func setupViewHierarchy() {
		view.addSubview(searchTitleLabel)
		view.addSubview(searchTextField)
		view.addSubview(searchButton)
		view.addSubview(collectionView)
		view.addSubview(loadingView)
	}
	
	private func setupViews() {
		searchTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		searchTextField.translatesAutoresizingMaskIntoConstraints = false
		searchButton.translatesAutoresizingMaskIntoConstraints = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		loadingView.translatesAutoresizingMaskIntoConstraints = false
		
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
		
		collectionView.register(MusicCollectionViewCell.self, forCellWithReuseIdentifier: "\(MusicCollectionViewCell.self)")
		
		loadingView.isHidden = true
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
		
		NSLayoutConstraint.activate([
			loadingView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 12),
			loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
