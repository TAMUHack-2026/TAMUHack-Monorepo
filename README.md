# Developing on this Monorepo

This README provides guidelines on the overall structure of the monorepo,
as well as how to run the backend and frontend code.

## Monorepo Structure

* `backend/`: Contains the backend code, which is a microservices architecture built with Spring Boot.
  * `model/`: Contains the API for interacting with the PyTorch model, and the Dockerfile for building the model service.
  * `usermanagement/`: Contains the API for interacting with the PostgreSQL database for user management and authentication.
  * `postgres/schema.sql`: Contains the PostgreSQL database schema.
* `frontend/`: Contains the frontend code, built with React Native and Expo.
* `docs/`: Contains documentation related to the project.

## Running the Backend

> Developing on backend requires Docker and GNU Make to be installed on your machine.

The backend utilizes Docker Compose to manage the microservices on your local machine.
Eventually, we plan to deploy the backend services to a Kubernetes cluster.

> Before starting any backend service, make sure you're in the `backend/` directory.

To start the entire backend, run:

```bash
make # This can also be run as `make all` 
```

To build all backend services without starting them, use:

```bash
make build
```

To start all backend services without rebuilding them, use:

```bash
make up
```

To start a specific service, use:

```bash
make <service-name>
```

Replace `<service-name>` with one of the following:

* `postgres`: Starts the PostgreSQL database service.
* `usermanagement`: Starts the User Management service.
* `model`: Starts the model service.

To get a list of all available services, run:

```bash
make services
```

To stop all running services, use:

```bash
make down
```

To stop all running services and remove all associated Docker volumes, use:

```bash
make clean
```

## Running the Frontend
