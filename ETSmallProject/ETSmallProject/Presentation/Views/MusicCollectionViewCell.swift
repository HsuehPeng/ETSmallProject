import Kingfisher
import UIKit

final class MusicCollectionViewCell: UICollectionViewCell {
	private let leadingVStack = UIStackView()
	private let trailingVStack = UIStackView()
	private let trackHStack = UIStackView()
	private let contentHStack = UIStackView()
	
	private let playTitleLabel = UILabel()
	private let musicImageView = UIImageView()
	private let trackNameLabel = UILabel()
	private let trackTimeLabel = UILabel()
	private let descriptionLabel = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViewHierarchy()
		setupViews()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(with viewModel: MusicCollectionViewCellViewModel) {
		trackNameLabel.text = viewModel.trackName
		trackTimeLabel.text = viewModel.trackTime
		descriptionLabel.text = viewModel.longDescription
		
		if let imageUrlString = viewModel.imageUrlString, let imageUrl = URL(string: imageUrlString) {
			musicImageView.kf.indicatorType = .activity
			musicImageView.kf.setImage(with: imageUrl)
		}
		
		switch viewModel.playState {
		case .finished, .pause:
			playTitleLabel.text = "正在播放 ▶️"
			playTitleLabel.isHidden = false
		case .resumed, .start:
			playTitleLabel.text = "正在播放 ⏸️"
			playTitleLabel.isHidden = false
		case .none:
			playTitleLabel.text = ""
			playTitleLabel.isHidden = true
		}
	}
}

extension MusicCollectionViewCell {
	private func setupViewHierarchy() {
		contentView.addSubview(contentHStack)
		
		trackHStack.addArrangedSubview(trackNameLabel)
		trackHStack.addArrangedSubview(trackTimeLabel)
		
		leadingVStack.addArrangedSubview(playTitleLabel)
		leadingVStack.addArrangedSubview(musicImageView)
		
		trailingVStack.addArrangedSubview(trackHStack)
		trailingVStack.addArrangedSubview(descriptionLabel)
		
		contentHStack.addArrangedSubview(leadingVStack)
		contentHStack.addArrangedSubview(trailingVStack)
	}
	
	private func setupViews() {
		trackHStack.translatesAutoresizingMaskIntoConstraints = false
		leadingVStack.translatesAutoresizingMaskIntoConstraints = false
		trailingVStack.translatesAutoresizingMaskIntoConstraints = false
		contentHStack.translatesAutoresizingMaskIntoConstraints = false
		playTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		musicImageView.translatesAutoresizingMaskIntoConstraints = false
		trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
		trackTimeLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		
		playTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
		
		musicImageView.layer.cornerRadius = 16
		musicImageView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		
		trackNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		trackNameLabel.numberOfLines = 2
		
		trackTimeLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
		trackTimeLabel.textColor = UIColor.black.withAlphaComponent(0.5)
		trackTimeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		trackTimeLabel.setContentHuggingPriority(.required, for: .horizontal)

		descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
		descriptionLabel.textColor = UIColor.black.withAlphaComponent(0.5)
		descriptionLabel.numberOfLines = 0

		musicImageView.clipsToBounds = true
		
		leadingVStack.axis = .vertical
		leadingVStack.spacing = 10
		leadingVStack.alignment = .center
		
		trackHStack.axis = .horizontal
		trackHStack.spacing = 10
		trackHStack.alignment = .center

		trailingVStack.axis = .vertical
		trailingVStack.spacing = 10
		trailingVStack.alignment = .fill
		
		contentHStack.axis = .horizontal
		contentHStack.spacing = 18
		contentHStack.alignment = .center
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			contentHStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			contentHStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
			contentHStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			contentHStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -23)
		])
		
		NSLayoutConstraint.activate([
			leadingVStack.widthAnchor.constraint(equalToConstant: 100)
		])
		
		let musicImageViewHeightConstraint = musicImageView.heightAnchor.constraint(equalToConstant: 100)
		musicImageViewHeightConstraint.priority = .defaultLow
		NSLayoutConstraint.activate([
			musicImageView.widthAnchor.constraint(equalToConstant: 100),
			musicImageViewHeightConstraint
		])
	}
}

final class MusicCollectionViewCellViewModel: Equatable {
	let music: Music
	let trackName: String
	let trackTime: String
	let imageUrlString: String?
	let longDescription: String?
	var playState: PlayState
	
	init(
		music: Music,
		trackName: String,
		trackTime: String,
		imageUrlString: String?,
		longDescription: String?,
		playState: PlayState = .none
	) {
		self.music = music
		self.trackName = trackName
		self.trackTime = trackTime
		self.imageUrlString = imageUrlString
		self.longDescription = longDescription
		self.playState = playState
	}
	
	static func == (lhs: MusicCollectionViewCellViewModel, rhs: MusicCollectionViewCellViewModel) -> Bool {
		lhs.music == rhs.music && lhs.playState == rhs.playState
	}
}
