# ICT Day Papers — Cropped Quiz App

Fresh quiz app for PHY 01–21 using only the newly cropped original question images and their matching original marking/explanation images.

## Included
- 21 day papers
- 126 questions
- 5 answer choices each
- Original Sinhala-containing question crops
- Matching original marking crops shown after answering
- Save/bookmark, progress, previous/next, results
- Static Netlify deployment

## Fresh crop asset pack
The original-quality crop assets are split into two GitHub-upload-safe files:

- `assets-pack.part-00`
- `assets-pack.part-01`

Put both files in the repository root. Netlify runs `prepare-assets.sh`, verifies both SHA-256 hashes, reconstructs the ZIP, extracts `assets/`, and then verifies exactly **126 question crops + 126 marking crops** before publishing.

The source archive and both parts are backed up in Google Drive under **ICT Day Papers Fresh Quiz App**.

No Vercel asset dependency is used.
