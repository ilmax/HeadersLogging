# FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
# ARG TARGETARCH
# USER $APP_UID
# EXPOSE 8080
# WORKDIR /app

# ENV TARGETARCH=$TARGETARCH
# FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0 AS build
# ARG BUILD_CONFIGURATION=Release
# WORKDIR /src
# COPY ["HeadersLogging/HeadersLogging.csproj", "HeadersLogging/"]
# RUN dotnet restore -a $TARGETARCH "HeadersLogging/HeadersLogging.csproj"
# COPY . .
# WORKDIR "/src/HeadersLogging"
# RUN dotnet build "HeadersLogging.csproj" -c $BUILD_CONFIGURATION -o /app/build

# ENV TARGETARCH=$TARGETARCH
# FROM build AS publish
# ARG BUILD_CONFIGURATION=Release
# RUN dotnet publish -a $TARGETARCH "HeadersLogging.csproj" -c $BUILD_CONFIGURATION --no-restore -o /app/publish /p:UseAppHost=false

# FROM base AS final
# WORKDIR /app
# COPY --from=publish /app/publish .
# ENTRYPOINT ["dotnet", "HeadersLogging.dll"]


FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG TARGETARCH
WORKDIR /source

# Copy project file and restore as distinct layers
COPY --link HeadersLogging/*.csproj .
RUN dotnet restore -a $TARGETARCH

# Copy source code and publish app
COPY --link HeadersLogging/. .
RUN dotnet publish -a $TARGETARCH --no-restore -o /app


# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0
EXPOSE 8080
WORKDIR /app
COPY --link --from=build /app .
USER $APP_UID
ENTRYPOINT ["dotnet", "HeadersLogging.dll"]