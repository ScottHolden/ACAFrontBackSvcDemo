#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["src/ACADemo.BackEnd/ACADemo.BackEnd.csproj", "src/ACADemo.BackEnd/"]
RUN dotnet restore "src/ACADemo.BackEnd/ACADemo.BackEnd.csproj"
COPY . .
WORKDIR "/src/src/ACADemo.BackEnd"
RUN dotnet build "ACADemo.BackEnd.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ACADemo.BackEnd.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ACADemo.BackEnd.dll"]