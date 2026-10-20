param(
    [Parameter(Mandatory)] [string] $Root,       # an installed {userappdata}\SAM (install-hosted-exe.ps1)
    [Parameter(Mandatory)] [string] $Version,    # the run's SAMVersion, e.g. 2026.4.227.0
    [Parameter(Mandatory)] [string] $Revision,   # the run's stamped SAM_Deploy revision, e.g. 717533c
    [Parameter(Mandatory)] [string] $Out
)
# S06 harness: inventory an installed payload for the repin payload-equivalence check (compare-payloads.ps1).
# One TSV row per file: relative path, length, SHA-256, FileVersion, ProductVersion, and for text files the SHA-256 of
# the content after the run's stamp strings are replaced by placeholders, so two runs' text files can be compared
# independently of their stamp.
$ErrorActionPreference = 'Stop'
$text = '.json', '.config', '.xml', '.txt', '.md', '.ini', '.bat', '.cmd', '.ps1', '.csv', '.html', '.htm', '.css', '.js', '.ghuser', '.ghlink', '.addin', '.yml', '.yaml'
$sha = [Security.Cryptography.SHA256]::Create()
$rows = foreach ($f in Get-ChildItem $Root -Recurse -File) {
    $rel = $f.FullName.Substring($Root.TrimEnd('\').Length + 1)
    $vi = $f.VersionInfo
    $norm = ''
    if ($text -contains $f.Extension.ToLowerInvariant()) {
        $s = [IO.File]::ReadAllText($f.FullName)
        $s = $s.Replace($Version, '<SAMVersion>').Replace($Revision, '<rev>')
        # SAM_OCCT declares [assembly: AssemblyVersion("1.0.*")]: build = days since 2000-01-01, revision = seconds
        # since midnight / 2, i.e. a build-time stamp. Normalise it where deps.json files reference those assemblies.
        # Only 1.0.9xxx.n matches (build number 9000-9999 = days since 2000, i.e. 2024-2027), so a fixed third-party
        # version is never normalised.
        $s = [regex]::Replace($s, '(SAM\.[A-Za-z.]*OCCT(?:/|"\s*:\s*"))1\.0\.9\d{3}\.\d+', '$1<occt-build-time-version>')
        $s = [regex]::Replace($s, '("assemblyVersion"\s*:\s*")1\.0\.9\d{3}\.\d+', '$1<occt-build-time-version>')
        $norm = -join ($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($s)) | ForEach-Object { $_.ToString('x2') })
    }
    # Empty fields are written as '-' (no trailing whitespace in the committed TSV).
    $cols = @($rel, $f.Length, (Get-FileHash $f.FullName -Algorithm SHA256).Hash, "$($vi.FileVersion)".Trim(), "$($vi.ProductVersion)".Trim(), $norm) |
        ForEach-Object { if ("$_" -eq '') { '-' } else { "$_" } }
    $cols -join "`t"
}
Set-Content -Path $Out -Value (@("path`tlength`tsha256`tfileVersion`tproductVersion`tstampNormalizedTextSha256") + $rows) -Encoding UTF8
"{0} files inventoried from {1}" -f @($rows).Count, $Root
