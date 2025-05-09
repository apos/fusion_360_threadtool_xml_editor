# Fusion 360 Gewindetool – XML-Editor mit Jupyter Notebook

⚠️ **Wichtige Hinweise:**  
1. Fusion kann an sein, man muss nur das Thread-Tool neu starten.  
2. Der Pfad muss in der config-Datei gesetzt werden.

   Beispiel (Mac):
   FUSION_PATH="/Users/yourname/Library/Application Support/Autodesk/webdeploy/production/.../ThreadData/Metric.xml"

   Hinweis: Der Pfad unterscheidet sich auf Windows und Mac. Details findest du hier:
   - https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/Custom-Threads-in-Fusion-360.html

   Man kann diese Webseite (DE) zur Berechnung verwenden:
   - https://github.com/apos/fusion_360_threadtool_xml_editor
 
   Dank auch an Paul Gerlach
   - https://stargazerslounge.com/topic/346425-astro-threads-for-fusion-360/
  
   Danke an 

Dieses Tool ermöglicht die komfortable Bearbeitung von Gewinde-XML-Dateien für Fusion 360 direkt in einem Jupyter Notebook.

![alt text](data/image_de.png)

## Funktionen

✅ XML-Dateien aus Fusion 360 exportieren  
✅ Vorhandene Gewindeeinträge anzeigen und bearbeiten  
✅ Neue Gewindeeinträge hinzufügen  
✅ Gewindeeinträge löschen  
✅ Änderungen direkt ins XML zurückschreiben  
✅ Leere Zeilen aus der XML entfernen  
✅ Sprachumschaltung DE ↔ EN

## Bedienung

1. Starte das Jupyter Notebook mit:
    ```bash
    jupyter notebook
    ```

2. Lade die Notebook-Datei und führe die Zellen aus.

3. Nutze die Buttons:
    - **Get XML from Fusion** → XML exportieren
    - **Patch Fusion XML** → Änderungen ins XML schreiben
    - **Rebuild .venv** → virtuelle Umgebung neu erstellen

4. Nutze das Dropdown, um vorhandene Gewinde zu laden.

5. Fülle die Felder aus oder passe Werte an.

6. Speichere:
    - **Speichern** → überschreibt existierenden Eintrag
    - **Als neu speichern** → legt neuen Eintrag an (`_neu`)

7. Mit **Switch to English / Auf Deutsch umschalten** kannst du die Sprache wechseln.

## Voraussetzungen

- Python 3.x
- Jupyter Notebook
- ipywidgets

Installation (Beispiel):

```bash
pip install -r bin/requirements.txt
```

## Verzeichnisstruktur

```
├── bin
│   ├── create_venv.sh
│   ├── requirements.txt
│   └── sync_xml.sh
├── config_fusion_threaddata_path.ini
├── data
│   ├── AstroISOmetric.xml
│   ├── AstroISOmetric.xml.bak
│   ├── image_de.png
│   └── image.png
├── fusion360_thread_editor.ipynb
├── README_DE.md
└── README.md
```

---

© 2025 github.com/apos