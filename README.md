# Zarf Vite React Template

This template provides a complete setup for building and deploying a React + TypeScript + Vite application using Zarf for Kubernetes deployment. It includes everything needed to create a Zarf package for air-gapped or edge deployments.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Babel](https://babeljs.io/) (or [oxc](https://oxc.rs) when used in [rolldown-vite](https://vite.dev/guide/rolldown)) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## Quick Start

### Development

```bash
npm install
npm run dev
```

### Building and Deploying with Zarf

```bash
# Start local Docker registry (if not already running)
docker run -d -p 5000:5000 --name registry registry:2.7

# Build and deploy
./build.sh
```

## Zarf Package Configuration

This project includes a complete Zarf package configuration for deploying the Vite React application to Kubernetes.

### Zarf Package Structure

The Zarf package is defined in `deployment/zarf.yaml` and includes:

- **Package Metadata**: Name, version, and description
- **Kubernetes Manifests**: All K8s resources needed for deployment
- **Container Images**: Pre-built Docker image for the application
- **Deployment Actions**: Post-deployment configuration (e.g., k3d port mapping)

### Zarf Package Features

- **Namespace Management**: Automatically creates and manages the `zarf-vite-template` namespace
- **Image Bundling**: Includes the container image in the package for offline deployment
- **Connect Service**: Enables `zarf connect` for easy access without ingress configuration
- **k3d Integration**: Automatically configures port mappings for local k3d clusters

### Building the Zarf Package

The `build.sh` script automates the entire build process:

1. Starts the local Docker registry
2. Builds the multi-platform Docker image
3. Pushes the image to the registry
4. Creates the Zarf package
5. Optionally removes old packages and deploys the new one

## Kubernetes Resources

The project includes all necessary Kubernetes manifests in `deployment/k8s/`:

### Deployment (`deployment.yaml`)

- **Replicas**: 2 pods for high availability
- **Resource Limits**: 
  - Memory: 64Mi request, 128Mi limit
  - CPU: 50m request, 100m limit
- **Health Probes**: 
  - Liveness probe: checks `/` every 10 seconds
  - Readiness probe: checks `/` every 5 seconds
- **Image**: Uses `localhost:5000/zarf-vite-template:latest` (will be replaced by Zarf during deployment)

### Service (`service.yaml`)

- **Type**: ClusterIP (internal service)
- **Port**: 80 (HTTP)
- **Selector**: Routes traffic to pods with label `app: zarf-vite-template`

### Ingress (`ingress.yaml`)

- **External Access**: Enables access from outside the cluster
- **Path**: `/` (root path)
- **Backend**: Routes to the `zarf-vite-template` service on port 80
- **SSL Redirect**: Disabled (for development)

### Connect Service (`connect-service.yaml`)

- **Zarf Connect**: Enables `zarf connect zarf-vite-template` command
- **Description**: "The Vite React application"
- **Port**: 80 (HTTP)

## Deployment

### Prerequisites

- Docker and Docker registry running
- Zarf CLI installed
- Kubernetes cluster (or k3d for local development)

### Local Development with k3d

```bash
# Create k3d cluster
k3d cluster create

# Initialize Zarf
zarf init --confirm

# Deploy the package
zarf package deploy zarf-package-zarf-vite-template-amd64-latest.tar.zst --confirm
```

### Accessing the Application

After deployment, you can access the application in two ways:

1. **Via Zarf Connect** (recommended for development):
   ```bash
   zarf connect zarf-vite-template
   ```
   This creates a secure tunnel without needing ingress, DNS, or TLS configuration.

2. **Via Ingress** (if configured):
   - For k3d: `http://localhost:8080/`
   - For other clusters: Configure the ingress hostname in `ingress.yaml`

### Removing the Package

```bash
zarf package remove zarf-vite-template --confirm
```

## Docker Configuration

### Dockerfile

The project uses a multi-stage Docker build:

1. **Build Stage**: Uses `node:20-alpine` to build the Vite application
2. **Production Stage**: Uses `nginx:alpine` to serve the static files

### Nginx Configuration

The `nginx.conf` file is configured for:
- SPA routing (all routes serve `index.html`)
- Static asset caching
- Gzip compression

## React Compiler

The React Compiler is not enabled on this template because of its impact on dev & build performances. To add it, see [this documentation](https://react.dev/learn/react-compiler/installation).

## Expanding the ESLint configuration

If you are developing a production application, we recommend updating the configuration to enable type-aware lint rules:

```js
export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...

      // Remove tseslint.configs.recommended and replace with this
      tseslint.configs.recommendedTypeChecked,
      // Alternatively, use this for stricter rules
      tseslint.configs.strictTypeChecked,
      // Optionally, add this for stylistic rules
      tseslint.configs.stylisticTypeChecked,

      // Other configs...
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```

You can also install [eslint-plugin-react-x](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-x) and [eslint-plugin-react-dom](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-dom) for React-specific lint rules:

```js
// eslint.config.js
import reactX from 'eslint-plugin-react-x'
import reactDom from 'eslint-plugin-react-dom'

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...
      // Enable lint rules for React
      reactX.configs['recommended-typescript'],
      // Enable lint rules for React DOM
      reactDom.configs.recommended,
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```
