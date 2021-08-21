
# ASP.NET Web API + Entity Framework Test

## About
This project is supposed to be a boilerplate for testing an ASP.NET Web API
using EntityFramework Core (SQLite) as data storage in a dockerized context.

## How to Build

```sh
# build docker image
docker build . -t "aspnet-efcore-test" \
    --build-arg HTTPS_SSL_PW=$(openssl rand -hex 50)

# create a service instance
docker run -p 5001:443 -p 5000:80 "aspnet-efcore-test"

# run the API test script
./tests/test_api.sh
```
