# Diagnoses API

Base URL:

http://localhost:3000


## Create Diagnosis

Create AI plant disease diagnosis result.


POST

/diagnoses


Authorization:

Bearer TOKEN


Role:

FARMER


Request Body:

```json
{
  "cropId": "CROP_ID",
  "imageUrl": "image_url",
  "diseaseName": "Leaf Blight",
  "confidence": 95,
  "description": "Disease detected on leaves",
  "causes": "Fungal infection",
  "treatment": "Use suitable treatment",
  "prevention": "Regular monitoring"
}
Response:

{
  "id": "DIAGNOSIS_ID",
  "diseaseName": "Leaf Blight",
  "confidence": 95
}
Get All Diagnoses

GET

/diagnoses

Response:

Returns diagnoses with:

farmer information
crop information
Get Diagnosis By ID

GET

/diagnoses/:id

Update Diagnosis

PATCH

/diagnoses/:id

Authorization:

Bearer TOKEN

Role:

FARMER

Delete Diagnosis

DELETE

/diagnoses/:id

Authorization:

Bearer TOKEN

Role:

FARMER