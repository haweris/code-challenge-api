# Article Manager API

This is a Ruby on Rails API-only application for managing educational articles. It includes a RESTful API and a simple user interface for CRUD operations.

## Setup Instructions

1. Clone the repository
2. Install dependencies:
    # SHELL command
    bundle install

3. Set up the database:
    # SHELL commands
    rails db:create
    rails db:migrate

4. Run the server:
    # SHELL command
    rails server


## API Endpoints

- `GET /articles` - List all articles
- `GET /articles/:id` - Get a specific article
- `POST /articles` - Create a new article
- `PATCH/PUT /articles/:id` - Update an existing article
- `DELETE /articles/:id` - Delete an article

## Testing

Run tests using:
 # SHELL command
 rails test
