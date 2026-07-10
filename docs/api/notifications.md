# Notifications API

Base URL:

http://localhost:3000


## Create Notification

Create a notification for a user.

POST

/notifications


Request Body:

```json
{
  "userId": "USER_ID",
  "title": "New Order",
  "message": "You received a new order",
  "type": "ORDER"
}
Response:

{
  "id": "NOTIFICATION_ID",
  "title": "New Order",
  "message": "You received a new order",
  "isRead": false
}
Get My Notifications

Get notifications for the current logged-in user.

GET

/notifications/my

Authorization:

Bearer TOKEN

Response:

[
  {
    "id": "NOTIFICATION_ID",
    "title": "Irrigation Reminder",
    "message": "Your tomato crop needs irrigation today",
    "isRead": false
  }
]
Get Notification By ID

GET

/notifications/:id

Authorization:

Bearer TOKEN

Mark Notification As Read

Update notification status.

PATCH

/notifications/:id/read

Authorization:

Bearer TOKEN

Response:

{
  "id": "NOTIFICATION_ID",
  "isRead": true
}