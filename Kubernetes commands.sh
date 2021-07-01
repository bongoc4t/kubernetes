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

#-MINIKUBE
minikube start
minikube stop
minikube delete #in case you get "machine does not exist" to clear the minikube local state
minikube start --driver=virtualbox #to start minikube in virtualbox
minikube start --nodes X -p NAME_MULTINODE 
HOME SERVER LAUNCH > minikube -p multinode-lab --nodes 2 start

kubectl config set-context $(kubectl config current-context) --namespace=NAMESPACE_NAME #switch the namespace workaround

kubectl get all #get all the deployment, ReplicaSets and Pods created

kubectl run POD --image=IMAGE #create a pod. From v1.18 th command only creates a pod instead of deployment
kubectl get pods #get a simple info of pods
kubectl get pods -o wide #get a simple info + Node where is attached
kubectl describe pod POD #get info of the pod
kubectl create deployment POD --image=IMAGE #create a pod and a deployment for it

kubectl create -f CONFIG_FILE
kubectl get ReplicaSet
kubectl delete ReplicaSet NAME_REPLICA
kubectl replace -f CONFIG_FILE
kubectl edit replicaset CONFIG_FILE
kubectl scale replicaset CONFIG_FILE --replicas=X

#NODES (NO in short)
kubectl get no
        get no -o wide
        describe no
        get no -o YAML
        get node --selector=[LABEL_NAME]
        top node NODE_NAME

#PODS (po)
kubectl get po
        get po -o wide
        describe po
        get po --show-labels
        get po -l app=APP_NAME
        get po -o YAML
        get pod POD_NAME -o YAML --export
        get pod POD_NAME -o YAML --export > NAME_FILE.YAML
        get pods --field-selector stats.phase=running

#NAMESPACES (NS)
kubectl get ns
        get ns -o YAML
        describe ns

#DEPLOYMENT (DEPLOY)
kubectl get deploy
        describe deploy
        get deploy -o wide
        get deploy -o YAML

#SERVICES (SVC)
kubectl get svc
        describe svc
        get svc -o wide
                -o YAML
                --show-labels

SERVICE OPTIONS:
NodePort = Expose service through Internal network VMs also external to k8s ip/name:port
ClusterIp = Expose service through k8s cluster with ip/name:port
LoadBalancer = Expose service through External world or whatever you defined in your LB.

#--SCHEDULER--#
#example in the kubernetes_pod_definition.yaml
#pod can be assigned to a fixed node to being deployed instead of doing it randomly
#another way to do it is creating a Pod binding object -> Pod-bind-definition.yaml

#-LABELS AND SELECTORS
#example in kubernetes_replicaset_definition.yaml and service-definition.yaml
#are used in the replicaset-definition or service-definition as it has to go over the pod definition to match the label of the pods
kubectl get pods --selector env=ENVIRONMENT

#- TAINTS AND TOLERATIONS
#example in
#used to check what pods can be scheduled on what nodes
#taints=nodes toleration=pods
kubectl taint nodes NODE_NAME key=value:taint-effect # taint-efect options-> Noschedule | PreferNoSchedule | NoExecute
kubectl taint node master NODE_NAME:taint-effect- #to remove a taint
kubectl describe nodes NODE_NAME | grep -i Taints #to check the status of taint



#ROLLOUT
2 way of doing it:
        1- Recreate #this will cause an APP downtime as all the pods get removed and new ones recreated.
        2- Rolling #this use the Blue/Green technique. 1 up, 1 down. It's the default 
kubectl rollout status DEPLOYMENT #check the status of deployment
                history DEPLOYMENT #check the history of deployment
        set POD_NAME DEPLOYMENT IMAGE=IMAGE:VERSION #this is an alternative and not recomended as it creates another YAML file.