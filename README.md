# Bangladesh Divisional Choropleth Map — Shiny App

An R Shiny app that draws a choropleth map of Bangladesh's **8 divisions**.
No shapefile upload is required — the boundary data is bundled with the app
(`www/bd_divisions.geojson`). Just type a percentage for each division and
generate the map.

## Features
- Type a value (%) for each of the 8 divisions: Barishal, Chattogram, Dhaka,
  Khulna, Mymensingh, Rajshahi, Rangpur, Sylhet
- Press **Enter** in any field, or click **Generate Map**
- Continuous colour bar (legend) showing intensity from low to high
- Choice of 10 colour palettes (Viridis, Plasma, Blues, Reds, etc.)
- Customizable **title, subtitle, caption, footnote**, and legend title
- Optional division-name and value labels drawn directly on the map
- Download the finished map as a high-resolution PNG

## Setup

1. Install R (4.x or later) from https://cran.r-project.org
2. Install the required packages (one time):

```r
install.packages(c("shiny", "sf", "ggplot2", "dplyr"))
```

   Note: `sf` needs GDAL/GEOS/PROJ system libraries. On Windows/Mac these
   are bundled with the CRAN binary. On Ubuntu/Debian, if the install fails,
   run first:
   ```bash
   sudo apt-get install -y libgdal-dev libgeos-dev libproj-dev
   ```

## Running the app

From R / RStudio, open the folder and run:

```r
shiny::runApp("bd_choropleth_app")
```

or open `app.R` in RStudio and click **Run App**.

## Folder structure

```
bd_choropleth_app/
├── app.R                      # the Shiny app (UI + server)
├── www/
│   └── bd_divisions.geojson   # bundled 8-division boundary (~245 KB)
└── README.md
```

## Data source & accuracy note

The division boundaries were derived from the Bangladesh Bureau of
Statistics (BBS) administrative boundary dataset (2020), simplified for
fast rendering. Geometry was cross-checked and one division (Dhaka) was
reconstructed from the national outline minus the other 7 divisions to
correct a defect in the original source file. Boundaries are for general
visualization purposes and are simplified — not suitable for precise
surveying or legal/administrative use.

## Customizing further
- To change the default sample percentages, edit the `value = ...` defaults
  in the `numericInput()` calls inside `app.R`.
- To add more colour palettes, add an entry to `palette_choices` and to the
  `custom_gradients` list (or `viridis_opts`) inside `get_fill_scale()`.
