FROM nginx:alpine

# OCI Labels for GitHub Container Registry
LABEL org.opencontainers.image.source="https://github.com/bryanlabs/matt-website"
LABEL org.opencontainers.image.description="Personal portfolio website for Matt Bryan, PTA"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="matt-website"
LABEL org.opencontainers.image.vendor="bryanlabs"

# Copy the static website to nginx's default serve directory
COPY index.html /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# nginx runs automatically as the default command
