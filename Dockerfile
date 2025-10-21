# Use official Tomcat image with JDK 17
FROM tomcat:9.0.98-jdk17

# Disable Tomcat shutdown port to avoid "Invalid shutdown command" warnings
RUN sed -i 's/port="8005"/port="-1"/' /usr/local/tomcat/conf/server.xml

# Set working directory to ROOT webapp
WORKDIR /usr/local/tomcat/webapps/ROOT/

# Copy project files
COPY ./HTML ./HTML
COPY ./CSS ./CSS
COPY ./JS ./JS
COPY ./IMAGES ./IMAGES
COPY ./WEB-INF ./WEB-INF

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
