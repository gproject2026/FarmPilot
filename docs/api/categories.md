# Categories API

Base URL:

http://localhost:3000


---

## Create Category

Create a new product category.

POST

/categories


Authorization:

Bearer TOKEN


Role:

ADMIN


Request Body:

```json
{
  "name": "Vegetables",
  "description": "Fresh organic vegetables"
}
Response:

{
  "id": "CATEGORY_ID",
  "name": "Vegetables",
  "description": "Fresh organic vegetables"
}
Get All Categories

GET

/categories

Response:

Returns all categories.

Get Category By ID

GET

/categories/:id

Response:

{
  "id": "CATEGORY_ID",
  "name": "Vegetables",
  "description": "Fresh organic vegetables"
}
Update Category

PATCH

/categories/:id

Authorization:

Bearer TOKEN

Role:

ADMIN

Request Body:

{
  "name": "Fruits"
}
Delete Category

DELETE

/categories/:id

Authorization:

Bearer TOKEN

Role:

ADMIN