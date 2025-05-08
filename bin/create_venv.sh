#!/bin/bash
# Erstellt ein virtuelles Python-Umfeld im Projekt-Hauptverzeichnis

set -e

VENV_DIR="../.venv"

# Prüfen ob venv existiert
if [ -d "$VENV_DIR" ]; then
  echo "✅ Virtuelle Umgebung existiert bereits: $VENV_DIR"
else
  echo "🛠 Erstelle virtuelle Umgebung..."
  python3 -m venv "$VENV_DIR"
  echo "✅ Virtuelle Umgebung erstellt: $VENV_DIR"
fi

# Aktivieren und installieren
source "$VENV_DIR/bin/activate"
echo "📦 Installiere Abhängigkeiten aus bin/requirements.txt ..."
pip install --upgrade pip
pip install -r bin/requirements.txt
echo "✅ Umgebung bereit. Aktiviere sie bei Bedarf mit:"
echo "source $VENV_DIR/bin/activate"