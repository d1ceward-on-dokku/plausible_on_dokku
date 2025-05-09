![](.github/images/repo_header.png)

[![Plausible](https://img.shields.io/badge/Plausible-3.0.1-blue.svg)](https://github.com/plausible/analytics/releases/tag/v3.0.1)
[![Dokku](https://img.shields.io/badge/Dokku-Repo-blue.svg)](https://github.com/dokku/dokku)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/d1ceward-on-dokku/plausible_on_dokku/graphs/commit-activity)

# Run Plausible on Dokku

## Overview

This guide explains how to deploy [Plausible](https://plausible.io/), a lightweight and open-source website analytics tool, on a [Dokku](https://dokku.com/) host. Dokku is a lightweight PaaS that simplifies deploying and managing applications using Docker.

## Prerequisites

Before proceeding, ensure you have the following:

- A working [Dokku host](https://dokku.com/docs/getting-started/installation/).
- The [PostgreSQL plugin](https://github.com/dokku/dokku-postgres) for database support.
- The [Clickhouse plugin](https://github.com/dokku/dokku-clickhouse) for analytics storage.
- (Optional) The [Let's Encrypt plugin](https://github.com/dokku/dokku-letsencrypt) for SSL certificates.

## Setup Instructions

### 1. Create the App

Log into your Dokku host and create the `plausible` app:

```bash
dokku apps:create plausible
```

### 2. Configure the Databases

Install, create, and link the PostgreSQL and Clickhouse plugins to the app:

```bash
# Install plugins
dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
dokku plugin:install https://github.com/dokku/dokku-clickhouse.git clickhouse

# Create instances
dokku postgres:create plausible
dokku clickhouse:create plausible

# Link plugins to the app
dokku postgres:link plausible plausible
dokku clickhouse:link plausible plausible
```

### 3. Configure Environment Variables

Set up the required environment variables for Plausible:

```bash
# Secret key for sessions
dokku config:set plausible SECRET_KEY_BASE=$(openssl rand -base64 48 | tr -d '\n')

# TOTP vault key for encrypting secrets
dokku config:set plausible TOTP_VAULT_KEY=$(openssl rand -base64 32 | tr -d '\n')

# Base URL for the app
dokku config:set plausible BASE_URL=https://plausible.example.com

# SMTP configuration for email
dokku config:set plausible MAILER_EMAIL=admin@example.com \
                           SMTP_HOST_ADDR=mail.example.com \
                           SMTP_HOST_PORT=465 \
                           SMTP_USER_NAME=admin@example.com \
                           SMTP_USER_PWD=example1234 \
                           SMTP_HOST_SSL_ENABLED=true

# (Optional) Disable user registration
dokku config:set plausible DISABLE_REGISTRATION=true
```

### 4. Configure Persistent Storage

To persist data between restarts, create a folder on the host machine and mount it to the app container:

```bash
dokku storage:ensure-directory plausible --chown false
chown 999:65533 /var/lib/dokku/data/storage/plausible
dokku storage:mount plausible /var/lib/dokku/data/storage/plausible:/var/lib/plausible
```

### 5. Configure the Domain and Ports

Set the domain for your app to enable routing:

```bash
dokku domains:set plausible plausible.example.com
```

Map the internal port `8000` to the external port `80`:

```bash
dokku proxy:ports-set plausible http:80:8000
```

### 6. Deploy the App

You can deploy the app to your Dokku server using one of the following methods:

#### Option 1: Deploy Using `dokku git:sync`

If your repository is hosted on a remote Git server with an HTTPS URL, you can deploy the app directly to your Dokku server using `dokku git:sync`. This method also triggers a build process automatically. Run the following command:

```bash
dokku git:sync --build plausible https://github.com/d1ceward-on-dokku/plausible_on_dokku.git
```

#### Option 2: Clone the Repository and Push Manually

If you prefer to work with the repository locally, you can clone it to your machine and push it to your Dokku server manually:

1. Clone the repository:

    ```bash
    # Via SSH
    git clone git@github.com:d1ceward-on-dokku/plausible_on_dokku.git

    # Via HTTPS
    git clone https://github.com/d1ceward-on-dokku/plausible_on_dokku.git
    ```

2. Add your Dokku server as a Git remote:

    ```bash
    git remote add dokku dokku@example.com:plausible
    ```

3. Push the app to your Dokku server:

    ```bash
    git push dokku master
    ```

Choose the method that best suits your workflow.

### 7. Enable SSL (Optional)

Secure your app with an SSL certificate from Let's Encrypt:

1. Add the HTTPS port:

    ```bash
    dokku ports:add plausible https:443:8000
    ```

2. Install the Let's Encrypt plugin:

    ```bash
    dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
    ```

3. Set the contact email for Let's Encrypt:

    ```bash
    dokku letsencrypt:set plausible email you@example.com
    ```

4. Enable Let's Encrypt for the app:

    ```bash
    dokku letsencrypt:enable plausible
    ```

## Wrapping Up

Congratulations! Your Plausible instance is now up and running. You can access it at [https://plausible.example.com](https://plausible.example.com).

Happy analyzing!
