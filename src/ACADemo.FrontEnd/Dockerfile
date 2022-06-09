#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["src/ACADemo.FrontEnd/ACADemo.FrontEnd.csproj", "src/ACADemo.FrontEnd/"]
RUN dotnet restore "src/ACADemo.FrontEnd/ACADemo.FrontEnd.csproj"
COPY . .
WORKDIR "/src/src/ACADemo.FrontEnd"
RUN dotnet build "ACADemo.FrontEnd.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ACADemo.FrontEnd.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ACADemo.FrontEnd.dll"]