# serverless2-runner

Public build of the Serverless 2.0 job runner image: `ghcr.io/rene-tech/serverless2/jobs`.
It is the init container (fetch inputs), the uploader sidecar and the endpoint-call container of every
run-class Job of the platform; the image is public so that a Job can be dispatched to any region at queue
time (nodes pull it anonymously). Contents: alpine + aws-cli + curl + jq + bash and three scripts. The source
of truth is `services/jobs` in the platform repository; this repository is a push mirror whose GitHub Actions
workflow builds and publishes the image on every tag `v*` (`services/jobs/publish.sh` there updates it).
