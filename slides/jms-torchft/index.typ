// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}


// This is an example typst template (based on the default template that ships
// with Quarto). It defines a typst function named 'article' which provides
// various customization options. This function is called from the 
// 'typst-show.typ' file (which maps Pandoc metadata function arguments)
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-show.typ' entirely. You can find 
// documentation on creating typst templates and some examples here: 
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  resume: none,
  cols: 1,
  margin: (x: 25mm, y: 25mm),
  paper: "a4",
  header: (),
  footer: none,
  lang: "fr",
  region: "FR",
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  keywords: (),
  domains: (),
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: "1.1.1",
  pagenumbering: "1",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
    background: none,
    footer: context {
      let page-number = counter(page).get().first()
      set text(size: 0.9em)

      // sur les pages paires (pages de gauche),
      // on affiche le numéro de page avant le pied de page
      if calc.even(page-number){
        [#counter(page).display("1")]
      }
      
      text(size: 0.9em)[#h(1fr) #footer #h(1fr)]
      
      // sur les pages impaires (pages de droite),
      // on affiche le numéro de page après le pied de page
      if calc.odd(page-number){
        [#counter(page).display("1")]
      }
    }
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  show heading.where(level: 1): set text(size: 1em)
  show heading.where(level: 2): set text(size: 1.1em)
  show heading.where(level: 3): set text(size: 1em)
  show footnote: set text(size: 1.2em) // taille de l'appel de note dans le corps du texte
  set footnote.entry(indent: 0em) // indentation dans la note de bas de page
  // modifie les tailles dans la note de bas de page
  show footnote.entry: it => {
    let loc = it.note.location()
    // taille de l'appel de note
    text(size: 1.2em)[#super[#numbering(
      "1",
      ..counter(footnote).at(loc),
    )]]
    // taille du texte
    text(size: 0.8em)[#it.note.body]
  }

  if header.len() > 0 {
    align(header.location,  image(header.path, width: header.width, alt: header.alt))
  }
  
  if title != none {
    align(center)[#block(inset: 1em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color, hyphenate: false)
        text(size: title-size)[#smallcaps[#title]]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#smallcaps[#title]]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    let count = authors.len()
    // crée des étoiles pour référencer les auteurs, exemple : (**)
    let authors = authors.enumerate(start: 1).map(it => {
        let (position, author) = it
        let stars = "(" + range(position).map(it => "*").join() + ")"
        author.insert("stars", stars)
        author
      })

    emph(align(center)[
      #set text(size: 1.1em, hyphenate: false)
      #authors.map(author => {
        let (name, stars, ) = author
        name + " " + stars
      }).join(", ") \ 
      
      #for author in authors {
        [#author.stars #author.affiliation \ ]
      }
      
      #authors.map(author => {
        let (email, ) = author
        email
      }).join(" ")
    ])
  }

  let capitalize(text) = upper(text.first()) + text.clusters().slice(1).join()
  let capitalize-first-word(arr) = {
    let capitalized-first-word = capitalize(arr.remove(1))
    arr.insert(0, capitalized-first-word)
    arr
  }

    if keywords.len() > 0 {
    block[
      #set par(justify: false)
      #set text(size: 1.1em)
      #strong[Mots-clés] : #if type(keywords) == array {
        capitalize-first-word(keywords).join(", ")
      } else {
        capitalize(keywords)
      }
    ]
  }

  if domains.len() > 0 {
    block[
      #set par(justify: false)
      #set text(size: 1.1em)
      #strong[Domaines] : #if type(domains) == array {
        capitalize-first-word(domains).join(", ")
      } else {
        capitalize(domains)
      }
    ]
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if resume != none {
    block[
      #text(weight: "semibold", size: 1.2em)[Résumé] \ 
      #emph(resume)
    ]
  }

  if abstract != none {
    block[
      #text(weight: "semibold", size: 1.2em)[#abstract-title] \ 
      #emph(abstract)
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }
  
  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
)
#set page(background: align(center+top, box(inset: 0.75in, image("../../slides/_extensions/InseeFrLab/jms2025/head_jms2025.png", width: 160mm))))


// Typst custom formats typically consist of a 'typst-template.typ' (which is
// the source code for a typst template) and a 'typst-show.typ' which calls the
// template's function (forwarding Pandoc metadata values as required)
//
// This is an example 'typst-show.typ' file (based on the default template  
// that ships with Quarto). It calls the typst function named 'article' which 
// is defined in the 'typst-template.typ' file. 
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-template.typ' entirely. You can find
// documentation on creating typst templates here and some examples here:
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

#show: doc => article(
  title: [Échantillonnage optimum sous contraintes fortes],
  authors: (
    ( name: [Antoine DUPONT],
      affiliation: [Insee, Direction de la méthodologie et de la coordination statistique et internationale],
      email: [#link("mailto:antoine.dupont@insee.fr")[antoine.dupont\@insee.fr];] ),
    ( name: [Alii],
      affiliation: [Insee, Département de la Démographie],
      email: [] ),
    ),
  keywords: ("échantillonnage", "calage", "collecte", "équilibrage", "multimode", "séries temporelles"),
  domains: ("enquêtes", "sondages"),
  abstract: [(Texte en anglais de 5 à 10 lignes) \
#lorem(30)

],
  abstract-title: "Abstract",
  resume: [(entre 350 et 900 mots environ) \
#lorem(30)

],
  header: (path: "../../slides/_extensions/InseeFrLab/jms2025/head_jms2025.png", width: 160mm, alt: none, location: center+top),
  footer: [15#super[e] édition des journées de méthodologie statistique de l'Insee (JMS 2025)],
  font: ("tex gyre heros",),
  heading-family: ("tex gyre heros",),
  sectionnumbering: "1.1.1.",
  pagenumbering: "1",
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)

= Titre de niveau 1 numéroté
<titre-de-niveau-1-numéroté>
Cet article reprend et enrichit une problématique déjà présentée aux JMS 2000. Il s'agit de constituer, au sein d'une population de référence, des classes présentant des conditions d'homogénéité ou d'hétérogénéité maximales vis-à-vis de certaines caractéristiques quantitatives.

Le projet Nautile va se substituer au projet Octopusse~: mais la filiation est claire. Il est possible en fait de généraliser cette notion d'inertie en introduisant une pseudo-distance entre les unités de la population de référence, non nécessairement euclidienne, et non nécessairement nulle lorsqu'on mesure la distance d'une unité à elle-même. Sous réserve de donner des poids à chaque unité de la population, l'inertie d'une classe K sera donnée par~:

$ I (K) = 1 / 2 frac(sum_(i in K) sum_(j in K) alpha_i alpha_j d_(i \, j)^2, sum_(i in K) alpha_i) $

Cette formule redonne l'expression de la variance de la classe lorsque la distance considérée $d_(i \, j)$ est euclidienne.

Dans le second groupe d'exemples, on cherchera à appliquer ces techniques à des cas non euclidiens, par exemple en comparant département de naissance et département de résidence.

Une référence à la bibliographie @elstonlatafa1994.

== Titre de niveau 2 numéroté
<titre-de-niveau-2-numéroté>
#lorem(100)
\

Un exemple de note de bas de page#footnote[«~Un algorithme de regroupement d'unités statistiques selon certains critères de similitude~», Marc CHRISTINE et Michel ISNARD, VIIèmes Journées de Méthodologie statistique, 4-5 décembre 2000.]

=== Titre de niveau 3 numéroté
<titre-de-niveau-3-numéroté>
#lorem(40)
\

Une autre référence à la bibliographie @eratosthene.

#bibliography("references.bib")

