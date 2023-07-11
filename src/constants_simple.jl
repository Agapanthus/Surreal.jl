
const nil = EmptySurrealSet()
const S0 = Surreal(nil, nil)
const S1 = Surreal(S0, nil)
const SM1 = Surreal(nil, S0)


"first countable infinity"
const omega = Surreal(CountedSurrealSet(n_s), nil)