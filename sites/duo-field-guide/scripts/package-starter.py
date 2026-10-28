"""Package the native starter from its tracked, human-readable source."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
ROOT = Path(__file__).resolve().parents[1]
source = ROOT / 'starter' / 'DuoNotes'
output = ROOT / 'dist' / 'downloads' / 'DuoNotesStarter.zip'
output.parent.mkdir(parents=True, exist_ok=True)
with ZipFile(output, 'w', compression=ZIP_DEFLATED) as archive:
    for file in sorted(source.rglob('*')):
        if file.is_file() and not any(part in {'xcuserdata', '.DS_Store', 'DerivedData'} for part in file.relative_to(source).parts):
            archive.write(file, Path('DuoNotes') / file.relative_to(source))
print(output)
