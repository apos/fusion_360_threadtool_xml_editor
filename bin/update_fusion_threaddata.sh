#!/bin/bash
# =============================================================================
# update_fusion_threaddata.sh
# -----------------------------------------------------------------------------
# Führt nach einer Fusion 360 (Re-)Installation alle nötigen Anpassungen durch:
#
#   1. Erkennt automatisch die aktuelle Fusion-360-UID im webdeploy-Verzeichnis
#   2. Aktualisiert die FusionUID in config_fusion_threaddata_path.ini
#   3. Kopiert alle Custom-Thread-XMLs aus data/ in das ThreadData-Verzeichnis
#      der neuen Fusion-Installation
#
# Aufruf:  bash bin/update_fusion_threaddata.sh
#          (aus dem Projekthauptverzeichnis heraus, oder beliebig - Pfade sind
#           relativ zum Skript-Verzeichnis berechnet)
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Pfade
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

CONFIG_FILE="$PROJECT_DIR/config_fusion_threaddata_path.ini"
DATA_DIR="$PROJECT_DIR/data"

WEBDEPLOY_BASE="$HOME/Library/Application Support/Autodesk/webdeploy/production"
THREADDATA_RELATIVE="Autodesk Fusion.app/Contents/Libraries/Applications/Fusion/Fusion/Server/Fusion/Configuration/ThreadData"

# ---------------------------------------------------------------------------
# Hilfsfunktionen
# ---------------------------------------------------------------------------
info()    { echo "ℹ️  $*"; }
success() { echo "✅ $*"; }
warn()    { echo "⚠️  $*"; }
error()   { echo "❌ $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 1. Aktuelle Fusion-UID ermitteln
#    → neuestes Verzeichnis unter webdeploy/production, das eine Fusion.app enthält
# ---------------------------------------------------------------------------
info "Suche aktuelle Fusion 360 Installation in:"
info "  $WEBDEPLOY_BASE"

LATEST_UID=""
LATEST_MTIME=0

# Iteriere über alle Unterverzeichnisse in webdeploy/production
# und prüfe, ob sie eine Fusion.app enthalten
while IFS= read -r uid; do
    [[ -z "$uid" ]] && continue
    app_path="$WEBDEPLOY_BASE/$uid/Autodesk Fusion.app"
    [[ -d "$app_path" ]] || continue

    mtime=$(stat -f "%m" "$WEBDEPLOY_BASE/$uid" 2>/dev/null || echo 0)
    if (( mtime > LATEST_MTIME )); then
        LATEST_MTIME=$mtime
        LATEST_UID="$uid"
    fi
done < <(ls "$WEBDEPLOY_BASE" 2>/dev/null)

if [[ -z "$LATEST_UID" ]]; then
    error "Keine Fusion 360 Installation gefunden unter:\n  $WEBDEPLOY_BASE\n  Bitte sicherstellen, dass Fusion 360 installiert ist."
fi

success "Gefundene Fusion-UID: $LATEST_UID"

THREADDATA_DIR="$WEBDEPLOY_BASE/$LATEST_UID/$THREADDATA_RELATIVE"

if [[ ! -d "$THREADDATA_DIR" ]]; then
    error "ThreadData-Verzeichnis nicht gefunden:\n  $THREADDATA_DIR"
fi

# ---------------------------------------------------------------------------
# 2. Config-Datei aktualisieren
# ---------------------------------------------------------------------------
info "Aktualisiere FusionUID in: $CONFIG_FILE"

# Lese alte UID zur Anzeige
OLD_UID=$(grep -E '^FusionUID\s*=' "$CONFIG_FILE" | sed 's/.*=\s*//' | tr -d '[:space:]') || OLD_UID="(unbekannt)"

if [[ "$OLD_UID" == "$LATEST_UID" ]]; then
    info "FusionUID ist bereits aktuell – keine Änderung nötig."
else
    # Ersetze die FusionUID-Zeile (sed -i '' = macOS in-place ohne Backup-Extension)
    sed -i '' "s|^FusionUID\s*=.*|FusionUID = $LATEST_UID|" "$CONFIG_FILE"
    success "FusionUID aktualisiert:  $OLD_UID  →  $LATEST_UID"
fi

# ---------------------------------------------------------------------------
# 3. Custom-Thread-XMLs kopieren
# ---------------------------------------------------------------------------
info "Kopiere Custom-Thread-XMLs aus data/ nach:"
info "  $THREADDATA_DIR"

COPIED=0
SKIPPED=0

for xml_file in "$DATA_DIR"/*.xml; do
    [[ -f "$xml_file" ]] || continue
    basename_xml="$(basename "$xml_file")"

    # .bak-Dateien überspringen
    [[ "$basename_xml" == *.bak ]] && continue

    dest="$THREADDATA_DIR/$basename_xml"

    if [[ -f "$dest" ]]; then
        # Prüfen ob identisch
        if cmp -s "$xml_file" "$dest"; then
            info "  Unverändert (übersprungen): $basename_xml"
            ((SKIPPED++)) || true
            continue
        fi
        warn "  Überschreibe vorhandene Datei: $basename_xml"
    fi

    cp "$xml_file" "$dest"
    success "  Kopiert: $basename_xml"
    ((COPIED++)) || true
done

if (( COPIED == 0 && SKIPPED > 0 )); then
    success "Alle Custom-Threads sind bereits aktuell – nichts zu tun."
elif (( COPIED == 0 )); then
    warn "Keine XML-Dateien in $DATA_DIR gefunden."
else
    success "$COPIED Custom-Thread-XML(s) erfolgreich installiert."
fi

# ---------------------------------------------------------------------------
# Zusammenfassung
# ---------------------------------------------------------------------------
echo ""
echo "══════════════════════════════════════════════════════"
echo "  Fusion 360 ThreadData Update abgeschlossen"
echo "  UID    : $LATEST_UID"
echo "  Ziel   : $THREADDATA_DIR"
echo "  Kopiert: $COPIED  |  Unverändert: $SKIPPED"
echo "══════════════════════════════════════════════════════"
echo ""
info "Fusion 360 neu starten, damit die Gewinde-Daten neu geladen werden."
