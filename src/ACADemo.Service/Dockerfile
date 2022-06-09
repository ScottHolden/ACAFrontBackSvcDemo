FROM mcr.microsoft.com/dotnet/runtime:7.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["src/ACADemo.Service/ACADemo.Service.csproj", "src/ACADemo.Service/"]
RUN dotnet restore "src/ACADemo.Service/ACADemo.Service.csproj"
COPY . .
WORKDIR "/src/src/ACADemo.Service"
RUN dotnet build "ACADemo.Service.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ACADemo.Service.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ACADemo.Service.dll"]