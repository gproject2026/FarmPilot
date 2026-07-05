# FarmPilot Database Design

## MVP Decision

FarmPilot MVP will not include a separate Farm entity.  
Crops, products, diagnoses, and reminders will be linked directly to the Farmer user.

Reason:
This keeps the system simpler and more suitable for small farmers and home-based producers, while supporting multi-farm management as a future enhancement.
---

# Database Tables

## 1. Users

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary Key |
| full_name | VARCHAR(100) | User full name |
| email | VARCHAR(100) | Unique email |
| password | VARCHAR(255) | Encrypted password |
| phone | VARCHAR(20) | Phone number |
| role | ENUM | FARMER / CUSTOMER / ADMIN |
| address | TEXT | User address |
| profile_image | TEXT | Profile image URL |
| created_at | TIMESTAMP | Creation date |
| updated_at | TIMESTAMP | Last update |

---

## 2. Categories

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary Key |
| name | VARCHAR(100) | Category name |
| description | TEXT | Category description |
| created_at | TIMESTAMP | Creation date |


---

## 3. Products

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary Key |
| farmer_id | UUID | Foreign Key references users(id) |
| category_id | UUID | Foreign Key references categories(id) |
| name | VARCHAR(150) | Product name |
| description | TEXT | Product description |
| price | DECIMAL(10,2) | Product price |
| quantity | INT | Available quantity |
| unit | VARCHAR(30) | kg / box / piece / liter |
| image_url | TEXT | Product image URL |
| status | ENUM | PENDING / APPROVED / REJECTED / OUT_OF_STOCK |
| created_at | TIMESTAMP | Creation date |
| updated_at | TIMESTAMP | Last update |

Relationship:
- One farmer can add many products.
- One category can contain many products.

---

## 4. Crops

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary Key |
| farmer_id | UUID | Foreign Key references users(id) |
| crop_name | VARCHAR(100) | Crop name |
| crop_type | VARCHAR(100) | Crop type |
| planting_date | DATE | Planting date |
| irrigation_schedule | VARCHAR(100) | Irrigation schedule |
| fertilization_schedule | VARCHAR(100) | Fertilization schedule |
| notes | TEXT | Farmer notes |
| status | ENUM | ACTIVE / HARVESTED / DAMAGED |
| created_at | TIMESTAMP | Creation date |
| updated_at | TIMESTAMP | Last update |

Relationship:
- One farmer can manage many crops.

---

## 5. Diagnoses

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary Key |
| farmer_id | UUID | Foreign Key references users(id) |
| crop_id | UUID | Foreign Key references crops(id) |
| image_url | TEXT | Uploaded plant image |
| disease_name | VARCHAR(150) | Predicted disease name |
| confidence | DECIMAL(5,2) | AI confidence percentage |
| description | TEXT | Disease description |
| causes | TEXT | Disease causes |
| treatment | TEXT | Suggested treatment |
| prevention | TEXT | Prevention methods |
| created_at | TIMESTAMP | Diagnosis date |

Relationship:
- One farmer can have many diagnoses.
- One crop can have many diagnoses.


---

## 6. Orders

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary Key |
| customer_id | UUID | Foreign Key references users(id) |
| total_price | DECIMAL(10,2) | Total order price |
| status | ENUM | PENDING / ACCEPTED / PREPARING / DELIVERED / CANCELLED |
| created_at | TIMESTAMP | Creation date |
| updated_at | TIMESTAMP | Last update |

Relationship:

- One customer can place many orders.

---

## 7. Order Items

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary Key |
| order_id | UUID | Foreign Key references orders(id) |
| product_id | UUID | Foreign Key references products(id) |
| quantity | INT | Ordered quantity |
| price | DECIMAL(10,2) | Product price at purchase |

Relationship:

- One order contains many products.
- One product can appear in many orders.

---

## 8. Reviews

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary Key |
| customer_id | UUID | Foreign Key references users(id) |
| product_id | UUID | Foreign Key references products(id) |
| rating | INT | Rating (1-5) |
| comment | TEXT | Customer review |
| created_at | TIMESTAMP | Creation date |

Relationship:

- One customer can review many products.
- One product can receive many reviews.


---

## 9. Favorites

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary Key |
| customer_id | UUID | Foreign Key references users(id) |
| product_id | UUID | Foreign Key references products(id) |
| created_at | TIMESTAMP | Creation date |

Relationship:

- One customer can favorite many products.

---

## 10. Reminders

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary Key |
| farmer_id | UUID | Foreign Key references users(id) |
| crop_id | UUID | Foreign Key references crops(id) |
| type | ENUM | IRRIGATION / FERTILIZATION |
| reminder_date | TIMESTAMP | Reminder date |
| status | BOOLEAN | Completed or not |
| created_at | TIMESTAMP | Creation date |

Relationship:

- One crop can have many reminders.

---

## 11. Notifications

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary Key |
| user_id | UUID | Foreign Key references users(id) |
| title | VARCHAR(150) | Notification title |
| message | TEXT | Notification content |
| type | VARCHAR(50) | Notification type |
| is_read | BOOLEAN | Read status |
| created_at | TIMESTAMP | Creation date |

Relationship:

- One user can receive many notifications.

---

## 12. AI Marketing Logs

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary Key |
| farmer_id | UUID | Foreign Key references users(id) |
| product_id | UUID | Foreign Key references products(id) |
| input_text | TEXT | User input |
| generated_title | TEXT | AI generated title |
| generated_description | TEXT | AI generated description |
| generated_keywords | TEXT | AI generated keywords |
| suggestions | TEXT | AI suggestions |
| created_at | TIMESTAMP | Creation date |

Relationship:

- One farmer can generate many marketing suggestions.