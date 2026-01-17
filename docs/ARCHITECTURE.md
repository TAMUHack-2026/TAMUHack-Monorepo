# Architecture

## High-Level System Architecture

```mermaid
flowchart TD
    subgraph api["API"]
        auth[Authentication]
        db[(Database)]
        model[Model Server]
        
        auth --"Sends profile data to"--> db
        model --"Queries for profile data"--> db
        db --"Returns profile data to"--> model
    end
    
    subgraph frontend["Frontend"]
        spirometer[Spirometer]
        app[Mobile App]
        
        spirometer --"Sends breath data to"--> app
    end
    
    app --"Sends profile data on registration"--> auth
    app --"Calls when breath data is received"--> model
    model --"Returns analysis results to"--> app
```

## Tech Stack
* Frontend:
  * Mobile App: React Native (TypeScript)
  * Spirometer: Arduino Uno (MicroPython)
* Backend:
  * API: Spring Boot (Java)
  * Authentication: Spring Security JWT (Java)
  * Database: PostgreSQL
  * Model Server: Spring Boot (Java) with PyTorch (Python) and Redis for caching
    * **NOTE**: Redis may not be necessary depending on performance and time
* Deployment:
  * Docker
  * Kubernetes
  * AWS or Azure (Decision TBD)
  * gRPC for communication between services
* Build Tools:
  * Maven for Java projects
  * npm for React Native project
  * Expo for React Native development
