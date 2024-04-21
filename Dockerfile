FROM openjdk:17-alpine
COPY ./target/*.jar /spring-petclinic-2.7.0-SNAPSHOT.jar
CMD ["java","-jar", "/spring-petclinic-2.7.0-SNAPSHOT.jar"]
