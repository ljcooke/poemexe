poem.exe
========

**poem.exe** is a project that generates tiny haiku-like poems and posts them
on social media.

- [@poem_exe](https://twitter.com/poem_exe) on Twitter (the original);

- [@poem_exe](https://botsin.space/@poem_exe) on Mastodon;

- [@quasihaiku](https://oulipo.social/@quasihaiku) on Mastodon (posts without
  using the letter _e_).

More info:

- <https://liamcooke.com/code/poem-exe/>
- <https://poemexe.com/>

## Code

The `corpus` directory contains text files with poems and word lists, and
Python scripts which compile these files into a `model.json` file.

The `lib` directory contains a Ruby library which reads this `model.json` file
and generates poems using a [Queneau assembly][queneau] process. A poem is
constructed by selecting the first line of a random poem, the second line of
another, and the third line of yet another.

This forms a 1–2–3 structure. Sometimes a different structure is used: for
example, a 1–2–2–3 structure, in which two middle lines are taken from two
different poems.

[poem_exe]: https://twitter.com/poem_exe
[queneau]: http://www.crummy.com/2011/08/18/0
