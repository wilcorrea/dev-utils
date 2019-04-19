# dev-utils

Only a set of functions to standardize common dev operations

## How to configure

Clone (or download) the repo in your local project folder, ex.: 
```
git clone https://github.com/wilcorrea/dev-utils.git ~/projects/dev-utils
```

Add the script to your .bashrc, ex.: 
```
echo "source ~/projects/dev-utils/git.sh" >> ~/.bashrc
```

## How to use

After add the script in .bashrc make sure you created a new session in your terminal and use the commands available in the script you added.

### git.sh

#### status

The status function will basically execute the `git status` with the parameter` --short`

#### commit

The commit function will run an interactive menu to execute a `git commit -m "standardize commit message"`.

#### log

Use the log command to get a `git log` with a preconfigured format and the option to pass as argument a text that will be used in the `grep` parameter.

#### push

Using the push command will be executed `git config credential.helper store` before `git push`.
This can be useful to store the credentials of repository.

#### pull

The command pull has the same features than `push` command.