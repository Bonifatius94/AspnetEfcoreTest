
# -----------------------------------
#       B U I L D   S T A G E
# -----------------------------------

# use the official Microsoft .NET build image
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-env

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

# run the unit tests
RUN dotnet test --runtime linux-x64 --configuration Release --no-restore

# make a release build
RUN dotnet publish --runtime linux-x64 --configuration Release \
                   --output /app/bin/ --no-restore

# -----------------------------------
#      D E P L O Y   S T A G E
# -----------------------------------

# use the official Microsoft .NET runtime image
FROM mcr.microsoft.com/dotnet/runtime:7.0 AS runtime-env

# deploy the release build to the runtime
WORKDIR /app/bin
COPY --from=build-env /app/bin /app/bin

# launch the ASP.NET service on container startup
ENTRYPOINT ["dotnet", "EfcoreTest.Api.dll"]
