SVSS - SVSS's Vim Style Sheet
=============================
Are you a good friends with CSS or SCSS?
SVSS is a style sheet for Vim. You can easily create your own color scheme with SCSS-like syntax. For example:

```
    $base-hue: 240;
    Normal {
        guibg: hsl($base-hue, 0, 0);
        guifg: hsl($base-hue, 100%, 50%);
    }
```

It will be compiled as the following command:

```vim
    hi! Normal guibg=#000000 guifg=#0000ff
```

SVSS provides various useful features to create a color scheme.
See `doc/svss.text` for full features.


License
-------
MIT License. See `LICENSE.txt` for more information.
