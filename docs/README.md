# Connection troubleshooting guide

End-user help for when the Remote Panel 2 app can't reach the ExtPlane plugin.

| File | What it is |
|---|---|
| `index.html` | The guide. Self-contained — no external CSS, JS, fonts or images |
| `Remote-Panel-2-Connection-Help.pdf` | Same content, 6 pages, for handing out or attaching to a support reply |
| `src/` | What the two files above are generated from |

Published via GitHub Pages at **https://gdevic.github.io/XPlaneRemotePlugin/docs/**

## Rebuilding

Edit `src/connection-help.source.html`, then:

```powershell
powershell -ExecutionPolicy Bypass -File src\build.ps1
```

Both outputs are regenerated. The PDF step uses headless Edge (or Chrome); if neither is
installed the script writes the HTML, warns, and skips the PDF — print it from a browser
instead.

**Do not edit `index.html` directly.** It is generated, and the screenshot is embedded in it
as an ~80 KB base64 data URI, which makes hand-editing impractical. Change the source and
rebuild.

`src/connection-help.source.html` deliberately omits `<!DOCTYPE>`, `<html>`, `<head>` and
`<body>` so it can also be dropped into a host that supplies its own scaffolding. The build
script adds those plus a minimal CSS reset.

## Hosting it elsewhere

`index.html` is a single file with nothing external, so it can be copied anywhere as-is.

On a WordPress site, upload it by FTP or File Manager into a folder under the WordPress root
and link to it directly. Do not use the Media Library — it rejects `.html` uploads by
default, and the usual workaround lets any author upload HTML. A real file is served straight
by Apache and never reaches WordPress, because the stock `.htaccess` only routes to
`index.php` when the request doesn't match an existing file:

```apache
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
```

So there are no permalink conflicts and the theme's CSS can't collide with the page's.
Pasting the content into a post instead *would* collide — the document styles `h1`, `h2`,
`pre` and `:root` custom properties.
