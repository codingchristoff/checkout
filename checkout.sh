#!/bin/bash
#####
# V2.0.0
#####
set -m
declare gitCheckout="git checkout"
declare gitFetch="git fetch"
declare gitPull="git pull"
declare gitBranch="git branch"
declare feature="feature/"
declare rebase="rebase/"
declare revert="revert/"
declare hotfix="hotfix/"
declare merge="merge/"
declare userName="clowe/"
declare develop="develop"
declare currentBranch=""
declare branchPrefix=""
declare branchName=""

displayCheckoutOptions() {
	echo -e "\e[36mPress 'ENTER' to only checkout branch. Otherwise select an option:\e[0m"
	echo -e "\e[36m1 - to fetch & pull.\e[0m"
	echo -e "\e[36m2 - to fetch.\e[0m"
	echo -e "\e[36m3 - to pull.\e[0m"
	echo -e "\e[36m4 - to create new branch off latest changes. (This will include option 1.)\e[0m"
	echo -e "\e[36m5 - to create new branch off local changes.\e[0m"
	read -r response
	case $response in
	1)
		echo -e "\e[32m### Fetching ###\e[0m"
		$gitFetch
		echo -e "\e[32m### Pulling ###\e[0m"
		$gitPull
		;;
	2)
		echo -e "\e[32m### Fetching ###\e[0m"
		$gitFetch
		;;
	3)
		echo -e "\e[32m### Pulling ###\e[0m"
		$gitPull
		;;
	4)
		echo -e "\e[32m### Fetching ###\e[0m"
		$gitFetch
		echo -e "\e[32m### Pulling ###\e[0m"
		$gitPull
		checkoutNewBranch
		;;
	5)
		checkoutNewBranch
		;;
	esac
	return 0
}

getBranchArray() {
	local -n _arr=$1
	consoleOut=$(git branch 2>&1)
	readarray -t array <<<"$consoleOut"
	for branch in "${array[@]}"; do
		_arr+=("$(printf '%s\n' "${branch//[[:space:]]/}")")
	done
}

checkBranchMatches() {
	local -n _arr2=$1
	local branchArray
	getBranchArray branchArray
	for branch in "${branchArray[@]}"; do
		if [[ $branch == *"$branchName" ]]; then
			_arr2+=("$branch")
		fi
	done
}

checkoutBranch() {
	local branchMatches
	checkBranchMatches branchMatches

	if [[ ${#branchMatches[@]} == 1 ]]; then
		checkout "${branchMatches[0]/\*/}" #remove asterix
		exit
	fi

	index=0
	for branch in "${branchMatches[@]}"; do
		if [[ $branch != *\** ]]; then
			optionList+=("$branch")
			((index += 1))
		fi
	done

	if [[ index -le 1 ]]; then
		branch="${optionList[$((0))]}"
	else
		echo -e "\e[35m### Several branches matched! Please select from the list. ###\e[0m"
		index=0
		for option in "${optionList[@]}"; do
			item=$((index + 1))
			((index += 1))
			echo -e "\e[36m$item - $option\e[0m"
		done

		read -r response
		branch="${optionList[$((response - 1))]}"
	fi

	checkout "$branch"
	exit
}

checkoutNewBranch() {
	echo -e "\e[1;35m### Creating New Branch off '$currentBranch' ###\e[0m"
	setBranchPrefix

	echo -e "\e[33mDo you want to use the existing name? (y/n)\e[0m"
	read -r response

	case $response in
	"y")
		string1="*\/*\/"
		branchName="${currentBranch/$string1/}"
		;;
	"n")
		setBranchName
		;;
	esac

	branch="$branchPrefix$userName$branchName"
	checkout 0
	echo -e "\e[32m### Branch '${branch}' created ###\e[0m"
	return
}

getCurrentBranch() {
	currentBranch="$($gitBranch --show-current)"
}

setBranchName() {
	echo -e "\e[32mPlease enter a branch name. (without prefix)\e[0m"
	read -r response
	branchName=$response
}

checkout() {
	if [[ "$1" == 0 ]]; then
		ERROR="$($gitCheckout "-b" $branch 2>&1)"
	else
		echo -e "\e[32m### Checking Out '$1' ###\e[0m"
		ERROR="$($gitCheckout "$1" 2>&1)"
	fi

	if validateMessage; then
		return
	fi
	exit
}

validateMessage() {

	if [[ $ERROR == *"Switched to"* ]]; then #success
		return 0
	fi

	if [[ $ERROR == *"Already on"* ]]; then #branch already checked out
		echo -e "\e[33m***WARNING*** - Already on requested branch.\e[0m"
		return 1
	fi

	if [[ $ERROR == *"pathspec"* ]]; then #file not found
		echo -e "\e[31m***ERROR*** - Branch not found.\e[0m"
		return 2
	fi

	if [[ $ERROR == *"commit your changes"* ]]; then #changes not committed
		echo -e "\e[31m***ERROR*** - Changes are not committed. Aborting checkout.\e[0m"
		return 3
	fi

	if [[ $ERROR == *"fatal: not a git repository"* ]]; then #repo doesn't exist
		echo -e "\e[31m***ERROR*** - Repository does not exist.\e[0m"
		return 4
	fi

	if [[ $ERROR == *"command not found"* ]]; then #command not found
		echo -e "\e[31m***ERROR*** - Command syntax error.\e[0m"
		return 5
	fi

	echo -e "\e[31m***ERROR*** - Unknown Error.\e[0m" #run in debug to catch error
	echo -e "\e[32m$ERROR\e[0m"
	return 6
}

setBranchPrefix() {
	echo -e "\e[32mPlease select a branch prefix.\e[0m"
	echo -e "\e[36m1 - $feature\e[0m"
	echo -e "\e[36m2 - $merge\e[0m"
	echo -e "\e[36m3 - $rebase\e[0m"
	echo -e "\e[36m4 - $revert\e[0m"
	echo -e "\e[36m5 - $hotfix\e[0m"
	echo -e "\e[36m6 - create custom\e[0m"
	read -r response
	case $response in
	1) branchPrefix=$feature ;;
	2) branchPrefix=$merge ;;
	3) branchPrefix=$rebase ;;
	4) branchPrefix=$revert ;;
	5) branchPrefix=$hotfix ;;
	6)
		echo -e "\e[32mEnter branch prefix. (without branch name)\e[0m"
		read -r branchPrefix
		;;
	esac
}

createNewBranch() {
	echo -e "\e[35m### Creating New Branch ###\e[0m"
	echo -e "\e[33mDo you want to branch off 'develop'? (y/n)\e[0m"
	read -r response
	case $response in
	"y")
		checkout "$develop"
		displayCheckoutOptions
		return
		;;
	"n")
		checkoutNewBranch
		return
		;;
	esac
}

checkoutControl() {

	#*** CREATE NEW BRANCHES ***#

	if [[ "$branchName" == "" && "$currentBranch" != "$develop" ]]; then
		createNewBranch
		exit
	fi

	#*** CHECKOUT BRANCHES ***#

	# If arg is develop and current not develop switch to develop
	if [[ "$branchName" == "$develop" && "$currentBranch" != "$develop" ]]; then
		checkout "$develop"
		displayCheckoutOptions
		exit
	fi

	# If arg is nothing or develop and the branch is develop, then display checkout options.
	if [[ ("$branchName" == "" || "$branchName" == "$develop") && "$currentBranch" == "$develop" ]]; then
		displayCheckoutOptions
		exit
	fi

	checkoutBranch
	exit
}

# ********** START ********** #
getCurrentBranch
branchName="$1"
checkoutControl
exit
