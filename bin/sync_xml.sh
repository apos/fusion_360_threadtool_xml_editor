#!/bin/bash
# Sync-Skript für AstroISOmetric.xml

set -e

FUSION_PATH="/Users/apos/Library/Application Support/Autodesk/webdeploy/production/e70c239bb1d26fec5aba0c1faee6762025157baa/Autodesk Fusion.app/Contents/Libraries/Applications/Fusion/Fusion/Server/Fusion/Configuration/ThreadData"
LOCAL_FILE="../data/AstroISOmetric.xml"

if [ "$1" == "export" ]; then
  echo "⚠️ Bitte Fusion 360 zuerst beenden!"
  cp "$FUSION_PATH/AstroISOmetric.xml" "../data/AstroISOmetric.xml.bak"  # Lokales Backup
  cp "$FUSION_PATH/AstroISOmetric.xml" "$LOCAL_FILE"
  echo "✅ Datei aus Fusion-Ordner ins data-Verzeichnis kopiert"
elif [ "$1" == "import" ]; then
  echo "⚠️ Bitte Fusion 360 zuerst beenden!"
  cp "$FUSION_PATH/AstroISOmetric.xml" "$FUSION_PATH/AstroISOmetric.xml.bak"  # Backup im Paket
  cp "$LOCAL_FILE" "$FUSION_PATH/AstroISOmetric.xml"
  echo "✅ Datei aus data-Verzeichnis zurück ins Fusion-Programm kopiert"
else
  echo "Usage: $0 [export|import]"
fi