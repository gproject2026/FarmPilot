# Orders API

Base URL:

http://localhost:3000


## Create Order

Create a new order by customer.

POST

/orders


Authorization:

Bearer TOKEN


Role:

CUSTOMER


Request Body:

```json
{
  "items": [
    {
      "productId": "PRODUCT_ID",
      "quantity": 2
    }
  ]
}
Response:

{
  "id": "ORDER_ID",
  "customerId": "CUSTOMER_ID",
  "totalPrice": 20,
  "status": "PENDING",
  "orderItems": []
}
Get All Orders

GET

/orders

Response:

Returns all orders with:

customer information
order items
products
Get Order By ID

GET

/orders/:id

Example:

/orders/a1e78bab-0d4f-44be-9b84-97b8ac771b50

Response:

{
  "id": "ORDER_ID",
  "status": "CONFIRMED",
  "totalPrice": 20,
  "customer": {},
  "orderItems": []
}
Update Order Status

Update order status by farmer.

PATCH

/orders/:id/status

Authorization:

Bearer TOKEN

Role:

FARMER

Request Body:

{
  "status": "CONFIRMED"
}

Available Status:

PENDING
CONFIRMED
CANCELLED
COMPLETED

Response:

{
  "id": "ORDER_ID",
  "status": "CONFIRMED"
}