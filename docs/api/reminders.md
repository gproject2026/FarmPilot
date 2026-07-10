# Reminders API

Base URL:

http://localhost:3000


## Create Reminder

POST

/reminders


Authorization:

Bearer TOKEN


Role:

FARMER


Request Body:

```json
{
  "cropId": "CROP_ID",
  "type": "IRRIGATION",
  "reminderDate": "2026-07-15T10:00:00Z"
}
Response:

{
  "id": "REMINDER_ID",
  "type": "IRRIGATION",
  "status": false
}
Get All Reminders

GET

/reminders

Response:

Returns all reminders with crop and farmer information.

Get Reminder By ID

GET

/reminders/:id

Update Reminder

PATCH

/reminders/:id

Authorization:

Bearer TOKEN

Delete Reminder

DELETE

/reminders/:id

Authorization:

Bearer TOKEN