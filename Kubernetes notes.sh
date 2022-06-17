#-KUBERNETES ALIASES AND INITIAL CONFIGURATION
alias k='kubectl'
alias kn='kubectl get nodes -o wide'
alias kp='kubectl get pods -o wide'
alias kd='kubectl get deployment -o wide'
alias ks='kubectl get svc -o wide'
alias kdp='kubectl describe pod'
alias kdd='kubectl describe deployment'
alias kds='kubectl describe service'
alias kdn='kubectl describe node'
export do="--dry-run=client -o yaml" 
export now="--force --grace-period 0" #fast pod delete
complete -F __start_kubectl k

#- CONFIGURE VIM [THIS IS MORE FOR THE CERTIFICATE EXAM]
To make vim use 2 spaces for a tab edit ~/.vimrc to contain:
set tabstop=2
set expandtab
set shiftwidth=2

#ETCD 
all information updated from nodes, PODs, Configs, Secrets, Accounts... is updated in ETCD
- export ETCDCTL_API=3 #to set the right version of API
#->PATHS
/etc/kubernetes/manifests/etcd.yaml #as static pod
/etc/systemd/system/etcd.service # run as a system service defined
ps -aux | grep etcd

#KUBELET 
- you need always manually install kubelet on worker nodes
- Is responsible for:
    - register nodes
    - create PODs
    - Monitor the state of nodes & PODs
#->PATHS
/etc/kubernetes/kubelet.conf #KubeConfig file with the unique kubelet identity
/var/lib/kubelet/config.yaml #The file containing the kubelet's ComponentConfig
/etc/systemd/system/kubelet.service.d/10-kubeadm.conf #file used by systemd
ps -aux | grep kubelet

#KUBE-APISERVER
- Is responsible for:
    - Autheticate users
    - validate requests
    - retrieve and update data from ETCD
Communicate with Scheduler
Communicate with kubelet
#-> PATHS
/etc/kubernetes/manifests/kube-apiserver.yaml
/etc/systemd/system/kube-apiserver.service # run as a system service defined
ps -aux | grep kube-apiserver

#KUBE CONTROLLER MANAGER
- Is responsible for:
    - Watch status
    - Remediate status
    - Mode monitor period = every 5s
    - Node moniroe grace period = every 40s
    - POD eviction timeout = 5min
#-> PATHS
/etc/kubernetes/manifests/kube-controller-manager.yaml
/etc/systemd/system/kube-controller-manager.service # run as a system service defined
ps -aux | grep kube-controller-manager

#KUBE SCHEDULER
decide which pod goes where.
#-> PATHS
/etc/kubernetes/manifests/kube-scheduler.yaml

#KUBE PROXY
Its a process that runs inside all nodes in the kubernetes cluster, its job is to look for new services, and once a new service is created then the rules are created on each node to forward the traffic to each pod. One way to do it is with IPTABLES rules
- kube-proxy is deployed as a deamonset so in every node it will be always one kube-proxy

#TSHOOT COMMANDS
kubectl get pod -A POD
kubectl get pod -o wide POD
kubectl describe pod POD
#-> LOGS
- Container logs are automatically rotated daily and every time the log file reaches 10MB. 'kubectl logs' command only shows the log entries for the last rotation.
Kubectl logs -p POD #logs of previos pods in case of restart/reset
kubectl logs MULTIPOD -c POD #to check the logs of one of the containers

#DNS
<Service>.<Namespace>.svc.cluster.local

#IMPORTANT PATHS PATHS
/etc/kubernetes/manifests/
/etc/kubernetes/pki/
/var/log/containers/ #logs of the containers
/var/log/pods/ #logs of the pods

#-CONFIG-#
KUBECONFIG=~/.kube/config:~/.kube/kubconfig2 #Use multiple kubeconfig files at the same time 
k config get-contexts                          # display list of contexts 
k config current-context                       # display the current-context
k config use-context my-cluster-name           # set the default context to my-cluster-name
k config get-contexts -o name                  # display the names of the contexts

#EXTRACT THE CERTIFICATE OF A USER
k config view --raw # manual way
k config view --raw -ojsonpath="{.users[?(.name == 'NAME')].user.client-certificate-data}" | base64 -d # complicated way

#IMPORTANT COMMANDS
k exec etcd-master -n kube-system etcdctl get --prefix -keys-only #to list all keys stored by kubernetes
k exec POD -it -- bash #execute bash in the pod
kubectl expose POD --port=80 --target-port=8000 #Create a service for a POD, which serves on port 80 and connects to the containers on port 8000

#CRICTL
Normally used to find processes for tasks like finding malicious syscalls
#1- finding POD ID
crictl ps -id CONTAINER_ID #this CONRAINER_ID normally is  provided or get it via greping logs with FALCO
#2- find the CONTAINER ID of the pod
crictl pod -id  POD_ID #obtained with the command before. with this we see what is the name of the pod and namespace
#3- find the process. This is for the syscall mainly
crictl inspect CONTAINER_ID | grep args -A1

#-LABELS AND SELECTORS
#example in kubernetes_replicaset_definition.yaml and service-definition.yaml
#are used in the replicaset-definition or service-definition as it has to go over the pod definition to match the label of the pods
types of NodeAffinity
        requiredDuringSchedulingIgnoredDuringExecution > must/hard 
        preferredDuringSchedulingIgnoredDuringExecution > soft/light
        requiredDuringSchedulingRequiredDuringExecution > hardest

#- TAINTS AND TOLERATIONS
#example in pod_definition.yaml
#used to check what pods can be scheduled on what nodes
#taints=nodes toleration=pods
kubectl taint nodes NODE_NAME key=value:taint-effect # taint-efect options-> Noschedule | PreferNoSchedule | NoExecute
kubectl taint node master NODE_NAME:taint-effect- #to remove a taint
kubectl describe nodes NODE_NAME | grep -i Taints #to check the status of taint

#- LABEL NODES
#example in pd-labels-and-selectors.yaml; spec.nodeSelector
kubectl label nodes NODE_NAME key=value

#--LOGGING AND MONITORING--#
kubectl top node
        top pod

#-- APPLICATION LIFECYCLE MANAGEMENT --#
kubectl rollout status deployment/DEPLOYMENT_NAME #remove all the replicas and then recreate it
kubectl rollout history deployment/DEPLOYMENT_NAME
kubectl describe deployment DEPLOYMENT_NAME #check how the changes were done

#--CLUSTER MAINTENANCE--#
#Pod-eviction-timeout: time to a pod to come back online after a node goes down. Default = 5 minutes
kubectl drain NODE_NAME #workloads are moved to other nodes and node as marked as unscheduled
        uncordon NODE_NAME #make the node available again
        cordon NODE_NAME #make the node unabled to schedule new pods, but old ones will work till end cycle


#---CLUSTER UPGRADE PROCESS
#drain the node, this means prepare it for maintenance by marking it unscheduable
kubectl drain NODE_NAME --ignore-daemonsets
#first in control plane node
kubeadm version #check the version
kubeadm upgrade plan #check the planned version
kubeadm upgrade apply VERSION
#(If you have) For the other control plane nodes do the same as the control plane node but using:
kubeadm upgrade NODE_NAME
kubeadm upgrade apply.
#upgrade the kubelet and kubectl
apt-get update && \
    apt-get install -y --allow-change-held-packages kubelet=VERSION kubectl=VERSION
#restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet
#bring the node back
kubectl uncordon NODE_NAME
#now you can proceed to do the same with the workers.The upgrade procedure on worker nodes should be executed 
#one node at a time or few nodes at a time, without compromising the minimum required capacity for running your workloads.
apt-get update && \
        apt-get install -y --allow-change-held-packages kubeadm=VERSION
kubeadm upgrade NODE_NAME
kubectl drain NODE_NAME --ignore-daemonsets
apt-get update && \
        apt-get install -y --allow-change-held-packages kubelet=VERSION kubectl=VERSION
sudo systemctl daemon-reload
sudo systemctl restart kubelet
kubectl uncordon NODE_NAME
#finally verify it
kubectl get nodes

#ETCD BACKUP RESOURCE CONFIGS 
kubectl get all --all-namespaces -o yaml > ALL-DEPLOY-SERVICES.yaml #backup of the configuration
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep 'etcd'
ETCDCTL_APY=3 etcdctl snapshot save NAME.db #backup of a ETCD database
ETCDCTL_APY=3 etcdctl snapshot status NAME.db #check the status of the ETCD backup
ETCDCTL_API=3 etcdctl version


#CREATE A SELF-SIGNED CA CERTIFICATE
1- openssl genrsa -out alex.key 2048 #create a private key
2- openssl req -new -key alex.key -out ca.csr #to create a certificate signing request (In "Common Name" we have to specify the name, in ths case alex)
3- openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt #sign the certificate create in last step, in this case, selfsigned
The steps done here create a CA for Kubernetes Cluster, then we have to repeat steps 1 and 2 for the admin Certificate
but instead of CN=KUBERNETES-CA we create a selfsigned kube-admin ("/CN=kube-admin"). then we sign it with the CA key pair;
- openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -out admin.crt #this are based in the last example
To know who is a member of admin we should create a group and this info should be added in step 2 next to CN ("/CN=kube-admin/O=system:masters")
in this case the group name is called "masters".
We should repite this steps with kube-scheduler, kube-contreller-manager and kube-proxy. 
IMPORTANT; all the components related to the control-plane have to have the prefix SYSTEM [kube-scheduler, kube-contreller-manager and kube-proxy]
After this is done you can move this parameters to a kube-config.yaml*
All the Client Certificates for clients have to have a copy of the public certificate (ca.crt).
#KUBE API SERVER
1- create an openssl.cnf (config file) #created as an example in this github
2- openssl req -new -key apiserver.key -subj "/CN=kube-apiserver" -out apiserver.csr -config openssl.cnf
3- openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -out apiserver.crt

#--- EXTERNAL API SERVER ACCESS
1- you have to expose the cluster changing the service to NodePort (k edit svc kubernetes) and get the svc PORT exposed
2- k config view --raw #and copy all the data to a file "vim FILE"
3- check the apiserver.crt #cat /etc/kubernetes/pki/apiserver.crt
4- add an entry to /etc/hosts with the IP addres of the command "k --kubeconfig FILE https://10.10.10.10:PORT" and the name "kubernetes"
5- then change the IP of the FILE "server" entry with "kubernetes:PORT"
6- test now with the command "k --kubeconfig FILE get pods/svc/deploy..."