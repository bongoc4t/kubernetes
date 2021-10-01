#- QUICK SHOT TO LABS AND MEMO
alias k='kubectl'
alias kn='kubectl get nodes -o wide'
alias kp='kubectl get pods -o wide'
alias kd='kubectl get deployment -o wide'
alias ks='kubectl get svc -o wide'
alias kdp='kubectl describe pod'
alias kdd='kubectl describe deployment'
alias kds='kubectl describe service'
alias kdn='kubectl describe node'
source <(kubectl completion bash)
complete -F __start_kubectl k
export do="--dry-run=client -o yaml" 

github > kubernetes/website/master/content/en/examples
k run NAME --image=IMAGE --dry-run=client -o yaml

To make vim use 2 spaces for a tab edit ~/.vimrc to contain:
set tabstop=2
set expandtab
set shiftwidth=2
