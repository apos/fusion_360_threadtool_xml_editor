# Using the Fusion 360 Thread Tool with AI Assistance

This guide explains how to work together with an AI assistant (e.g. Claude, ChatGPT) to add, modify, or identify custom threads in Fusion 360 using this project.

No deep knowledge of thread geometry is required — the AI handles the calculations. You provide measurements and context, the AI does the math and edits the XML.

---

## Overview: How It Works

```
You measure  →  AI identifies thread  →  AI calculates values
     →  AI edits data/AstroISOmetric.xml
         →  Script deploys to Fusion 360
             →  You test-print and iterate
```

The central file is `data/AstroISOmetric.xml`. It contains all custom thread definitions.  
The deploy script `bin/update_fusion_threaddata.sh` copies them into Fusion 360 automatically.

---

## Step 1: Give the AI Context

When starting a session, tell the AI:

- Which project this is: **fusion-360-threadtool**
- What you want: add a thread, modify tolerances, identify an unknown thread, etc.
- What file to edit: `data/AstroISOmetric.xml`

The AI can read the file directly and understand its current contents.

---

## Step 2: Identifying an Unknown Thread

If you have a physical part and don't know the thread specification, provide measurements:

### What to measure

| Measurement | How | Tool |
|---|---|---|
| **Outer diameter** | Across thread crests on external thread | Caliper |
| **Pitch** | Distance across N crests, then divide by (N−1) | Caliper |

### Best practice for pitch measurement

Count **N visible crests** and measure the total span from first to last crest:

```
  v v v v v        ← 5 crests
  |.          |    ← measure this span
  =  total length

Pitch = total length / (N − 1)  =  total / 4
```

> Avoid measuring from the very edge if there is a chamfer — it distorts the result.  
> More crests = more accurate result.

### Example

```
5 crests over 3.00 mm  →  Pitch = 3.00 / 4 = 0.75 mm
4 crests over 2.27 mm  →  Pitch = 2.27 / 3 = 0.757 mm ≈ 0.75 mm
```

### Common standard pitches to compare against

| Pitch | Typical use |
|---|---|
| 0.5 mm | M×0.5 fine thread |
| 0.6 mm | 1.25" astronomy filter thread |
| 0.75 mm | M×0.75 fine thread (very common in astronomy) |
| 0.8 mm | M×0.8 standard fine |
| 1.0 mm | M×1.0 |
| 1.0583 mm | 24 TPI (inch) — e.g. 2" SC telescope thread |
| 1.5875 mm | 16 TPI (inch) — e.g. 3.28" SCT thread |

---

## Step 3: Understanding the XML Structure

Each thread type is defined as a `<ThreadSize>` block containing one or more `<Designation>` blocks:

```xml
<ThreadSize>
  <Size>28.85</Size>               <!-- nominal diameter in mm -->
  <Designation>
    <ThreadDesignation>My Thread</ThreadDesignation>
    <CTD>My Thread</CTD>           <!-- same as ThreadDesignation -->
    <Pitch>0.75</Pitch>            <!-- in mm -->
    <Thread>
      <Gender>external</Gender>
      <Class>6g</Class>            <!-- external tolerance class -->
      <MajorDia>28.810</MajorDia>
      <PitchDia>28.323</PitchDia>
      <MinorDia>27.998</MinorDia>
    </Thread>
    <Thread>
      <Gender>internal</Gender>
      <Class>6H</Class>            <!-- internal tolerance class -->
      <MajorDia>28.850</MajorDia>
      <PitchDia>28.363</PitchDia>
      <MinorDia>28.038</MinorDia>
      <TapDrill>28.0</TapDrill>
    </Thread>
    <Thread>
      <Gender>external</Gender>
      <Class>4g6g</Class>          <!-- tighter external tolerance -->
      <MajorDia>28.830</MajorDia>
      <PitchDia>28.343</PitchDia>
      <MinorDia>28.018</MinorDia>
    </Thread>
  </Designation>
</ThreadSize>
```

### The three thread classes

| Class | Gender | Use |
|---|---|---|
| `6g` | external | Standard bolt/plug |
| `6H` | internal | Standard nut/hole |
| `4g6g` | external | Tighter fit |

### How the AI calculates the diameters

Given nominal diameter `D` and pitch `P` (ISO metric formula):

```
PitchDia = MajorDia − 0.6495 × P
MinorDia = MajorDia − 1.0825 × P
```

You don't need to do this yourself — just give the AI `D` and `P`.

---

## Step 4: FDM 3D-Print Tolerance (the "FDM" variant)

FDM printers (e.g. 0.2 mm layer height) print slightly oversized due to over-extrusion and elephant foot. Fine threads are especially affected.

The solution: create a second `<Designation>` with the suffix `FDM` and apply an offset to all diameters.

### Offset direction

| Thread gender | Offset direction | Effect |
|---|---|---|
| External (plug) | **minus** (e.g. −0.4 mm) | Prints thinner → fits into bore |
| Internal (hole) | **plus** (e.g. +0.4 mm) | Prints wider → external thread fits in |

### Starting offsets by pitch (at 0.2 mm layer height)

| Pitch | Recommended starting offset | Notes |
|---|---|---|
| ≥ 1.5 mm | ±0.30 mm | Coarse — less compensation needed |
| ~1.0 mm | ±0.50 mm | Medium fine |
| ≤ 0.75 mm | ±0.40 mm | Fine — test first |
| ≤ 0.6 mm | ±0.40 mm | Very fine — iterate carefully |

> These are starting points only. Always print a **test ring** (5 mm tall, just the thread)  
> and adjust in ±0.1 mm steps until the fit is correct.

### Naming convention

```
Okular-Hülse 28.85x0.75       ← standard (for CNC / reference)
Okular-Hülse 28.85x0.75 FDM   ← 3D-print variant with offset
```

### What to tell the AI

Simply say e.g.:
> *"Add an FDM variant for this thread with −0.4 mm offset."*

The AI will create the second `<Designation>` block automatically.

---

## Step 5: Deploy to Fusion 360

After every XML change, run:

```bash
bash bin/update_fusion_threaddata.sh
```

This script:
1. Finds the current Fusion 360 installation automatically
2. Updates the config file with the current UID
3. Copies all `data/*.xml` files into Fusion's ThreadData directory

Then **restart Fusion 360** (or just the Thread Tool dialog) to reload thread data.

> Fusion 360 can remain open — you only need to close and reopen the Thread Tool panel.

---

## Step 6: Iterating on FDM Fit

Print a small test ring (5 mm tall) first. Then report back to the AI:

| Result | Action |
|---|---|
| Does not engage at all | Pitch is wrong — re-measure more carefully |
| Engages < 1 turn, then binds | Pitch slightly off, or offset too small |
| Engages 1–2 turns, then binds | Increase offset by 0.1–0.2 mm |
| Screws in but feels loose | Decrease offset by 0.1 mm |
| Screws in smoothly, holds well | Done |

---

## Safety Rule: Always Backup First

**Before every modifying step**, the AI must create a timestamped backup:

```bash
cp data/AstroISOmetric.xml data/AstroISOmetric.xml.$(date +%Y%m%d_%H%M%S).bak
```

This is mandatory. Backups are stored alongside the XML in `data/` and can be used to roll back at any time.

---

## Threads Already in AstroISOmetric.xml

| Size | Designation | Pitch | Notes |
|---|---|---|---|
| 48.0 | 2 inch filter thread | 0.75 mm | Standard 2" astro filter |
| 28.5 | 1.25 inch filter | 0.60 mm | Standard 1.25" filter + FDM |
| 28.5 | M28.5x0.6 | 0.60 mm | Metric variant |
| 28.85 | Okular-Hülse 28.85x0.75 | 0.75 mm | Eyepiece barrel thread + FDM |
| 25.4 | C-mount | 0.794 mm | Camera lens C-mount |
| 56.0 | M56x0.75 | 0.75 mm | Metric fine |
| 50.8 | 2"-24 UNS SC | 1.058 mm | Schmidt-Cassegrain 2" + FDM |
| 82.8 | 3,28 inch SCT | 1.588 mm | SCT visual back + FDM |
| 42.0 | M42x0.75 | 1.00 mm | T2 / M42 photography thread |

---

## Example Prompts for the AI

**Identify a thread:**
> "I measured an outer diameter of 28.85 mm and 4 crests over 2.27 mm. What thread is this?"

**Add a new thread:**
> "Add a thread with 28.85 mm diameter and 0.75 mm pitch to AstroISOmetric.xml, with an FDM variant at −0.4 mm offset."

**Adjust FDM tolerance:**
> "The 0.75 FDM thread is still too tight. Increase the external offset to −0.5 mm."

**Clean up test entries:**
> "Delete the 0.7 and 0.8 mm variants — only keep the 0.75 mm ones."

**Deploy after changes:**
> "Deploy the updated XML to Fusion 360."

---

## Tips

- **Always state the diameter AND pitch** when asking for a new thread — the AI needs both.
- **For unknown proprietary threads**, print 2–3 variants with different pitches at once (as separate Designations) to find the right one faster.
- **FDM offset is empirical** — slicer settings, filament, and printer calibration all affect the result. The values in this file reflect 0.2 mm layer height on a well-tuned printer.
- **The standard Designation** (without FDM) is kept as a reference and for CNC/resin printing where no compensation is needed.

---

© 2025 github.com/apos
