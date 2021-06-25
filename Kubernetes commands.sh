Pods > ReplicaSets > Deployment > Namespaces #Layers of abstraction
<Service>.<Namespace>.svc.cluster.local

kubectl run #CLI
kubectl apply #YAML/JSON
kubectl create #CLI & YAML/JSON

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
#- KUBERNETES INFO
#- WHAT IS IT?
it is a container management technology developed by GOOGLE (later made open source in 2015) 
to manage contai­nerized applic­ati­on(­orc­hes­tra­tion).

#- WHY?
1.Service discovery and load balancing 1.Service discovery and load balancing
2.Auto­mated rollbacks
3.Self­-he­aling
4.Auto Scaling
5.Canary updates and Rolling updates
6.Open source & Community driven
7.High Availa­bility

#- CONCEPTS
Node -> machine in the cluster
Docker -> helps in creation of containers that includes apps and its binaries.
Pods -> A Pod is the basic building block of Kubern­­et­e­s–the smallest and simplest unit in the Kubernetes object model that you create or deploy,is also a group of containers (1 or more).Only containers of same pod can share shared storage.
Service -> is an abstra­­ction which defines a logical set of Pods and a policy by which to access them.
Jobs -> Creates pod(s) and ensures that a specified number succes­­sfully comple­ted.When a specified number of successful run of pods is completed, then the job is considered complete.
Cronjob -> job scheduler in K8s
Repli­­casets -> ensures how many replica of pod should be running.
Names­­paces -> Logical seperation between teams and thier enviro­nme­nts.It allows various teams(­Dev­,Prod) to share k8s cluster by providing isolated workspace.
Deployment -> Desired state of pods for declar­­ative updates
Daemonset -> Ensures a particular pod to be run on some or all nodes
Persis­­te­n­t­volume -> Persistent storage in the cluster with an indepe­­ndent lifecycle.
persis­­te­n­t­vo­­lum­­eclaim -> Request for storage (for a Persi­­ste­­nt­V­o­lume) by a user
ingress -> is a collection of rules that allow inbound connec­­tions to reach the cluster services.

#-NOTES
minikube start
minikube stop
minikube delete #in case you get "machine does not exist" to clear the minikube local state
minikube start --driver=virtualbox #to start minikube in virtualbox
minikube start --nodes X -p NAME_MULTINODE 

kubectl get all #get all the deployment, ReplicaSets and Pods created

kubectl run POD --image=IMAGE #create a pod. From v1.18 th command only creates a pod instead of deployment
kubectl create deployment POD --image=IMAGE #create a pod and a deployment for it
kubectl get pods #get a simple info of pods
kubectl get pods -o wide #get a simple info + Node where is attached
kubectl describe pod POD #get info of the pod

kubectl create -f CONFIG_FILE
kubectl get ReplicaSet
kubectl delete ReplicaSet NAME_REPLICA
kubectl replace -f CONFIG_FILE
kubectl edit replicaset CONFIG_FILE
kubectl scale replicaset CONFIG_FILE --replicas=X
