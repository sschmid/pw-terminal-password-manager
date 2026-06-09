parse_git_branch() {
	git rev-parse --is-inside-work-tree &>/dev/null || return
	local branch
	branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null)
	[[ -n "${branch}" ]] && echo " (${branch})"
}

export PS1='\[\e[1;36m\]pw ➜\[\e[0m\] \[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\[\e[33m\]$(parse_git_branch)\[\e[0m\]\$ '

complete -C bee bee
