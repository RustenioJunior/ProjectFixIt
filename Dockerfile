# Stage 1: Build frontend
FROM node:22-alpine AS with-node  
WORKDIR /app/fixit.client 
COPY fixit.client/package.json fixit.client/package-lock.json ./ 
RUN npm ci --only=production 
COPY fixit.client/ .
RUN npm run build

# Stage 2: Build backend
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /FixIt.Server
COPY FixIt.Server/FixIt.Server.csproj .  
RUN dotnet restore
COPY FixIt.Server/ .                   
RUN dotnet build -c Release -o /app/build

# Stage 3: Final image
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine 
WORKDIR /app
COPY --from=build /app/build .
COPY --from=with-node /app/fixit.client/dist/fixit.client ./wwwroot
ENTRYPOINT ["dotnet", "FixIt.Server.dll"]
