
# Project Name

## Overview

This project is a Rails-based application designed to manage sleep records and follow functionality for users. It allows users to clock in and clock out, as well as follow and unfollow other users. The system ensures that there are no concurrent clock-ins and handles multiple users following the same person concurrently.

## Technologies Used

- Ruby version: `3.4.2`
- Rails version: `8.0.2`
- Database: MySQL

## Setup Instructions

### Prerequisites

Ensure that you have the following installed:

- Ruby 3.4.2
- Rails 8.0.2
- MySQL
- Rspec

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/WillyamZhang/GoodNightAPI.git
   cd GoodNightAPI
   ```

2. Install required gems:

   ```bash
   bundle install
   ```

3. Set up the database:

   ```bash
   rails db:setup
   ```

4. Start the Rails server:

   ```bash
   rails s
   ```

Your application will be running on `http://localhost:3000`.

## API Endpoints

### Create Sleep Record (Clock In)

**POST** `/api/v1/sleep_records`

- **Description**: Clock in the user and create a new sleep record.
- **Request Body**:
  
  ```json
  {
    "user_id": 1
  }
  ```

- **Response**:
  
  ```json
  {
    "message": "Clocked In successfully",
    "records": [
      {
        "id": 1,
        "user_id": 1,
        "clock_in": "2025-04-13T10:00:00Z"
      }
    ]
  }
  ```

### Clock Out

**POST** `/api/v1/sleep_records/clock_out`

- **Description**: Clock out the user and update the sleep record with the current time.
- **Request Body**:
  
  ```json
  {
    "user_id": 1
  }
  ```

- **Response**:
  
  ```json
  {
    "message": "Clocked Out successfully",
    "records": [
      {
        "clock_out": "2025-04-13T03:16:35.195Z",
        "user_id": 2,
        "id": 4,
        "clock_in": "2025-04-13T03:16:30.119Z",
        "created_at": "2025-04-13T03:16:30.145Z",
        "updated_at": "2025-04-13T03:16:35.196Z"
      }
    ]
  }
  ```

### Follow a User

**POST** `/api/v1/follows`

- **Description**: Allows a user to follow another user.
- **Request Body**:
  
  ```json
  {
    "user_id": 1,
    "followed_id": 2
  }
  ```

- **Response**:
  
  ```json
  {
    "message": "Follow successfully",
    "followed": {
      "id": 1,
      "user_id": 1,
      "followed_id": 2,
      "created_at": "2025-04-12T20:26:14.348Z",
      "updated_at": "2025-04-12T20:26:14.348Z"
    }
  }
  ```

### Unfollow a User

**DELETE** `/api/v1/follows/unfollow`

- **Description**: Allows a user to unfollow another user.
- **Request Body**:
  
  ```json
  {
    "user_id": 1,
    "followed_id": 2
  }
  ```

- **Response**:
  
  ```json
  {
    "message": "UnFollow successfully",
    "Unfollow": {
      "id": 1,
      "user_id": 1,
      "followed_id": 2,
      "created_at": "2025-04-12T20:26:14.348Z",
      "updated_at": "2025-04-12T20:26:14.348Z"
    }
  }
  ```

### Get Following Users' Sleep Records

**GET** `/api/v1/sleep_records/following_record`

- **Description**: Retrieves sleep records of users followed by the specified user.
- **Request Parameters**:
  
  ```json
  {
    "user_id": 1
  }
  ```

- **Response**:
  
  ```json
  {
    "following_records": [
      {
          "result": "record 420 minutes from user3"
      },
      {
          "result": "record 460 minutes from user4"
      },
      {
          "result": "record 1304 minutes from user2"
      }
    ]
  }
  ```

## Database Indexes

To improve performance and enforce data integrity during concurrent access, the following indexes are used:

- `index_follows_on_user_id_and_followed_id`  
  Ensures a user can only follow another user once. Also supports fast lookup for unfollowing operations.

- `index_sleep_records_on_user_id_and_clock_out`  
  Optimized for querying active sleep records (where `clock_out` is `NULL`) during clock in/out operations.

- `index_sleep_records_on_user_id_and_created_at`  
  Speeds up retrieval of historical sleep records, especially for sorting or filtering by user and time.

## Testing

### Unit and Request Tests

To run tests:

```bash
bundle exec rspec
```

### Concurrency Tests

This project includes tests to handle concurrent requests such as:

- Multiple clock-in requests for the same user.
- Multiple follow requests for the same user pair.

### 🧪 Performance Testing

#### Dataset:
- **Users**: 50,000 users
- **Sleep Records**: Each user has **3–5 records** → ~200,000 total records
- **Follows**: Each user follows **2–10 other users**

#### Indexed Query Optimization

We optimized the query performance by adding the following indexes:

```ruby
add_index :follows, [:user_id, :followed_id], unique: true
add_index :sleep_records, [:user_id, :clock_out]
add_index :sleep_records, [:user_id, :created_at]
```

#### Sample Query Performance (Using `EXPLAIN` in MySQL)

```sql
SELECT `sleep_records`.* FROM `sleep_records`
WHERE `sleep_records`.`user_id` IN (8102, 9098, 9961, 13194, 14533, 15731, 25597, 34689, 45804)
AND NOT (`sleep_records`.`clock_in` IS NULL AND `sleep_records`.`clock_out` IS NULL)
AND (created_at >= '2025-04-06 05:01:42.940510')
ORDER BY TIMESTAMPDIFF(SECOND, clock_in, clock_out)
```

| Field     | Value                                                                 |
|-----------|-----------------------------------------------------------------------|
| type      | `range` – Efficient index usage for a range scan                     |
| key       | `index_sleep_records_on_user_id_and_clock_out` – Index is being used |
| rows      | `39` – Very few rows scanned                                          |
| Extra     | `Using index condition; Using where; Using MRR`                       |

**Result**: Query uses the appropriate composite index, scans a small number of rows efficiently, and performs very well even with over 200,000 records in the table.

## Known Issues

- Concurrency issues related to race conditions can occur if transactions are not handled correctly.
