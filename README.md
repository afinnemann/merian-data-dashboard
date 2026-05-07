# Merian Environmental Data Dashboard — Starter set v0.1 (prototype)

Curated R-snippet starter cards for high-quality environmental and health data covering São Paulo and the Netherlands, built as a prototype for discussion within the five NWO/FAPESP Merian "Extreme Heat and Water Events" consortia (2026–2031).

**This is a prototype. Source list, framing and metadata fields will be revised after consortium consultation.**

## Scope of v0.1

- Seven seed cards spanning pollution, heat, rain, and health-outcome anchors for both countries.
- One YAML registry validated against a JSON Schema. HTML rendered from the YAML.
- No charts in v0.1 (a `head()` preview of snippet output sits inside the card drawer instead).
- No "AI layer" category in v0.1. AlphaEarth and similar are deferred to a later experimental section once the core registry is consultation-validated.

## Folder layout

```
merian-data-dashboard/
├── README.md                          # this file
├── schema/dataset_card.schema.json    # card schema, validates registry entries
├── registry/cards.yaml                # the 7 seed cards (human-edited)
├── docs/                              # GitHub Pages site root
│   ├── index.html                     # self-contained dashboard (data inlined)
│   └── data/cards.json                # compiled from cards.yaml (machine view)
├── scripts/
│   ├── compile_registry.R             # YAML -> JSON for the dashboard
│   └── check_liveness.R               # URL liveness + snippet smoke test
└── handout/                           # bilingual A4 PDF for the conference
```

## Card identity

Stable IDs of the form `clh-br-0001`, `clh-nl-0001` — never reused, never renumbered.

## Maintenance

Maintainer: Adam Finnemann (UvA). Backup: TBD after consultation. Next review: after first consortium feedback round.

## What this is NOT (yet)

- Not a registry. 7 cards is a starter set, not a comprehensive reference.
- Not a "shared infrastructure" claim. The four sister consortia have not been consulted; we will ask after they have seen this prototype.
- Not maintained on an SLA. Snippet liveness CI is on the v0.2 roadmap.
