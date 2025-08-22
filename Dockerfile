FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["src/CleanArchitectureAPI.WebAPI/CleanArchitectureAPI.WebAPI.csproj", "src/CleanArchitectureAPI.WebAPI/"]
COPY ["src/CleanArchitectureAPI.Application/CleanArchitectureAPI.Application.csproj", "src/CleanArchitectureAPI.Application/"]
COPY ["src/CleanArchitectureAPI.Infrastructure/CleanArchitectureAPI.Infrastructure.csproj", "src/CleanArchitectureAPI.Infrastructure/"]
COPY ["src/CleanArchitectureAPI.Core/CleanArchitectureAPI.Core.csproj", "src/CleanArchitectureAPI.Core/"]
RUN dotnet restore "src/CleanArchitectureAPI.WebAPI/CleanArchitectureAPI.WebAPI.csproj"
COPY . .
WORKDIR "/src/src/CleanArchitectureAPI.WebAPI"
RUN dotnet build "CleanArchitectureAPI.WebAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CleanArchitectureAPI.WebAPI.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CleanArchitectureAPI.WebAPI.dll"]