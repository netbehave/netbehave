#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY ["netbehave-wwwv2/netbehave-wwwv2.csproj", "netbehave-wwwv2/"]
RUN dotnet restore "netbehave-wwwv2/netbehave-wwwv2.csproj"
COPY . .
WORKDIR "/src/netbehave-wwwv2"
RUN dotnet clean "netbehave-wwwv2.csproj" -c Release -o /app/build
RUN dotnet build "netbehave-wwwv2.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "netbehave-wwwv2.csproj" -c Release -o /app/publish

# build Vue app portion
FROM node:alpine as buildvue
WORKDIR /src
COPY netbehave-wwwv2/clientapp/package.json .
RUN npm install
# webpack build
COPY netbehave-wwwv2/clientapp .
RUN npm run build
# RUN ls -R /src/dist

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY --from=buildvue /src/dist /
COPY /app/publish/appsettings-linux.json /app/appsettings.json
RUN mkdir -p /wwwroot
ENTRYPOINT ["dotnet", "netbehave-wwwv2.dll"]