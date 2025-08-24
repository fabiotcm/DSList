# Estágio 1: Construir a aplicação
# Versão do Maven ajustada para 3.9.0 e OpenJDK para 24
FROM maven:3.9.0-openjdk-24 AS build

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia o arquivo pom.xml para o container
COPY pom.xml .

# Baixa as dependências do Maven.
RUN mvn dependency:go-offline

# Copia todo o código-fonte para o container
COPY src ./src

# Empacota a aplicação em um arquivo JAR executável
RUN mvn package -DskipTests

# Estágio 2: Criar a imagem final para a aplicação
# Versão do OpenJDK para o runtime ajustada para 24
FROM openjdk:24-jdk-slim

# Define o diretório de trabalho
WORKDIR /app

# Copia o arquivo JAR gerado no estágio de "build" para a imagem final
COPY --from=build /app/target/*.jar dslistservice.jar

# Expõe a porta que sua aplicação Spring Boot usa (geralmente a 8080)
EXPOSE 8080

# Comando para rodar a aplicação quando o container iniciar
ENTRYPOINT ["java", "-jar", "dslistservice.jar"]