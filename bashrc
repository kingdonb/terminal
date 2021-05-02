cat << EOF
Welcome to your Kubernetes terminal. Happy coding!
EOF

# add Alias definitions.
if [ -f /root/.bash_aliases ]; then
    . /root/.bash_aliases
fi

. <(flux completion bash)

. <(helm completion bash)

source $HOME/.bash_git
GIT_PS1_SHOWUPSTREAM="verbose"
GIT_PS1_SHOWDIRTYSTATE=true
PS1='\[\033[32m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[31m\]$(__git_ps1)\[\033[00m\]\$ '
