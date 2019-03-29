show() {
	defaults write com.apple.finder CreateDesktop -bool true
	Killall Finder
}

hide() {
	defaults write com.apple.finder CreateDesktop -bool false
	killall Finder
}

test() {
	ls
}

"$@"