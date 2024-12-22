so what I did in this project. I have took the source code from GitHub docker file team, In Azure DevOps I created a project known as Voting-App. 
In that repos section I cloned the repo where I copied from the Docker File GitHub. after that I need in Azure I created a Azure Container Registry when I can store my docker images. 
once I created the container registry now I created a azure virtual machine where it was going to act as my agent pool to run my voting application in azure devops. 
once I created virtual machine I can connect it from my local computer using git bash. once I connected to my virtual machine using gitbash I have made some required configurations and 
installations [azure pipelines requirements and Docker] on my virtual machine, once I setup everything on my azure virtual machine I can able to successfully run my pipelines and I can see my pipelines are successfully running, 
upto this I have successfully my CI Application,



Now my CD Part:
For CD, I need to run on my local machine for that I need to connect to my azure devops to my Azure for that I have created a azure kuberenetes cluser on my azure once I can connect to my virtual machine I can install 
the requirements of Kuberentes and also the requirements for argoCD [it'a a application which is a part of CD process], once I had connected to argocd I can se my voting application has been running on my argocd, now if I make 
any changes on my voting application it will be reflected on the argocd application and also it'll deploy the latest changes once I made any changes on my CI pipelines.



so overall process of CI/ CD:
CI [In Pipelines I created two stages name dev & test, once it deployed successfully I create another stage name as update now it will be the connecting point to my CD]
CD[In CD the argocd have been looking for the repos if there are any changes made, once there is a change the Kuberenetes pod deploy the changes as a new change in the argocd]
