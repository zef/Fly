docker rm swift
docker build -t swift ./
docker run -p 80:8080 --name swift -it swift /bin/bash
