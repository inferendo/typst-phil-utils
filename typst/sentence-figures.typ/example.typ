#import "sentence-figures.typ": item-rules, item, list-items, item-debug, index-item-refs
#import "@preview/codly:1.3.0": *

#show: codly-init.with()
#show: item-rules
/* 

```typ


```

*/

Use ```typ #import "sentence-figures.typ": item-rules, item, list-items, item-debug, index-item-refs``` to import the scripts.

After importing the scripts, apply ```typ #show: item-rules``` to the document.

```typ #item``` is a function that will make a sentence figure item. If no figure mark is given as argument with `(mark: [content])` or `(mark: "string")` then the marker will be its incremental number, here are some examples:

#let examples_basic = ```typ
#item[#lorem(10)]
#item(mark: "TEST")[#lorem(15)]
#item(mark: [$"TEST"_2$])[#lorem(20)]
```


#columns(2)[  
  #examples_basic

  #colbreak()
  #item[#lorem(5)]
  #item(mark: "TEST")[#lorem(10)]
  #item(mark: [$"TEST"_2$])[#lorem(15)]

]

You can apply ```typ #item-debug(on: true)``` at the beginning of the document to show the incremental number of each sentence figure, including those which have custom markers.


#let examples_dbg = ```typ
Pandispositionalism is the view that:
#item-debug(on: true)
#item(mark: "PD")[All sparse fundamental properties are intrinsically powerful, i.e. they are powers.]
#item-debug(on: false)
```

#columns(2)[  
  #examples_dbg

  #colbreak()
  Pandispositionalism is the view that:
  #item-debug(on: true)
  #item(mark: "PD")[All sparse fundamental properties are intrinsically powerful, i.e. they are powers.]
  #item-debug(on: false)
]


Go to the next page to see how to refer to these sentence figures.

#pagebreak()

Sentence figures can be referenced with ```typ @item:n```, where $n$ is the incremental number of the item to refer. 

#align(center)[
  #figure(
    image("def-autocomplete-ex.png"), caption: [when referencing, the Typst web app will show you the sentence figure's content.]
  )
]

When a referenced marker is clicked on, it will bring the viewer to where the sentence figure was produced (try it out yourself).

#let example_refer = ```typ
Since (@item:4) does not have to claim that abundant properties like 'grey or weighing twenty pounds' are also powers, it does not have to claim that all properties are powers. Also the identity theory may be seen as a pandispositionalism, since it takes all properties to be powers.
```

#columns(2)[  
  #example_refer

  #colbreak()
  Since (@item:4) does not have to claim that abundant properties like 'grey or weighing twenty pounds' are also powers, it does not have to claim that all properties are powers. Also the identity theory may be seen as a pandispositionalism, since it takes all properties to be powers.
]

You can also make an index of all sentence figures with ```typ #list-items(title: [title here])```:

#list-items(title: [Index of Sentences])



(@item:4) is from _The metaphysics of powers: their grounding and their manifestations_, edited by Anna Marmodoro.

```typ #index-item-refs(title: [title here])``` will show which figures were used multiple times and at which pages the references occur.
#index-item-refs(title: [Index of Sentence References])