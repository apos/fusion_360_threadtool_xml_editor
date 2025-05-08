# Fusion 360 Thread Tool – XML Editor with Jupyter Notebook

⚠️ **Important Notes:**  
1. Fusion 360 must be closed before using this tool.  
2. The `FUSION_PATH` must be correctly set in the `sync_xml.sh` script.  
   - This path is different on Mac and Windows.  
   - Please refer to this Autodesk article for details:  
     https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/Custom-Threads-in-Fusion-360.html

This tool allows convenient editing of Fusion 360 thread XML files directly inside a Jupyter Notebook.

![alt text](data/image.png)

## Features

✅ Export XML files from Fusion 360  
✅ View and edit existing thread entries  
✅ Add new thread entries  
✅ Delete thread entries  
✅ Write changes back to the XML file  
✅ Remove blank lines from the XML  
✅ Switch language DE ↔ EN

## Usage

1. Start the Jupyter Notebook:
    ```bash
    jupyter notebook
    ```

2. Load the notebook file and run the cells.

3. Use the buttons:
    - **Get XML from Fusion** → Export XML
    - **Patch Fusion XML** → Apply changes to XML
    - **Rebuild .venv** → Rebuild the virtual environment

4. Use the dropdown to load existing threads.

5. Fill in the fields or adjust values.

6. Save:
    - **Save** → overwrite existing entry
    - **Save as New** → create a new entry (`_neu`)

7. Use **Switch to English / Auf Deutsch umschalten** to change the language.

## Requirements

- Python 3.x
- Jupyter Notebook
- ipywidgets

Example installation:

```bash
pip install -r requirements.txt
```

## Directory Structure

```
data/
 └─ AstroISOmetric.xml
bin/
 └─ sync_xml.sh
 └─ create_venv.sh
notebooks/
 └─ fusion360_thread_editor.ipynb
```

---

© 2025 github.com/apos