#!/bin/sh


#Update and Push changes if last commit is not an update-readme commit
last_sha=$(git rev-parse HEAD)
commit_message=$(git log -1 --pretty=%B $last_sha)
if [ "$commit_message" = "${UPDATE_README_COMMIT_MESSAGE}" ]; then
	echo "Last commit is \"${UPDATE_README_COMMIT_MESSAGE}\", continue ..."
else
	# Get new version
	version_line=$(ls -l | grep -i '^  s.version' Moya.podspec)
	version=$(echo $version_line | cut -d \= -f 2)
	version=$(echo $version | tr -d \" | tr -d ' ')

	# Update Readme(s)
	## Update pod 'Moya'
	sed -i -e "s#pod 'Moya'.*#pod 'Moya' '~> ${version}'#" *.md
	## Update pod 'Moya/RxSwift'
	sed -i -e "s#pod 'Moya/RxSwift'.*#pod 'Moya/RxSwift' '~> ${version}'#" *.md
	## Update pod 'Moya/ReactiveSwift'
	sed -i -e "s#pod 'Moya/ReactiveSwift'.*#pod 'Moya/ReactiveSwift' '~> ${version}'#" *.md

	number_of_changed_readme_files=$(git status | grep 'Readme' | wc -l)
	echo ">>> $number_of_changed_readme_files"
	if [[ "$number_of_changed_readme_files" > 0 ]]; then
		# Push changes
		echo "Pushing chnages to Readme(s)."
		git config credential.helper 'cache --timeout=120'
		git config user.email "ali.ntg3@gmail.com"
		git config user.name "CircleCI"
		git add *.md
		git commit -m "${UPDATE_README_COMMIT_MESSAGE}"
		# Push quitely to prevent showing the token in log
		git push -q https://${GITHUB_PERSONAL_TOKEN}@github.com/alintg/Moya.git update-pod-install-in-readme-ci
	else
		echo "No Readme files changed."
	fi

	echo "Done."
fi