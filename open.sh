IP=`docker-machine inspect default --format '{{ .Driver.IPAddress }}'`
open "http://$IP"
