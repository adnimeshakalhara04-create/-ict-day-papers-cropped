# ICT Day Papers — Cropped Quiz App

Fresh quiz app for PHY 01–22 using only the newly cropped original question images and their matching original marking/explanation images.

## Included
- 22 day papers
- 132 questions
- 5 answer choices each
- Original Sinhala-containing question crops
- Matching original marking crops shown after answering
- Save/bookmark, progress, previous/next, results
- Static Vercel and Netlify deployment support

## Fresh crop asset pack
The original-quality crop assets are split into two GitHub-upload-safe files:

- `assets-pack.part-00`
- `assets-pack.part-01`

Put both files in the repository root. The deployment build runs `prepare-assets.sh`, verifies both SHA-256 hashes, reconstructs the ZIP, extracts `assets/`, and then verifies exactly **132 question crops + 132 marking crops** before publishing. PHY 22 uses the latest original JPEG crops from the Google Drive `Days Paper` folder.

The source archive and both parts are backed up in Google Drive under **ICT Day Papers Fresh Quiz App**.

`vercel-build.sh` stages only the website files and verified assets into `dist/` for Vercel.
