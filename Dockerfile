# Use official Tomcat with Java 17
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

# Copy optional index.html redirect
COPY ./HTML/index.html ./index.html

# Copy SQL initialization script
COPY ./SQL/init.sql /init.sql

# Install PostgreSQL client to run init.sql
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Add PostgreSQL JDBC driver (Tomcat needs this)
RUN curl -o /usr/local/tomcat/lib/postgresql.jar https://jdbc.postgresql.org/download/postgresql-42.7.4.jar

# Set environment variables (Render will override these)
ENV DB_HOST=localhost
ENV DB_PORT=5432
ENV DB_NAME=food_delivery
ENV DB_USER=vikyath
ENV DB_PASSWORD=changeme
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"

# Startup script: run SQL once, then start Tomcat
COPY <<EOF /usr/local/bin/start.sh
#!/bin/bash
set -e
echo "Waiting for PostgreSQL at $DB_HOST:$DB_PORT..."
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" >/dev/null 2>&1; do
  sleep 2
done

echo "Running DB initialization (if not yet done)..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f /init.sql || echo "DB init skipped or already done."

echo "Starting Tomcat..."
exec catalina.sh run
EOF

RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8080

CMD ["/usr/local/bin/start.sh"]
