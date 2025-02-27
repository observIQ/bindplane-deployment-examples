# Bindplane Docker Compose Deployment

This directory contains a Docker Compose configuration for running Bindplane locally.
This setup is intended for development and testing purposes.

## Components

- **Bindplane**: The main Bindplane service
- **Transform Agent**: Bindplane's transformation service
- **PostgreSQL**: Database for Bindplane
- **Prometheus**: Metrics storage and querying

## Prerequisites

- Docker Engine 20.10.0 or newer
- Docker Compose V2
- At least 4GB of available RAM
- A valid Bindplane license

## Configuration

1. Create a `.env` file in this directory with the following variables:

```env
BINDPLANE_LICENSE=your_license_here
BINDPLANE_SESSIONS_SECRET=your_secret_here
BINDPLANE_SECRET_KEY=your_secret_here
```

Replace the placeholder values with your actual configuration:

- `BINDPLANE_LICENSE`: Your Bindplane license key
- `BINDPLANE_SESSIONS_SECRET`: A random UUID for session encryption (e.g., `uuidgen`)
- `BINDPLANE_SECRET_KEY`: A random UUID for API key encryption (e.g., `uuidgen`)

## Usage

### Starting the Services

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f

# Check service status
docker compose ps
```

### Accessing Services

- Bindplane UI: <http://localhost:3001>
- Prometheus UI: <http://localhost:9090>

### Stopping the Services

```bash
# Stop all services
docker compose down

# Stop and remove volumes (this will delete all data)
docker compose down -v
```

## Troubleshooting

### Common Issues

1. **PostgreSQL fails to start**

   - Check if port 5432 is already in use
   - Ensure you have proper permissions for the data volume

2. **Bindplane fails to connect to PostgreSQL**

   - Wait for PostgreSQL to fully initialize (health check will ensure this)
   - Check the PostgreSQL logs: `docker compose logs postgres`

3. **Transform agent connection issues**
   - Verify the transform agent is running: `docker compose ps transform`
   - Check transform agent logs: `docker compose logs transform`

### Viewing Logs

```bash
# View logs for a specific service
docker compose logs -f bindplane
docker compose logs -f postgres
docker compose logs -f transform
docker compose logs -f prometheus

# View all logs
docker compose logs -f
```

## Data Persistence

Data is persisted in Docker volumes:

- PostgreSQL data: `bindplane` volume
- Prometheus data: `prometheus` volume

To backup your data, you can use Docker volume backup commands:

```bash
docker run --rm -v bindplane:/data -v $(pwd):/backup alpine tar czf /backup/bindplane-backup.tar.gz /data
```

## Security Notes

- This configuration uses default passwords for PostgreSQL. In a production environment, you should change these.
- The default configuration exposes ports to localhost only.
- Sensitive information should be stored in environment variables or secrets management.
- Generate unique UUIDs for BINDPLANE_SESSIONS_SECRET and BINDPLANE_SECRET_KEY

## Additional Resources

- [Bindplane Documentation](https://docs.bindplane.observiq.com)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
