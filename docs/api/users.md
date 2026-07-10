# Users API

Base URL:

http://localhost:3000


---

## Get Profile

Get current logged-in user profile.


GET

/users/profile


Authorization:

Bearer TOKEN


Response:

```json
{
  "id": "USER_ID",
  "fullName": "User Name",
  "email": "user@test.com",
  "phone": "0599999999",
  "role": "FARMER"
}
Update Profile

PATCH

/users/profile

Authorization:

Bearer TOKEN

Request Body:

{
  "fullName": "New Name",
  "phone": "0598888888",
  "address": "Palestine"
}

Response:

Returns updated user information.