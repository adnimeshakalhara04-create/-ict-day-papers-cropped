# ICT Day Papers — Cropped Quiz App

Fresh quiz app for PHY 01–27 using only the newly cropped original question images and their matching original marking/explanation images.

## Included
- 27 day papers
- 164 questions
- 5 answer choices each
- Original Sinhala-containing question crops
- Matching original marking crops shown after answering
- Save/bookmark, progress, previous/next, results
- Static Vercel and Netlify deployment support

## Fresh crop asset pack
The original-quality crop assets are split into two GitHub-upload-safe files:

- `assets-pack.part-00`
- `assets-pack.part-01`

Put both files in the repository root. The deployment build runs `prepare-assets.sh`, verifies both SHA-256 hashes, reconstructs the ZIP, extracts `assets/`, and then verifies exactly **164 question crops + 177 marking crops** before publishing. PHY 22 uses the latest original JPEG crops from the Google Drive `Days Paper` folder.

The source archive and both parts are backed up in Google Drive under **ICT Day Papers Fresh Quiz App**.

`vercel-build.sh` stages only the website files and verified assets into `dist/` for Vercel.


## PHY 23–25 update
The verified PHY 23–25 question/marking crops are stored in the shared Google Drive Cropped folder as `PHY 23-25 Crops.zip`. The Vercel build downloads the public bundle, verifies its SHA-256 checksum, extracts it into `assets/`, and validates the complete 25-paper / 148-question asset map before publishing.

<!-- deploy-sync: 2026-09-22 phy01-25-r11 -->

## PHY 26–27 source-verified update (2026-11-04)

- 16 fresh question crops and 21 marking/explanation images extracted from the four original PDFs, at high resolution; no invented content.
- Answers read from the official source PDFs: PHY 26 = `[2,1,3,1,1,2,5,1]`, PHY 27 = `[4,2,2,2,5,2,1,2]`.
- Crops are copied into each corresponding `PHY 26/27 > Q01–Q08` Google Drive question/marking folder, with multipart explanations kept in order.
- New immutable crop pack stored under `updates/phy26-27/part-00` through `part-03` and reconstructed/verified by `prepare-assets.sh` during Vercel build.
- Checksums and original PDFs are retained in the Google Drive Days Paper folders, with a release backup under `PHY 26-27 — Verified Build Assets`.
