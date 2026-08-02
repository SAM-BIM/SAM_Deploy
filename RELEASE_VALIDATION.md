# SAM_Deploy release acceptance matrix v1

This matrix is newly defined in PR `maintenance/final-repository-hardening`. It
replaces the previously undefined "H1–H12 hand tests" wording used in earlier
handovers — those labels existed without definitions, so no claim is made here
to execute or complete any historical matrix. Every result below starts
**PENDING** and changes only on direct evidence.

## H1 — Clean installer build

Trigger installer.yml manually from the PR branch with publish_release=false.

Pass criteria:

- workflow completes successfully;
- one installer artifact is produced;
- artifact filename contains the requested test version;
- no tag or GitHub Release is created;
- workflow run URL, run number, commit SHA and artifact SHA-256 are recorded.

## H2 — Clean-profile installation

Install the generated artifact using a clean Windows user profile or clean test
machine.

Pass criteria:

- installer completes without errors;
- no files from a previous SAM installation are present before installation;
- expected %APPDATA%\SAM directories are created;
- expected Rhino 8 and Rhino 9 package directories are created;
- installed files originate from the tested artifact.

## H3 — Rhino 8 load test

Start Rhino 8 using the clean test profile.

Pass criteria:

- SAM Rhino plugin loads;
- Grasshopper starts;
- SAM component tabs and components appear;
- no missing-assembly errors occur;
- no duplicate assembly or duplicate component GUID warnings occur.

## H4 — Rhino 9 load test

Start Rhino 9 using the clean test profile.

Pass criteria:

- SAM Rhino plugin loads;
- Grasshopper starts;
- SAM component tabs and components appear;
- no missing-assembly errors occur;
- no duplicate assembly or duplicate component GUID warnings occur.

## H5 — TAS Grasshopper assembly deployment

Inspect the installation and Grasshopper load report.

Pass criteria:

- all six expected SAM_Tas_Grasshopper .gha assemblies are installed;
- each assembly is loaded from the installer destination, not a developer build
  directory;
- assemblies carry timestamps and file versions from the tested build;
- no stale TAS Grasshopper assemblies remain from the old SAM_Tas layout.

The exact six filenames are recorded below after being discovered from the
built output (not guessed):

*(pending — recorded during H5 execution)*

## H6 — TAS UserObject deployment

Verify the two TAS .ghuser UserObjects.

Pass criteria:

- both expected UserObjects are installed;
- both appear in Grasshopper;
- both can be placed on a new canvas;
- no missing-component or missing-assembly messages occur.

*(exact filenames and component names recorded during H6 execution)*

## H7 — Representative TAS workflow

Open or create a small representative TAS Grasshopper definition.

It must exercise:

- at least one SAM analytical input;
- a TAS conversion or simulation component;
- the newly split SAM_Tas_Grasshopper assemblies;
- a visible, inspectable output.

Pass criteria:

- the definition opens without replacement components;
- the solution completes without runtime exceptions;
- outputs are non-empty and plausible;
- the test file and screenshot are retained as evidence.

## H8 — Rhino.Inside.Revit 2025

Using Revit 2025 and Rhino.Inside.Revit:

Pass criteria:

- Grasshopper starts;
- installed SAM components load from the Revit 2025 payload;
- a representative SAM component can be placed and solved;
- no framework mismatch, duplicate assembly or loader errors occur.

## H9 — Rhino.Inside.Revit 2026

Repeat the H8 test using Revit 2026.

Pass criteria are identical, using the Revit 2026 payload.

## H10 — Revit 2027 energy-analysis runtime path

Using Revit 2027 and a suitable test model, exercise the runtime paths fixed by
SAM_Revit PR #17:

- ToSAM_AnalyticalModel;
- TogbXML.

Pass criteria:

- no AnalysisType range exception occurs;
- the detailed energy model is created;
- analytical spaces and surfaces are returned;
- gbXML export completes or reaches a clearly documented model-data limitation
  unrelated to the API migration;
- installed assemblies are confirmed to target the Revit 2027/net10 payload.

This test cannot be replaced by a compile-only result.

## H11 — Upgrade and uninstall behaviour

Test installation over an existing previous SAM installer version, followed by
uninstall.

Pass criteria:

- upgrade completes without duplicate or stale assemblies;
- current files replace previous versions;
- uninstall completes without fatal errors;
- SAM-owned files installed by the tested package are removed;
- unrelated user files and unrelated Rhino/Grasshopper packages remain;
- any intentionally retained files are documented.

If uninstall symmetry is incomplete, mark this test failed or partially passed
and create a specific follow-up issue. Do not hide residual files.

## H12 — Final payload and provenance audit

Audit the installed payload against the workflow artifact.

Pass criteria:

- installer SHA-256 is recorded;
- installed DLL FileVersion values match the workflow run identity;
- Revit 2025, 2026 and 2027 payloads contain the correct framework-specific
  assemblies;
- Rhino 8 and Rhino 9 package payloads are present;
- no developer paths, build_tests output, obsolete Topologic files, private
  certificates or signing passwords are packaged;
- no unexpected duplicate DLL names with different hashes are present;
- the complete result table links to screenshots, logs and workflow evidence.

## Results

Environment (recorded at execution time):

- Windows: *(pending)*
- Rhino 8 / Rhino 9: *(pending)*
- Revit: *(pending)*
- Rhino.Inside.Revit: *(pending)*
- TAS: *(pending)*
- installer.yml run: *(pending — URL, run number, commit SHA, artifact SHA-256)*

| Test | Result | Environment | Evidence | Notes |
|---|---|---|---|---|
| H1 | PENDING | | | |
| H2 | PENDING | | | |
| H3 | PENDING | | | |
| H4 | PENDING | | | |
| H5 | PENDING | | | |
| H6 | PENDING | | | |
| H7 | PENDING | | | |
| H8 | PENDING | | | |
| H9 | PENDING | | | |
| H10 | PENDING | | | |
| H11 | PENDING | | | |
| H12 | PENDING | | | |

Rules:

- PASS requires direct evidence.
- FAIL means the tested behaviour is defective.
- BLOCKED means the required software, licence, model or environment was not
  available.
- Do not convert BLOCKED or waived tests into PASS.
- Build success is not evidence for H3–H12.
- Record exact Rhino, Revit, Rhino.Inside and Windows versions.
- Keep test installer evidence out of Git unless it is small documentation,
  logs or screenshots suitable for the repository.

Release validation is complete only when every row is PASS. Any BLOCKED or FAIL
result must remain clearly listed before merge/release.
