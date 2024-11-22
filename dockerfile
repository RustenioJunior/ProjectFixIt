# Stage 1: Build frontend
FROM node:22 AS with-node
WORKDIR /app
COPY fixit.client/ .  
WORKDIR /app/fixit.client
RUN npm install
RUN npm run build 

# Stage 2: Build backend
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY FixIt.Server/FIxIt.Server.csproj ./FixIt.Server/  
RUN dotnet restore "FixIt.Server/FIxIt.Server.csproj"
COPY FixIt.Server/ ./FixIt.Server/  
WORKDIR "/src/FixIt.Server"
RUN dotnet build "FIxIt.Server.csproj" -c Release -o out

# Stage 3: Publish backend
FROM build AS publish
RUN dotnet publish "FIxIt.Server.csproj" -c Release -o out --self-contained false -p:PublishSingleFile=false

# Stage 4: Final image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=publish /src/FixIt.Server/out ./
COPY --from=with-node /app/fixit.client/dist/fixit.client ./wwwroot
ENTRYPOINT ["dotnet", "FIxIt.Server.dll"]
