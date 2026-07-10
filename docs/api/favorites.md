# Favorites API

Base URL:

http://localhost:3000


## Add Product To Favorites

POST

/favorites


Authorization:

Bearer TOKEN


Role:

CUSTOMER


Request Body:

```json
{
  "productId": "PRODUCT_ID"
}
Get My Favorites

GET

/favorites

Authorization:

Bearer TOKEN

Remove Favorite

DELETE

/favorites/:productId

Authorization:

Bearer TOKEN