# Products API

Base URL:

http://localhost:3000


## Create Product

POST

/products

Authorization:

Bearer TOKEN


Role:

FARMER


Request Body:

{
  "categoryId": "CATEGORY_ID",
  "name": "Fresh Tomato",
  "description": "Organic tomato",
  "price": 10,
  "quantity": 20,
  "unit": "kg",
  "imageUrl": "image_url"
}


---

## Get All Products

GET

/products


Response:

[
  {
    "id": "PRODUCT_ID",
    "name": "Fresh Tomato",
    "price": 10,
    "quantity": 20
  }
]


---

## Get Product By ID

GET

/products/:id


---

## Update Product

PATCH

/products/:id

Authorization:

Bearer TOKEN


---

## Delete Product

DELETE

/products/:id

Authorization:

Bearer TOKEN