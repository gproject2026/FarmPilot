# Authentication API

Base URL:

http://localhost:3000


## Register

POST

/auth/register


Request Body:

{
  "fullName": "Test User",
  "email": "user@test.com",
  "password": "123456",
  "phone": "0599999999",
  "role": "CUSTOMER",
  "address": "Palestine"
}


Response:

{
  "message": "User registered successfully",
  "user": {}
}


---

## Login

POST

/auth/login


Request Body:

{
  "email": "user@test.com",
  "password": "123456"
}


Response:

{
  "message": "Login successful",
  "accessToken": "JWT_TOKEN",
  "user": {}
}