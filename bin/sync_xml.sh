#!/bin/bash
# Sync-Skript für AstroISOmetric.xml

set -e
set -x

FUSION_PATH="/Users/apos/Library/Application Support/Autodesk/webdeploy/production/e70c239bb1d26fec5aba0c1faee6762025157baa/Autodesk Fusion.app/Contents/Libraries/Applications/Fusion/Fusion/Server/Fusion/Configuration/ThreadData"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCAL_FILE="${SCRIPT_DIR}/../data/AstroISOmetric.xml"

if [ "${1}" == "export" ]; then
  cp "${FUSION_PATH}/AstroISOmetric.xml" "../data/AstroISOmetric.xml.bak"  # Lokales Backup
  cp "${FUSION_PATH}/AstroISOmetric.xml" "${LOCAL_FILE}"
  echo "✅ Datei aus Fusion-Ordner ins data-Verzeichnis kopiert"
elif [ "${1}" == "import" ]; then
  echo "Vorher:"
  ls -l "${FUSION_PATH}/AstroISOmetric.xml"
  # Create a verbose backup of the existing file in Fusion path
  cp -v "${FUSION_PATH}/AstroISOmetric.xml" "${FUSION_PATH}/AstroISOmetric.xml.bak"
  cp -v "${LOCAL_FILE}" "${FUSION_PATH}/AstroISOmetric.xml"
  echo "✅ Datei aus data-Verzeichnis zurück ins Fusion-Programm kopiert"
else
  echo "Usage: ${0} [export|import]"
fi