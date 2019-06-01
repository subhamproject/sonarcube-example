FROM maven:3.3
ADD ./target/my-app-1.0-SNAPSHOT.jar /tmp/my-app-1.0-SNAPSHOT.jar
EXPOSE 8080
CMD ["java", "-jar", "/tmp/my-app-1.0-SNAPSHOT.jar"]
