# Checkout Branch Script

This is a script to help automate some git checkout command functions.

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

### No argument given 
`gcout` 

If no argument given, this will enter the new branch creation tool.

### Develop Argument
`gcout develop`

If develop is checked out it will skip the checkout step and display the options to update the branch or create a new branch off develop. 

#### *Create New Branch* develop

A menu will appear and allow you to create a new branch off the latest changes or off the current local changes.

#### *Create New Branch* other branch

A series of prompts will appear and allow you to create a new branch off the local changes of that current branch.

### BranchName Argument
`gcout <branchName>`

`gcout cool-branch`

This will first retrieve a list of branches, if more than one match is found a list will be displayed and you can select which branch to check out. 

## Glossary
Each part of the branch is split into sections. Please see below to get the definition for each.

`<branchPrefix/branchName>`

- branch - refers to the whole name
    - feature/clowe/cool-branch
- branchPrefix - refers to the first portion of the branch
    - feature/
- branchName - refers to the actual name of the branch
    - cool-branch