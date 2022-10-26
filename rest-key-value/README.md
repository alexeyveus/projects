# Example REST API

Sample REST API using Express and Redis for managing key-value pairs

## Requirements

* NodeJS 16.x
* Redis 6.x

## Commands

* `npm install` - Download and install dependencies
* `npm run test` - Placeholder for unit tests
* `npm run watch` - Run the application in development mode
* `npm run start` - Run the application in production mode

## Endpoints

* `PUT /data/:key/:value`
  * Description: Insert/Update value for the given key
  * Example Response:
    ```
    {"status":"OK"}
    ```

* `GET /data/:key`
  * Description: Get value for the given key from the datastore (returns null if key not found)
  * Example Response:
    ```
    {"status":"OK","data":"value from redis"}
    ```

## Configuration

Environment variable configuration items:

* `PORT` - Port for API to listen on (default: `3000`)
* `REDIS_HOST` - Redis host to use (default: `localhost`)
* `REDIS_PORT` - Redis port to use (default: `6379`)
