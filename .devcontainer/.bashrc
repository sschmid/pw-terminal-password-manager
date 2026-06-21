source "$(git --exec-path)/git-sh-prompt"
export PS1='\n╭─ \[\e[1;36m\]pw ➜\[\e[0m\] \[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\[\e[33m\]$(__git_ps1 " (%s)")\[\e[0m\]\n╰─ \$ '

complete -C bee bee
