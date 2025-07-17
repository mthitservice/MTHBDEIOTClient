# Pipeline Trigger Test Script

Write-Host "🚀 Pipeline Trigger Test" -ForegroundColor Green
Write-Host "========================"
Write-Host ""

# Erstelle eine kleine Änderung um Pipeline zu triggern
$triggerFile = "App/pipeline-trigger.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Schreibe Timestamp in Trigger-Datei
Set-Content -Path $triggerFile -Value "Pipeline trigger test - $timestamp"

Write-Host "✅ Trigger-Datei erstellt: $triggerFile"
Write-Host "   Inhalt: Pipeline trigger test - $timestamp"

# Git-Änderungen vornehmen
git add $triggerFile
git commit -m "Pipeline trigger test - $timestamp"

Write-Host ""
Write-Host "🔄 Pushe Änderungen..."
git push origin master

Write-Host ""
Write-Host "✅ Pipeline sollte jetzt ausgelöst werden!"
Write-Host ""
Write-Host "🔍 Überwache den Status unter:"
Write-Host "   Azure DevOps: https://dev.azure.com/mth-it-service/MTHUABDEDS/_build"
Write-Host "   GitHub Actions: https://github.com/mthitservice/MTHBDEIOTClient/actions"
Write-Host ""
Write-Host "📋 Wenn Pipeline nicht startet, überprüfe:"
Write-Host "   1. Azure DevOps Pipeline-Einstellungen"
Write-Host "   2. Service Connection Status"
Write-Host "   3. Branch-Policies"
Write-Host "   4. Repository-Berechtigungen"
