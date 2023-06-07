Deploys an api gateway rest api using the api.yaml file

Also includes a module that makes it easy to create lambdas that are integrated with the api.

endpoints
/create-user
POST request that expects 
{
  "username": "username",
  "password": "password"
}

/reset-password
POST request that expects body
{
  "previous_password": "username",
  "new_password": "password"
}

/sign-in
POST request that expects body
{
  "username": "username",
  "password": "password"
}

/start-ark
POST request that doesn't expect a body

/stop-ark
POST request that doesn't expect a body



