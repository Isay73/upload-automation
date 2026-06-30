# Architecture

## Overview

This project deploys a self-hosted Nextcloud instance on Ubuntu Server using Docker.

The application is available only through Nginx Reverse Proxy over HTTPS.

PostgreSQL is used as the primary database, while Redis provides caching for better performance.

---

## Infrastructure

```text
                 Internet
                      │
                   Domain
                      │
            Let's Encrypt SSL
                      │
                  Nginx
                      │
               127.0.0.1:8080
                      │
                 Nextcloud
                  │       │
             PostgreSQL  Redis

             WireGuard VPN
                    │
                 wg-easy
                    │
              Remote Clients
```

---

## Components

| Component | Purpose |
|-----------|---------|
| Ubuntu Server | Operating System |
| Docker | Container Platform |
| Nextcloud | File Storage |
| PostgreSQL | Database |
| Redis | Cache |
| Nginx | Reverse Proxy |
| Let's Encrypt | SSL Certificates |
| WireGuard | Secure Remote Access |
| wg-easy | VPN Client Management |

---

## Network Flow

Internet → Nginx → Docker → Nextcloud → PostgreSQL / Redis
