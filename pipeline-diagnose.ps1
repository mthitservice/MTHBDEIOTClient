# Azure DevOps Pipeline Diagnose Script
# Hilft bei der Identifizierung von Pipeline-Problemen

Write-Host "🔍 Azure DevOps Pipeline Diagnose" -ForegroundColor Green
Write-Host "===================================="
Write-Host ""

# 1. Pipeline-Datei Existenz prüfen
$pipelineFile = "azure-pipelines-raspberry.yml"
if (Test-Path $pipelineFile) {
    Write-Host "✅ Pipeline-Datei gefunden: $pipelineFile" -ForegroundColor Green
    
    # Dateigröße prüfen
    $fileSize = (Get-Item $pipelineFile).Length
    Write-Host "   Dateigröße: $fileSize Bytes"
    
    if ($fileSize -eq 0) {
        Write-Host "❌ Pipeline-Datei ist leer!" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Pipeline-Datei nicht gefunden: $pipelineFile" -ForegroundColor Red
}

# 2. YAML-Syntax prüfen
Write-Host ""
Write-Host "🔧 YAML-Syntax Validierung..." -ForegroundColor Yellow

# Überprüfe auf häufige YAML-Probleme
$content = Get-Content $pipelineFile -Raw
if ($content -match '\t') {
    Write-Host "⚠️  Warnung: Tabs gefunden - Azure DevOps bevorzugt Leerzeichen" -ForegroundColor Yellow
}

# Prüfe auf korrekte Einrückung
$lines = Get-Content $pipelineFile
$indentationIssues = @()
for ($i = 0; $i -lt $lines.Length; $i++) {
    $line = $lines[$i]
    if ($line -match '^(\s+)' -and $matches[1].Length % 2 -ne 0) {
        $indentationIssues += "Zeile $($i+1): Ungerade Einrückung"
    }
}

if ($indentationIssues.Count -gt 0) {
    Write-Host "⚠️  Mögliche Einrückungsprobleme:" -ForegroundColor Yellow
    $indentationIssues | ForEach-Object { Write-Host "   $_" }
}

# 3. Branch-Konfiguration prüfen
Write-Host ""
Write-Host "🌿 Branch-Konfiguration..." -ForegroundColor Yellow

# Aktueller Branch
try {
    $currentBranch = & git rev-parse --abbrev-ref HEAD 2>$null
    if ($currentBranch) {
        Write-Host "   Aktueller Branch: $currentBranch"
        
        # Prüfe ob Branch in Trigger-Konfiguration enthalten
        if ($content -match "main|develop|master") {
            if ($currentBranch -match "main|develop|master") {
                Write-Host "✅ Branch ist in Pipeline-Trigger konfiguriert" -ForegroundColor Green
            } else {
                Write-Host "⚠️  Branch '$currentBranch' ist nicht in Pipeline-Trigger konfiguriert" -ForegroundColor Yellow
            }
        }
    }
} catch {
    Write-Host "❌ Git-Repository nicht gefunden oder nicht initialisiert" -ForegroundColor Red
}

# 4. Letzte Commits prüfen
Write-Host ""
Write-Host "📝 Letzte Commits..." -ForegroundColor Yellow

try {
    $lastCommits = & git log --oneline -5 2>$null
    if ($lastCommits) {
        Write-Host "   Letzte 5 Commits:"
        $lastCommits | ForEach-Object { Write-Host "   $_" }
    }
} catch {
    Write-Host "❌ Kann Git-Log nicht abrufen" -ForegroundColor Red
}

# 5. Dateiänderungen prüfen
Write-Host ""
Write-Host "📁 Überwachte Dateipfade..." -ForegroundColor Yellow

$watchedPaths = @("App/*", "scripts/*", "azure-pipelines-raspberry.yml")
foreach ($path in $watchedPaths) {
    $files = Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue
    if ($files) {
        Write-Host "✅ Pfad '$path' enthält $($files.Count) Dateien" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Pfad '$path' ist leer oder existiert nicht" -ForegroundColor Yellow
    }
}

# 6. Service Connection prüfen
Write-Host ""
Write-Host "🔗 Service Connection..." -ForegroundColor Yellow

if ($content -match "gitHubConnection:\s*'([^']+)'") {
    $connectionName = $matches[1]
    Write-Host "   GitHub Service Connection: $connectionName"
    Write-Host "   ⚠️  Bitte in Azure DevOps prüfen, ob Service Connection aktiv ist" -ForegroundColor Yellow
}

# 7. Pipeline-Berechtigungen
Write-Host ""
Write-Host "🔐 Pipeline-Berechtigungen..." -ForegroundColor Yellow
Write-Host "   Repository-Berechtigungen zu prüfen:"
Write-Host "   - Build Service hat Schreibzugriff auf Repository"
Write-Host "   - Pipeline ist als Build-Definition konfiguriert"
Write-Host "   - Branch-Policies erlauben Pipeline-Ausführung"

# 8. Häufige Probleme und Lösungen
Write-Host ""
Write-Host "💡 Häufige Probleme und Lösungen:" -ForegroundColor Cyan
Write-Host "=================================="
Write-Host ""

Write-Host "Problem: Pipeline springt nicht an" -ForegroundColor Yellow
Write-Host "Lösungen:"
Write-Host "1. Prüfe Azure DevOps Pipeline-Einstellungen"
Write-Host "2. Verifiziere Service Connection Status"
Write-Host "3. Prüfe Repository-Berechtigungen"
Write-Host "4. Teste manuellen Pipeline-Trigger"
Write-Host "5. Prüfe Branch-Policies"
Write-Host ""

Write-Host "Problem: Pipeline-Trigger funktioniert nicht" -ForegroundColor Yellow
Write-Host "Lösungen:"
Write-Host "1. Commit/Push auf überwachten Branch (main/develop)"
Write-Host "2. Ändere Dateien in überwachten Pfaden (App/*, scripts/*)"
Write-Host "3. Prüfe 'batch: true' Einstellung"
Write-Host "4. Deaktiviere/Aktiviere Pipeline in Azure DevOps"
Write-Host ""

Write-Host "Problem: Service Connection Fehler" -ForegroundColor Yellow
Write-Host "Lösungen:"
Write-Host "1. Erneuere GitHub Personal Access Token"
Write-Host "2. Prüfe Service Connection in Azure DevOps"
Write-Host "3. Verifiziere Repository-Zugriff"
Write-Host ""

# 9. Empfohlene Aktionen
Write-Host ""
Write-Host "🎯 Empfohlene Aktionen:" -ForegroundColor Green
Write-Host "======================"
Write-Host ""

Write-Host "1. Manueller Pipeline-Test:"
Write-Host "   - Gehe zu Azure DevOps → Pipelines"
Write-Host "   - Wähle 'Run pipeline' manuell aus"
Write-Host "   - Prüfe Logs auf Fehler"
Write-Host ""

Write-Host "2. Test-Commit erstellen:"
Write-Host "   git add ."
Write-Host "   git commit -m 'Pipeline trigger test'"
Write-Host "   git push origin main"
Write-Host ""

Write-Host "3. Pipeline-Konfiguration prüfen:"
Write-Host "   - Öffne Azure DevOps"
Write-Host "   - Gehe zu Project Settings → Service connections"
Write-Host "   - Prüfe 'github-service-connection'"
Write-Host ""

Write-Host "4. Alternative: GitHub Actions verwenden:"
Write-Host "   - Erstelle .github/workflows/raspberry-build.yml"
Write-Host "   - Migriere Build-Logic zu GitHub Actions"
Write-Host ""

Write-Host "✅ Diagnose abgeschlossen!" -ForegroundColor Green
Write-Host "Führe die empfohlenen Aktionen aus, um das Problem zu beheben."
