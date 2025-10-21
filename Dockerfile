# Use official Tomcat image with JDK 17
FROM tomcat:9.0.98-jdk17

# Set working directory to ROOT
WORKDIR /usr/local/tomcat/webapps/ROOT/

# Copy all project files
COPY ./HTML ./HTML
COPY ./CSS ./CSS
COPY ./JS ./JS
COPY ./IMAGES ./IMAGES
COPY ./WEB-INF ./WEB-INF

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
