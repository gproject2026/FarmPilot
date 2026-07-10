# Reviews API

Base URL:

http://localhost:3000


## Create Review

POST

/reviews


Authorization:

Bearer TOKEN


Role:

CUSTOMER


Request Body:

```json
{
  "productId": "PRODUCT_ID",
  "rating": 5,
  "comment": "Excellent product"
}
Get Product Reviews

GET

/reviews/product/:productId

Delete Review

DELETE

/reviews/:id

Authorization:

Bearer TOKEN