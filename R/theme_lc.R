#' Theme based off of Lauren Condie's work
#'
#' A custom ggplot2 theme that provides a cohesive, aesthetically pleasing color scheme
#' and styling for statistical graphics. This theme sets both default geom aesthetics
#' and plot theme elements to create a consistent visual style across all plots.
#' The color palette uses warm, earthy tones that work well for academic and professional
#' presentations.
#'
#' @export
#'
#'
theme_lc <- function(){

  # Set default aesthetic values for various geom types
  # These will be applied automatically to all plots using this theme
  # unless explicitly overridden in individual geom calls
  
  # Points: warm gray color that's easy on the eyes
  update_geom_defaults('point', list(color = "#78776C"))
  
  # Smooth lines (like geom_smooth): light brown line with warm fill and transparency
  # The alpha = 0.3 makes confidence bands semi-transparent
  update_geom_defaults('smooth', list(color= '#B7B799', fill = '#D3B593', alpha = 0.3))
  
  # Regular lines: coordinated light brown color
  update_geom_defaults('line', list(color='#B7B799'))
  
  # Line segments: matching color for consistency
  update_geom_defaults('segment', list(color='#B7B799'))
  
  # Horizontal reference lines: same coordinated color
  update_geom_defaults('hline', list(color='#B7B799'))

  # Build the theme by starting with theme_minimal() and modifying specific elements
  # %+replace% ensures our customizations completely replace the defaults
  theme_minimal() %+replace%

  theme(
    # Plot title: warm reddish-brown color that stands out without being harsh
    plot.title = element_text(color = "#B07E63"),
    
    # Axis titles: warm beige color that's readable but not overpowering
    axis.title.y = element_text(color = "#D3B593"),
    axis.title.x = element_text(color = "#D3B593"),
    
    # Major grid lines: very subtle beige lines with thin width
    # These provide structure without overwhelming the data
    panel.grid.major = element_line(color = "#D3B593", linewidth = .06),
    
    # Axis text (tick labels): matching the point color for consistency
    axis.text.x = element_text(color = "#78776C"),
    axis.text.y = element_text(color = "#78776C"),
    
    # Remove minor grid lines entirely for a cleaner look
    panel.grid.minor = element_blank(),
    
    # Mark theme as complete - this prevents inheritance issues
    complete=TRUE
  )
}
