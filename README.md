# Cloud Programming – Multi-Region Azure Website

Dieses Projekt implementiert eine hochverfügbare und automatisch skalierbare Webanwendung in Microsoft Azure. Die gesamte Cloud-Infrastruktur wird mit Terraform als Infrastructure as Code (IaC) bereitgestellt.

## Architektur

Die Anwendung wird parallel in zwei Azure-Regionen betrieben:

- France Central
- Sweden Central

Azure Traffic Manager dient als globaler DNS-basierter Einstiegspunkt und verwendet das Routing-Verfahren `Performance`. Dadurch wird ein gesunder Endpunkt mit möglichst geringer Netzwerklatenz ausgewählt.

Beide Regionen verfügen über einen eigenen Azure App Service Plan und eine eigene Linux Web App.

```text
                    Global Users
                         |
                         v
              Azure Traffic Manager
                 Performance Routing
                         |
              +----------+----------+
              |                     |
              v                     v
       France Central         Sweden Central
              |                     |
       App Service Plan       App Service Plan
              |                     |
          Linux Web App         Linux Web App
              |                     |
              +----------+----------+
                         |
                         v
               Azure Monitor
                         |
                         v
               Log Analytics
```

## Verwendete Azure-Dienste

### Azure App Service

Die Node.js-Webanwendung wird in zwei Azure App Services bereitgestellt.

Beide Web Apps verwenden unter anderem:

- HTTPS-only
- TLS mindestens Version 1.2
- deaktiviertes FTP
- deaktivierte Basic-Authentication für FTP und WebDeploy
- Always On
- `/health` als Health-Check-Endpunkt

Die Anwendung gibt zusätzlich die Azure-Region aus, in der die Anfrage verarbeitet wurde.

### Azure Traffic Manager

Azure Traffic Manager verbindet beide Regionen zu einer global verfügbaren Architektur.

Konfiguration:

- Routing-Methode: `Performance`
- Health Check: HTTPS
- Health-Check-Pfad: `/health`
- Intervall: 30 Sekunden
- DNS-TTL: 30 Sekunden
- maximal tolerierte fehlgeschlagene Prüfungen: 3

Fällt eine Web App aus, wird sie aus der DNS-Auswahl entfernt und Traffic wird auf die verbleibende gesunde Region geleitet.

### Autoscaling

Für beide App Service Plans ist automatisches CPU-basiertes Skalieren aktiviert.

Kapazität:

```text
Minimum: 1 Instanz
Standard: 1 Instanz
Maximum: 3 Instanzen
```

Scale-out:

```text
CPU > 70 %
Zeitraum: 5 Minuten
Aktion: +1 Instanz
Cooldown: 5 Minuten
```

Scale-in:

```text
CPU < 30 %
Zeitraum: 5 Minuten
Aktion: -1 Instanz
Cooldown: 5 Minuten
```

### Azure Monitor und Log Analytics

Die HTTP- und Konsolen-Logs beider Web Apps werden zentral in einem Log Analytics Workspace gesammelt.

Konfigurierte Log-Kategorien:

- `AppServiceHTTPLogs`
- `AppServiceConsoleLogs`

Die Aufbewahrungszeit beträgt 30 Tage.

Damit können Requests, HTTP-Statuscodes und die Health-Probes des Azure Traffic Managers zentral analysiert werden.

## Infrastructure as Code

Die Infrastruktur wird vollständig mit Terraform verwaltet.

Die Terraform-Dateien sind funktional getrennt:

```text
terraform/
├── providers.tf
├── main.tf
├── appservice.tf
├── trafficmanager.tf
├── autoscale.tf
├── monitoring.tf
├── variables.tf
├── outputs.tf
└── .terraform.lock.hcl
```

Die Terraform-State-Dateien und lokale Deployment-Dateien werden nicht in Git versioniert.

## Voraussetzungen

Für die Bereitstellung werden benötigt:

- Microsoft Azure Subscription
- Azure CLI
- Terraform
- Git
- ZIP

Die verwendeten Terraform-Provider werden über `.terraform.lock.hcl` reproduzierbar versioniert.

## Azure-Anmeldung

Azure CLI anmelden:

```bash
az login
```

Aktive Subscription prüfen:

```bash
az account show --output table
```

## Azure Resource Provider registrieren

Die verwendeten Azure-Dienste benötigen mehrere Resource Provider:

```bash
az provider register --namespace Microsoft.Web --wait
az provider register --namespace Microsoft.Network --wait
az provider register --namespace Microsoft.Insights --wait
az provider register --namespace Microsoft.OperationalInsights --wait
```

Registrierungsstatus kann beispielsweise so geprüft werden:

```bash
az provider show \
  --namespace Microsoft.Web \
  --query registrationState \
  --output tsv
```

## Anwendung vorbereiten

Die Webanwendung befindet sich unter:

```text
website/app/
```

Vor dem Terraform-Deployment wird daraus das ZIP-Paket für Azure App Service erzeugt:

```bash
cd website/app
zip -r ../app.zip .
cd ../../terraform
```

Die erzeugte Datei `website/app.zip` wird nicht in Git eingecheckt.

## Terraform initialisieren

Im Terraform-Verzeichnis:

```bash
cd terraform

terraform init
terraform fmt
terraform validate
```

## Deployment planen

```bash
terraform plan
```

Optional kann der geprüfte Plan gespeichert werden:

```bash
terraform plan -out=deployment.tfplan
```

## Deployment durchführen

Bei gespeichertem Plan:

```bash
terraform apply deployment.tfplan
```

Alternativ:

```bash
terraform apply
```

## Outputs anzeigen

Nach erfolgreicher Bereitstellung:

```bash
terraform output
```

Terraform gibt unter anderem die URLs der beiden Web Apps und den DNS-Namen des Traffic Managers aus.

## Web Apps testen

France Central:

```bash
curl "$(terraform output -raw france_central_web_app_url)"
```

Sweden Central:

```bash
curl "$(terraform output -raw sweden_central_web_app_url)"
```

Health Checks:

```bash
curl "$(terraform output -raw france_central_web_app_url)/health"
curl "$(terraform output -raw sweden_central_web_app_url)/health"
```

Erwartete Antwort:

```text
OK
```

## Traffic Manager testen

DNS-Ziel anzeigen:

```bash
dig +short CNAME "$(terraform output -raw traffic_manager_fqdn)"
```

Der zurückgegebene CNAME verweist abhängig von Verfügbarkeit und Performance auf eine der beiden Azure Web Apps.

## Failover testen

Zum Test kann beispielsweise France Central temporär gestoppt werden:

```bash
az webapp stop \
  --resource-group rg-cloudprogramming-dev \
  --name <FRANCE-WEB-APP-NAME>
```

Status der Traffic-Manager-Endpunkte:

```bash
az network traffic-manager endpoint list \
  --profile-name <TRAFFIC-MANAGER-PROFILE> \
  --resource-group rg-cloudprogramming-dev \
  --type azureEndpoints \
  --query "[].{Name:name,Monitor:endpointMonitorStatus}" \
  --output table
```

Anschließend kann erneut geprüft werden:

```bash
dig +short CNAME "$(terraform output -raw traffic_manager_fqdn)"
```

Bei erkanntem Ausfall wird nur noch der gesunde Endpunkt zurückgegeben.

Die gestoppte Anwendung anschließend wieder starten:

```bash
az webapp start \
  --resource-group rg-cloudprogramming-dev \
  --name <FRANCE-WEB-APP-NAME>
```

## Monitoring testen

Für Testdaten können Requests an beide Web Apps gesendet werden:

```bash
for i in {1..10}; do
  curl -s "$(terraform output -raw france_central_web_app_url)" > /dev/null
  curl -s "$(terraform output -raw sweden_central_web_app_url)" > /dev/null
done
```

Anschließend können die HTTP-Logs im Log Analytics Workspace mit Kusto Query Language ausgewertet werden.

Beispiel:

```text
AppServiceHTTPLogs
| summarize
    Requests=count(),
    SuccessfulRequests=countif(ScStatus == 200),
    LastRequest=max(TimeGenerated)
  by CsHost
| order by CsHost asc
```

## Sicherheitsmaßnahmen

Im Projekt werden unter anderem folgende Maßnahmen eingesetzt:

- ausschließlich HTTPS für die Web Apps
- TLS mindestens Version 1.2
- FTP deaktiviert
- FTP Basic Authentication deaktiviert
- WebDeploy Basic Authentication deaktiviert
- keine Zugangsdaten im Terraform-Code
- keine Terraform-State-Dateien im Git-Repository
- keine `.tfvars`-Dateien im Git-Repository
- Health Checks über HTTPS
- reproduzierbare Provider-Versionen über Terraform Lockfile

## Abweichungen vom ursprünglichen Architekturentwurf

Ursprünglich war Azure Front Door als globaler Einstiegspunkt vorgesehen.

Die verwendete Azure-for-Students-Subscription erlaubt jedoch keine Erstellung von Azure-Front-Door-Ressourcen. Deshalb wurde die Architektur während der Implementierung angepasst und Azure Traffic Manager eingesetzt.

Traffic Manager erfüllt die wesentlichen Anforderungen des Projekts durch:

- globales DNS-Routing
- Performance-basierte Auswahl
- Health Monitoring
- automatisches Failover zwischen Regionen

Traffic Manager arbeitet im Gegensatz zu Azure Front Door auf DNS-Ebene und bietet daher kein Edge-Caching oder TLS-Termination.

Auch die ursprünglich vorgesehenen Azure-Regionen mussten aufgrund von Subscription-Richtlinien angepasst werden. Die Anwendung wird deshalb tatsächlich in France Central und Sweden Central betrieben.

## Kosten

Das Projekt wurde innerhalb einer Azure-for-Students-Subscription umgesetzt.

Zur Kostenkontrolle wurden:

- nur zwei App-Service-Pläne verwendet
- die maximale Autoscale-Kapazität auf drei Instanzen je Region begrenzt
- die Log-Aufbewahrung auf 30 Tage begrenzt
- nur für das Projekt notwendige Cloud-Ressourcen erstellt

Nicht mehr benötigte Ressourcen sollten nach Abschluss des Projekts entfernt werden.

## Infrastruktur entfernen

Alle durch Terraform verwalteten Ressourcen können mit folgendem Befehl gelöscht werden:

```bash
terraform destroy
```

Vor dem Löschen zeigt Terraform nochmals alle betroffenen Ressourcen an.

## Projektstruktur

```text
cloud-programming/
├── terraform/
│   ├── providers.tf
│   ├── main.tf
│   ├── appservice.tf
│   ├── trafficmanager.tf
│   ├── autoscale.tf
│   ├── monitoring.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── .terraform.lock.hcl
├── website/
│   └── app/
│       ├── server.js
│       └── package.json
├── screenshots/
├── .gitignore
└── README.md
```

## Ergebnis

Die implementierte Azure-Architektur stellt eine reproduzierbare Multi-Region-Cloud-Lösung bereit.

Die Umsetzung umfasst:

- zwei unabhängige Azure-Regionen
- Performance-basiertes globales Routing
- Health Monitoring
- automatischen Failover
- CPU-basiertes Autoscaling
- zentrales Logging und Monitoring
- Sicherheitskonfiguration
- vollständige Infrastructure-as-Code-Verwaltung mit Terraform
