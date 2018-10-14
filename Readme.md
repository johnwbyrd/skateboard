sudo docker exec $CONTAINER_ID cat /home/ubuntu/password.txt
sudo docker run -itd -p 80:6080 -e PASSWORD=$YOUR_PASSWORD $DOCKER_ID
