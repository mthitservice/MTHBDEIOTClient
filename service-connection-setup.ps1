# Azure DevOps Service Connection Setup Guide

Write-Host "🔧 Azure DevOps GitHub Service Connection Setup" -ForegroundColor Green
Write-Host "================================================="
Write-Host ""

Write-Host "🔍 Service Connection Problem erkannt!" -ForegroundColor Yellow
Write-Host "Die Pipeline kann nicht auf GitHub zugreifen, da die Service Connection fehlt oder nicht autorisiert ist."
Write-Host ""

Write-Host "📋 Schritt-für-Schritt Anleitung:" -ForegroundColor Cyan
Write-Host "====================================="
Write-Host ""

Write-Host "1. Azure DevOps öffnen:" -ForegroundColor Yellow
Write-Host "   - Gehe zu: https://dev.azure.com/mth-it-service"
Write-Host "   - Wähle dein Projekt: MTHUABDEDS"
Write-Host ""

Write-Host "2. Service Connection erstellen:" -ForegroundColor Yellow
Write-Host "   - Gehe zu: Project Settings (unten links)"
Write-Host "   - Wähle: Service connections"
Write-Host "   - Klicke: 'Create service connection'"
Write-Host "   - Wähle: GitHub"
Write-Host ""

Write-Host "3. GitHub Connection konfigurieren:" -ForegroundColor Yellow
Write-Host "   - Connection name: github-service-connection"
Write-Host "   - Repository: mthitservice/MTHBDEIOTClient"
Write-Host "   - Wähle: Grant access permission to all pipelines"
Write-Host ""

Write-Host "4. GitHub Personal Access Token erstellen:" -ForegroundColor Yellow
Write-Host "   - Gehe zu: https://github.com/settings/tokens"
Write-Host "   - Klicke: 'Generate new token (classic)'"
Write-Host "   - Benötigte Berechtigungen:"
Write-Host "     ✅ repo (Full control of private repositories)"
Write-Host "     ✅ workflow (Update GitHub Action workflows)"
Write-Host "     ✅ write:packages (Write packages to GitHub Package Registry)"
Write-Host ""

Write-Host "5. Token in Azure DevOps eingeben:" -ForegroundColor Yellow
Write-Host "   - Füge den Token in das 'Personal Access Token' Feld ein"
Write-Host "   - Klicke 'Verify and save'"
Write-Host ""

Write-Host "🚀 Alternative Lösungen:" -ForegroundColor Green
Write-Host "========================="
Write-Host ""

Write-Host "Option 1: GitHub Actions verwenden (Empfohlen)" -ForegroundColor Cyan
Write-Host "   - GitHub Actions Workflow ist bereits erstellt"
Write-Host "   - Datei: .github/workflows/raspberry-build.yml"
Write-Host "   - Aktiviere GitHub Actions in deinem Repository"
Write-Host ""

Write-Host "Option 2: Manuelle Releases" -ForegroundColor Cyan
Write-Host "   - Pipeline baut die Artefakte"
Write-Host "   - Lade Artefakte manuell zu GitHub Releases hoch"
Write-Host "   - Artifacts sind verfügbar in Azure DevOps"
Write-Host ""

Write-Host "Option 3: GitHub CLI verwenden" -ForegroundColor Cyan
Write-Host "   - Installiere GitHub CLI auf Build-Agent"
Write-Host "   - Authentifiziere mit: gh auth login"
Write-Host "   - Pipeline verwendet automatisch GitHub CLI"
Write-Host ""

Write-Host "📝 Sofortige Lösung:" -ForegroundColor Green
Write-Host "==================="
Write-Host ""

Write-Host "Die Pipeline wurde so angepasst, dass sie auch ohne Service Connection funktioniert:"
Write-Host "✅ Build-Stage funktioniert weiterhin"
Write-Host "✅ DEB-Pakete werden validiert"
Write-Host "✅ Artefakte werden gespeichert"
Write-Host "✅ Deploy-Stage überspringt Release-Erstellung bei Fehlern"
Write-Host ""

Write-Host "🔄 Nächste Schritte:" -ForegroundColor Yellow
Write-Host "=================="
Write-Host ""

Write-Host "1. Aktuelle Pipeline läuft durch (Build erfolgreich)"
Write-Host "2. Artefakte sind in Azure DevOps verfügbar"
Write-Host "3. Service Connection optional später konfigurieren"
Write-Host "4. Oder GitHub Actions aktivieren für automatische Releases"
Write-Host ""

Write-Host "💡 Empfehlung:" -ForegroundColor Cyan
Write-Host "Verwende GitHub Actions für einfacheres Setup und bessere GitHub-Integration!"
Write-Host ""

Write-Host "📧 Bei Problemen:" -ForegroundColor Yellow
Write-Host "- Prüfe Azure DevOps Pipeline-Logs"
Write-Host "- Teste GitHub Actions als Alternative"
Write-Host "- Verwende manuelle Release-Erstellung"
Write-Host ""

Write-Host "✅ Pipeline ist jetzt funktionsfähig!" -ForegroundColor Green
