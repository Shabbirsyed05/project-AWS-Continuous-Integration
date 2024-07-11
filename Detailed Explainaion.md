# CI with AWS
![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/f6019357-3310-405e-b946-a8daaddc2927)

AWS -> code build -> Create build project -> name(simple-python-flask-service) , description

Source 1 - Primary => source provide -> Github (Authenticate) ,  Public repository / Repository in my GitHub account -> provide the url based on it.

Environment => All default , Operating system -> Ubuntu,  Existing service role (create a service role with code build and SSMFULLACESS) , Additional configuration -> 

Enable this flag if you want to build Docker images or want your builds to get elevated privileges(TICK)

Buildspec => Insert build commands -> Switch to editor .
```
For storing credentials => AWS => System Manager => Parameter Store (left side) => create 3 parameters and store their values.
/myapp/docker-credentials/username :
/myapp/docker-credentials/password
/myapp/docker-credentials/url => docker.io
```
![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/fe57c2b4-355c-472f-a786-79bd2aac517f)

```
version: 0.2

env:
  parameter-store:
    DOCKER_REGISTER_USERNAME: /myapp/docker-credentials/username
    DOCKER_REGISTER_PASSWORD: /myapp/docker-credentials/password
    DOCKER_REGISTER_URL: /myapp/docker-credentials/url

phases:
  install:
    runtime-versions:
      python: 3.11
    commands:
      - pip install -r simple-python-app/requirements.txt
  
  pre_build:
    commands:
      - echo "Installing dependencies"

  build:
    commands:
      - cd simple-python-app
      - echo "Building Docker image"
      - echo "$DOCKER_REGISTER_PASSWORD" | docker login -u "$DOCKER_REGISTER_USERNAME" --password-stdin "$DOCKER_REGISTER_URL"
      - docker build -t "$DOCKER_REGISTER_URL/$DOCKER_REGISTER_USERNAME/simple-python-flask-app:latest" .
      - echo "Pushing Docker image"
      - docker push "$DOCKER_REGISTER_URL/$DOCKER_REGISTER_USERNAME/simple-python-flask-app:latest"
  
  post_build:
    commands:
      - echo "Build is successful."
```
Start Build
```
Notes: 
The command you've shared is used to log in to a Docker registry using credentials stored in environment variables. Here's a breakdown of the command:

echo "$DOCKER_REGISTER_PASSWORD": This echoes the Docker registry password stored in the environment variable DOCKER_REGISTER_PASSWORD.

| docker login -u "$DOCKER_REGISTER_USERNAME" --password-stdin "$DOCKER_REGISTER_URL": This pipes the password to the Docker login command.

docker login: Command to log in to a Docker registry.
-u "$DOCKER_REGISTER_USERNAME": Specifies the username for the Docker registry, stored in the environment variable DOCKER_REGISTER_USERNAME.
--password-stdin: Option to read the password from standard input (stdin), which is the output of the echo command.
"$DOCKER_REGISTER_URL": The URL of the Docker registry, stored in the environment variable DOCKER_REGISTER_URL.
```

Errors:
![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/833e30de-edd0-4814-9847-3b754d82fa32)
Cross check path and spellings
![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/eb228a9a-bfca-421d-ba7e-2c9f9198d567)

![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/d046e3ab-0ae4-4677-a8cf-3f3c5d383f77)
Crosscheck does it has docker login . If has username and password are correct or not

![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/41e19d32-f28a-49af-88f2-d42c61641f94)
Verify Docker build override is present or not

# Now we will be using Code Pipeline  (So that we dont have to do manually. If any change is made to github repository it will triggered)

AWS => CodePipeline => create Pipeline => Name(simple-python-app) , Service Role (New Service role -> it will be displaying automatically) => next

Source => Source Provider (Github version 2) -> connect to gihub => connection name (any name:python-demo-name), github apps (ur account) , 
Repository name(give repo/aws folder name) , Branch name (main) trigger => branch(main) -> next

Build => Build Provider -> AWS CodeBuild , Project Name(Your CodeBuild Project) , Build Type (Single Build) -> next

Add Deploy Stage => Deploy Provider => Skip deploy stage (As it will be covered in Deployment Stage) => Create Pipeline

If someone makes change to github repo , It will be triggered automatically.

# CD with AWS 

![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/7da4b4a1-303a-4545-9ba2-7bffb55c2b2c)

Code Build also happens as somechange make to  Github Repository.

![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/271ad16c-e971-4d1f-9e19-7b83cc3d17e9)
We are using CodePipeline as an orchestrator where as it invokes AWS CodeBuild and AWS Code Deploy

AWS => Code Deploy => Create Application => Application Name (any name : sample-python-flask) , Compute Platform (Ec2/On-primises)
```
This Code deploy should deploy application on Ec2 Instance.
AWS => Ec2 instance =>  ubuntu with normal config (Ensure Public Ip enabled(Auto-assign Pulic Ip -> from Network Settings))
EC2 instances->click on instance -> manage Instance -> Manage Tags -> Create tags => Name , sample-python
Note : Code Deploy will identify by tags , we can do by ec2 names also but if anyone create with same name it will be difficult.
Need to install Code Deploy agent inside the ec2 instance.
```
ssh -i key-pair.pem ubuntu@ip

Follow this document :
https://docs.aws.amazon.com/codedeploy/latest/userguide/codedeploy-agent-operations-install-ubuntu.html

wget https://bucket-name.s3.region-identifier.amazonaws.com/latest/install (Provide the region in place of region-identifier as per doc , bucket-name also as per region from the link in doc)

Find and select the S3 bucket where your source artifacts are stored (e.g., codepipeline-ap-southeast-2-449240622834).
Click on the "Permissions" tab.
Under "Bucket policy", ensure that the policy grants access to the CodeBuild service.
```
EC2 Instace will talk to Code Deploy and vice versa
roles is for services
granting access to users , we use IAM 

IAM -> roles -> AWS Service -> Use Case (Code Deploy) -> next -> Role name (anyname : ec2-codedeploy-role) -> create role
ec2 -> click on instance -> actions -> security -> Modify IAM role -> Provide the role u created
 
ec2 terminal -> sudo service codedeploy-agent restart
sudo service codedeploy-agent status
```

![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/e945c713-eeec-44ea-a899-6698fd4f6539)

Currently u created a folder for the application , name of the appication and provided deploy on ec2 instace. U need to provide where is the source code , what type of app is this , how to execute, how to deploy this app
```
you need to provide target/ target group to code deploy
Roles -> ec2-codedeploy-role => Permission policay -> Add permission -> attach permission => ec2fullaccess
Code deploy =>  Application (sample-python-flask-app)-> Deployment Groups => Create deployment groups => name (sample-python-app), service role -> ec2-codedeploy-role (role u create above) ,
Deployment type => In-place (if we choose Blue/Green Deployment , we need 2 sites and loadbalancer) ,
Environment configuration -> Amazon ec2 instance => key (name), value(sample-python) (it will show, how many instances are matching) ,
Load Balancer (untick) -> Create Deployment group
```
```
Inside codedeploy we register application payment , create a folder/registered for payments application , we created instance for payments application , for deploying payments on ec2 instnace.
so integrated both saying this is my target group and has to be impleted but we havent told how to deploy
Now we shown the target group to code deploy, need to show how to deploy . For showing we will create a file and update in it
```
```
Code deploy =>  Application (sample-python-flask-app)-> deployments => deployment group (sample-python-app) , 
Resouse type -> My appplication is stored in github -> authenticate -> repository name -> username/repo  ,
commit id (provide any commit id for checking CD working or not later it can integrate with codepipeline) -> create deployment (it will fail,need to have appspec.yaml at the root of the repository)
```
ec2 Terminal -> sudo apt install docker.io -y
```
code deploy -> deploy
code pipeline -> sample-python-app -> edit ->  add stage (code-deploy below build) -> action group (name : code-deploy , 
action provider : AWS codeDeploy, Input artifact : BuildArtifact ,Application name : sample-python-flastk-app , deployment group : sample-python-app/Output Artifact : anyname: CodeDeployArtifact) -> save
```
![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/a3f5b56a-63de-4bc4-9ddd-e07f3491769a)

```
make somechange in  github . Now the code pipeline will run
Instead of codecommit . we used github
check dockerhub now
```
```
check codepipe -> release has failed
ec2 terminal ->sudo docker images 
sudo docker ps
```
errors(we will get below error. if dont create a script to remove the containers):
![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/aa07969f-e3bf-455d-b73b-561d71a8aa3f)

![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/c9bfeb8d-fd8a-4ff0-aaca-4ff967eb23ba)

![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/eddecb63-b7f2-4446-af7f-8359c876badc)

as we ran for 2 times -> we it ran for 2nd time (1st by manually then by codepipe port is already registered for 1st time) -> it can by done by removing the container, it can be fixed by changing the port (not recomended)

check codepipe -> release (it will work)
