# Architecture

## High-Level System Architecture

```mermaid
flowchart TD
    subgraph api["API"]
        gateway[API Gateway]
        user_management[User Management API]
        db[(Database)]
        model[Model Server API]
    end
    
    subgraph frontend["Frontend"]
        spirometer[Spirometer]
        app[Mobile App]

        spirometer -->|Sends Breath Data| app
    end

    app -->|API Requests| gateway
    gateway -->|JWT Tokens| app
    gateway -->|Queries/Updates| user_management
    gateway -->|Sends Data| model
    model -->|Retrieves Profile Data| user_management
    model -->|Sends Predictions| gateway
    gateway -->|Sends Responses| app
    user_management -->|Reads/Writes| db

```

## Tech Stack

* Frontend:
  * Mobile App: React Native (TypeScript) with Gluestack UI for components
  * Spirometer: Arduino Uno (MicroPython)
* Backend:
  * API: Spring Boot (Java)
  * API Gateway: Spring Security JWT (Java)
  * Database: PostgreSQL (local for development, Supabase for production)
  * Model Server: Spring Boot (Java) with PyTorch (Python) and Redis for caching
    * **NOTE**: Redis may not be necessary depending on performance and time
* Deployment:
  * Docker
  * Kubernetes
  * Google Cloud Platform (GCP)
  * gRPC for communication between services
* Build Tools:
  * Maven for Java projects
  * npm for React Native project
  * Expo for React Native development
