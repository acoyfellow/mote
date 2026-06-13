# Mote PARALLAX branding guide

## Palette

- Cold teal ink / structure: `#075C59`
- Cyan sample marks: `#16B8B0`
- Vermilion anomaly: `#FF5A36` — one visible anomaly per view
- Carbon hard text: `#172019`
- Mineral paper: `#F3EFE2`
- Paper well: `#FBF7EA`
- Hairline: teal at low alpha

Rule: teal carries structure, frames, labels, rails, and hard edges. Cyan marks samples, confidence, active surfaces, and measurements. Vermilion marks the one item that needs attention in the current view.

## Typography

- System sans for human-readable text: restrained, compact, high confidence.
- System monospace for specimen labels, coordinates, command handles, timestamps, confidence values, and reproduction handles.
- No theatrical scale jumps. Headings are measured, not poster-like.
- Labels are uppercase with wide tracking. Body text is quiet and carbon.

## Surface language

Use observation plates, calibration rails, ticks, grid paper, confidence bands, sample wells, spectral strips, measured signal lines, and specimen labels. Every decorative element should imply measurement or reproducibility.

## Voice

Write like a lab note:

- Observed under these conditions.
- Here is the error.
- Here is how to reproduce it.
- State conditions, sample size, confidence, known limits, and the reproduction steps.

## Mote-specific uniqueness

PARALLAX can become too clinical. For Mote, keep the observation language but make the subject personal software:

- The Mac is the specimen and runtime.
- The Svelte workspace is the preserved artifact.
- The bridge is an instrument, not a chatbot.
- Optional cloud services are integrations, not the local edit loop.

## Image contract

Prefer deterministic HTML/SVG plates for the website so labels stay accessible HTML and no generated glyphs are baked into pixels. If using generated plates later, crop or mask any hallucinated text; publish only texture/plot imagery and keep all words in HTML captions.
