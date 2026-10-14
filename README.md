# XDDBOT — F-Droid & stores

Distribution files for **XDDBOT** (`xdbot.bitplugg.ru`): metadata for
F-Droid / IzzyOnDroid and configuration for a self-hosted F-Droid repository.

The app itself lives in **https://github.com/bitplugg/XDDbot**.

## Contents

| Path | Purpose |
|---|---|
| `metadata/xdbot.bitplugg.ru.yml` | App metadata in the [fdroiddata](https://f-droid.org/docs/Build_Metadata_Reference/) format (F-Droid, IzzyOnDroid). |
| `config.yml` | [`fdroidserver`](https://f-droid.org/docs/Setup_an_F-Droid_App_Repo/) config for the self-hosted binary repo. No secrets. |
| `scripts/publish.sh` | Builds a release APK and refreshes the repo index. |
| `repo/` | Generated index + APKs (git-ignored, published via GitHub Pages). |

## Add the app (self-hosted repo)

1. Generate a repo signing key once:
   ```bash
   keytool -genkeypair -v -keystore ~/XDDbot-keys/fdroid.jks \
     -alias xddbot -keyalg RSA -keysize 4096 -validity 10000
   ```
2. Publish:
   ```bash
   XDBBOT_SRC=../XDDbot \
   FDROID_KEYSTORE=~/XDDbot-keys/fdroid.jks \
   ./scripts/publish.sh
   git add repo && git commit -m "publish: <version>" && git push
   ```
3. Enable GitHub Pages for this repository (branch `main`, folder `/`).
4. On a device, add the repo in the F-Droid client:
   `https://bitplugg.github.io/XDDbot-fdroid/repo`.

## Submit to F-Droid / IzzyOnDroid

- **F-Droid (main repo):** open a merge request against
  [fdroiddata](https://gitlab.com/fdroid/fdroiddata) adding
  `metadata/xdbot.bitplugg.ru.yml` from this project.
- **IzzyOnDroid:** file an issue at
  [izzysoft/apps](https://codeberg.org/izzy/Issues) referencing the upstream
  repository.

Both use the same metadata file. `UpdateCheckMode: Tags` and
`AutoUpdateMode: Version` mean a build tag (`v*`) is required for each release —
push a tag like `v0.1.0` in the upstream repo before submitting.

## Obtainium / direct APK

Point Obtainium at `https://github.com/bitplugg/XDDbot/releases` — GitHub
Releases are published automatically by the upstream CI on every `v*` tag.

## Notes

- The upstream project currently ships **no `LICENSE` file**; set `License:` in
  the metadata to the license you actually intend to publish under.
- `baselineprofile` is a JVM 17 test module that is not needed for store builds.
  The metadata removes it during `prebuild`; adjust if the build layout changes.
