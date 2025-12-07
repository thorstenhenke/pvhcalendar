# PvH Calendar Generator

Automated tool to fetch school calendars from [Prinz-von-Homburg-Schule](https://www.homburgschule.de), filter relevant dates, and generate clean, printable PDFs.

## Features

* **Automated Fetching:** Downloads the latest ICS calendars directly from the school website.
* **Data Conversion:** Converts `ICS` $\to$ `TSV` $\to$ `Markdown` $\to$ `PDF`.
* **Smart Formatting:**
    * Dates formatted as `dd.mm.YYYY`.
    * Chronological sorting.
    * Filters out past events (auto-removes dates prior to July 2025).
* **Categorization:** Generates four separate PDFs:
    * `allgemein.pdf`
    * `grundschule.pdf`
    * `sek1.pdf`
    * `sek2.pdf`
* **CI/CD:** ~~Automatically builds and deploys via GitHub Actions and Netlify.~~

## Usage

### Prerequisites
* `make`
* `curl`
* `pandoc`
* `pdflatex` (via TeX Live or similar)
* `sed` (GNU sed required on macOS as `gsed`)

### Build Locally
To generate all PDFs:
```bash
make all
