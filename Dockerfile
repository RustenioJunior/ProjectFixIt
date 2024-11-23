# Stage 1: Build frontend (unchanged)
FROM node:22-alpine AS with-node
WORKDIR /app/fixit.client
COPY fixit.client/package.json fixit.client/package-lock.json ./
RUN npm ci --only=production
COPY fixit.client/ .
RUN npm run build

# Stage 2: Build and Publish backend (combined)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-publish
WORKDIR /FixIt.Server
COPY FixIt.Server/FixIt.Server.csproj .
RUN dotnet restore
COPY FixIt.Server/ .
RUN dotnet publish -c Release -o /app/publish  

# Stage 3: Final image (modified)
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
WORKDIR /app
COPY --from=build-publish /app/publish . 
COPY --from=with-node /app/fixit.client/dist/fixit.client ./wwwroot
ENTRYPOINT ["dotnet", "FixIt.Server.dll"]  
