#!/bin/bash
#####
# V1.0.0
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

displayCheckoutOptions()
{
	echo -e "\e[36mPress 'ENTER' to only checkout branch. Otherwise select an option:\e[0m"
	echo -e "\e[36m1 - to fetch & pull.\e[0m"
	echo -e "\e[36m2 - to fetch.\e[0m"
	echo -e "\e[36m3 - to pull.\e[0m"
	echo -e "\e[36m4 - to create new branch off latest changes. (This will include option 1.)\e[0m"
	echo -e "\e[36m5 - to create new branch off local changes.\e[0m"
	read -r response		
	case $response in
		1) echo -e "\e[32m### Fetching ###\e[0m"; $gitFetch; echo -e "\e[32m### Pulling ###\e[0m"; $gitPull;;
		2) echo -e "\e[32m### Fetching ###\e[0m"; $gitFetch;;
		3) echo -e "\e[32m### Pulling ###\e[0m"; $gitPull;;
		4) echo -e "\e[32m### Fetching ###\e[0m"; $gitFetch; echo -e "\e[32m### Pulling ###\e[0m"; $gitPull; setBranchPrefix; setBranchName; echo -e "\e[36m### Creating New Branch. ###\e[0m"; checkoutNewBranch;;
		5) echo -e "\e[36m### Creating New Branch. ###\e[0m"; setBranchPrefix; setBranchName; checkoutNewBranch;;
	esac
}

getBranchArray()
{
	local -n _arr=$1
	consoleOut=$(git branch 2>&1)
	readarray -t array <<<"$consoleOut"
	for branch in "${array[@]}";
	do
		_arr+=("$(printf '%s\n' "${branch//[[:space:]]}")")		
	done
}

checkBranchMatches()
{
	local -n _arr2=$1
	local branchArray
	getBranchArray branchArray	
	for branch in "${branchArray[@]}";
	do	
		if [[ $branch == *"$branchName" ]];
			then								
				_arr2+=("$branch")
		fi		
	done
}

checkoutBranch()
{
	local branchMatches
	checkBranchMatches branchMatches
	if [[ ${#branchMatches[@]} == 1 ]];
	then		
		checkout "${branchMatches[0]}"
		validateMessage "$?"
		if validateMessage;
		then
			echo -e "\e[32m### Checking out '${branchMatches[0]}'. ###\e[0m"
			exit 0
		fi
	fi	

	if [[ ${#branchMatches[@]} -gt 1 ]];
	then
		index=0		
		echo -e "\e[35m### Several branches matched! Please select from the list. ###\e[0m"		
		for branch in "${branchMatches[@]}";
		do
		optionList+=("$branch")
		item=$((index+1))
		echo -e "\e[36m$item - $branch\e[0m"
		index+=1
		done
		read -r response

		checkout "${optionList[$((response-1))]}"				
		validateMessage "$?"
		if validateMessage;
		then
			echo -e "\e[32m### Checking out '${branch}' ###\e[0m"
		elif [[ $? == 2 ]];
		then
			echo -e "\e[32m### Please commit or stash changes. ###\e[0m"
		fi
	fi	
		exit 0
}

checkoutNewBranch()
{
	branch="$branchPrefix$userName$branchName"
	ERROR="$($gitCheckout "-b" $branch 2>&1)"
	validateMessage "$?"
	if validateMessage;
	then
		echo -e "\e[32m### Branch '${branch}' created ###\e[0m"
	elif [[ $? == 2 ]];
	then
		echo -e "\e[32m### Something Went Wrong ###\e[0m"
	fi
		exit 0
}

getCurrentBranch()
{	
	currentBranch="$($gitBranch --show-current)"	
}

setBranchName()
{
	echo -e "\e[32mPlease enter a branch name. (without prefix)\e[0m"	
	read -r response
	branchName=$response
}

checkout()
{
	ERROR="$($gitCheckout "$1" 2>&1)"
}

validateMessage()
{
	if [[ $ERROR == *"Switched to"* ]]; #success
	then		
		return 0
	fi

	if [[ $ERROR == *"pathspec"* ]]; #file not found
	then
		echo -e "\e[31m***ERROR*** - Branch not found.\e[0m"
		return 1
	fi

	if [[ $ERROR == *"commit your changes"* ]]; #changes not committed
	then
		echo -e "\e[31m***ERROR*** - Changes are not committed. Aborting checkout.\e[0m"
		return 2
	fi	
	
	if [[ $ERROR == *"fatal: not a git repository"* ]]; #repo doesn't exist
	then
		echo -e "\e[31m***ERROR*** - Repository does not exist.\e[0m"
		return 3
	fi
		if [[ $ERROR == *"command not found"* ]]; #repo doesn't exist
	then
		echo -e "\e[31m***ERROR*** - Command syntax error.\e[0m"
		return 4
	fi
	echo -e "\e[31m***ERROR*** - Unknown Error.\e[0m" #run in debug to catch error
		return 5
}

setBranchPrefix()
{
	echo -e "\e[32mPlease select a branch prefix.\e[0m"
	echo -e "\e[36m1 - $feature\e[0m"
	echo -e "\e[36m2 - $merge\e[0m"
	echo -e "\e[36m3 - $rebase\e[0m"
	echo -e "\e[36m4 - $revert\e[0m"
	echo -e "\e[36m5 - $hotfix\e[0m"
	echo -e "\e[36m6 - create custom\e[0m"
	read -r response
	case $response in
		1) branchPrefix=$feature;;
		2) branchPrefix=$merge;;
		3) branchPrefix=$rebase;;
		4) branchPrefix=$revert;;
		5) branchPrefix=$hotfix;;
		6) echo -e "\e[32mEnter branch prefix. (without branch name)\e[0m";read -r branchPrefix;;		
	esac
}

switchToDevelopBranch()
{	
		echo -e "\e[33mDo you want to checkout 'develop'? (y/n)\e[0m"
		read -r response
		case $response in
			"y") echo -e "\e[32m### Checking Out 'develop' ###\e[0m";checkout "$branchName";return 0;;
			"n") setBranchName;checkoutBranch;return 0;;
		esac	
}

checkoutControl()
{
	if [[ "$1" == "" ]];
	then
		branchName=$develop
	fi
	#
	# If arg is nothing or develop and the branch is not develop, check if switching to develop.
	# If code is 0 then develop checked out. Exit script.
	#
	if [[ $branchName == "" || $branchName == "$develop" && $currentBranch != "$develop" ]];
	then
		
		if switchToDevelopBranch;
		then
		validateMessage "$ERROR"
		displayCheckoutOptions
		exit 0
		fi
	fi

	#If arg is nothing or develop and the branch is develop, then display checkout options.
	if [[ $branchName == "" || $branchName == "$develop" && $currentBranch == "$develop" ]];
	then	
		displayCheckoutOptions
		exit 0
	fi

	checkoutBranch
	exit 0
}

# ********** START ********** #
getCurrentBranch
branchName="$1"
checkoutControl "$branchName"
exit 0