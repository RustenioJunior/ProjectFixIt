# Stage 1: Build do frontend
FROM node:22 AS with-node
WORKDIR /app
COPY /fixit.client .
WORKDIR /app/fixit.client
RUN npm install
RUN npm run build  

# Stage 2: Build do backend
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["FIxIt.Server/FIxIt.Server.csproj", "FIxIt.Server/"]
RUN dotnet restore "FIxIt.Server/FIxIt.Server.csproj"
COPY . .
WORKDIR "/src/FIxIt.Server"
RUN dotnet build "FIxIt.Server.csproj" -c Release -o out

# Stage 3: Publish do backend
FROM build AS publish
RUN dotnet publish "FIxIt.Server.csproj" -c Release -o out --self-contained false -p:PublishSingleFile=false

# Stage 4: Imagem final
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=publish /src/FIxIt.Server/out ./
COPY --from=with-node /app/fixit.client/dist/fixit.client ./wwwroot  
ENTRYPOINT ["dotnet", "FIxIt.Server.dll"]