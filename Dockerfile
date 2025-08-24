# ========================
# ESTÁGIO 1: BUILD
# ========================
# Usamos a imagem do Maven para compilar o projeto. Damos o nome de 'builder' a este estágio.
FROM maven:3.9.6 AS builder

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia o arquivo pom.xml para o container
COPY pom.xml .

# Baixa as dependências do Maven. Isso otimiza o cache do Docker.
RUN mvn dependency:go-offline

# Copia todo o código-fonte para o container
COPY src ./src

# Empacota a aplicação em um arquivo JAR executável
RUN mvn package -DskipTests

# ========================
# ESTÁGIO 2: RUNTIME
# ========================
# Usamos uma imagem base menor (OpenJDR) para o runtime, que é mais leve.
FROM openjdk:24-jdk-slim

# Define o diretório de trabalho
WORKDIR /app

# Copia o arquivo JAR gerado no estágio de "builder" para a imagem final
# AQUI, o '--from=builder' referencia o primeiro estágio
COPY --from=builder /app/target/*.jar dslistservice.jar

# Expõe a porta que sua aplicação Spring Boot usa
EXPOSE 8080

# Comando para rodar a aplicação quando o container iniciar
ENTRYPOINT ["java", "-jar", "dslistservice.jar"]