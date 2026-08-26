MONGO:
$ docker run -d \
--name mongodb \
--network app-network \
-p 27017:27017 \
-v mongo-data:/data/db \
mongo:8

BACKEND:
 docker run \
--name backend-container \
--network app-network \
--env-file ./backend/.env \
-p 4000:4000 \
backend-image

USER FRONT:
docker run \
--name user-container \
--network app-network \
-p 3000:80 \
user-frontend-image


admin front:
 docker run \
--name admin-container \
--network app-network \
-p 3001:80 \
admin-frontend-image


