# poem.exe

**poem.exe** is a creative coding project that generates tiny haiku-like poems.

It started as a Twitter bot in 2014. As of 2026, it runs in the following places:

- [app.poemexe.com](https://app.poemexe.com/) – Generate poems in your browser.
- [@quasihaiku@oulipo.social](https://oulipo.social/@quasihaiku) – Follow on Mastodon to see a new poem in your feed every 4–5 hours. This account runs on a server which enforces a creative constraint: poems cannot use the letter *e*.

This project does not use generative AI or LLMs (though maybe you could call it a tiny language model).

## Code

The `example` directory contains text files with poems and word lists.

`bin/build-model` compiles the text files into a model file (`model.jsonz`).

The `lib` directory contains a Ruby library which reads the model file and generates poems.

## Process

Poems are generated using a process inspired by the [Queneau Assembly](https://www.crummy.com/nb/nycb/2011/08/queneau-assembly) technique. The generator essentially takes the first, second and third lines from three different poems, and combines them to make a new poem. Other rules come into play to keep things interesting.

More info: https://app.poemexe.com/faq/
