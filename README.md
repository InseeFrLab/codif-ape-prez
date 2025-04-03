Run `. setup.sh`in the root folder to start.

When developing, modify `_quarto.yaml` to use:

```yaml
render:
    - /slides/[YOUR NEW PREZ]/*.qmd
    - index.qmd
    - /cards/*.qmd
```

and avoid needing the dependencies for other presentations (especially the language `R`...).