# Power BI Built-in Themes
# Color values sourced from Power BI Desktop theme exports and community documentation.
# Some themes use approximated values — export from Power BI Desktop for exact matches.

make_theme <- function(name, dataColors, background = "#FFFFFF", foreground = "#252423",
                       tableAccent = NULL, good = "#1EAB40", neutral = "#D9B300",
                       bad = "#D64550", font = "Segoe UI") {
  if (is.null(tableAccent)) tableAccent <- dataColors[1]
  list(
    name        = name,
    dataColors  = dataColors,
    background  = background,
    foreground  = foreground,
    tableAccent = tableAccent,
    good        = good,
    neutral     = neutral,
    bad         = bad,
    textClasses = list(
      label   = list(fontFace = font,                              fontSize = 9,  color = foreground),
      title   = list(fontFace = paste(font, "Semibold"),           fontSize = 12, color = foreground),
      callout = list(fontFace = paste(font, "Light"),              fontSize = 28, color = foreground),
      header  = list(fontFace = paste(font, "Semibold"),           fontSize = 12, color = foreground)
    )
  )
}

builtin_themes <- list(

  "Default" = make_theme(
    "Default",
    c("#118DFF", "#12239E", "#E66C37", "#6B007B", "#E044A7", "#744EC2", "#D9B300", "#D64550",
      "#197278", "#1AAB40")
  ),

  "Classic" = make_theme(
    "Classic",
    c("#01B8AA", "#374649", "#FD625E", "#F2C80F", "#5F6B6D", "#8AD4EB", "#FE9666", "#A66999",
      "#3599B8", "#DFBFBF"),
    foreground = "#000000"
  ),

  "Highrise" = make_theme(
    "Highrise",
    c("#4E5B6F", "#ED4A5A", "#C2AFCF", "#FF8C00", "#8CADCE", "#E5B36C", "#A5CFE5", "#6B6B6B",
      "#D69EAB", "#C3D9E0"),
    foreground = "#4E5B6F"
  ),

  "Executive" = make_theme(
    "Executive",
    c("#643B2E", "#C4652D", "#DE9B35", "#896C4B", "#6A503A", "#C7A07C", "#D5A95D", "#8B6D47",
      "#A07C5A", "#B09572"),
    foreground = "#643B2E"
  ),

  "Frontier" = make_theme(
    "Frontier",
    c("#A16B56", "#5C8E6B", "#4D6D8E", "#C28E5A", "#7A5A3C", "#88A47C", "#6B8EAA", "#D4A76A",
      "#9C7A5C", "#6B9E84"),
    foreground = "#4D6D8E"
  ),

  "Innovate" = make_theme(
    "Innovate",
    c("#2D72D2", "#29A634", "#D13913", "#D99E0B", "#9179F2", "#00B3A4", "#DB2C6F", "#8F398F",
      "#43BF4D", "#F2B824"),
    foreground = "#1C2127"
  ),

  "Bloom" = make_theme(
    "Bloom",
    c("#E0588E", "#8764B8", "#52C0C4", "#F5A623", "#C05090", "#6B9AC4", "#D97ABA", "#58C29D",
      "#E87B5F", "#AE8CD0"),
    foreground = "#3B3A39"
  ),

  "Tidal" = make_theme(
    "Tidal",
    c("#1B7D8E", "#21A1B3", "#53C1BD", "#78D0BA", "#A0E0CA", "#C5EDDF", "#2D9AA0", "#3EAAAD",
      "#68C5C0", "#90D4CC"),
    foreground = "#1B4E5E"
  ),

  "Temperature" = make_theme(
    "Temperature",
    c("#0B3A5D", "#1D6FA5", "#73B8E2", "#D5E8F4", "#F2D4A7", "#F0A75E", "#E06D33", "#B83218",
      "#7A1B0A", "#A04820"),
    foreground = "#0B3A5D"
  ),

  "Solar" = make_theme(
    "Solar",
    c("#FFC000", "#FF8C00", "#FF6100", "#E84C22", "#C63D1E", "#9E3419", "#FFD34E", "#FFAB40",
      "#FF7F3F", "#ED6A3B"),
    foreground = "#6B3A19"
  ),

  "Divergent" = make_theme(
    "Divergent",
    c("#3C68A8", "#6895D2", "#A0C4E8", "#D3E3F3", "#F5E1D0", "#F0B68E", "#E07D4F", "#C44E27",
      "#8B3215", "#5A8BBD"),
    foreground = "#3C4043"
  ),

  "Storm" = make_theme(
    "Storm",
    c("#346187", "#4E7AA1", "#6A94B8", "#8AAECC", "#ADC8DD", "#C7D8E8", "#5880A2", "#7A9DBD",
      "#9CB8D2", "#B8CDE0"),
    foreground = "#1E3A5F"
  ),

  "City park" = make_theme(
    "City park",
    c("#577846", "#7A9E6E", "#A3C295", "#C2D8B9", "#DFEBD7", "#B0CC9E", "#6E9460", "#8FB082",
      "#C8DCBB", "#94B888"),
    foreground = "#3D5430"
  ),

  "Classroom" = make_theme(
    "Classroom",
    c("#A93B3B", "#D36B4B", "#F2A154", "#E8D26C", "#7EB05B", "#4A8C7F", "#3B7BA4", "#5858A6",
      "#7E4E8C", "#C05A5A"),
    foreground = "#3B3A39"
  ),

  "Color-blind safe" = make_theme(
    "Color-blind safe",
    c("#074650", "#009292", "#FE6DB6", "#FEB5DA", "#480091", "#B66DFF", "#B5DAFE", "#6DB6FF",
      "#914800", "#23FD23"),
    foreground = "#074650"
  ),

  "Electric" = make_theme(
    "Electric",
    c("#4A00E0", "#8E2DE2", "#00D2FF", "#3A7BD5", "#FC00FF", "#7B68EE", "#00BFFF", "#A855F7",
      "#6366F1", "#EC4899"),
    foreground = "#1A1A2E"
  ),

  "High contrast" = make_theme(
    "High contrast",
    c("#01B8AA", "#374649", "#FD625E", "#F2C80F", "#5F6B6D", "#8AD4EB", "#FE9666", "#A66999",
      "#3599B8", "#DFBFBF"),
    background = "#000000",
    foreground = "#FFFFFF",
    tableAccent = "#01B8AA"
  ),

  "Sunset" = make_theme(
    "Sunset",
    c("#C34A6E", "#E07050", "#F5A623", "#F7CC5A", "#9B3E6B", "#D96A4B", "#E89040", "#F2B854",
      "#A84870", "#D68060"),
    foreground = "#5C2D3E"
  ),

  "Twilight" = make_theme(
    "Twilight",
    c("#2B5876", "#4E4376", "#7B6BA4", "#3C6E8E", "#5A4B8A", "#9486BB", "#4A7A9E", "#6B5EA0",
      "#A89CC8", "#3E7090"),
    foreground = "#2B2B3D"
  ),

  "Accessible default" = make_theme(
    "Accessible default",
    c("#1170AA", "#FC7D0B", "#A3ACB9", "#57606C", "#5FA2CE", "#C85200", "#7B848F", "#A3CCE9",
      "#E57A00", "#8595A8")
  ),

  "Accessible city park" = make_theme(
    "Accessible city park",
    c("#1B7837", "#5AAE61", "#A6DBA0", "#D9F0D3", "#E7D4E8", "#C2A5CF", "#9970AB", "#762A83",
      "#4D9221", "#B8E186"),
    foreground = "#1B4332"
  ),

  "Accessible tidal" = make_theme(
    "Accessible tidal",
    c("#1B7D8E", "#21A1B3", "#53C1BD", "#78D0BA", "#A0E0CA", "#C5EDDF", "#2D9AA0", "#3EAAAD",
      "#68C5C0", "#90D4CC"),
    foreground = "#1B4E5E"
  ),

  "Accessible neutral" = make_theme(
    "Accessible neutral",
    c("#4E79A7", "#F28E2B", "#E15759", "#76B7B2", "#59A14F", "#EDC948", "#B07AA1", "#FF9DA7",
      "#9C755F", "#BAB0AC"),
    foreground = "#333333"
  ),

  "Accessible orchid" = make_theme(
    "Accessible orchid",
    c("#7B2D8E", "#A050B0", "#C87DD6", "#DBA3E2", "#EDCAF0", "#9440A8", "#B268C4", "#D598DD",
      "#E5B8EB", "#8838A0"),
    foreground = "#3D1650"
  )
)
