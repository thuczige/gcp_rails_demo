deploy-sync-data-on-production:
	gcloud beta run jobs deploy sync-data-on-production \
	--region=asia-northeast1 \
	--image=gcr.io/zigexn-vn-sandbox/gcp_rails_demo/huytp-gcp-demo-web \
	--vpc-connector=nc-gcp-demo-vpc \
	--cpu=1 \
	--memory=512Mi \
	--task-timeout=30m \
	--set-env-vars=RAILS_ENV=production \
	--set-env-vars=GCP_PROJECT_ID=zigexn-vn-sandbox \
	--set-env-vars=REGION=asia-northeast1 \
	--set-env-vars=PRIMARY_DB_NAME=huytp_production \
	--set-secrets=SECRET_KEY_BASE=demo_secret_key_base:latest \
  --set-secrets=PRIMARY_DB_USERNAME=demo_primary_db_username:latest \
  --set-secrets=PRIMARY_DB_PASSWORD=demo_primary_db_password:latest \
  --set-secrets=PRIMARY_DB_PORT=demo_primary_db_port:latest \
  --set-secrets=PRIMARY_DB_HOST=demo_primary_db_host:latest \
  --set-secrets=REDIS_HOST=demo_redis_host:latest \
  --set-secrets=REDIS_PORT=demo_redis_port:latest \
  --set-secrets=REDIS_AUTH_STRING=demo_redis_auth_string:latest \
  --set-secrets=REDIS_USERNAME=demo_redis_username:latest \
  --set-secrets=GCP_TASK_QUEUE=demo_gcp_task_queue:latest \
  --set-secrets=GCP_TASK_SERVICE_EMAIL=demo_gcp_task_service_email:latest \
	--parallelism=1 \
	--tasks=1 \
	--max-retries=1 \
	--command="bin/rails" \
	--args="sync_data_task:sync"
execute-sync-data-on-production:
	gcloud beta run jobs execute sync-data-on-production \
	--region=asia-northeast1 \

deploy-remove-data-on-production:
	gcloud beta run jobs deploy remove-data-on-production \
	--region=asia-northeast1 \
	--image=gcr.io/zigexn-vn-sandbox/gcp_rails_demo/huytp-gcp-demo-web \
	--vpc-connector=nc-gcp-demo-vpc \
	--cpu=1 \
	--memory=512Mi \
	--task-timeout=30m \
	--set-env-vars=RAILS_ENV=production \
	--set-env-vars=GCP_PROJECT_ID=zigexn-vn-sandbox \
	--set-env-vars=REGION=asia-northeast1 \
	--set-env-vars=PRIMARY_DB_NAME=huytp_production \
	--set-secrets=SECRET_KEY_BASE=demo_secret_key_base:latest \
  --set-secrets=PRIMARY_DB_USERNAME=demo_primary_db_username:latest \
  --set-secrets=PRIMARY_DB_PASSWORD=demo_primary_db_password:latest \
  --set-secrets=PRIMARY_DB_PORT=demo_primary_db_port:latest \
  --set-secrets=PRIMARY_DB_HOST=demo_primary_db_host:latest \
  --set-secrets=REDIS_HOST=demo_redis_host:latest \
  --set-secrets=REDIS_PORT=demo_redis_port:latest \
  --set-secrets=REDIS_AUTH_STRING=demo_redis_auth_string:latest \
  --set-secrets=REDIS_USERNAME=demo_redis_username:latest \
  --set-secrets=GCP_TASK_QUEUE=demo_gcp_task_queue:latest \
  --set-secrets=GCP_TASK_SERVICE_EMAIL=demo_gcp_task_service_email:latest \
	--parallelism=1 \
	--tasks=1 \
	--max-retries=1 \
	--command="bin/rails" \
	--args="sync_data_task:remove"
execute-remove-data-on-production:
	gcloud beta run jobs execute remove-data-on-production \
	--region=asia-northeast1 \


deploy-reset-data-workflow:
	gcloud workflows deploy reset_data_workflows \
	 --project=zigexn-vn-sandbox \
	 --location=asia-northeast1 \
	 --source=./reset_data_workflow/workflows/config.yaml

execute-remove-and-sync-data-workflow:
	gcloud workflows run reset_data_workflows --location=asia-northeast1 --data='{"exec_step": "remove_and_syn"}'
