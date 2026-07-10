# Dashboard API

Base URL:

http://localhost:3000


# Farmer Dashboard

GET

/dashboard/farmer


Authorization:

Bearer TOKEN


Role:

FARMER


Response:

```json
{
  "productsCount": 1,
  "cropsCount": 1,
  "diagnosesCount": 0,
  "ordersCount": 1,
  "totalSales": "20"
}
Admin Dashboard

GET

/dashboard/admin

Authorization:

Bearer TOKEN

Role:

ADMIN

Response:

{
  "totalUsers": 5,
  "totalFarmers": 2,
  "totalCustomers": 2,
  "totalProducts": 2,
  "totalOrders": 2,
  "totalDiagnoses": 0
}