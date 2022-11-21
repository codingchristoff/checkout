# Checkout Branch Script

## Version 1

First implementation, currently can checkout <{feature - merge - rebase - revert - hotfix}/userName/branchName>

If you always use feature but append -merge or -rebase etc on the branchName it will still work. 

### Planned Changes

- Add set-up options to tailor script to user preferences.
- Add functionality to create a new branch on any branch.

## Installation

To use `gcout` you will need to set up an alias in your `~/.bashrc` file.

Save script into a folder and add an entry into your `~/.bashrc` that updates the PATH variable so it can be run globally. 

```
# ----------------------
# Git Command Aliases
# ----------------------
alias gp='git pull'
alias gcfp='git checkout develop | git fetch | git pull'
alias gsave='git commit --amend --reset-author --no-edit'
alias gcout='checkout-feature.sh'
alias evaltest='shell-test.sh'

# ----------------------
# Custom Path
# ----------------------
export PATH=$PATH:/c/bash-scripts/
export PATH=$PATH:/c/Program\ Files/Microsoft\ Visual\ Studio/2022/Professional/Common7/IDE
```

Please ensure you restart the bash terminal.

Open up the .sh file in an editor and change the value for `userName`

## Commands

`gcout <optional branchName>` 

### No argument given / Develop Argument
`gcout` 

`gcout develop`

If no argument given, this will checkout develop by default.
If develop is checked out it will skip the checkout step and display the options to update the branch or create a new branch off develop. 

#### Create New Branch

A menu will appear and allow you to create a new branch off the latest changes or off the current local changes.

### BranchName Argument
`gcout <branchName>`

`gcout cool-branch`

This will first retrieve a list of branches, if more than one match is found a list will be displayed and you can select which branch to checkout out. 

## Glossary
Each part of the branch is split into sections. Please see below to get the definition for each.

`<branchPrefix/branchName>`

- branch - refers to the whole name
    - feature/clowe/cool-branch
- branchPrefix - refers to the first portion of the branch
    - feature/clowe/
- branchName - refers to the actual name of the branch
    - cool-branch