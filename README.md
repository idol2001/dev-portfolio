# Jacob Lee - Developer Portfolio

A full-stack developer portfolio website with admin panel.

## Tech Stack

### Backend
- **Language**: Go
- **Framework**: Gin
- **Database**: MySQL 8.0
- **ORM**: GORM

### Frontend
- **Framework**: Vue 3
- **Build Tool**: Vite
- **State Management**: Pinia
- **Routing**: Vue Router
- **Styling**: TailwindCSS

### Deployment
- Docker & Docker Compose

## Project Structure

```
dev-portfolio/
├── dev-portfolio-api/    # Backend Go API
├── dev-portfolio-web/    # Frontend Vue 3 App
├── docker-compose.yml    # Docker Compose Configuration
├── init.sql             # Database Initialization
└── README.md
```

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Or: Go 1.21+, Node.js 18+, MySQL 8.0

### Using Docker Compose (Recommended)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

Access:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- Admin Panel: http://localhost:3000/admin

### Manual Setup

#### Backend

```bash
cd dev-portfolio-api

# Install dependencies
go mod tidy

# Update config in configs/config.se.yml

# Run
go run main.go
```

#### Frontend

```bash
cd dev-portfolio-web

# Install dependencies
npm install

# Development
npm run dev

# Build
npm run build
```

## API Endpoints

### Profile
- `GET /dev-portfolio/v1/profile/info` - Get profile
- `PUT /dev-portfolio/v1/profile/info` - Update profile
- `GET /dev-portfolio/v1/profile/skills` - Get skills

### Projects
- `GET /dev-portfolio/v1/projects` - List projects
- `GET /dev-portfolio/v1/projects/:id` - Get project
- `POST /dev-portfolio/v1/projects` - Create project
- `PUT /dev-portfolio/v1/projects/:id` - Update project
- `DELETE /dev-portfolio/v1/projects/:id` - Delete project

### Blogs
- `GET /dev-portfolio/v1/blogs` - List blog posts
- `GET /dev-portfolio/v1/blogs/slug/:slug` - Get post by slug
- `GET /dev-portfolio/v1/blogs/:id` - Get post
- `POST /dev-portfolio/v1/blogs` - Create post
- `PUT /dev-portfolio/v1/blogs/:id` - Update post
- `DELETE /dev-portfolio/v1/blogs/:id` - Delete post

## Database Schema

- `users` - User accounts
- `profiles` - User profiles
- `profile_skill_groups` - Skill categories
- `profile_skills` - Individual skills
- `projects` - Portfolio projects
- `blog_posts` - Blog articles

## License

MIT
