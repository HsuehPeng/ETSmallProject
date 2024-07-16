extension Music {
	func mapToMusicCellViewModel() -> MusicCollectionViewCellViewModel {
		return .init(
			music: self,
			trackName: self.trackName,
			trackTime: self.formatMilliseconds(self.trackTimeMillis),
			imageUrlString: self.artworkUrl100,
			longDescription: self.longDescription
		)
	}
	
	private func formatMilliseconds(_ milliseconds: Int) -> String {
		let totalSeconds = milliseconds / 1000
		let minutes = totalSeconds / 60
		let seconds = totalSeconds % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}
}
