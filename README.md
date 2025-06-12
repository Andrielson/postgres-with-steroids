# PostgreSQL with Steroids

A Docker image that extends the official PostgreSQL image with enhanced security features and additional functionality. This image is based on PostgreSQL 17 and includes built-in SSL certificate management and DuckDB integration.

## Features

- **PostgreSQL 17**: Based on the latest PostgreSQL version
- **Automatic SSL Certificate Management**:
  - Self-signed certificate generation
  - Automatic certificate renewal
  - X.509v3 certificate support
  - Secure default configurations
- **DuckDB Integration**: Built-in support for DuckDB through pg_duckdb extension
- **Enhanced Security**:
  - Automatic SSL/TLS configuration
  - Certificate expiration monitoring
  - Secure default settings
- **Docker Optimized**:
  - Multi-stage builds for smaller image size
  - Proper user permissions
  - Volume management for data persistence

## Quick Start

```bash
# Pull the image
docker pull [your-registry]/postgres-with-steroids

# Run the container
docker run -d \
  --name postgres-steroids \
  -e POSTGRES_PASSWORD=yourpassword \
  -p 5432:5432 \
  [your-registry]/postgres-with-steroids
```

## Environment Variables

- `POSTGRES_PASSWORD`: (Required) Password for the postgres user
- `POSTGRES_USER`: (Optional) Username for the postgres user (defaults to 'postgres')
- `POSTGRES_DB`: (Optional) Name of the database to create (defaults to the value of POSTGRES_USER)
- `SSL_CERT_DAYS`: (Optional) Number of days for SSL certificate validity (defaults to 820 days)
- `LOG_TO_STDOUT`: (Optional) Set to "true" to redirect logs to stdout

## SSL Certificate Management

The container automatically handles SSL certificate generation and management:

- Certificates are generated on first run
- Certificates are automatically renewed when:
  - They are not X.509v3 certificates
  - They are expired or will expire within 30 days
  - The database was initialized without certificates

## DuckDB Integration

The image includes the pg_duckdb extension, allowing you to use DuckDB functionality within PostgreSQL. To use it:

```sql
-- Enable the extension
CREATE EXTENSION pg_duckdb;

-- Use DuckDB functions
SELECT duckdb_version();
```

## Data Persistence

The container uses a Docker volume for data persistence. The data is stored in `/var/lib/postgresql/data` inside the container.

## Security Considerations

- SSL is enabled by default
- Certificates are automatically managed
- Proper file permissions are set
- The container runs as the postgres user

## Building from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/postgres-with-steroids.git

# Build the image
docker build -t postgres-with-steroids .
```

## License

This project is licensed under the terms of the license included in the repository.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.