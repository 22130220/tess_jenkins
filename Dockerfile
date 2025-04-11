FROM gradle:jdk21 AS build
WORKDIR /app
COPY . .
RUN gradle clean build --no-daemon



FROM tomcat:10.1.36-jre21
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
