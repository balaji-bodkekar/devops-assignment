## DevOps Assessment Assignment

Design and implement a workflow to:

- **Containerize the application**
  - Build Docker images for the existing backend.
  - Provide a setup to run the app locally.
  - Identify all the hardcoded values and replace those with environment variables.
  - Include any required local dependencies (e.g. message broker, database) as containers.

- **Run containers locally**
  - Provide clear commands to:
    - Build images.
    - Start the full stack.
    - View logs and debug.

- **Deploy to a cloud provider using code (no manual clicks)**
  - Use **Infrastructure as Code (IaC)** to provision all cloud resources.
  - Use **CI/CD** (GitHub Actions, GitLab CI, Azure DevOps, etc.) to build, push images, and deploy the app.

- **Maximize managed cloud services**
  - Prefer managed services over self-hosted where possible.
  - Use cloud-native logging/monitoring where reasonable (e.g. CloudWatch, Azure Monitor, Stackdriver).

- **Deliverables**
  - updated code base with IAC and build related code.
  - document your journey in `journey.md` file.
  - create `instructions.md` file for developers to run this locally.
  - simple architecture diagram to showcase cloud resources.
  - single-page frontend in `frontend/index.html` that:
    - calls the `POST /notify/` API to trigger a background task.
    - polls the `GET /task_status/{task_id}` API to show live task status and result.