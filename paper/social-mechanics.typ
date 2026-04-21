#set document(title: "Social Mechanics", author: "Chandler")
#set page(margin: 1in, numbering: "1")
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1")

#align(center)[
  #text(size: 20pt, weight: "bold")[Social Mechanics]
  #v(4pt)
  #text(size: 14pt, style: "italic")[A Mathematical Approach]
  #v(8pt)
  #text(size: 11pt)[chandler\@mnty.sh]
  #v(8pt)
]

#v(8pt)

*Abstract.* Recently, all of my friends broke up. These breakups were not trivial cases; one relationship had a duration of over a year and a half, and another was over four years total. All breakups happened within the span of a single week. In an attempt to find an explanation, we introduce Social Mechanics, a framework for the description and prediction of social phenomena.

#v(12pt)

#columns(2)[

= Social Circles

Contrary to geometric intuition, we choose to model a social circle as a graph:

- *Nodes* represent individuals.
- *Edges* represent how "close" (emotionally and geometrically) two individuals are. This value is a computed scalar referred to as a PAIR Score.

== Interaction Time

To compute the PAIR Score for two nodes, we need to know the corresponding value for _interaction time_ $tau(i,j)$: the average number of hours per day that individuals $i$ and $j$ spend interacting. This quantity has several desirable properties:

- *Measurable.* Unlike subjective, non-rigorous assessments of human closeness or affection, interaction time is a quantifiable observable that is easier for clankers to work with.
- *Symmetric.* If $i$ and $j$ play video games for one hour together, both have spent one hour wisely, despite what their parents may say. Thus $tau(i,j) = tau(j,i)$.
- *Bounded.* Time flies when you're having fun, but unfortunately we all have jobs, so $0 <= tau(i,j) <= 24$ for all pairs.

The full set of pairwise interaction times across a population defines the _interaction matrix_ $bold(T)$, where $T_(i j) = tau(i,j)$.

To build intuition, we can consider some representative values:

#align(center)[
  #table(
    columns: 2,
    align: (left, right),
    stroke: none,
    table.header(
      [*Relationship*], [*$tau$ (hrs\/day)*],
    ),
    table.hline(),
    [Live-in partner], [8],
    [Coworker], [2],
    [Regular friend], [0.5],
    [Casual acquaintance], [0.05],
    [Weird uncle], [0.01],
    [Your friend after they start dating someone], [0.001],
  )
]

== The PAIR Score

Interaction time alone is not ideal as a distance metric. To accurately represent relationships between nodes in a geometric way, we choose to combine interaction time with division by a constant and adjust using a logarithmic scale.#footnote[Despite the straightforward motivation for the equation, there continues to exist a small subset of the population that fails to understand the circumstantial necessity of social distancing.]

#colbreak()
We can now define the *PAIR Score* (Pairwise Adjacency Interaction Rating) as:

$ "PAIR"(i,j) = -ln(tau(i,j) / 24) $

The denominator --- 24 hours in a day --- is a universal physical constant that normalizes the ratio into $[0, 1]$ before applying the logarithm. This yields a non-negative score where lower values indicate closer relationships.

This equation has applications beyond computing scores for relationships between individuals. Consider a possible table of values for someone who works from home:

#align(center)[
  #table(
    columns: 3,
    align: (left, right, right),
    stroke: none,
    table.header(
      [*Relationship*], [*$tau$ (hrs\/day)*], [*PAIR Score*],
    ),
    table.hline(),
    [Office chair], [8], [1.10],
    [Teammate], [3], [2.08],
    [Manager], [1], [3.18],
    ["Can you guys hear me"], [0.5], [3.87],
    [Leadership], [0.01], [7.78],
    [A sense of purpose], [0.001], [10.09],
  )
]

The PAIR Score has the following properties:

- *Symmetric.* Since $tau(i,j) = tau(j,i)$, we have $"PAIR"(i,j) = "PAIR"(j,i)$.
- *Non-negative.* Since $tau(i,j) <= 24$, the ratio $tau\/24 <= 1$, and $-ln(x) >= 0$ for $x in (0, 1]$.
- *Self-score is zero.* $"PAIR"(i,i) = -ln(24\/24) = 0$, reflecting the trivial and unfortunate fact that you spend all of your time with yourself.

The choice of the natural logarithm is not essential --- any logarithmic base produces an equivalent metric up to a constant factor. We use $ln$ because I felt like it.

= Friend Group Theory

The established structure allows us to describe relationships between individuals at a certain point in time. However, as we know from the abstract, change is inevitable; relationships form, strengthen, weaken, and end. To describe this, we need a theory with dynamics, describing how the graph evolves over time.

== Forces

We introduce two matrices that govern how the interaction time between individuals changes.

The first matrix encodes "attraction" forces. The entry $A_(i j)$ represents how much node $i$ yearns to interact with node $j$. This matrix is not symmetric ($A_(i j) eq.not A_(j i)$ in general, as your crush would tell you), not sparse, and bounded in $[0, 1]$. This is the *Attention Matrix* $bold(A)$.#footnote[If the outgoing values for a certain individual exhibit rapid fluctuations (indicating a frequent change in interest from one node to another, as might be typical of a teenager), then we may colloquially refer to this as just a phase space.]

The second matrix encodes "repelling" forces. The entry $R_(i j)$ represents how much node $i$ is annoyed by node $j$ leaving dishes in the sink, among other indiscretions. It shares the same structural properties as $bold(A)$, and we refer to this object $bold(R)$ as the *I-Need* space.

Together, these define the *Situationship* $sigma_(i j) = A_(i j) - R_(i j)$, which, at any given point in time, can be positive (pulling together) or negative (pushing apart).

The combination of a node's outgoing preferences $(A_(i ast), R_(i ast))$ and the incoming perceptions of others $(A_(ast i), R_(ast i))$ defines a separate object we refer to as the node's *Personal Space*. This is a fun name for a variable we will not use again.

]

#pagebreak()

#columns(2)[
== Time Allocation

Each node has a finite _social meter_ $S$: an upper bound on total interaction time per day. Given the Situationship $sigma_(i j)$, each node allocates their available time via a softmax distribution, as all normal humans do:

$ hat(tau)_i (j) = S dot (e^(beta sigma_(i j))) / (sum_k e^(beta sigma_(i k))) $

The parameter $beta$ controls how sharply preferences translate into time allocation. At low $beta$, time is distributed roughly uniformly. At high $beta$, time concentrates on the highest attention (seeking) connections.

Since interaction requires both parties, the actual interaction time is the bilateral minimum:

$ tau(i,j) = min(hat(tau)_i (j), thin hat(tau)_j (i)) $

The less enthusiastic party is the bottleneck. A finite social meter creates competition: increasing interaction time with one person reduces time available for others (hence why you haven't seen your newly-coupled friend from earlier in, like, 3 months).

== Evolution

Forces evolve in response to the interactions they produce, creating feedback loops.

*Attention* grows quadratically with interaction time:

$ Delta A_(i j) = gamma_A dot tau(i,j)^2 dot (1 - A_(i j)) - delta dot A_(i j) + eta_A $

The quadratic dependence on $tau$ creates a critical threshold $tau^ast = sqrt(delta \/ gamma_A)$. Below $tau^ast$, decay dominates and attention erodes. Above it, growth dominates and attention strengthens. This produces _bistability_: relationships tend toward one of two equilibria --- high $A$ with high $tau$, or low $A$ with low $tau$.

*Values in I-Need space* compound with existing values. We define the _excess interaction fraction_ as:

$ epsilon_(i j) = max(0, thin tau(i,j)\/S - r_0) $

$R$ grows only when $epsilon > 0$ --- that is, when the relationship consumes more than a threshold fraction $r_0$ of the social meter:

$ Delta R_(i j) = gamma_R dot (1 + alpha_R dot R_(i j)) dot epsilon_(i j) - delta dot R_(i j) + eta_R $

The $(1 + alpha_R R)$ factor means that existing I-Need values accelerate further growth. Both $A$ and $R$ decay at the same universal rate $delta$ in the absence of reinforcement. The noise terms $eta_A$ and $eta_R$ represent day-to-day variance. This is fine.

== Simulation

In order to explore the potential emergent behaviors of our model, we need to provide a starting configuration and apply our dynamics equations to examine how our system evolves over time.

To do this, we select a friend group with eight members --- Alice, Bob, Carol, Dan, Eve, Frank, Grace, and Hiro --- and simulate their relationships over a period of two years.

*Day 0.*
At the start, Alice and Bob are a couple ($tau approx 9.5$), as are Carol and Dan ($tau approx 8.9$). The remaining connections are friendships and acquaintances, with interaction times well below the bistability threshold.

*Day 116.* Both couples collapse within the same week (the model is looking very promising so far). From Alice's perspective, Bob drops from her closest connection (PAIR $approx 1.1$) to a distant one (PAIR $approx 4.3$). The freed time is reallocated: within days, Alice--Eve strengthens into Alice's primary relationship ($tau approx 9.7$ by Day 200). Bob, similarly unmoored, redirects toward Dan ($tau approx 9.1$ by Day 200). In a short period, the graph has reorganized.#footnote[Here we can observe an interesting emergent property of this system: oftentimes "major" events (like breakups or new relationships) can cause bursts of rapid restructuring in the graph. We can refer to one of these events as a *Transient Effect Activation*, or "tea".]

From Bob's perspective at Day 200, Alice has moved from his innermost ring to his outer periphery (he still follows her on Instagram). Dan, previously a moderate friend, is now his closest connection. The same set of events looks entirely different depending on whose perspective you examine from.

*Day 250--300.* A secondary restructuring. Alice--Eve weakens and ends. Alice--Bob reforms ($tau approx 10.7$ by Day 300, probably because people keep writing papers about them). Carol--Dan also decide to give it another try. The graph has not settled --- it is cycling through configurations as accumulated annoyance builds and decays in each new arrangement.

*Day 419.* Alice--Bob ends for the second time. Eve rolls her eyes. Alice's social budget shifts again, this time toward Grace ($tau approx 11.4$ by Day 500). Bob starts joining Xbox parties with Dan again.

*Day 550--640.* Eve--Frank realize they were meant for each other. Carol--Dan collapses for the final time.

*Day 700.* Alice is now closest to Carol ($tau approx 10.3$, PAIR $approx 0.85$). Bob is a peripheral connection at PAIR $approx 4.6$. The graph bears little resemblance to its initial state. They could hardly be blamed; no one told them life was gonna be this way.

= Conclusion

Over these two years, this group experienced multiple episodes of rapid restructuring --- breakups, new relationships, the revival and re-collapse of old connections --- interspersed with periods of relative stability.

One might choose to see these results as discouraging; a sign that true stability is a rarity in a system awash in chaos. On the other hand, we can choose to accept that change -- good, bad, or maybe just different -- is an inevitable part of the lived human experience.

#colbreak()
We can never know ahead of time what the result of bringing someone into our life will be. We can only know the joy of having people to share it with. For now, we have each other.

Love you guys.

-- Chandler
]
