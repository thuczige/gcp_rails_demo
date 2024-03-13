DEMO: https://huytp-gcp-demo-web-cp7nmoqjta-an.a.run.app/
# I. Build ở môi trường local.
### Step 1: Install Google Cloud SDK
refer to this document: https://cloud.google.com/sdk/docs/install-sdk#mac

### Step 2: Run gcloud auth login
it will auto goto your browser (need to login with Ventura google account)
accept permissions
### Step 3: Create .env file from .env.example, Change GOOGLE_APPLICATION_CREDENTIALS in .env file to suit your environment.
How to get GOOGLE_APPLICATION_CREDENTIALS?
cd ~/.config/gcloud/legacy_credentials
ls
cd your_email_address
pwd
now you can see ex: /Users/mac/.config/gcloud/legacy_credentials/staff@zigexn.vn

GOOGLE_APPLICATION_CREDENTIALS is /Users/mac/.config/gcloud/legacy_credentials/staff@zigexn.vn/adc.json
### Step 5: Create file application.yml
Create config/application.yml file from config/application.yml.example. This yaml file is only used for your local development environment.

### Step 6, start docker compose 
Run `docker-compose up` to create the remaining containers.

Run `docker-compose up -d` to run with daemon

Once all the containers are created, if you need to stop them
```
docker-compose stop
```
If you need to turn them on again
```
docker-compose start
```

# II. Các biến môi trường cần thiết lập.
- RAILS_ENV
- SECRET_KEY_BASE
- PRIMARY_DB_USERNAME
- PRIMARY_DB_PASSWORD
- PRIMARY_DB_PORT
- PRIMARY_DB_HOST
- PRIMARY_DB_NAME
- REDIS_HOST
- REDIS_PORT
- REDIS_AUTH_STRING
- REDIS_USERNAME
- GCP_PROJECT_ID
- GCP_TASK_QUEUE
- REGION
- GCP_TASK_SERVICE_EMAIL

Trong đó có các biến môi trường sau giá trị được get từ secret manager:
```
        '--set-secrets', 'SECRET_KEY_BASE=demo_secret_key_base:latest',
        '--set-secrets', 'PRIMARY_DB_USERNAME=demo_primary_db_username:latest',
        '--set-secrets', 'PRIMARY_DB_PASSWORD=demo_primary_db_password:latest',
        '--set-secrets', 'PRIMARY_DB_PORT=demo_primary_db_port:latest',
        '--set-secrets', 'PRIMARY_DB_HOST=demo_primary_db_host:latest',

        '--set-secrets', 'REDIS_HOST=demo_redis_host:latest',
        '--set-secrets', 'REDIS_PORT=demo_redis_port:latest',
        '--set-secrets', 'REDIS_AUTH_STRING=demo_redis_auth_string:latest',
        '--set-secrets', 'REDIS_USERNAME=demo_redis_username:latest',

        '--set-secrets', 'GCP_TASK_QUEUE=demo_gcp_task_queue:latest',
        '--set-secrets', 'GCP_TASK_SERVICE_EMAIL=demo_gcp_task_service_email:latest'
```
giải thích: VD SECRET_KEY_BASE, thì đang connect với secret key trong secretManager là demo_secret_key_base (https://console.cloud.google.com/security/secret-manager/secret/demo_secret_key_base/versions?project=zigexn-vn-sandbox)

Các biến môi trường còn lại:
- RAILS_ENV = production (mình có 4 môi trường chính development/staging/production/test)
- GCP_PROJECT_ID = zigexn-vn-sandbox (hiện mình đang dùng project này của cty để test, các bạn có thể đăng ký tài khoản riêng và tạo project khác, nhớ đổi lại chỗ này)
- REGION = asia-northeast1 (các bạn có thể đổi region phù hợp)
- PRIMARY_DB_NAME = huytp_production (đây là db mẫu, các bạn có thể thay đổi thành db của các bạn theo cú pháp {yourname}_production)
# III. Các file build configuration
## 1. CI
- Để chạy CI cho unitest thì sẽ sử dụng file config: cloudbuild-rspec.yaml
- Để chạy CI cho rubocop (check lỗi cú pháp, coding convention, best practice) thì mình sẽ dùng file config: cloudbuild-rubocop.yaml
- Tương tự như vậy sau này nếu muốn viết thêm CI, cho bất cứ ngôn ngữ nào thì cũng tạo file cloudbuild tương tự, nó hoạt động theo lõi docker nên rất linh hoạt.
## 2. CD
- Để chạy CD, tức là deploy source code lên cloudRun (ở đây mình dùng cloudRun) thì mình dùng file config này: cloudbuild.yaml
# File cloudbuild.yaml tham khảo
(File này để deploy lên cloudRun)
```
steps:
- name: gcr.io/kaniko-project/executor:v1.9.0
  args:
  - --build-arg=RAILS_ENV=${_RAILS_ENV}
  - --build-arg=SECRET_KEY_BASE=$$SECRET_KEY_BASE

  - --build-arg=PRIMARY_DB_USERNAME=$$PRIMARY_DB_USERNAME
  - --build-arg=PRIMARY_DB_PASSWORD=$$PRIMARY_DB_PASSWORD
  - --build-arg=PRIMARY_DB_PORT=$$PRIMARY_DB_PORT
  - --build-arg=PRIMARY_DB_HOST=$$PRIMARY_DB_HOST
  - --build-arg=PRIMARY_DB_NAME=${_PRIMARY_DB_NAME}

  - --build-arg=REDIS_HOST=$$REDIS_HOST
  - --build-arg=REDIS_PORT=$$REDIS_PORT
  - --build-arg=REDIS_AUTH_STRING=$$REDIS_AUTH_STRING
  - --build-arg=REDIS_USERNAME=$$REDIS_USERNAME

  - --build-arg=GCP_PROJECT_ID=$PROJECT_ID
  - --build-arg=GCP_TASK_QUEUE=$$GCP_TASK_QUEUE
  - --build-arg=REGION=${_REGION}
  - --build-arg=GCP_TASK_SERVICE_EMAIL=$$GCP_TASK_SERVICE_EMAIL
  - --destination=${_GCR_IMAGE}
  - --cache=true
  - --cache-ttl=36h
  secretEnv: ['SECRET_KEY_BASE',
              'PRIMARY_DB_USERNAME',
              'PRIMARY_DB_PASSWORD',
              'PRIMARY_DB_PORT',
              'PRIMARY_DB_HOST',
              'REDIS_HOST',
              'REDIS_PORT',
              'REDIS_AUTH_STRING',
              'REDIS_USERNAME',
              'GCP_TASK_QUEUE',
              'GCP_TASK_SERVICE_EMAIL']

- name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
  entrypoint: gcloud
  args: ['beta', 'run', 'deploy', '${_SERVICE_NAME}',
        '--image', '${_GCR_IMAGE}',
        '--add-cloudsql-instances', '${_CLOUD_SQL}',
        '-${_ALLOW_UNAUTHENTICATED}-allow-unauthenticated',
        '-${_CPU_THROTTLING}-cpu-throttling',
        '--execution-environment', '${_EXECUTION_ENVIRONMENT}',
        '--vpc-connector', '${_VPC_CONNECTOR}',
        '--ingress', '${_INGRESS}',
        '--vpc-egress', '${_VPC_EGRESS}',
        '--region', '${_REGION}',
        '--cpu', '${_CPU}',
        '--memory', '${_MEMORY}',
        '--concurrency', '${_CONCURRENCY}',
        '--min-instances', '${_MIN_INSTANCES}',
        '--max-instances', '${_MAX_INSTANCES}',
        '--platform', 'managed',
        '--revision-suffix', '${_REVISION_SUFFIX}',
        '--set-env-vars', 'RAILS_ENV=${_RAILS_ENV}',
        '--set-env-vars', 'GCP_PROJECT_ID=$PROJECT_ID',
        '--set-env-vars', 'REGION=${_REGION}',
        '--set-env-vars', 'PRIMARY_DB_NAME=${_PRIMARY_DB_NAME}',

        '--set-secrets', 'SECRET_KEY_BASE=demo_secret_key_base:latest',
        '--set-secrets', 'PRIMARY_DB_USERNAME=demo_primary_db_username:latest',
        '--set-secrets', 'PRIMARY_DB_PASSWORD=demo_primary_db_password:latest',
        '--set-secrets', 'PRIMARY_DB_PORT=demo_primary_db_port:latest',
        '--set-secrets', 'PRIMARY_DB_HOST=demo_primary_db_host:latest',

        '--set-secrets', 'REDIS_HOST=demo_redis_host:latest',
        '--set-secrets', 'REDIS_PORT=demo_redis_port:latest',
        '--set-secrets', 'REDIS_AUTH_STRING=demo_redis_auth_string:latest',
        '--set-secrets', 'REDIS_USERNAME=demo_redis_username:latest',

        '--set-secrets', 'GCP_TASK_QUEUE=demo_gcp_task_queue:latest',
        '--set-secrets', 'GCP_TASK_SERVICE_EMAIL=demo_gcp_task_service_email:latest']

# Production subtitutions
substitutions:
  _RAILS_ENV: 'production'
  _REGION: 'asia-northeast1'
  _SERVICE_NAME: 'huytp-gcp-demo-web'
  _GCR_IMAGE: 'gcr.io/${PROJECT_ID}/${REPO_NAME}/${_SERVICE_NAME}'
  _VPC_CONNECTOR: 'nc-gcp-demo-vpc'
  _VPC_EGRESS: 'private-ranges-only'
  _CPU_THROTTLING: '-no'
  _EXECUTION_ENVIRONMENT: 'gen2'
  _CPU: '1'
  _MEMORY: '512Mi'
  _REVISION_SUFFIX: '${_PR_NUMBER}-${SHORT_SHA}'
  _CONCURRENCY: '80'
  _MIN_INSTANCES: '0'
  _MAX_INSTANCES: 'default'
  _ALLOW_UNAUTHENTICATED: ''
  _INGRESS: 'all'
  _PRIMARY_DB_NAME: 'huytp_production'

availableSecrets:
  secretManager:
  - versionName: 'projects/$PROJECT_ID/secrets/demo_secret_key_base/versions/latest'
    env: 'SECRET_KEY_BASE'
  - versionName: 'projects/$PROJECT_ID/secrets/demo_primary_db_username/versions/latest'
    env: 'PRIMARY_DB_USERNAME'
  - versionName: 'projects/$PROJECT_ID/secrets/demo_primary_db_password/versions/latest'
    env: 'PRIMARY_DB_PASSWORD'
  - versionName: 'projects/$PROJECT_ID/secrets/demo_primary_db_port/versions/latest'
    env: 'PRIMARY_DB_PORT'
  - versionName: 'projects/$PROJECT_ID/secrets/demo_primary_db_host/versions/latest'
    env: 'PRIMARY_DB_HOST'
  - versionName: 'projects/$PROJECT_ID/secrets/demo_redis_host/versions/latest'
    env: 'REDIS_HOST'
  - versionName: 'projects/$PROJECT_ID/secrets/demo_redis_port/versions/latest'
    env: 'REDIS_PORT'
  - versionName: 'projects/$PROJECT_ID/secrets/demo_redis_auth_string/versions/latest'
    env: 'REDIS_AUTH_STRING'
  - versionName: 'projects/$PROJECT_ID/secrets/demo_redis_username/versions/latest'
    env: 'REDIS_USERNAME'
  - versionName: 'projects/$PROJECT_ID/secrets/demo_gcp_task_queue/versions/latest'
    env: 'GCP_TASK_QUEUE'
  - versionName: 'projects/$PROJECT_ID/secrets/demo_gcp_task_service_email/versions/latest'
    env: 'GCP_TASK_SERVICE_EMAIL'
timeout: 2400s
options:
  logging: CLOUD_LOGGING_ONLY

```

Chú ý:
1. _SERVICE_NAME, hiện tại là huytp-gcp-demo-web, các bạn cần đổi lại thành tên của bạn, tên này sẽ được hiển thị trong cloudRun (https://console.cloud.google.com/run/detail/asia-northeast1/huytp-gcp-demo-web/metrics?project=zigexn-vn-sandbox)
2. _CPU, mình đang để 1GB để tiết kiệm chi phí, các bạn giữ nguyên như vậy là ok.
3. _MEMORY, mình đang để 512Mb, các bạn cũng nên giữ nguyên.
4. _MIN_INSTANCES, mình đang để là 0, để khi không access thì con cloudRun của mình sẽ ngủ đông, khi nào có access nó tự mở lên lại (chờ tầm 15 giây)
5. _PRIMARY_DB_NAME, các bạn phải đổi lại thành tên của bạn theo cú pháp: {yourname}_production)
6. Những biến như PRIMARY_DB_USERNAME, PRIMARY_DB_PASSWORD, PRIMARY_DB_PORT, PRIMARY_DB_HOST, REDIS_HOST, REDIS_PORT, REDIS_AUTH_STRING, REDIS_USERNAME mình đang set giá trị trên secretManager (https://console.cloud.google.com/security/secret-manager?project=zigexn-vn-sandbox), đang trỏ đến server sql và server redis các nhân của mình, các bạn cứ thoải mái sử dụng học tập miễn phí (vì sử dụng sql + redis trên GCP giá khá cao nên sẽ tắt khi không dùng đến, điều này sẽ khiến các bạn không thể làm ở nhà được)

# IV. API để chạy scheduler
### 1. Giới thiệu
Hiện đang cung cấp sẵn api để thực hiện đồng bộ file từ cloudStorage với db của mình, khi access vô đường dẫn này thì việc đông bộ sẽ được thực hiện
### 2. API URL:
/cronjobs/push_to_task
### 3. Chú ý:
Khi dùng cloudScheduler để hẹn giờ chạy tác vụ này thì nhớ chú ý:
- Add OIDC token trong phần Auth header
- Service account thì chọn zigexn-vn-sandbox-batch-invoker (hoặc là account được cấp quyền Cloud Tasks Enqueuer, Service Account Token Creator, Cloud Run Invoker)
- audience sẽ là {CloudRun_url}/cronjobs/push_to_task
# V. Chạy background job:
### Giới thiệu
Đối với những công việc không cần xử lý tức thời, thì các bạn nên sử dụng backgroud job, trong GCP có cung cấp cloudTask (https://console.cloud.google.com/cloudtasks?referrer=search&project=zigexn-vn-sandbox)
### Hướng dẫn
Các bạn tham khảo đoạn code sau:
```
module Cronjobs
  class SyncDataController < Cronjobs::BaseController
    def push_to_task
      verify_oidc_token! cronjobs_push_to_task_url
      url = cronjobs_execute_sync_url
      Extensions::GoogleCloud::Tasks.create(url: url, audience: url)
      head :ok
    end

    def execute_sync
      verify_oidc_token! cronjobs_execute_sync_url
      SyncServices.call

      head :ok
    end
  end
end
```
ở đây mình dùng method push_to_task để tạo 1 tác vụ vào cây xử lý của cloudTask, tại đây cloudTask sẽ có thuật toán xử lý, cho cái này chạy trước, cái nào chạy sau. Thì push lên mình cũng gắn url vào, thì url này chính là url mà mình sẽ ra lệnh cho cloudTask chạy khi đến lượt.

### Chú ý:
Trong dự án của ta, thì cần có biến môi trường
- GCP_TASK_QUEUE (mình sẽ tạo 1 push queue ở đây https://console.cloud.google.com/cloudtasks?referrer=search&project=zigexn-vn-sandbox), gán name vừa tạo ra vô GCP_TASK_QUEUE
- GCP_TASK_SERVICE_EMAIL cần tạo e service account, hiện tại mình có thể dùng zigexn-vn-sandbox-batch-invoker@zigexn-vn-sandbox.iam.gserviceaccount.com (cần quyền Cloud Tasks Enqueuer, Service Account Token Creator, Cloud Run Invoker)

# VI. Chạy rake task
## 1. Giới thiệu
Với những tác vụ như khởi tạo dữ liệu, đồng bộ hoá dữ liệu, clear cache, những tác vụ không có kế hoạch thực hiện trước thường sẽ được đưa vào rake task.
## 2. Các rake task cung cấp sẵn trong dự án:
```
sync_data_task:sync
sync_data_task:remove
```
## 3. Hướng dẫn deploy và chạy rake task bằng cloudJob
Các bạn có thể mở file Makefile để tham khảo.
### 3.1. Cách deploy
Viết lệnh sau vào file Makefile
```
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
```

để chạy lệnh trên trên terminal thì dùng lệnh: make deploy-sync-data-on-production
### 3.2 cách thực thi rake task
Viết lệnh sau vào file Makefile

```
execute-sync-data-on-production:
  gcloud beta run jobs execute sync-data-on-production \
  --region=asia-northeast1 \
```
để chạy lệnh trên trên terminal thì dùng lệnh: make execute-sync-data-on-production
# VII. Chạy workflows
## 1. Giới thiệu
Với mong muốn thực hiện một chuối các công việc theo các thứ tự mong muốn thì mình có thể dùng workflows.
## 2. Code tham khảo
Các bạn tham khảo đoạn code sau: https://github.com/ZIGExN-VeNtura-Education/gcp_rails_demo/blob/main/reset_data_workflow/workflows/config.yaml
ở đây các bạn có thể nhập vào exec_step để chọn flows mong muốn.

## 3. Cách deploy workflows
Thêm đoạn code sau vào Makefile
```
deploy-reset-data-workflow:
  gcloud workflows deploy reset_data_workflows \
   --project=zigexn-vn-sandbox \
   --location=asia-northeast1 \
   --source=./reset_data_workflow/workflows/config.yaml
```
để deploy bằng terminal thì gõ lệnh: make deploy-reset-data-workflow
## 4. Cách chạy workflows:
### 4.1 Chạy bằng terminal:
Gõ câu lệnh sau vào Makefile:
```
execute-remove-and-sync-data-workflow:
  gcloud workflows run reset_data_workflows --location=asia-northeast1 --data='{"exec_step": "remove_and_syn"}'
```
để chạy thì gõ lệnh make execute-remove-and-sync-data-workflow
### 4.2 Chạy bằng giao diện console GCP
- https://console.cloud.google.com/workflows?referrer=search&project=zigexn-vn-sandbox
- Chọn workflow mà bạn đã deploy trước đó sau đó bấm execute
- khi execute thì gõ {"exec_step":"remove_and_syn"}, bạn có thể đổi remove_and_syn thành only_remove hoặc only_sync (xem trong chỗ condition của file config workflow ở trên), tức là mình sẽ lựa chọn đi theo flows nào.

