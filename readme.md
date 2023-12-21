## Development / Testing Environment

Goal: Create a shareable environment that utilizes docker for ease of use.

### Docker Compose

docker compose is used to simplify the commands required to launch the docker image

-e JUPYTER_TOKEN="PASSWORD" #allows for a password to be used instead of shifting though logs to find the jupyter token
-p host_port:mapped_port  #maps port to image
-t tag #name of the built image
-n name #name of image ** restart the image via `docker compose up -d `
-v .:app/  #mounts run location to the /app directory in the docker image (links file system)

### jupyter.env 
this file allows you to pass sensitive information into the image and store them via a file that doesn't get commited to the repo
```
env_file:
      - jupyter.env
```




### .env

this stores sensitive information that is accessable to docker & docker compose 
used like :     ```environment:
      - JUPYTER_TOKEN=${jupyter_pw}```

### Commands

- Builds the image
docker compose build 

- Runs the built image
docker compose up

- Runs the built image headlessly 
docker compose up -d

#### Run just docker image

- Build example:

docker built . -t jupyter_labs

- Run image example:

docker run jupyter_labs -p 8800:8888 -e JUPTYER_TOKEN="password" -v .:/app -d


#### Add additonal services
--
Advantage using docker networking allows you to reference the container name instead of ip address
and takes less time to worry about getting a service up and running
for anything where data retention is needed ensure to keep a volume mounted (either docker controlled or direct file system)
--
To the docker compose image you can add additonal services:
mysql example:
mysql:
    image: mysql:8.2
    container_name: ga_mysql
    # command: --ignore-db-dir=lost+found
    # restart: always
    ports:
    - 3306:3306
    environment:
        MYSQL_ROOT_PASSWORD: ${mysql_root_password}
        MYSQL_DATABASE: ds
        MYSQL_ROOT_HOST: "%"
        MYSQL_USER: ${mysql_user}
        MYSQL_PASSWORD: ${mysql_password}
    volumes:
    - mysql_vol_test:/var/lib/mysql/

### Workflows

#### Python packages
Adding additional requirements.

using pip install package
you can install additonal packages however remember that unless the requirementx.txt is updated it will not take between builds


#### Enviornmental Variables

The image needs to be rebuilt to add additonal virables 

TODO: Create a function or script that will reload values into the environment