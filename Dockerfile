# Stage 1: Build frontend (unchanged)
FROM node:22-alpine AS with-node
WORKDIR /app/fixit.client
COPY fixit.client/package.json fixit.client/package-lock.json ./
RUN npm ci --only=production
COPY fixit.client/ .
RUN npm run build

# Stage 2: Build and Publish backend (corrected paths)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-publish
WORKDIR /FixItFull/FIxIt.Server/
COPY /FixItFull/FixIt.Server/FixIt.Server.csproj .
RUN dotnet restore
COPY /FixItFull/FIxIt.Server/ .
RUN dotnet publish -c Release -o /app/publish

# Stage 3: Final image (unchanged)
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
WORKDIR /app
COPY --from=build-publish /app/publish .
COPY --from=with-node /app/fixit.client/dist/fixit.client ./wwwroot
ENTRYPOINT ["dotnet", "FixIt.Server.dll"]
