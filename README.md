# An experiment (failed so far) at avoiding unnecessary Haskell recompilation in nix-build

One weakness of using `nix-build` for your Haskell project's CI is that the project is fully recompiled for every change. That is: builds are not incremental and do not reuse previous builds' results.

There have been a number of attempts to this problem:

- [snack](https://github.com/nmattia/snack)
- "recursive Nix" (in the future?)
- ...

I thought of trying the dumbest thing that could possibly work: what if `haskellPackages.mkDerivation` emitted Cabal's `dist` and `dist-newstyle` directories as secondary outputs, and also allowed you to depend on these outputs, so that the build could begin with a prepopulated cache?

(Admittedly, if it worked, this solution would be highly stateful and require some annoying bookkeeping. But let's leave that concern aside and focus on if it can be made to work.)

I have [forked Nixpkgs](https://github.com/danidiaz/nixpkgs) and, in the [`haskell_avoid_recomp_experiment`](https://github.com/danidiaz/nixpkgs/tree/haskell_avoid_recomp_experiment) branch, I made [this commit](https://github.com/danidiaz/nixpkgs/commit/73801a39f303a4d59394a09b8adda49a52bd832c) which adds a new function [`mkDerivationSpecial`](https://github.com/danidiaz/nixpkgs/blob/73801a39f303a4d59394a09b8adda49a52bd832c/pkgs/development/haskell-modules/make-package-set.nix#L99) to `haskellPackages`.

`mkDerivationSpecial` differs from the usual `mkDerivation` in having four new arguments (all of them optional):

- `enableSeparateDistOutput` Boolean. If `true`, emit the `dist` folder as a derivation output. Default `false`.
- `enableSeparateDistNewstyleOutput` Boolean. If `true`, emit the `dist-newstyle` folder as a derivation output. Default `false`.
- `preexistingDist` A derivation. If not null, use this derivation as a preexisting `dist` folder. Default `null`.
- `preexistingDistNewstyle` A derivation. If not null, use this derivation as a preexisting `dist-newstyle` folder. Default `null`.

## What about this repo?

This repo exists to test if this approach works. It constains a very simple Cabal project, along with some Nix code to build it.

You should edit the `default.nix` file and point it to a clone of the above mentioned fork of Nixpkgs (branch `haskell_avoid_recomp_experiment`).

If you look at the derivation in the `myderivation.nix` file, you'll see that it uses `mkDerivationSpecial`.

We can build it (including the outputs for `dist` and `dist-newstyle`) like this:

    $ nix-build --no-out-link -A all
	/nix/store/ks9i6640sxymv4iknra1bgr5v23nhqmr-foo-1.0.0.0
	/nix/store/5kcg8rpp2wqbz0ml5pqigpl518cn5hsk-foo-1.0.0.0-doc
	/nix/store/9s8qjkk5hn9zv5wkn8905wl8ialdqjwi-foo-1.0.0.0-dist
	/nix/store/fc0giacchzdnhk61i34ha0idpxga3lyy-foo-1.0.0.0-distNewstyle

Now, try the following: edit `myderivation.nix`, uncomment the `preexistingDist` and `preexistingDistNewstyle` parameters, and make them point to the `dist` and `distNewstyle` generated in the previous `nix-build` invocation. Then invoke `nix-build --no-out-link -A all` again.

What should happen:

- `Main.hs` should *not* be recompiled.

What actually happens, alas:

- `Main.hs` is recompiled.

I don't know why recompilation happens anyway. Perhaps Nix mangles the contents of the directories in some way? Maybe, but if I copy the `dist` and `distNewstyle` derivations to the local project as `dist` and `dist-newstyle`, and compile using `cabal build`, there is no recompilation! Why do we recompile in the Nix build, then? 🤔.

