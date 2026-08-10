FROM nginx:1.27-alpine

ENV TZ=Africa/Luanda

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

COPY index.html logo.svg og-image.png /usr/share/nginx/html/
COPY assets/mark.svg /usr/share/nginx/html/assets/mark.svg

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1/healthz || exit 1
