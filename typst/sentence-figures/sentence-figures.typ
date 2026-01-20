// sentence-figures.typ

// ---------------- Document-level toggles ----------------
#let _item_debug = state("utils-item-debug", false)
#let _item_center = state("utils-item-center-marker", false)
#let _item_spacing = state("utils-item-spacing", auto)

#let item-debug(on: true) = _item_debug.update(on)
#let item-center-marker(on: true) = _item_center.update(on)
#let item-spacing(value: auto) = _item_spacing.update(value)


// ---------------- Scoped styling wrapper (recommended) ----------------
#let item-rules(doc) = {
  show figure.where(kind: "item"): it => context {
    let dbg = _item_debug.get()
    let center = _item_center.get()
    let sp = _item_spacing.get()

    let shown = it.counter.display(it.numbering)
    let real = it.counter.display("1")

    let dbg_frag = if dbg { [#h(0.35em)#text(size: 0.8em)[·#real]] } else { [] }
    let marker_valign = if center { horizon } else { top }

    block(spacing: sp)[
      #grid(
        columns: (auto, 1fr),
        column-gutter: 0.6em,
        align: (start + marker_valign, start + top),
      )[
        (#shown)#dbg_frag
      ][
        #it.body
      ]
    ]
  }

  doc
}


// ---------------- Item macro ----------------
#let item(tag: auto, mark: none, auto-prefix: "item:", body) = context {
  let sel = figure.where(kind: "item")
  let next = counter(sel).get().at(0) + 1

  let numbering = if mark == none { "1" } else { _ => [#mark] }

  let lab = if tag == none { none }
    else if tag == auto { label(auto-prefix + str(next)) }
    else if type(tag) == label { tag }
    else { label(str(tag)) }

  // IMPORTANT FIXES:
  // - outlined: true  -> include in outlines
  // - caption: body   -> outline entries have something to show
  let fig = figure(
    body,
    kind: "item",
    numbering: numbering,
    supplement: none,
    outlined: true,
    caption: body,
  )

  if lab == none { fig } else { [#fig#lab] }
}


// ---------------- List of items ----------------
#let list-items(title: [List of Items], depth: none, indent: auto) = {
  show outline.entry: e => context {
    let loc = e.element.location()

    // Counter values at the referenced element's location:
    let nums = counter(figure.where(kind: "item")).at(loc)

    // Render the element's numbering (handles numeric or custom mark):
    let shown = numbering(e.element.numbering, ..nums)

    link(
      loc,
      e.indented([(#shown)], e.inner())
    )
  }

  outline(
    title: title,
    target: figure.where(kind: "item"),
    depth: depth,
    indent: indent,
  )
}


// ---------------- (Optional) Generic list of figures helper ----------------
#let list-figures(title: [List of Figures], kind: none, depth: none, indent: auto) = outline(
  title: title,
  target: if kind == none { figure } else { figure.where(kind: kind) },
  depth: depth,
  indent: indent,
)



#let _display-page(loc) = {
  let pn = loc.page-numbering()
  if pn == none {
    // No page numbering set -> fall back to physical page index.
    str(loc.page())
  } else {
    numbering(pn, ..counter(page).at(loc))
  }
}


/// Index of item *references* (pages where @item:n appears).
/// - `show-unreferenced`: include items that are never referenced (shows "—").
/// - `page-supplement`: prefix before the page list (set to none for no prefix).
/// - `page-sep`: separator between page numbers.
// ---- helper: display a page number for a location (with fallback) ----
#let _display-page(loc) = {
  let pn = loc.page-numbering()
  if pn == none { str(loc.page()) }
  else { numbering(pn, ..counter(page).at(loc)) }
}

/// Index of item usage:
/// - shows pages where the item is referenced
/// - also includes the page where the item is defined
/// - removes the black table gridlines via `stroke: none`
#let index-item-refs(
  title: [Sentence reference index],
  show-unreferenced: false,   // include items that are never referenced
  include-definition: true,   // also include where the item is defined
  page-prefix: [],
  page-sep: [, ],
) = context {
  let sel = figure.where(kind: "item")
  let items = query(sel).sorted(key: it => counter(sel).at(it.location()).at(0))

  let rows = items.map(it => {
    let defloc = it.location()
    let marker = numbering(it.numbering, ..counter(sel).at(defloc))

    // If the item has no label, it cannot be referenced via @... .
    let lab = if it.has("label") and it.label != none { it.label } else { none }
    let refs = if lab == none { () } else { query(ref.where(target: lab)) }

    if not show-unreferenced and refs.len() == 0 {
      // skip
      ()
    } else {
      // Build page entries: references first (prio 0), definition second (prio 1).
      let ref_pages = refs.map(r => {
        let loc = r.location()
        (phys: loc.page(), prio: 0, loc: loc, disp: _display-page(loc))
      })

      let def_pages = if include-definition {
          ((phys: defloc.page(), prio: 1, loc: defloc, disp: _display-page(defloc)),)
        } else { () }

      // Sort and dedup by physical page; keep the reference location if both exist on same page.
      let pages = (..ref_pages, ..def_pages)
          .sorted(key: p => (p.phys, p.prio))
          .dedup(key: p => p.phys)

      let page_links = pages.map(p => link(p.loc, [#p.disp]))
      let pages_cell = if pages.len() == 0 { [—] }
        else if page-prefix == none { page_links.join(page-sep) }
        else { [#page-prefix~#page_links.join(page-sep)] }

      (
        // marker and text link to definition
        [#link(defloc, [(#marker)])],
        [#link(defloc, [#it.body])],
        pages_cell,
      )
    }
  }).flatten()

  if title != none { heading(outlined: false)[#title] }

  table(
    stroke: none,                // <-- removes the black outlines
    columns: (auto, 1fr, auto),
    column-gutter: 0.8em,
    row-gutter: 0.25em,
    ..rows,
  )
}
