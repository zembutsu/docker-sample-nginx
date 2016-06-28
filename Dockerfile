FROM nginx:latest

COPY default.conf /etc/nginx/conf.d/
COPY index.html /usr/share/nginx/html/
