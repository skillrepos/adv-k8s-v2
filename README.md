# Advanced Kubernetes - lab setup

These instructions will guide you through configuring a GitHub Codespaces environment that you can use to run the course labs.

These steps **must** be completed prior to starting the actual labs.

## Create your own repository for these labs

- Ensure that you have created a repository by forking the [skillrepos/adv-k8s-v2](https://github.com/skillrepos/adv-k8s-v2) project as a template into your own GitHub area.
- You do this by clicking the `Fork` button in the upper right portion of the main project page and following the steps to create a copy in [your-github-userid/kint](https://<your-github-userid>/kint).

![Forking repository](./images/advk8s1.png?raw=true "Forking the repository")

## Configure your codespace

1. In your forked repository, start a new codespace.

    - Click the `Code` button on your repository's landing page.
    - Click the `Codespaces` tab.
    - Click `Create codespaces on main` to create the codespace.
    - After the codespace has initialized there will be a terminal present.

![Starting codespace](./images/advk8s2.png?raw=true "Starting your codespace")

After a few minutes, you should have a new codespace up and running. This will start a new single-node kubernetes cluster using the minikube application.
#

## Labs
You should see the labs document opened automatically.
![Labs doc preview in codespace](./images/advk8s3.png?raw=true "Labs doc preview in codespace")

If not, open the labs document by clicking on the link below. (Alternatively, you can go to the file tree on the left, find the file named **labs.md**, right-click on it, and open it with the `Preview` option.)
This will open it up in a tab above your terminal. Then you can follow along with the steps in the labs. 
Any command in the gray boxes is either code intended to be run in the console or code to be updated in a file.

Labs doc: [Advanced Kubernetes Labs](codespace-labs.md)

