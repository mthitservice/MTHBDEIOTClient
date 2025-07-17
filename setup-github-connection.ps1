# GitHub Service Connection Setup Guide

Write-Host "🔗 GitHub Service Connection Setup" -ForegroundColor Green
Write-Host "=================================="
Write-Host ""

Write-Host "Service Connection Name: github-connection" -ForegroundColor Yellow
Write-Host "Repository: mthitservice/MTHBDEIOTClient" -ForegroundColor Yellow
Write-Host ""

Write-Host "📋 Schritte zur Konfiguration der GitHub Service Connection:" -ForegroundColor Cyan
Write-Host "============================================================"
Write-Host ""

Write-Host "1. Öffne Azure DevOps Portal:" -ForegroundColor White
Write-Host "   https://dev.azure.com/mth-it-service/MTHUABDEDS"
Write-Host ""

Write-Host "2. Gehe zu Project Settings:" -ForegroundColor White
Write-Host "   - Klicke auf das Zahnrad-Symbol (unten links)"
Write-Host "   - Oder direkte URL: https://dev.azure.com/mth-it-service/MTHUABDEDS/_settings/"
Write-Host ""

Write-Host "3. Service Connections:" -ForegroundColor White
Write-Host "   - Klicke auf 'Service connections' im linken Menü"
Write-Host "   - Oder direkte URL: https://dev.azure.com/mth-it-service/MTHUABDEDS/_settings/adminservices"
Write-Host ""

Write-Host "4. Suche nach 'github-connection':" -ForegroundColor White
Write-Host "   - Falls vorhanden: Prüfe Status und Berechtigung"
Write-Host "   - Falls nicht vorhanden: Erstelle neue Service Connection"
Write-Host ""

Write-Host "5. Neue Service Connection erstellen:" -ForegroundColor White
Write-Host "   - Klicke 'New service connection'"
Write-Host "   - Wähle 'GitHub'"
Write-Host "   - Name: github-connection"
Write-Host "   - Repository: mthitservice/MTHBDEIOTClient"
Write-Host ""

Write-Host "6. Authentifizierung:" -ForegroundColor White
Write-Host "   - Wähle 'Personal Access Token'"
Write-Host "   - Erstelle GitHub PAT mit folgenden Berechtigungen:"
Write-Host "     ✅ repo (alle Repository-Berechtigungen)"
Write-Host "     ✅ write:packages"
Write-Host "     ✅ read:org"
Write-Host ""

Write-Host "7. GitHub Personal Access Token erstellen:" -ForegroundColor White
Write-Host "   - Gehe zu https://github.com/settings/tokens"
Write-Host "   - Klicke 'Generate new token (classic)'"
Write-Host "   - Name: Azure DevOps Pipeline"
Write-Host "   - Berechtigungen: repo, write:packages, read:org"
Write-Host "   - Kopiere das Token"
Write-Host ""

Write-Host "8. Service Connection fertigstellen:" -ForegroundColor White
Write-Host "   - Füge das GitHub PAT ein"
Write-Host "   - Repository URL: https://github.com/mthitservice/MTHBDEIOTClient"
Write-Host "   - Name: github-connection"
Write-Host "   - Klicke 'Verify and save'"
Write-Host ""

Write-Host "9. Pipeline-Berechtigung:" -ForegroundColor White
Write-Host "   - Gehe zurück zu deiner Pipeline"
Write-Host "   - Führe einen manuellen Pipeline-Lauf aus"
Write-Host "   - Autorisiere die Service Connection wenn gefragt"
Write-Host ""

Write-Host "🔧 Fehlerbehebung:" -ForegroundColor Yellow
Write-Host "=================="
Write-Host ""

Write-Host "Problem: Service Connection nicht gefunden" -ForegroundColor Red
Write-Host "Lösung:"
Write-Host "- Prüfe den exakten Namen: 'github-connection'"
Write-Host "- Prüfe Project-Berechtigungen"
Write-Host "- Erstelle neue Service Connection falls nötig"
Write-Host ""

Write-Host "Problem: Authentifizierung fehlgeschlagen" -ForegroundColor Red
Write-Host "Lösung:"
Write-Host "- Prüfe GitHub PAT Gültigkeit"
Write-Host "- Prüfe PAT Berechtigungen"
Write-Host "- Erneuere PAT falls abgelaufen"
Write-Host ""

Write-Host "Problem: Pipeline nicht autorisiert" -ForegroundColor Red
Write-Host "Lösung:"
Write-Host "- Führe manuellen Pipeline-Lauf aus"
Write-Host "- Autorisiere Service Connection in Pipeline-Einstellungen"
Write-Host "- Prüfe 'Security' Tab der Service Connection"
Write-Host ""

Write-Host "✅ Test der Service Connection:" -ForegroundColor Green
Write-Host "==============================="
Write-Host ""

Write-Host "Nach der Konfiguration:"
Write-Host "1. Gehe zu Pipeline: https://dev.azure.com/mth-it-service/MTHUABDEDS/_build"
Write-Host "2. Führe manuellen Pipeline-Lauf aus"
Write-Host "3. Prüfe 'Deploy' Stage auf Erfolg"
Write-Host "4. Prüfe GitHub Releases: https://github.com/mthitservice/MTHBDEIOTClient/releases"
Write-Host ""

Write-Host "🎯 Wichtige Punkte:" -ForegroundColor Cyan
Write-Host "==================="
Write-Host ""

Write-Host "✅ Service Connection Name: github-connection (exakt so)"
Write-Host "✅ Repository: mthitservice/MTHBDEIOTClient"
Write-Host "✅ GitHub PAT mit repo + write:packages Berechtigungen"
Write-Host "✅ Pipeline-Autorisierung erforderlich"
Write-Host "✅ Fallback über GitHub CLI falls Service Connection fehlschlägt"
Write-Host ""

Write-Host "📞 Bei weiteren Problemen:" -ForegroundColor Yellow
Write-Host "- Prüfe Azure DevOps Logs"
Write-Host "- Teste manuelle Pipeline-Ausführung"
Write-Host "- Nutze GitHub Actions als Alternative"
Write-Host ""

Write-Host "Setup-Guide abgeschlossen!" -ForegroundColor Green
