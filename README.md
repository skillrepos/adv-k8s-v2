# Advanced Kubernetes - Gaining Mastery over your deployments - lab setup

## 1. Create your own codespace to run the labs by clicking on the button below.
<br/><br/>

Click here ------> [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/skillrepos/adv-k8s-v2?quickstart=1)

<br/><br/>

Then click on the option to create a new codespace.

![Creating new codespace from button](./images/advk8s0.png?raw=true "Creating new codespace from button")

**This will run for several minutes while it gets everything ready.**

<br/><br/>

## 2. Start your single-node Kubernetes cluster
There is a simple one-node Kubernetes instance called **minikube** available in your codespace. Start it the following way:

Run the following commands in the codespace's terminal (**This will take several minutes to run...**):

```
minikube start
```

The output should look similar to the following. 

```console
😄  minikube v1.30.1 on Ubuntu 20.04 (docker/amd64)
✨  Using the docker driver based on existing profile
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
🏃  Updating the running docker "minikube" container ...
🐳  Preparing Kubernetes v1.26.3 on Docker 23.0.2 ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```
(**NOTE:** If you get a failure message like this "Exiting due to DRV_DOCKER_NOT_RUNNING: Found docker, but the docker service isn't running. Try restarting the docker service.", that means that Docker is still starting up. Just wait a minute or two and then run the command again.)

## 3. Open the labs doc. 

You can open the labs doc either in a separate browser tab/window via [Open Labs Document in Browser](https://github.com/skillrepos/adv-k8s-v2/blob/main/codespace-labs.md) and/or you can open the labs in the codespace itself. To open it in the codespace, follow the instructions below.

After the codespace has started, you can close the *Welcome* doc by clicking on the X in its tab. Then open the labs document by going to the file tree on the left, find the file named **codespace-labs.md**, right-click on it, and open it with the **Preview** option.)

![Labs doc preview in codespace](./images/advk8s7.png?raw=true "Labs doc preview in codespace")

This will open it up in a tab above your terminal. Then you can follow along with the steps in the labs. 
Any command in the gray boxes is either code intended to be run in the console or code to be updated in a file.

Labs doc: [Advanced Kubernetes Labs](codespace-labs.md)

## 4. Set codespace timeout (optional but recommended)

While logged in to GitHub, go to https://github.com/settings/codespaces.

Scroll down and find the section on the page labeled *Default idle timeout*. 

Increase the default timeout value to 90 minutes and then select the *Save* button.

![Increasing default timeout](./images/k8sdev33.png?raw=true "Increasing default timeout")

(**NOTE**: If your codespace does time out at some point in the course, there should be a button to restart it. In that case, you will need to run the *minikube start* command again.)


