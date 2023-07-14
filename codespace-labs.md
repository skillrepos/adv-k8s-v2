# Advanced Kubernetes
## Gaining Mastery over your Deployments
## Session labs for codespace only
## Revision 2.0 - 07/11/23

**Startup**
```
alias k=kubectl
minikube start
```


**Lab 1- Working with Kubernetes Probes**

**Purpose: In this lab, we'll learn how Kubernetes uses probes for determining the health of pods, how to set
them up, and how to debug problems around them.**

1. For this workshop, files that we need to use are contained in the directory **adv-k8s** in the home
directory on the disk. Under that directory are subdirectories for each of the main topics that we will
cover. For this section, we’ll use files in the roar-probes directory. (roar is the name of the sample app
we’ll be working with.) Change into that directory. In the terminal, enter.

```
cd roar-probes
```

2. In this directory, we have Helm charts to deploy the database and webapp parts of our application. You
can use the “tree” command to see the overall structure if you are interested. Then create a namespace
named “probes” to hold the deployment. Finally, deploy the app into the cluster with the “helm install”
command. (In the last command, the first occurrence of “probes” indicates the namespace, the second
is the name of the release, and the “.” means using the files from this directory.)

```
tree

k create ns probes

helm install -n probes probes .
```

3.  Now let's see how things are progressing. Take a look at the overall status of the pods, also showing the
labels on the pods

```
k get pods -n probes --show-labels
```

4.  You should see that while the web pod is running and ready, the database pod is not ready. (If the web pod
isn't "Running" yet, it may still need time to startup. You can run the command again after a minute or
so to give it time to finish starting up.). Now, let’s do a “describe” operation on the pod itself. We’ll
specify the pod using one of its labels instead of having to use the pod name.

```
k describe -n probes pod -l app=mysql
```

5.  Note the error message near the bottom of the output mentioning the readiness probe failed. The
readiness probe in this case is just an exec of a command to invoke mysql. The error implies that the call
to “mysql” failed. But note that it doesn’t say it couldn’t find it. Rather, it wasn’t valid to call it that way
since it tried to invoke it without a valid name and password to login.

6. You can see the YAML for this in the deployment template in the corresponding Helm chart. In the file explorer to the left,
 select the file [**roar-probes/charts/roar-db/templates/deployment.yaml**](./roar-probes/charts/roar-db/templates/deployment.yaml) file and click on it to open it up in the files area above the terminal.
Find the section near the bottom with the **readinessProbe** spec.

7. We actually don’t need to have a command login to verify readiness – we just need to know the mysql
application responds. Let’s fix this by simply calling the “version” command - which we should be able
to do without a login

8. Edit the [file](./roar-probes/charts/roar-db/templates/deployment.yaml) and add a **--version** option between the **mysql** and **failureThreshold:** lines, as shown below:

Change

```
readinessProbe:
exec:
command:
- mysql
failureThreshold: 3
initialDelaySeconds: 5
```
To add the line **- --version** in the spot shown below
```
readinessProbe:
exec:
command:
- mysql
- --version
failureThreshold: 3
initialDelaySeconds: 5
```
Also see screenshot below:

![Adding --version option](./images/lab2step8.png?raw=true "Adding --version option")

9. Upgrade the helm installation. After a minute or so, you can verify that you have a working mysql pod.
(You may have to wait a moment and then check again.)

```
helm upgrade -n probes probes .
```

10. At this point, you can get the service's nodeport.

```   
kubectl get svc -n probes
```

11.  Next, let's look at the running application.  Run the command below.

```
kubectl port-forward -n probes svc/roar-web 8089 &
```

12.  You should see a pop-up in your codespace that informs that `(i) Your application running on port 8089 is available.` and gives you a button to click on to `Open in browser`.  Click on that button. (If you don't see the pop-up, you can also switch to the `PORTS` tab at the top of the terminal, select the row with `8089`, and right-click and select `View in browser`.)

![Port pop-up](./images/advk8s6.png?raw=true "Port pop-up")

13.  What you should see in the browser is an application called **Apache Tomcat** running. Click at the end of the URL in the address bar and add the text `/roar/`.  Make sure to include the trailing slash.  Then hit enter and you should see the *roar* application running in the browser.

The complete URL should look something like
```console
https://gwstudent-cautious-space-goldfish-p7vpg5q55xx36944-8089.preview.app.github.dev/roar/
```
![Running app in K8s](./images/advk8s5.png?raw=true "Running app in K8s")

14. Since we're done with this lab, go ahead and remove the probes namespace to save resources.

```
k delete ns probes
```
 
<p align="center">
**[END OF LAB]**
</p>

**Lab 2 - Working with Quotas**

**Purpose: In this lab, we'll explore some of the simple ways we can account for resource usage with pods and
nodes, and setup and use quotas.**

1.  Before we launch any more deployments, let's set up some specific policies and classes of pods that
work with those policies. First, we'll setup some priority classes. Take a look at the definition of the
pod priorities and then apply the definition to create them.

```
cd ../extra

cat pod-priorities.yaml

k apply -f ./pod-priorities.yaml
```

2.  Now, that the priority classes have been created, we'll create some resource quotas built around
them. Since quotas are namespace-specific, we'll go ahead and create a new namespace to work in.
Take a look at the definition of the quotas and then apply the definition to create them.

```
k create ns quotas

cat pod-quotas.yaml

k apply -f ./pod-quotas.yaml -n quotas
```

3.  After setting up the quotas, you can see how things are currently setup and allocated.

```
k get priorityClassses

k describe quota -n quotas
```

4. In the roar-quota directory we have a version of our charts with requests, limits and priority classes
assigned. You can take a look at those by looking at the end of the deployment.yaml templates.
After that, go ahead and install the release.

```
cd ../roar-quotas

cat charts/roar-db/templates/deployment.yaml

cat charts/roar-web/templates/deployment.yaml

helm install -n quotas quota .
```

5.  After a few moments, take a look at the state of the pods in the deployment. Notice that while the
web pod is running, the database one does not exist. Let's figure out why. Since there is no pod to
do a describe on, we'll look for a replicaset.

``` 
k get pods -n quotas

k get rs -n quotas
```

6.  Notice the mysql replicaset. It has DESIRED=1, but CURRENT=0. Let's do a describe on it to see if we
can find the problem.

```
k describe -n quotas rs -l app=mysql
```

7. What does the error message say? The request for memory we asked for the pod exceeds the quota
for the quota "pods-average". If you recall, the pods-average one has a memory limit of 5Gi. The
pods-critical one has a higher memory limit of 10Gi. So let's change priority class for the mysql pod
to be critical.

Edit the [**roar-quotas/charts/roar-db/templates/deployment.yaml**](./roar-quotas/charts/roar-db/templates/deployment.yaml) file and change the last line from
```
priorityClassName: average
```
to
```
priorityClassName: critical
```
being careful not to change the spaces at the start of the line.

![Updating priorityClassName](./images/lab2step7.png?raw=true "Updating priorityClassName")

8.  Upgrade the Helm release to get your changes deployed and then look at the pods again.

```
helm upgrade -n quotas quota .

k get pods -n quotas
```

9.  Notice that while the mysql pod shows up in the list, its status is "Pending". Let's figure out why
that is by doing a describe on it

```
k describe -n quotas pod -l app=mysql
```

10.  The error message indicates that there are no nodes available with enough memory to schedule this
pod. Note that this does not reference any quotas we've setup. Let's get the list of nodes (there's
only 1 in the VM) and check how much memory is available on our node. Use the first command to
get the name of the node and the second to check how much memory it has.

```
k get nodes

k describe node minikube | grep memory
```

11.  Our mysql pod is asking for an unrealistically large number (to provoke the error). Even if it were
just the under the amount available on the node, other processes running on the node in other
namespaces could be using several Gi.

12. Getting back to our needs let's drop the limit and request values down to 1 and 0.5 respectively and
see if that fixes things. Open up the [**roar-quotas/charts/roar-db/templates/deployment.yaml**](./roar-quotas/charts/roar-db/templates/deployment.yaml) and change the two lines near the bottom from
```
memory: "100Gi"
```
to
```memory: "1Gi"``` (for limits)
and
```memory: "0.5Gi"``` (for requests)

![Updating limits and resources](./images/lab2step12.png?raw=true "Updating limits and resources")

13. Do a helm upgrade and add the "--recreate-pods" option to force the pods to be recreated. After a
moment if you check, you should see the pods running now. (If not, you might have to delete the mysql deployment and re-upgrade.)
Finally, you can check the quotas again to see what is being used.

```
helm upgrade -n quotas quota --recreate-pods .
 (ignore the deprecated warning)

k get pods -n quotas

k describe quota -n quotas
```
14. To save cycles on the node, go ahead and remove the quotas namespace.

```
k delete ns quotas
```
<p align="center">
**[END OF LAB]**
</p>

**Lab 3 - Selecting Nodes**

**Purpose: In this lab, we'll explore some of the ways we can tell Kubernetes which node to schedule pods on.**

1. The files for this lab are in the roar-affin subdirectory. Change to that, create a namespace, and do a
Helm install of our release.

```
cd ../roar-affin

k create ns affin

helm install -n affin affin .
```

2. Take a look at the status of the pods in the namespace. You'll notice that they are not ready. Let's
figure out why. Start with the mysql one and do a describe on it.

```
k get pods -n affin

k describe -n affin pod -l app=mysql
```

3. In the output of the describe command, in the Events section, you can see that it failed to be
scheduled because there were "0/1 nodes are available: 1 node(s) didn't match node selector". And
further up, you can see that it is looking for a Node-Selector of "type=mini".

4. This means the pod definition expected at least one node to have a label of "type=mini". Take a look
at what labels are on our single node now.

```
k get nodes --show-labels
```

5. Since we don't have the desired label on the node, we'll add it and then verify it's there.

```
k label node minikube type=mini

k get nodes --show-labels | grep type
```

6. At this point, if you look again at the pods in the namespace you should see that the mysql pod is
now running. Also, if you do a describe on it, you'll see an entry in the Events: section where it was
scheduled.

```
k get pods -n affin

k describe -n affin pod -l app=mysql
```

7. Now, let's look at the web pod. If you do a describe on it, you'll see similar messages about
problems scheduling. But the node-selector entry will not list one. This is because we are using the
node affinity functionality here. You can see the affinity definition by running the second command
below.

```
k describe pod -n affin -l app=roar-web

k get -n affin pod -l app=roar-web -o yaml | grep affinity -A10
```

8. In the output from the grep, you can see that the nodeAffinity setting is
"requiredDuringSchedulingIgnoredDuringExecution" and it would match up with a label of
"system=minikube" or "system=single". But let's assume that we don't really need a node like that,
it's only a preference. If that's the case we can change the pod spec to use
"preferredDuringSchedulingIgnoredDuringExecution".

Open [**roar-affin/charts/roar-web/templates/deployment.yaml**](./roar-affin/charts/roar-web/templates/deployment.yaml) and change
```
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
  - matchExpressions:
```
to
```
preferredDuringSchedulingIgnoredDuringExecution:
- weight: 1
  preference:
    matchExpressions:
```
See screenshot below for reference:

![Updating affinity](./images/lab3step8.png?raw=true "Updating affinity")

9. Now, upgrade the deployment with the recreate-pods option to see the changes take effect.

```
helm upgrade -n affin affin --recreate-pods .
```

10. After a few moments, you should be able to get the list of pods and see that the web one is running
now too. You can do a describe if you want and see that it has been assigned to the training1 node
since it was no longer a requirement to match those labels.

```
k get pods -n affin
```

11. To save cycles on the node, go ahead and remove the affin namespace.

```
k delete ns affin
```
<p align="center">
**[END OF LAB]**
</p>

**Lab 4 - Working with Taints and Tolerations**

**Purpose: In this lab, we'll explore some of the uses of taints and tolerations in Kubernetes**

1. The files for this lab are in the roar-taint subdirectory. Change to that, create a namespace, and do a
Helm install of our release.

```
cd ../roar-taint

k create ns taint

helm install -n taint taint .
```

2. At this point, all pods should be running because there are no taints on the node. (You can do a get on
the pods to verify if you want.). Let's add a taint on the node that implies that pods must be part of the
roar app to be scheduled.

```
k get pods -n taint

k taint nodes minikube roar=app:NoSchedule
```

3. Now, let's delete the release and install again. Then take a look at the pods.

```
helm delete -n taint taint

helm install -n taint taint .

k get pods -n taint
```

4. The web pod has failed to be scheduled. Do a describe to see why.

```   
k describe -n taint pod -l app=roar-web
```

5. Notice that it says "1 node(s) had taints that the pod didn't tolerate." So our database pod must have
had a toleration for it since it was running. Take a look at the two tolerations in the database pod (at
the end of the deployment.yaml file).

```
cat charts/roar-db/templates/deployment.yaml
```

6. Notice the toleration for "roar" and "Exists". This says that the pod can run on the node even if the taint
we created in step 2 above is there - regardless of the value. We need to add this to our web pod spec
so it can run there as well.

Edit the file [**roar-taint/charts/roar-web/templates/deployment.yaml**](./roar-taint/charts/roar-web/templates/deployment.yaml) add these lines (lining up with the same starting column as "containers:")
```
tolerations:
- key: "roar"
  operator: "Exists"
  effect: "NoSchedule"
```
See screenshot below for reference:

![Updating taints](./images/lab4step6.png?raw=true "Updating taints")

7. Now with the toleration added for the web pod, do an upgrade to see if we can get the web pod
scheduled now.

```
helm upgrade -n taint taint .

k get pods -n taint
```

8. Now let's add one more taint for the other toleration that the mysql pod had. Afterwards, take a look at
the state of the pods.

```
k taint nodes minikube use=database:NoExecute

k get pods -n taint
```

9. Why is the web pod not running? The database pod has a toleration for this taint. You can see that in
the charts/roar-db/templates/deployment.yaml file near the bottom. You can also do a describe on the
web pod again if you want to see that it didn't tolerate the new taint.

```
cat charts/roar-db/templates/deployment.yaml

k describe -n taint pod -l app=roar-web
```

10. But the web pod doesn't have this toleration, so because of the "No Execute" policy, it gets kicked out.
We could add a toleration to the web pod spec for this, but for simplicity, let's just remove the taint to
get things running again.

```
k taint nodes minikube use:NoExecute-

k get pods -n taint
```

11. Go ahead and remove the other taint to prepare for future labs.

```  
k taint nodes minikube roar:NoSchedule-
```

12. To save cycles on the node, go ahead and remove the taint namespace.

```
k delete ns taint
```
<p align="center">
**[END OF LAB]**
</p>


**Lab 5 - Working with Pod Security Admission Controllers **

**Purpose: In this lab, we'll learn more about what a pod security admission controller is and why they are needed.**

1. The files for this lab are in the roar-context subdirectory. Change to that, create a namespace, and do a
Helm install of our release.

```
cd ../roar-context

k create ns context

helm install -n context context .
```

2. Our pods should be running now. But we want to make sure that our current workloads do not potentially violate the baseline policy. 
So we'll do a dry-run on the namespace to check.

```
k get pods -n context

k label --dry-run=server --overwrite ns context  pod-security.kubernetes.io/enforce=baseline

```

3. It looks like our workloads are good if we want to just enforce the baseline policy. Let's check though for the restricted policy.

```
k label --dry-run=server --overwrite ns context  pod-security.kubernetes.io/enforce=restricted
```

4. Notice the warning messages from this run.  Let's see what would happen if we were to actually enforce the restricted policy instead.
In the directory **extra**, there is a file named psa-ns.yml that has a definition for a namespace with restricted policy enforced. Go ahead and
look at that file and then apply it to create the namespace.

```
cat ../extra/psa-ns.yml

k apply -f ../extra/psa-ns.yml
```
5. Now, let's see what happens when we try to install the same helm chart in the new namespace.

```
helm install -n psa context .
```

6. Notice the various errors you get. And notice that Helm reports that it is deployed. Take a look at the pods in the namespace.

```
k get pods -n psa
```
See screenshot below for reference:

![Errors trying to install](./images/lab5step6.png?raw=true "Errors trying to install")

7. There are no pods there because they were not permitted. Let's update the deployment manifest for the database charts to fix the issues.
Edit the file [**roar-context/charts/roar-db/templates/deployment.yaml**](./roar-context/charts/roar-db/templates/deployment.yaml) and add these lines (lining up with the same starting column as "ports:" and "env:")

```
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop: ["ALL"]  
      securityContext:
        runAsUser: 1000
        runAsGroup: 999
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
```
See screenshot below for reference:

![Correcting issues](./images/lab5step7.png?raw=true "Correcting issues")

8. Now, upgrade the deployment to deploy the new manifest. And verify that the mysql pod has been admitted and has started up.

```
helm upgrade -n psa context .

k get pods -n psa
```

9. Repeat steps 7 and 8 for the web deployment manifest - the file [**roar-context/charts/roar-web/templates/deployment.yaml**](./roar-context/charts/roar-web/templates/deployment.yaml) 


<p align="center">
**[END OF LAB]**
</p>
