#---CLUSTERIP, NODEPORT AND LOAD BALANCER
What's the difference between ClusterIP, NodePort and LoadBalancer service types in Kubernetes?
A ClusterIP exposes the following:
spec.clusterIp:spec.ports[*].port
You can only access this service while inside the cluster. It is accessible from its spec.clusterIp port. 
If a spec.ports[*].targetPort is set it will route from the port to the targetPort. The CLUSTER-IP you get when 
calling kubectl get services is the IP assigned to this service within the cluster internally.

A NodePort exposes the following:
<NodeIP>:spec.ports[*].nodePort
spec.clusterIp:spec.ports[*].port
If you access this service on a nodePort from the nodes external IP, 
it will route the request to spec.clusterIp:spec.ports[*].port, which will in turn route it to your
spec.ports[*].targetPort, if set. This service can also be accessed in the same way as ClusterIP.
Your NodeIPs are the external IP addresses of the nodes. You cannot access your service from 
spec.clusterIp:spec.ports[*].nodePort.

A LoadBalancer exposes the following:
spec.loadBalancerIp:spec.ports[*].port
<NodeIP>:spec.ports[*].nodePort
spec.clusterIp:spec.ports[*].port
You can access this service from your load balancers IP address, which routes your request to a nodePort, 
which in turn routes the request to the clusterIP port. You can access this service as you would a NodePort 
or a ClusterIP service as well.

To clarify in a simple way:
ClusterIp exposure < NodePort exposure < LoadBalancer exposure

ClusterIp = Expose service through k8s cluster with ip/name:port
NodePort = Expose service through Internal network VMs also external to k8s ip/name:port
LoadBalancer = Expose service through External world or whatever you defined in your LB.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#--- ABOUT LOGS
Container logs are automatically rotated daily and every time the log file reaches 10MB. 'kubectl logs' command only shows the log
entries for the last rotation.
Here are some tricks to take a look on logs;
cd /var/log/pods
cd /var/log/containers
Kubectl logs -p POD #logs of previous pods in case of restart/reset
kubectl logs MULTIPOD -c POD #to check the logs of one of the containers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
