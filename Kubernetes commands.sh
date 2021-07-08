Pods > ReplicaSets > Deployment > Namespaces #Layers of abstraction
<Service>.<Namespace>.svc.cluster.local

kubectl run #CLI
kubectl apply #YAML/JSON
kubectl create #CLI & YAML/JSON

#-BASICS
kubectl run NAME_POD --image=IMAGE #Start a single pod of IMAGE
                                    --port=XXXX #Expose port XXXX
                                    --replicas=X #Start a replicated pod                                 
kubectl delete pod NAME_POD

#-CONFIG-#
KUBECONFIG=~/.kube/config:~/.kube/kubconfig2 #Use multiple kubeconfig files at the same time 
kubectl config view #Show merged kubeconfig settings
kubectl config view -o jsonpath='{.users[].name}'    # display the first user
kubectl config view -o jsonpath='{.users[*].name}'   # get a list of users
kubectl config get-contexts                          # display list of contexts 
kubectl config current-context                       # display the current-context
kubectl config use-context my-cluster-name           # set the default context to my-cluster-name

#-MINIKUBE
minikube start
minikube stop
minikube delete #in case you get "machine does not exist" to clear the minikube local state
minikube start --driver=virtualbox #to start minikube in virtualbox
minikube start --nodes X -p NAME_MULTINODE 

#IMPORTANT COMMANDS
kubectl get pod POD_NAME -o yaml >FILE.YAML #copy the configuration file. With this you can remove the old pod and update the configuration
kubectl exec etcd-master -n kube-system etcdctl get --prefix -keys-only #to list all keys stored by kubernetes
ps -aux | grep kube-apiserver #view api-server options
cat /etc/kubernetes/manifests/kube-apiserver.yaml #view api-server options in kubeadm
ps -aux | grep kube-controller-manager #view controller-manager options

#DECLARATIVE WAY
kubectl create -f CONFIG_FILE
kubectl replace -f CONFIG_FILE
kubectl apply -f CONFIG_FILE

#NODES (NO in short)
kubectl get no
        get no -o wide
        describe no
        get no -o YAML
        get node --selector=[LABEL_NAME]
        top node NODE_NAME
        label nodes NODE_NAME label-key=label-value #label a node

#PODS (po)
kubectl get po
        get po -o wide
        describe po
        get po --show-labels
        get po --selector env=ENVIRONMENT
        get po -l app=APP_NAME
        get po -o YAML
        get pod POD_NAME -o YAML --export
        get pod POD_NAME -o YAML --export > NAME_FILE.YAML
        get pods --field-selector stats.phase=running
        get pods --namespace=NAMESPACE #get pod from that namespace, you can also put "-n" and the namespace
        get all --selector 

#DEPLOYMENT (DEPLOY)
kubectl get deploy
        describe deploy
        get deploy -o wide
        get deploy -o YAML

#NAMESPACES (NS)
#To create a pod in a selected namespace you hae to add this: metadata.namespace to the pod-definition file
#Example of namespace creation: namespace-definition.yaml
kubectl get ns
        get ns -o YAML
        describe ns
        config set-context $(kubectl config current-context) --namespace=NAMESPACE_NAME #switch the namespace workaround
        create -f namespace-definition.yaml #I use a file that I created as example. Very used command
        get pods --all-namespaces #check all the pods in all namespaces

#SERVICES (SVC)
kubectl get svc
        describe svc
        get svc -o wide
                -o YAML
                --show-labels
        create -f svc-definition.yaml #to create the configuration based on the file.
        

#--SCHEDULER--#
#example in 
#pod can be assigned to a fixed node to being deployed instead of doing it randomly
#another way to do it is creating a Pod binding object -> Pod-bind-definition.yaml

#-LABELS AND SELECTORS
#example in kubernetes_replicaset_definition.yaml and service-definition.yaml
#are used in the replicaset-definition or service-definition as it has to go over the pod definition to match the label of the pods
#types of NodeAffinity
        #requiredDuringSchedulingIgnoredDuringExecution > must/hard 
        #preferredDuringSchedulingIgnoredDuringExecution > soft/light
        #requiredDuringSchedulingRequiredDuringExecution > hardest, will stop all pods that not have the affinity reqs.

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

#- DAEMON SETS
kubectl get daemonsets
        describe daemonsets DAEMON_NAME

#- MULTIPLE SCHEDULERS
kubectl get events
        logs SCHEDULER_NAME --name-space=NAMESPACE_NAME #to check the logs

#--LOGGING AND MONITORING--#
#example pd-event-simulator.yaml
kubectl top node
        top pod



#- SECRETS
#example in pod_definition.yaml and the secret file; secrets_definition.yaml
kubectl create secret generic SECRET_NAME --from-literal=KEY=VALUE #imperative way of create a secret
        create -f 
        get secrets
        get secrets APP_NAME -o yaml #to check the secrets enconded
        describe secrets 

#ROLLOUT
2 way of doing it:
        1- Recreate #this will cause an APP downtime as all the pods get removed and new ones recreated.
        2- Rolling #this use the Blue/Green technique. 1 up, 1 down. It's the default 
kubectl rollout status DEPLOYMENT #check the status of deployment
                history DEPLOYMENT #check the history of deployment
        set POD_NAME DEPLOYMENT IMAGE=IMAGE:VERSION #this is an alternative and not recomended as it creates another YAML file.

#--CLUSTER MAINTENANCE--#
kubectl drain NODE_NAME #workloads are moved to other nodes and node as marked as unscheduled
        uncordon NODE_NAME #make the node available again
        cordon NODE_NAME #make the node unabled to schedule new pods, but old ones will work till end cycle

#---CLUSTER UPGRADE PROCESS
#For the first control plane node
kubeadm version #check the version
kubeadm upgrade plan #check the planned version
kubeadm upgrade apply VERSION
#(If you have) For the other control plane nodes do the asme as the control plane node but using:
kubeadm upgrade NODE_NAME
kubeadm upgrade apply.
#drain the node, this means prepare it for maintenance by marking it unscheduable
kubectl drain NODE_NAME --ignore-daemonsets
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

#--- SECURITY --REVIEW TWICE OR SEVERAL TIMES TO UNDERSTAND
#NOTES
Certificate Public Keys= *.crt *.pem
Private Key = *.key *-key.pem
---Client certificates for clients:
admin
scheduler
controller-manager
kube-proxy
apiserver-kubelet-client
apiserver-etcd-client
kubelet-client
---Server Certificates for servers:
etcd-server
api-server
kubelet
#CREATE A SELF-SIGNED CA CERTIFICATE
1- openssl genrsa -out ca.key 2048 #create a private key
2- openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr #to create a certificate signing request (cert with all details but no signature)
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
1- create an openssl.cnf (config file)
2- openssl req -new -key apiserver.key -subj "/CN=kube-apiserver" -out apiserver.csr -config openssl.cnf
3- openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -out apiserver.crt
#COMMANDS
kubectl config use-context USER@CLUSTER #change the context of the user
curl http://localhost:6443 -k #check the list of available API groups
curl http://localhost:6443/apis -k | grep "name" #it will return all the supported groups
#RBAC
kubectl create -f createuser-rol-binding.yaml #create a file of the binding
kubectl get roles #get a list of the roles
kubectl describe role ROLE #get a description of the role
kubectl describe rolebinding ROLEBINDING
kubectl auth can-i CREATE/DELETE/... DEPLOYMENT/NODES/PODS/... #check access
kubectl auth can-i CREATE/DELETE/... DEPLOYMENT/NODES/PODS/... --as USER #to impersonate and check users access
kubectl create -f createcluster-role-binding.yaml #create a file of the binding
we have to create a role (create-role.yaml) then we have to create a rule binding (createuser-rol-binding.yaml). Same with cluster roles

#--- STORAGE
File System:
/var/lib/docker/aufs
                containers
                image
                volumes
                
Storage Drivers: AUFS | ZFS | BTRFS | DEVICE MAPPER | OVERLAY
Volume Drivers: local | AZURE FILE STORAGE | CONVOY | FLOCKER | GCE-DOCKER | GLUSTER-FS | NETAPP |REXRAY | VMWARE VSPHERE STORAGE

docker volume create DATA_VOLUME #this will create a persisten folder in /var/lib/docker/volumes called DATA_VOLUME 
docker run -v DATA_VOLUME:/var/lib/mysql mysql #an example to attach the new volume. you even can skip the creatin phase and create
                                               #it with this command. This is a "Volume" mount. OLD WAY
docker run -v /path/to/VOLUME:/var/lib/mysql mysql #this create a "binding" mount. OLD WAY
docker run --mount type=bind,source=/data/mysql,target=/var/lib/mysql IMAGE #this is the new way to mount it

#CREATE A PERSISTENT VOLUME STEPS
1- copy pod configuration : kubectl get pod POD -O yaml > name.yaml
2- add the "volumeMounts" section #pod-definition-volumes.yaml example
3- add the "volumes" section #pod-definition-volumes.yaml example
4- if required, delete the old pod and create the new one: kubectl create -f FILE



#--- NETWORK
cat /etc/cni/net.d/*.conf #here we can find the IP address management
ps aux | grep kube-api-server #check the range of the service ip cluster default
kubectl -n kube-system logs NETWORK_POD #check the logs for the CNI pod
kubectl -n kube-system logs KUBE-PROXY #check what type of proxy is configured