AXXESS BAR — Website & QR

Hosting and QR instructions

1) Quick local test

- Open a terminal in this folder and run (Python 3):

```bash
python -m http.server 8000
```

- Visit http://localhost:8000 in your phone or computer to see the site.

2) Publish (recommended options)

- GitHub Pages:
  - Create a GitHub repo, push these files.
  - In repo Settings → Pages, set source to the `main` branch and root.
  - Your site will be available at `https://<your-user>.github.io/<repo>/`.

- Netlify / Vercel:
  - Connect your Git repo and deploy; both offer free static site hosting with custom domains.

3) Using the QR generator

- Open `qr.html` in the browser (either locally via http server or after publishing).
- Paste the published site URL (e.g. `https://<your>.github.io/repo/`), click "Generate QR".
- Click "Download QR" to save a PNG you can print and use on tables, posters, or stickers.

4) Tips

- Make sure the URL you paste is the publicly accessible URL (starts with `http://` or `https://`).
- Test the QR on multiple phones.
- If printing, use a high-resolution PNG and keep at least 2cm size for reliable scanning.
