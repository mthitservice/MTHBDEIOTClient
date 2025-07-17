# Azure DevOps Environment Setup
# Anweisungen zur Einrichtung der Environments

## Environment: RaspberryPi-Production

### Zweck
Production Environment für Raspberry Pi Releases

### Einrichtung in Azure DevOps

1. **Navigation:**
   - Azure DevOps > Pipelines > Environments
   - "New environment" klicken

2. **Konfiguration:**
   ```
   Name: RaspberryPi-Production
   Description: Production environment for Raspberry Pi releases
   Resource: None (Virtual environment)
   ```

3. **Security & Approvals:**
   ```
   Approvals and checks:
   - Required reviewers: [Ihr Name/Email]
   - Wait for completion: Yes
   - Instructions: "Review release package and approve deployment"
   ```

4. **Permissions:**
   ```
   Security:
   - Administrator: Project Administrators, Build Administrators
   - Reader: Contributors
   - User: Build Service Accounts
   ```

### Environment Gates (Optional)

Für zusätzliche Sicherheit können Sie Gates einrichten:

1. **Pre-deployment Conditions:**
   - Manual approval required
   - Specific users/groups

2. **Post-deployment Conditions:**
   - Notification on success/failure
   - Work item update

### Variables (Environment-specific)

Environment-spezifische Variablen können hier definiert werden:

```yaml
variables:
- name: DEPLOYMENT_TARGET
  value: "raspberry-pi-production"
- name: NOTIFICATION_EMAIL
  value: "admin@mth-it-service.com"
```

## Service Connections (für GitHub Release)

### GitHub Connection Setup

1. **Navigation:**
   - Azure DevOps > Project Settings > Service connections
   - "New service connection" > GitHub

2. **Konfiguration:**
   ```
   Service connection name: github-connection
   Server URL: https://github.com
   Personal Access Token: [Ihr GitHub PAT]
   ```

3. **GitHub PAT Berechtigungen:**
   ```
   Scopes erforderlich:
   - repo (Full control of private repositories)
   - write:packages (Upload packages to GitHub Package Registry)
   - read:org (Read org and team membership)
   ```

4. **Verification:**
   - Test connection
   - Grant access permission to all pipelines

### PAT erstellen in GitHub

1. **GitHub Settings:**
   - GitHub > Settings > Developer settings > Personal access tokens

2. **Token erstellen:**
   ```
   Note: Azure DevOps - MTH BDE IoT Client
   Expiration: 1 year
   Scopes:
   ✓ repo
   ✓ write:packages
   ✓ read:org
   ```

3. **Token kopieren:**
   - Token sicher speichern
   - In Azure DevOps Service Connection verwenden

## Pipeline Permissions

### Repository Permissions

```yaml
# azure-pipelines-raspberry.yml
# Berechtigung für Repository Checkout
permissions:
  contents: read
  metadata: read
```

### Build Service Permissions

1. **Project Settings:**
   - Security > Permissions
   - Build Service Accounts

2. **Required Permissions:**
   ```
   - Edit build definition: Allow
   - View build definition: Allow
   - Queue builds: Allow
   - View builds: Allow
   ```

## Notification Setup

### Email Notifications

1. **Project Settings:**
   - Notifications > New subscription

2. **Build Completion:**
   ```
   Event: Build completes
   Filter: [Your build definition]
   Delivery: Email
   Recipients: [Team/Individual emails]
   ```

3. **Release Events:**
   ```
   Event: Release deployment completed
   Filter: RaspberryPi-Production environment
   Recipients: [Deployment team]
   ```

### Teams/Slack Integration

Für Teams/Slack Benachrichtigungen:

1. **Service Hook:**
   - Project Settings > Service hooks
   - Microsoft Teams/Slack webhook

2. **Events:**
   - Build completed
   - Release deployment completed
   - Release deployment failed

## Variable Groups

### Shared Variables

1. **Create Variable Group:**
   ```
   Azure DevOps > Library > Variable groups
   Name: RaspberryPi-Shared
   ```

2. **Variables:**
   ```yaml
   NODE_VERSION: "22.x"
   BUILD_CONFIGURATION: "Release"
   ELECTRON_BUILDER_ALLOW_UNRESOLVED_DEPENDENCIES: "true"
   GITHUB_REPOSITORY: "mthitservice/MTHBDEIOTClient"
   ```

3. **Link to Pipelines:**
   ```yaml
   # In pipeline YAML
   variables:
   - group: RaspberryPi-Shared
   ```

## Security Best Practices

### Secrets Management

1. **Azure Key Vault Integration:**
   ```
   Service connections > Azure Key Vault
   Link: [Your Key Vault]
   ```

2. **Secure Variables:**
   ```yaml
   variables:
   - group: RaspberryPi-Secrets  # From Key Vault
   ```

### Access Control

1. **Least Privilege:**
   - Service accounts: Minimal required permissions
   - Users: Role-based access

2. **Pipeline Permissions:**
   ```
   - Restrict pipeline resource access
   - Limit environment access
   - Secure variable access
   ```

## Monitoring & Logging

### Pipeline Analytics

1. **Built-in Analytics:**
   - Azure DevOps > Analytics views
   - Build/Release success rates
   - Duration trends

2. **Custom Dashboards:**
   - Build status widgets
   - Release progress
   - Quality metrics

### Log Analysis

1. **Pipeline Logs:**
   - Structured logging in scripts
   - Consistent error messages
   - Performance metrics

2. **External Monitoring:**
   - Application Insights (optional)
   - Custom telemetry

## Troubleshooting

### Common Issues

1. **Permission Denied:**
   ```
   Solution: Check service connection permissions
   Verify: GitHub PAT scopes
   ```

2. **Environment Not Found:**
   ```
   Solution: Create environment first
   Verify: Exact name matching in YAML
   ```

3. **Approval Timeout:**
   ```
   Solution: Check approval settings
   Increase: Timeout values
   ```

### Debug Steps

1. **Enable Debug Logging:**
   ```yaml
   variables:
     system.debug: true
   ```

2. **Verbose Output:**
   ```bash
   npm install --verbose
   electron-builder --verbose
   ```

3. **Pipeline Variables:**
   ```yaml
   - script: |
       echo "All variables:"
       env | sort
   ```
