#import("cyr_numbering.typ"): cyrnum
#let is_appendix = state("appendix", false)

#let titlepage(
  body,
  signer_1: none,
  signer_2: none,
  city: "Москва",
  year: auto,
  signer_1_honorifics: none,
  signer_2_honorifics: none,
) = {
  set page(numbering: none)
  align(alignment.center, body)

  let bottom_1 = if signer_1_honorifics != none { signer_1_honorifics }
  let bottom_2 = if signer_2_honorifics != none { signer_2_honorifics }
  if year == auto {
    year = datetime.today().year()
  }

  let city-and-year = [#city#if year != none [, #year]]

  if signer_1 != none and signer_2 != none {
    align(alignment.bottom + alignment.center, [
      #table(
        stroke: none,
        align: (right, center, left),
        columns: (1fr, 1fr, 1fr),
        fill: none,
        bottom_1, repeat("_"), signer_1,
        bottom_2, repeat("_"), signer_2,
      )

      #city-and-year
    ])
  } else if signer_2 != none {
    align(alignment.bottom + alignment.center, [
      #table(
        stroke: none,
        align: (right, center, left),
        columns: (1fr, 1fr, 1fr),
        fill: none,
        bottom_2, repeat("_"), signer_2,
      )

      #city-and-year
    ])
  } else if signer_1 != none {
    align(alignment.bottom + alignment.center, [
      #table(
        stroke: none,
        align: (right, center, left),
        columns: (1fr, 1fr, 1fr),
        fill: none,
        bottom_1, repeat("_"), signer_1,
      )

      #city-and-year
    ])
  }

  pagebreak(weak: true)
}

#let text-settings-inner(body, font-size: 12pt, pagebreaks: auto) = {
  set page(paper: "a4", margin: (top: 20mm, left: 30mm, right: 15mm, bottom: 20mm))
  set text(
    font: "Times New Roman",
    size: font-size,
    lang: "ru",
    hyphenate: false,
    spacing: 100%,
  )
  set par(first-line-indent: (amount: 1.25cm, all: true), justify: true, spacing: 1.5em)

  set align(alignment.left + alignment.top)
  set page(numbering: "1")

  set heading(numbering: "1.1")
  show heading.where(numbering: none): it => {
    align(center, upper(it))
    v(0.5em)
  }
  show heading.where(numbering: cyrnum): set align(center)
  show heading.where(level: 1): it => [
    #if pagebreaks == auto {
      pagebreak(weak: true)
    } else if pagebreaks == true {
      pagebreak()
    } else {
      assert(pagebreaks == none or pagebreaks == false, message: "Pagebreaks must be either auto, or boolean, or none")
    }
    #it
  ]

  show heading: set text(size: font-size)

  let is_appendix = state("appendix", false)

  set bibliography(style: "gost-r-705-2008-numeric", title: "Список использованных источников")
  set outline(indent: 2em)
  show outline.entry: it => {
    show linebreak: [ ]
    if is_appendix.at(it.element.location()) {
      link(it.element.location(), it.indented(none, [Приложение #numbering(cyrnum, ..counter(heading).at(it.element.location())) #it.element.body] + sym.space + box(width: 1fr, it.fill) + sym.space + it.page()))
    } else {
      it
    }
  }

  set math.equation(numbering: "(1)", supplement: none)

  show ref: it => {
    // provide custom reference for equations
    if it.element != none and it.element.func() == math.equation {
      // optional: wrap inside link, so whole label is linked
      link(it.target)[(#it)]
    } else {
      it
    }
  }

  show link.where(body: []): l => {
    let heading-elem = query(l.dest).first()
    link(l.dest, heading-elem.body)
  }

  body
}

#let text-settings(pagebreaks: auto, font-size: 12pt) = {
  let inner(body) = text-settings-inner(body, font-size: font-size, pagebreaks: pagebreaks)
  inner
}

#let appendixes(content) = {
  counter(heading).update(0)
  set heading(supplement: "Приложение", numbering: cyrnum)
  is_appendix.update(true)
  counter(math.equation).update(0)

  show heading: it => {
    if it.numbering != cyrnum {
      it
    } else {
      block[
        #it.supplement #text(counter(heading).display(it.numbering))
        #linebreak()
        #text(it.body)
      ]
    }
  }

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }

  set figure(numbering: it => {
    let current-heading = counter(heading).get().first()

    (numbering(cyrnum, current-heading), numbering("1.1", counter(figure).get())).join(".")
  })

  set math.equation(numbering: it => {
    let current-heading = counter(heading).get().first()

    (numbering(cyrnum, current-heading), numbering("1.1", ..counter(math.equation).get())).join(".")
  })

  content
}
