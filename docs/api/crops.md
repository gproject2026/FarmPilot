# Crops API

Base URL:

http://localhost:3000


## Create Crop

Create a new crop for a farmer.


POST

/crops


Authorization:

Bearer TOKEN


Role:

FARMER


Request Body:

```json
{
  "cropName": "Tomato",
  "cropType": "Vegetable",
  "plantingDate": "2026-07-10",
  "irrigationSchedule": "Every 2 days",
  "fertilizationSchedule": "Weekly",
  "notes": "Healthy crop"
}
Response:

{
  "id": "CROP_ID",
  "cropName": "Tomato",
  "status": "ACTIVE"
}
Get All Crops

GET

/crops

Response:

Returns crops with farmer information.

Get Crop By ID

GET

/crops/:id

Update Crop

PATCH

/crops/:id

Authorization:

Bearer TOKEN

Role:

FARMER

Delete Crop

DELETE

/crops/:id

Authorization:

Bearer TOKEN

Role:

FARMER