sudo minikube start --vm-driver=none --kubernetes-version=v1.21.11  --extra-config=apiserver.enable-admission-plugins=PodSecurityPolicy,NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds --addons=pod-security-policy
sudo chown -R $USER $HOME/.kube $HOME/.minikube
chmod -R u+wrx $HOME/.minikube

