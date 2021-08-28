#!/bin/bash

# define the base URL
base_url=https://localhost:5001/todo

# query empty todo items list
curl -X GET "$base_url"

# create a todo item
curl -d '{"Id":0,"Text":"Buy 2 bottles of milk","Due":"2021-08-23"}' \
     -H 'Content-Type: application/json' -X POST "$base_url"

# create another todo item
curl -d '{"Id":0,"Text":"Buy a brezel and butter","Due":"2021-08-24"}' \
     -H 'Content-Type: application/json' -X POST "$base_url"

# query todo items list just created
curl -X GET "$base_url"

# update the second todo item
curl -d '{"Id":2,"Text":"Buy a brezel and buttermilk","Due":"2021-08-26"}' \
     -H 'Content-Type: application/json' -X PUT "$base_url/2"

# query the updated todo item
curl -X GET "$base_url/2"

# delete all todo items from database
curl -X DELETE "$base_url/1"
curl -X DELETE "$base_url/2"

# query todo items list (make sure deleted items are gone)
curl -X GET "$base_url"
