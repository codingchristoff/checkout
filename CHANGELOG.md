# Change log

## Versions

### 2.0.1

~ fix custom branch missing "/"

### 2.0.0
large refactor of code logic

\+ add ability to create new branch off any branch \
\+ add additional error handling

~ update checkout function when only 2 branches exist, to auto-checkout the other branch \
~ update logic to handle issues checking out an already checked out branch \
~ general code improvements \
~ improve readme

### 1.0.0

First implementation, currently can checkout <{feature - merge - rebase - revert - hotfix}/userName/branchName>

If you always use feature but append -merge or -rebase etc on the branchName it will still work. 

## Planned Changes

- Add set-up options to tailor script to user preferences.
- ~~Add functionality to create a new branch on any branch.~~ V2.0.0