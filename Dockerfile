FROM tomcat:9.0.98-jdk17

# Disable Tomcat shutdown port to remove warnings
RUN sed -i 's/port="8005"/port="-1"/' /usr/local/tomcat/conf/server.xml

# Set working directory to Tomcat ROOT webapp
WORKDIR /usr/local/tomcat/webapps/ROOT/

# Copy project files
COPY ./HTML ./HTML
COPY ./CSS ./CSS
COPY ./JS ./JS
COPY ./IMAGES ./IMAGES
COPY ./WEB-INF ./WEB-INF

# Copy the index.html redirect into the ROOT folder directly
COPY ./HTML/index.html ./index.html

# Optional: speed up startup random generator
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"

EXPOSE 8080

CMD ["catalina.sh", "run"]
