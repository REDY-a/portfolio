# About

Portfolio backing up and git excercise.

# Troubleshootings

1 Windows Connection

```
    fatal: unable to access 'https://github.com/REDY-a/portfolio.git/': Failed to connect to ... : Connection refused
```

Add Windows firewall inbound rules.

2 Gitbash pull hangs, but not push

```
$ GIT_TRACE=1 git push -v origin main
15:22:27.962771 exec-cmd.c:237          trace: resolved executable dir: C:/Program Files/Git/mingw64/bin
15:22:27.963769 git.c:455               trace: built-in: git push -v origin main
15:22:27.966629 run-command.c:667       trace: run_command: GIT_DIR=.git git remote-https origin https://github.com/REDY-a/portfolio.git
15:22:27.973273 exec-cmd.c:237          trace: resolved executable dir: C:/Program Files/Git/mingw64/libexec/git-core
15:22:27.974282 git.c:744               trace: exec: git-remote-https origin https://github.com/REDY-a/portfolio.git
15:22:27.974282 run-command.c:667       trace: run_command: git-remote-https origin https://github.com/REDY-a/portfolio.git
15:22:27.982357 exec-cmd.c:237          trace: resolved executable dir: C:/Program Files/Git/mingw64/libexec/git-core
Pushing to https://github.com/REDY-a/portfolio.git
15:22:28.879336 run-command.c:667       trace: run_command: 'git credential-manager-core get'
15:22:28.896165 exec-cmd.c:237          trace: resolved executable dir: C:/Program Files/Git/mingw64/libexec/git-core
15:22:28.896165 git.c:744               trace: exec: git-credential-manager-core get
15:22:28.896165 run-command.c:667       trace: run_command: git-credential-manager-core get

```

### Solution

create a PAT, personal access token
[github ocs](https://docs.github.com/en/get-started/getting-started-with-git/why-is-git-always-asking-for-my-password)
says:

```
Password-based authentication for Git has been removed in favor of more secure authentication methods. 
```

Creating a personal access token: 
[create PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

See [stackoverflow](https://stackoverflow.com/a/68781050) :

```
From your GitHub account, go to Settings 
=>
Developer Settings => Personal Access Token 
=>
Generate New Token (Give your password) 
=>
Fillup the form => click Generate token 
=>
Copy the generated Token, it will be something like

    ghp_sFhFsSHhTzMDreGRLjmks4Tzuzgthdvfsrta
```



[Access with Windows Credential Manager](
https://stackoverflow.com/questions/68775869/message-support-for-password-authentication-was-removed-please-use-a-personal)

For Windows OS ⤴

```
Go to Credential Manager from Control Panel =>
Windows Credentials =>
find git:https://github.com =>
Edit =>
On Password replace with with your GitHub Personal Access Token =>
```
You are Done

If you don’t find git:https://github.com 

```
Click on Add a generic credential 
=>
Internet address will be git:https://github.com 
and you need to type in your username and password will be your GitHub Personal Access Token 
=>
Click Ok
```
and you are done

Two more tip:

Open PAT permissions

use user name in Credential Manager
