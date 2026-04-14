Get the current git branch name, then review all changes made on this branch compared to main using `git diff main...HEAD`. Write a clear explanation of what was changed and why to a markdown file named after the branch (e.g. `<branch-name>.md`). If the file already exists, update it rather than overwriting it. If the file exists already, be sure the information is up to date and pertitent to the *current* changes in the *current* git branch. It is possible for outdated information to be
stored in the existing document with the same file name.

Do not give a summary, you will instead explain per file why you made the specific changes. If the change is extremely minimal (fixing a typo, type error, etc) then you can omit it.

You can also ignore test file changes unless it is significant to fix a bug in many tests.
