
# use the official Microsoft .NET 5 build image
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build-env

# define build args
ARG HTTPS_SSL_PW=cd6dafc5bfbc3e9d114fadcef904267912438fc20479714260a3fa48b4111ed72af9674550fd0a885d9238f1f56ac5dbc923

# configure ASP.NET https settings
ENV ASPNETCORE_URLS="https://+;http://+"
ENV ASPNETCORE_HTTP_PORT=80
ENV ASPNETCORE_HTTPS_PORT=443
ENV ASPNETCORE_Kestrel__Certificates__Default__Password=$HTTPS_SSL_PW
ENV ASPNETCORE_Kestrel__Certificates__Default__Path=/app/certs/aspnetapp.pfx

# TODO: make SSL connection work, too

# move to the src target dir
WORKDIR /app/src

# copy the solution and project files
ADD ./src/EfcoreTest.sln ./EfcoreTest.sln
ADD ./src/EfcoreTest.Api/EfcoreTest.Api.csproj ./EfcoreTest.Api/EfcoreTest.Api.csproj
ADD ./src/EfcoreTest.Data/EfcoreTest.Data.csproj ./EfcoreTest.Data/EfcoreTest.Data.csproj

# restore the NuGet packages (for caching)
RUN dotnet restore --runtime linux-x64

# copy the source code
ADD ./src/ ./

# TODO: run the unit tests here ...
RUN dotnet test --runtime linux-x64 --configuration Release --no-restore

# make a release build
RUN dotnet publish --runtime linux-x64 --configuration Release \
                   --output /app/bin/ --no-restore

# generate SSL certificates
RUN dotnet dev-certs https -ep /app/certs/aspnetapp.pfx -p $HTTPS_SSL_PW && \
    dotnet dev-certs https --trust

# define the .NET 5 runtime image
FROM mcr.microsoft.com/dotnet/runtime:5.0
WORKDIR /app/bin
COPY --from=build-env /app/bin /app/bin
COPY --from=build-env /app/certs /app/certs

# launch the daemon test service on container startup
ENTRYPOINT ["dotnet", "EfcoreTest.Api.dll"]
