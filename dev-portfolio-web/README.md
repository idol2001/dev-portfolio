# dev-portfolio-web

Frontend for Jacob Lee Developer Portfolio — a personal developer portfolio website with admin panel.

## Tech Stack

- **Framework**: Vue 3 (Composition API)
- **Build Tool**: Vite
- **State Management**: Pinia
- **Routing**: Vue Router
- **Styling**: TailwindCSS
- **HTTP Client**: Axios
- **Web Server**: Nginx (Docker deployment)

## Features

### Public Pages
- **Home** — Hero section with typing effect roles, social links
- **About** — Markdown-powered introduction with image
- **Skills** — Responsive grid of skill cards (icon + name)
- **Projects** — Project cards with tech stack, repo/demo links
- **Blogs** — Paginated blog listing
- **Blog Detail** — Markdown rendering with code highlighting, Mermaid diagrams, LaTeX formulas

### Admin Panel (`/admin`)
- **Dashboard** — Overview layout with sidebar
- **Profile** — Manage personal info, social links, navigation menu
- **Users** — User management (create, edit password, delete)
- **Skills** — Skill group and item CRUD with icon upload
- **Projects** — Project CRUD with cover image upload
- **Blogs** — Markdown editor (md-editor-v3), draft/publish workflow

## Quick Start

### Prerequisites
- Node.js 18+
- npm 9+
- Backend API running at `http://localhost:8080`

### Development
```bash
# Install dependencies
npm install

# Start dev server (proxies API to localhost:8080)
npm run dev

# Open http://localhost:3000
```

### Build for Production
```bash
npm run build
```
Output goes to `dist/` directory.

### Docker
```bash
# Build image
docker build -t dev-portfolio-web .

# Run
docker run -p 3000:80 dev-portfolio-web
```

## API Integration

All API calls go through `src/api/index.js` (Axios instance).

| Config | Value |
|--------|-------|
| Base URL | `/dev-portfolio/v1` |
| Timeout | 10000ms |
| Auth | Bearer Token (stored in localStorage) |

See the backend repository for API documentation: [dev-portfolio-api Wiki](https://github.com/idol2001/dev-portfolio-api/wiki)

## Project Structure

```
src/
├── api/            # Axios instance + API functions
├── components/     # Reusable components (TypingEffect, SocialLinks, etc.)
├── router/         # Vue Router config + route guards
├── stores/         # Pinia stores (auth)
├── views/          # Page components
│   ├── Home.vue
│   ├── About.vue
│   ├── Skills.vue
│   ├── Projects.vue
│   ├── Blogs.vue
│   ├── BlogDetail.vue
│   ├── Login.vue
│   └── admin/      # Admin panel pages
└── style.css       # Global styles (TailwindCSS)
```

## Deployment

Deployed via Docker Compose with the backend. See root project `docker-compose.yml`.

## License

MIT
