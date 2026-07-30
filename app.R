# Bangladesh Divisional Choropleth Map — Shiny App
# Required packages: shiny, sf, ggplot2, dplyr
# Install once with:
# install.packages(c("shiny", "sf", "ggplot2", "dplyr"))


library(shiny)
library(sf)
library(ggplot2)
library(dplyr)


# 1. Load the boundary data once when the app starts
bd_map <- st_read("www/bd_divisions.geojson", quiet = TRUE)

# The bundled geojson stores names as they appear in the source boundary
# file (older spellings). We display the current official English spellings
# in the UI and map them back internally so the join always works.
division_lookup <- data.frame(
  display = c("Barishal", "Chattogram", "Dhaka", "Khulna",
              "Mymensingh", "Rajshahi", "Rangpur", "Sylhet"),
  geo_name = c("Barisal", "Chittagong", "Dhaka", "Khulna",
               "Mymensingh", "Rajshahi", "Rangpur", "Sylhet"),
  stringsAsFactors = FALSE
)


# 2. Colour palette helper
palette_choices <- c(
  "Viridis"        = "viridis",
  "Plasma"         = "plasma",
  "Magma"          = "magma",
  "Inferno"        = "inferno",
  "Cividis"        = "cividis",
  "Blues"          = "blues",
  "Greens"         = "greens",
  "Reds"           = "reds",
  "Yellow-Orange-Red" = "yelloworangered",
  "Purples"        = "purples"
)

get_fill_scale <- function(palette, legend_title, low_high = NULL) {
  viridis_opts <- c("viridis", "plasma", "magma", "inferno", "cividis")
  custom_gradients <- list(
    blues            = c("#eff3ff", "#3182bd"),
    greens           = c("#edf8e9", "#238b45"),
    reds             = c("#fee5d9", "#a50f15"),
    yelloworangered  = c("#ffffb2", "#bd0026"),
    purples          = c("#f2f0f7", "#54278f")
  )

  if (palette %in% viridis_opts) {
    scale_fill_viridis_c(
      option = palette,
      name   = legend_title,
      na.value = "grey90",
      guide  = guide_colorbar(barheight = unit(6, "cm"), barwidth = unit(0.5, "cm"))
    )
  } else {
    cols <- custom_gradients[[palette]]
    scale_fill_gradient(
      low = cols[1], high = cols[2],
      name = legend_title,
      na.value = "grey90",
      guide = guide_colorbar(barheight = unit(6, "cm"), barwidth = unit(0.5, "cm"))
    )
  }
}


# 3. UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { background-color: #f7f8fa;
      font-family: 'Times New Roman', Times, serif;}
      .app-title { font-size: 26px; font-weight: 700; margin-bottom: 2px; }
      .app-subtitle { color: #666; margin-bottom: 20px; }
      .well { background-color: #ffffff; border: 1px solid #e3e3e3; border-radius: 10px; }
      #generate { width: 100%; font-weight: 600; }
      .division-input .form-group { margin-bottom: 8px; }
      .plot-panel { background-color: #ffffff; border-radius: 10px; padding: 15px;
                    border: 1px solid #e3e3e3; }
    ")),
    # Press Enter anywhere in an input field to generate the map
    tags$script(HTML("
      $(document).on('keydown', 'input', function(e) {
        if (e.keyCode === 13) {
          e.preventDefault();
          document.getElementById('generate').click();
        }
      });
    "))
  ),

  div(class = "app-title", "Bangladesh Divisional Choropleth Map"),
  div(class = "app-subtitle",
      "Enter the percentage of the coss-tablution of the Division with your target variable."),
  div(class = "app-subtitle",
      "Note: Keep the divisions in the rows and the target variable in the column."),

  sidebarLayout(
    sidebarPanel(
      width = 4,

      h4("1. Division values (%)"),
      div(class = "division-input",
        fluidRow(
          column(6,
            numericInput("val_barishal", "Barishal", value = 45, min = 0, max = 100, step = 0.1),
            numericInput("val_chattogram", "Chattogram", value = 62, min = 0, max = 100, step = 0.1),
            numericInput("val_dhaka", "Dhaka", value = 88, min = 0, max = 100, step = 0.1),
            numericInput("val_khulna", "Khulna", value = 54, min = 0, max = 100, step = 0.1)
          ),
          column(6,
            numericInput("val_mymensingh", "Mymensingh", value = 39, min = 0, max = 100, step = 0.1),
            numericInput("val_rajshahi", "Rajshahi", value = 58, min = 0, max = 100, step = 0.1),
            numericInput("val_rangpur", "Rangpur", value = 41, min = 0, max = 100, step = 0.1),
            numericInput("val_sylhet", "Sylhet", value = 47, min = 0, max = 100, step = 0.1)
          )
        )
      ),

      hr(),
      h4("2. Title & Subtitle"),
      textInput("title", "Title", value = "Enter your preferred title here....."),
      textInput("subtitle", "Subtitle", value = "Enter your preferred subtitle here..."),
      textInput("legend_title", "Legend title", value = "Percentage (%)"),
      textAreaInput("caption", "Caption (source, notes)", value = "Source: Sample data", rows = 2),
      textAreaInput("footnote", "Add Footnote", value = "", rows = 2),

      hr(),
      h4("3. Appearance"),
      selectInput("palette", "Colour palette", choices = palette_choices, selected = "reds"),
      checkboxInput("show_labels", "Show division names on map", value = TRUE),
      checkboxInput("show_values", "Show percentage values on map", value = TRUE),
      sliderInput("decimals", "Decimal places for values", min = 0, max = 2, value = 0, step = 1),

      hr(),
      actionButton("generate", "Generate Map", icon = icon("map"), class = "btn-primary"),
      br(), br(),
      downloadButton("download_png", "Download PNG", class = "btn-default", width = "100%")
    ),

    mainPanel(
      width = 8,
      div(class = "plot-panel",
        plotOutput("choropleth", height = "900px")
      )
    )
  ),
  hr(),
  
  div(
    style = "text-align:center; color:gray;",
    HTML("
      <b><i>Bangladesh Divisional Choropleth Map Generator</i></b><br>
      <b><i>Version 1.0</i></b><br>
      Developed by <b>Toukiroj Jaman</b><br>
      <a href='mailto:toukir.jaman778@email.com' title='Send Email'>
      <i class='fa fa-envelope' style='font-size:20px; color:#0072B2;'></i></a>
      <a href='https://github.com/toukir6138' title='Open Github'>
      <i class='fa fa-github' style='font-size:20px; color:#0072B2;'></i></a>
      <a href='https://www.linkedin.com/in/toukir6138/' title='Open Linkedin'>
      <i class='fa fa-linkedin' style='font-size:20px; color:#0072B2;'></i></a>
      <a href='https://orcid.org/0009-0002-9933-7019' title='Open ORCID'>
      <i class='fa-brands fa-orcid' style='font-size:20px; color:#0072B2;'></i></a>
    "),
  )
)


# 4. Server
server <- function(input, output, session) {

  # Build the data whenever Generate is pressed (or Enter key triggers the click)
  map_data <- eventReactive(input$generate, {
    values_df <- data.frame(
      display = c("Barishal", "Chattogram", "Dhaka", "Khulna",
                  "Mymensingh", "Rajshahi", "Rangpur", "Sylhet"),
      value = c(input$val_barishal, input$val_chattogram, input$val_dhaka,
                input$val_khulna, input$val_mymensingh, input$val_rajshahi,
                input$val_rangpur, input$val_sylhet),
      stringsAsFactors = FALSE
    ) %>%
      left_join(division_lookup, by = "display")

    bd_map %>%
      left_join(values_df, by = c("division" = "geo_name"))
  }, ignoreNULL = FALSE)  # ignoreNULL = FALSE lets the map render with defaults on first load

  build_plot <- reactive({
    df <- map_data()

    p <- ggplot(df) +
      geom_sf(aes(fill = value), color = "black", linewidth = 0.4) +
      get_fill_scale(input$palette, input$legend_title) +
      labs(
        title = input$title,
        subtitle = input$subtitle,
        caption = paste(
          Filter(function(x) nzchar(trimws(x)), c(input$caption, input$footnote)),
          collapse = "\n"
        )
      ) +
      theme_void(base_size = 15) +
      theme(
        text = element_text(family = "Times New Roman"),
        plot.title = element_text(face = "bold", size = 20, hjust = 0.5, margin = margin(t =20, b = 5)),
        plot.subtitle = element_text(size = 14, color = "grey5", hjust = 0.5, margin = margin(t =5, b = 15)),
        plot.caption = element_text(size = 9, color = "grey40", hjust = 0.5, margin = margin(t = 12, b=50)),
        legend.position = "right",
        legend.title = element_text(face = "bold")
      )

    if (isTRUE(input$show_labels) || isTRUE(input$show_values)) {
      centroids <- suppressWarnings(st_centroid(df))
      lbl <- if (isTRUE(input$show_labels) && isTRUE(input$show_values)) {
        paste0(centroids$display, "\n", sprintf(paste0("%.", input$decimals, "f%%"), centroids$value))
      } else if (isTRUE(input$show_labels)) {
        centroids$display
      } else {
        sprintf(paste0("%.", input$decimals, "f%%"), centroids$value)
      }
      p <- p + geom_sf_text(data = centroids, aes(label = lbl), size = 3.6, fontface = "bold", color = "black", family = "Times new roman")
    }

    p
  })

  output$choropleth <- renderPlot({
    build_plot()
  })

  output$download_png <- downloadHandler(
    filename = function() paste0("bangladesh_choropleth_", Sys.Date(), ".png"),
    content = function(file) {
      ggsave(file, plot = build_plot(), width = 11, height = 12, dpi = 900, bg = "white")
    }
  )
}

#Running the Shiney App
shinyApp(ui, server)
