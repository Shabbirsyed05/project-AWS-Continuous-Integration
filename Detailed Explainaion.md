![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/f6019357-3310-405e-b946-a8daaddc2927)


AWS -> code build -> Create build project -> name , description

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

![image](https://github.com/Shabbirsyed05/project-AWS-Continuous-Integration/assets/119849465/271ad16c-e971-4d1f-9e19-7b83cc3d17e9)

