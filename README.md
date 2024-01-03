
# ASP.NET Web API + Entity Framework Test

## About
This project is supposed to be a boilerplate for testing an ASP.NET Web API
using EntityFramework Core (SQLite) as data storage in a dockerized context.

Note that this service exposes its endpoint via HTTPS which requires quite
some configuration effort to get it to work. That is because the standard
configuration from the Microsoft docs does not work right away.

## Install Build Toolchain
First, you need to install Docker to your machine if you haven't done already.

```sh
# install docker / docker-compose and allow the currently logged-in
# user to issue docker commands without having to use 'sudo' all the time
sudo apt-get update && sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker $USER && reboot
```

## Generate SSL Certificates for HTTPS
Second, you need to generate SSL certificates for running an HTTPS endpoint.
Following commands generate only temporary, self-signed certificates.

### Approach for Windows and Mac OS
Use following commands when running a Windows or Mac OS host system.

```sh
# generate SSL certificates for HTTPS, written to ./certs folder
export HTTPS_SSL_PW=cd6dafc5bfbc3e9d114fadcef9042679
dotnet dev-certs https -ep ./certs/localhost.pfx -p $HTTPS_SSL_PW
dotnet dev-certs https --trust

# see: https://docs.microsoft.com/en-us/aspnet/core/security/docker-https?view=aspnetcore-5.0
```

### Approach for Linux Debian
Use following commands when running a Linux host system.

```sh
# define the password for the SSL certificate to be generated
export HTTPS_SSL_PW=cd6dafc5bfbc3e9d114fadcef9042679
cd certs

# create self-signed certs, leave fields and password empty
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout localhost.key -out localhost.crt -config localhost.conf \
    -passout pass:$HTTPS_SSL_PW
openssl pkcs12 -export -out localhost.pfx -inkey localhost.key -in localhost.crt

# verify the keygen worked
openssl verify -CAfile localhost.crt localhost.crt

# verify the certificate registeration was successful (expected to fail)
openssl verify localhost.crt

# register the self-signed certificate on the local machine, so the browser will trust it
sudo cp localhost.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates

# verify the certificate registeration was successful (expected to pass now)
cat /etc/ssl/certs/localhost.pem
openssl verify localhost.crt

# see: https://stackoverflow.com/questions/55485511/how-to-run-dotnet-dev-certs-https-trust
```

## Build and Test the Docker Image
Use following commands to build the ASP.NET service as Docker image, deploy it
as a docker-compose service and run the API test script (integration tests).

```sh
# build the docker image and start a new service instance
docker-compose up -d --build

# run the API test script
./tests/test_api.sh

# shut down the service instance
docker-compose down
```

Running the test_api.sh should print an output like the following:

```text
[]{"id":1,"text":"Buy 2 bottles of milk","due":"2021-08-23T00:00:00"}{"id":2,"text":"Buy a brezel and butter","due":"2021-08-24T00:00:00"}[{"id":1,"text":"Buy 2 bottles of milk","due":"2021-08-23T00:00:00"},{"id":2,"text":"Buy a brezel and butter","due":"2021-08-24T00:00:00"}]{"id":2,"text":"Buy a brezel and butter","due":"2021-08-24T00:00:00"}{"id":1,"text":"Buy 2 bottles of milk","due":"2021-08-23T00:00:00"}{"id":2,"text":"Buy a brezel and butter","due":"2021-08-24T00:00:00"}[]
```

 ## License
 No license, feel free to use this boilerplate for your project.
