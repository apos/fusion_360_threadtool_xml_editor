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
# 2. Vorab-Prüfung: Ist bereits alles in Ordnung?
# ---------------------------------------------------------------------------
OLD_UID=$(grep -E '^FusionUID\s*=' "$CONFIG_FILE" | sed 's/.*=\s*//' | tr -d '[:space:]') || OLD_UID=""

NEEDS_UPDATE=false

# UID stimmt nicht?
if [[ "$OLD_UID" != "$LATEST_UID" ]]; then
    NEEDS_UPDATE=true
fi

# Fehlt eine XML-Datei oder weicht sie ab?
if ! $NEEDS_UPDATE; then
    for xml_file in "$DATA_DIR"/*.xml; do
        [[ -f "$xml_file" ]] || continue
        basename_xml="$(basename "$xml_file")"
        [[ "$basename_xml" == *.bak ]] && continue
        dest="$THREADDATA_DIR/$basename_xml"
        if [[ ! -f "$dest" ]] || ! cmp -s "$xml_file" "$dest"; then
            NEEDS_UPDATE=true
            break
        fi
    done
fi

if ! $NEEDS_UPDATE; then
    echo ""
    echo "══════════════════════════════════════════════════════"
    success "Installation ist bereits in Ordnung – nichts zu tun."
    echo "  UID : $LATEST_UID"
    echo "══════════════════════════════════════════════════════"
    echo ""
    exit 0
fi

# ---------------------------------------------------------------------------
# 3. Config-Datei aktualisieren (nur wenn nötig)
# ---------------------------------------------------------------------------
if [[ "$OLD_UID" != "$LATEST_UID" ]]; then
    info "Aktualisiere FusionUID in: $CONFIG_FILE"
    sed -i '' "s|^FusionUID\s*=.*|FusionUID = $LATEST_UID|" "$CONFIG_FILE"
    success "FusionUID aktualisiert:  $OLD_UID  →  $LATEST_UID"
else
    info "FusionUID bereits aktuell: $LATEST_UID"
fi

# ---------------------------------------------------------------------------
# 4. Custom-Thread-XMLs kopieren (nur fehlende / abweichende)
# ---------------------------------------------------------------------------
info "Kopiere Custom-Thread-XMLs aus data/ nach:"
info "  $THREADDATA_DIR"

COPIED=0
SKIPPED=0

for xml_file in "$DATA_DIR"/*.xml; do
    [[ -f "$xml_file" ]] || continue
    basename_xml="$(basename "$xml_file")"
    [[ "$basename_xml" == *.bak ]] && continue

    dest="$THREADDATA_DIR/$basename_xml"

    if [[ -f "$dest" ]] && cmp -s "$xml_file" "$dest"; then
        info "  Unverändert (übersprungen): $basename_xml"
        ((SKIPPED++)) || true
        continue
    fi

    [[ -f "$dest" ]] && warn "  Überschreibe vorhandene Datei: $basename_xml"
    cp "$xml_file" "$dest"
    success "  Kopiert: $basename_xml"
    ((COPIED++)) || true
done

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
