# Developing on this Monorepo

This README provides guidelines on the overall structure of the monorepo, as well as how to run the backend and frontend code.

## Monorepo Structure
* `backend/`: Contains the backend code, which is a microservices architecture built with Spring Boot.
  * `model/`: Contains the API for interacting with the PyTorch model, and the Dockerfile for building the model service.
  * `gateway/`: Contains the API Gateway code, which routes requests to the appropriate microservices and handles authentication.
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
* `model`: Starts the model service.
* `gateway`: Starts the API Gateway service.
* `postgres`: Starts the PostgreSQL database service.

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
