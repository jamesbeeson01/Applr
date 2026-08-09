# Wrapping the geom_slice_subtitle() / geom_slice_caption() text to the width
# of the plot it describes.
#
# A model equation is long: `Sepal.Length ~ Sepal.Width * Species +
# Petal.Length` writes out to 14 inches of text at 11pt, and an 8-inch plot
# has under 7 inches of room for a subtitle. Left alone it runs off the page.
#
# Three things make this harder than calling strwrap():
#
#   1. Character counts are not widths. "iiii" and "MMMM" are both four
#      characters and differ threefold, so a character-count wrap breaks in
#      the wrong place and leaves the line either short or overflowing. Every
#      width here is measured with grid, in inches (annotation_width()).
#   2. An equation must not break just anywhere. "- " orphaned at the end of a
#      line, with its coefficient on the next, misreads as a minus sign that
#      is not there. Lines break between terms only (annotation_line_parts()).
#   3. Continuation lines have to hang under the right-hand side of the equal
#      sign, or the equation stops reading as an equation. The indent is a
#      measured width, and the run of spaces that produces it is assembled to
#      match that width rather than counted out (pad_run()).
#
# Why the wrap is computed here, when the annotation is added, and not when
# the plot is drawn: the width a subtitle gets is the width of its cell in the
# finished gtable, which is the device width minus the axis, the legend, and
# the margins. Resolving that at draw time means a custom grob whose height
# must be reserved before its width is known — grid asks for the height in the
# whole table's viewport and only later draws in the narrower cell, so the
# height comes out short and the subtitle collides with the panel. Measuring
# the built gtable now sidesteps that entirely: the result is an ordinary
# multi-line string, and ggplot2 sizes multi-line strings correctly by itself.
# The cost is that the wrap is fixed to the device open at the time — see the
# `wrap` argument of geom_slice_subtitle() for pinning it to a chosen width.


# Font metrics need a device, but measuring on the current one would start a
# page on it — a blank leading image in a png() sequence, or the user's
# graphics window opening as a side effect of `+`. So all measuring happens on
# an off-screen pdf() sized like the real device, whose width `npc` and null
# units then resolve against (as label_width_pt() does for slice labels).
with_measuring_device <- function(expr) {
  # dev.size() would open the default device when there is none — the very
  # side effect this is avoiding. dev.cur() is 1 for the null device and opens
  # nothing, so ask it first and fall back to R's own default size.
  old <- grDevices::dev.cur()
  size <- if (old > 1L) grDevices::dev.size("in") else c(7, 7)
  grDevices::pdf(NULL, width = size[1], height = size[2])
  on.exit({
    grDevices::dev.off()
    if (old != 1L) grDevices::dev.set(old)
  }, add = TRUE)
  force(expr)
}

# Width of each string in inches, as drawn in `gp`.
annotation_width <- function(strings, gp) {
  vapply(strings, function(s) {
    if (!nzchar(s)) return(0)
    grid::convertWidth(grid::grobWidth(grid::textGrob(s, gp = gp)), "in",
                       valueOnly = TRUE)
  }, numeric(1), USE.NAMES = FALSE)
}

# The gp the theme will draw this annotation with, plus the hjust that decides
# whether a hanging indent even makes sense (it does not for a right-aligned
# caption).
annotation_style <- function(plot, element) {
  theme <- tryCatch(ggplot2::complete_theme(plot$theme),
                    error = function(e) ggplot2::theme_get())
  el <- tryCatch(ggplot2::calc_element(paste0("plot.", element), theme),
                 error = function(e) NULL)
  list(
    gp = grid::gpar(fontsize = el$size %||% 11,
                    fontfamily = el$family %||% "",
                    fontface = el$face %||% "plain"),
    hjust = el$hjust %||% 0
  )
}

# Inches of room the annotation actually gets: the width of its cell in the
# finished gtable. Every column width there is fixed except the panels, which
# split what is left over — the same arithmetic gtable does when it draws.
# NA when the plot cannot be built or has no such cell, which turns wrapping
# off rather than guessing.
annotation_avail_width <- function(plot, element) {
  tryCatch({
    placeholder <- if (element == "caption") ggplot2::labs(caption = "x")
                   else ggplot2::labs(subtitle = "x")
    g <- suppressMessages(suppressWarnings(
      ggplot2::ggplotGrob(plot + placeholder)))
    i <- which(g$layout$name == element)
    if (length(i) != 1) return(NA_real_)

    widths <- g$widths
    type <- grid::unitType(widths)
    total <- grid::convertWidth(grid::unit(1, "npc"), "in", valueOnly = TRUE)
    fixed <- vapply(seq_along(widths), function(k) {
      if (type[k] == "null") 0
      else grid::convertWidth(widths[k], "in", valueOnly = TRUE)
    }, numeric(1))
    nulls <- vapply(seq_along(widths), function(k) {
      if (type[k] == "null") as.numeric(widths[k]) else 0
    }, numeric(1))
    per_null <- if (sum(nulls) > 0) max(0, total - sum(fixed)) / sum(nulls) else 0

    cols <- g$layout$l[i]:g$layout$r[i]
    sum(fixed[cols]) + sum(nulls[cols]) * per_null
  }, error = function(e) NA_real_)
}


# Space glyphs to build an indent from, widest first, keeping only those the
# device draws at a width of their own. A regular space is coarse — a whole
# space of slop at the end of an indent is visible next to an equal sign — and
# the thin and hair spaces land much closer. Fonts that have no separate
# glyphs for them report the width of a plain space instead; those are dropped
# here, so the indent quietly degrades to whole spaces rather than emitting
# characters the device would draw as a missing-glyph box.
pad_glyphs <- function(gp) {
  candidates <- c(" ", " ", " ", " ")
  w <- annotation_width(candidates, gp)
  keep <- w > 0 & !duplicated(round(w, 4))
  list(glyph = candidates[keep], width = w[keep])
}

# A run of spaces as close to `target` inches wide as those glyphs allow:
# greedy, widest first, then one more of the finest glyph when that lands
# nearer than stopping short.
pad_run <- function(target, gp) {
  g <- pad_glyphs(gp)
  ord <- order(g$width, decreasing = TRUE)
  out <- character(0)
  left <- target
  for (k in ord) {
    n <- floor(left / g$width[k])
    if (n > 0) {
      out <- c(out, strrep(g$glyph[k], n))
      left <- left - n * g$width[k]
    }
  }
  finest <- g$width[ord[length(ord)]]
  if (left > finest / 2) out <- c(out, g$glyph[ord[length(ord)]])
  paste(out, collapse = "")
}


# One line split into the prefix that continuation lines hang past, and the
# tokens a break may fall between, covering all three lines the annotation
# writes:
#
#   "y = 1.67 + 0.624*x"            -> "y = "               + terms
#   "held at: x2 = 2.51; g = \"A\"" -> "held at: "          + "x2 = 2.51;" ...
#   "projection band: x2 spanning"  -> "projection band: "  + words
#
# An equal sign wins over a colon when what follows it is an equation, so
# `prepend = "Fitted: "` still hangs the continuation lines under the
# right-hand side rather than under the prepended words. Terms keep their sign
# ("- 0.286*x"), so a break never strands an operator at the end of a line.
annotation_line_parts <- function(line) {
  equals <- regexpr(" = ", line, fixed = TRUE)
  if (equals > 0) {
    rest <- substr(line, equals + 3, nchar(line))
    if (grepl(" [+-] ", rest)) {
      return(list(
        prefix = substr(line, 1, equals + 2),
        tokens = strsplit(gsub(" ([+-]) ", "\v\\1 ", rest), "\v",
                          fixed = TRUE)[[1]]
      ))
    }
  }
  colon <- regexpr(": ", line, fixed = TRUE)
  if (colon < 0) return(list(prefix = "", tokens = strsplit(line, " ")[[1]]))

  rest <- substr(line, colon + 2, nchar(line))
  tokens <- if (grepl("; ", rest, fixed = TRUE)) {
    strsplit(gsub("; ", ";\v", rest, fixed = TRUE), "\v", fixed = TRUE)[[1]]
  } else {
    strsplit(rest, " ", fixed = TRUE)[[1]]
  }
  list(prefix = substr(line, 1, colon + 1), tokens = tokens)
}

# Greedy fill of one line into `avail` inches, hanging the continuations under
# the prefix. A token wider than the whole line goes on a line by itself and
# overflows — there is nowhere else for it to go.
wrap_annotation_line <- function(line, avail, gp, indent = TRUE) {
  if (annotation_width(line, gp) <= avail) return(line)

  parts <- annotation_line_parts(line)
  if (length(parts$tokens) < 2) return(line)
  indent_in <- if (indent) annotation_width(parts$prefix, gp) else 0
  # past half the line the indent costs more room than the alignment is worth
  if (indent_in > avail / 2) indent_in <- 0
  # nor is it worth pushing a term that would otherwise have fit off the plot:
  # a long interaction term can be wider than what the indent leaves behind
  if (indent_in + max(annotation_width(parts$tokens, gp)) > avail) indent_in <- 0

  lines <- character(0)
  current <- paste0(parts$prefix, parts$tokens[1])
  offset <- 0
  for (token in parts$tokens[-1]) {
    candidate <- paste(current, token)
    if (annotation_width(candidate, gp) + offset <= avail) {
      current <- candidate
    } else {
      lines <- c(lines, current)
      current <- token
      offset <- indent_in
    }
  }
  lines <- c(lines, current)

  if (indent_in > 0) {
    pad <- pad_run(indent_in, gp)
    lines <- c(lines[1], paste0(pad, lines[-1]))
  }
  lines
}

# The whole annotation, wrapped. `wrap` is TRUE (measure the plot), FALSE
# (leave the text alone), or a width in inches. Text that already fits comes
# back untouched, so short subtitles keep exactly the string they had.
wrap_annotation_text <- function(text, plot, element, wrap) {
  if (isFALSE(wrap)) return(text)
  with_measuring_device({
    avail <- if (is.numeric(wrap)) wrap else annotation_avail_width(plot, element)
    if (!is.finite(avail) || avail <= 0) return(text)
    style <- annotation_style(plot, element)
    lines <- unlist(lapply(strsplit(text, "\n", fixed = TRUE)[[1]],
                           wrap_annotation_line, avail = avail, gp = style$gp,
                           indent = style$hjust < 0.5))
    paste(lines, collapse = "\n")
  })
}
