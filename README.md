# Rendering Research — Metal port workspace

| Folder | Contents |
|---|---|
| `metal/` | Apple Metal (MSL) port: `Common.h`, `Trees.metal`, `Shadows.metal`, `AmbientOcclusion.metal`, `GlobalIllumination.metal`, `ReflectionsWater.metal`, `Atmospherics.metal` |
| `reference_hlsl/qualityN/` | Recovered D3D9 HLSL, one folder per quality tier: `fragments/vs`, `fragments/ps` (one file per fragment, named `slot_name.hlsl`), `materials/` (reassembled material shaders), `fragments.json`, `materials.json` |
| `engine_notes/` | Shader-builder prelude strings and the render-pass / render-target list |
| `tools/` | `dbpf.py` (package reader + RefPack decompressor), `extract_fragments.py` (fragment/material rebuild), `strscan.py`, `blobs.py` (precompiled DX9 blob extraction), `validate_metal.swift` |
| `paper/rendering_study.html` | Research report |

Validate the Metal port (no Xcode needed):

```bash
swift tools/validate_metal.swift metal
```

Re-run the extraction (resource type `0x0469A3F7` dumped with `dbpf.py`):

```bash
python3 -I tools/dbpf.py <app.package> dump <outdir> 469a3f7
python3 -I tools/extract_fragments.py <outdir>/0469a3f7 reference_hlsl
```
