FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
ARG TARGETARCH
USER $APP_UID
EXPOSE 8080
WORKDIR /app

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["HeadersLogging/HeadersLogging.csproj", "HeadersLogging/"]
RUN dotnet restore -a $TARGETARCH "HeadersLogging/HeadersLogging.csproj"
COPY . .
WORKDIR "/src/HeadersLogging"
RUN dotnet build "HeadersLogging.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish -a $TARGETARCH "HeadersLogging.csproj" -c $BUILD_CONFIGURATION --no-restore -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "HeadersLogging.dll"]
