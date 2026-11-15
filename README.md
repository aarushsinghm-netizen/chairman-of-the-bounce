# Chairman of the Bounce

[Play in your browser](https://aarushsinghm-netizen.itch.io/chairman-of-the-bounce)

[Public source repository](https://github.com/aarushsinghm-netizen/chairman-of-the-bounce)

A scrappy Godot game about throwing chairs at a desk until someone gives you a job.

**Theme: bounceback.** A bad throw earns a rescue token. On your next throw, press B to bounce upward, stop spinning, and try again. You can also bounce off the walls, because apparently the theme needed to be literal.

![A chair flying over a duck and a cup of coffee](docs/Chairman%20-%20Gameplay.png)

## Play

Open `project.godot` in **Godot 4.7.2**, then press **F6** for the open scene or **F5** for the project. The Compatibility renderer is already selected. No add-ons or paid assets are needed.

The macOS build and an itch.io-ready Web ZIP are supplied separately in `builds/` on the development computer. Builds are excluded from Git. To rebuild, use Godot's Project > Export menu and install the matching export templates.

| Control | Action |
| --- | --- |
| Hold Space or left mouse, then release | Charge and throw |
| A/D or left/right arrows | Rotate in the air |
| B or right mouse | One bounce-back rescue per throw; costs one token |
| Escape | Pause/resume; close credits |
| R | Restart |
| M | Mute/unmute |

Land five chairs upright on the desk before losing five confidence points. A landing must be within 32 degrees of upright. Ducks give 50 points and a rescue token. Coffee weakens your steering for one second. A rescued landing gives a comeback bonus. The desk moves after round one, round three has low gravity, and round four has wind.

First-throw hint: try roughly 20% power and briefly hold A after releasing. You can start charging again when the result message clears. Full power is usually too much.

## Why it looks like this

The mismatched emoji chair, duck, scribbled crate desk, plain buttons, and stretched tiles are intentional. This is a small amateur-looking jam game. There are no custom character animations, story cutscenes, level selection, touch buttons, or elaborate menus. Desktop keyboard/mouse is the intended way to play. The core controls and win/loss loop work.

## Assets and credits

**All art, fonts and audio are sourced assets.** Plain UI rectangles, the power meter, paper lines and layout are drawn in code. There are no generated images or sounds.

| Source | Used for | Author | License |
| --- | --- | --- | --- |
| [OpenMoji](https://github.com/hfg-gmuend/openmoji) | Chair | OpenMoji contributors | CC BY-SA 4.0 |
| [Twemoji](https://github.com/twitter/twemoji) | Duck, coffee, trophy | Twitter and contributors | CC BY 4.0 |
| [Scribble Platformer](https://kenney.nl/assets/scribble-platformer) | Floor and crate desk | Kenney | CC0 |
| [Impact Sounds](https://kenney.nl/assets/impact-sounds) | Chair clunks | Kenney | CC0 |
| [Happy Loop](https://opengameart.org/content/happy-loop) | Music | wipics | CC0 |
| [Backup icon](https://game-icons.net/1x1/lorc/backup.html) | Rescue indicator | Lorc | CC BY 3.0 |
| [Patrick Hand](https://github.com/google/fonts/tree/main/ofl/patrickhand) | Handwritten text | Patrick Wagesreiter | SIL OFL 1.1 |

Icons made by Lorc. See [ASSET_SOURCES.md](ASSET_SOURCES.md) for exact files, source/download links, changes, license links, and SHA-256 hashes. [ASSET_SOURCES.json](ASSET_SOURCES.json) contains the same data for scripts. Original license notices are in [licenses/](licenses/). Credits are also accessible inside the game.

Original code: MIT. Third-party assets retain their individual licenses, including OpenMoji's share-alike terms for those assets. Godot Engine is MIT licensed.

## Build and verify

With `godot` on your PATH, run these from the project directory:

```sh
godot --headless --editor --import --quit
godot --headless --script tests/physics_test.gd
godot --headless --export-release Web
godot --headless --export-release macOS
```

The physics checks cover wrapped landing angles, launches, rescue limits, failure recovery, pause, a reachable trajectory in each of five rounds, ducks, coffee, and both endings. The capture script (`godot --script tests/capture.gd`) renders menu, gameplay, credits and ending screenshots. Verification does not write a high score.

On the development Mac, Godot is installed at `/Applications/Godot.app`; its executable is `/Applications/Godot.app/Contents/MacOS/Godot`.

For Web, upload **Chairman - Web.zip** to itch.io as an HTML game, choose **This file will be played in the browser**, and use a 1000 x 650 embedded viewport with fullscreen available. `index.html` is at the ZIP root. The export is single-threaded and uses WebGL 2.0. To test locally, serve `builds/web/` over HTTP, for example `python3 -m http.server 8065 --directory builds/web`, then visit `http://localhost:8065`. Opening the HTML with `file://` will not work.

## GitHub

The development folder is a Git repository with a real initial commit. The source ZIP omits Git history; the publishing launcher initializes it if needed. To publish a new repository from the development folder after signing into GitHub CLI:

```sh
gh auth login
gh repo create chairman-of-the-bounce --public --source=. --remote=origin --push
```

The included `Chairman - Publish.command` runs the same flow and checks for an existing remote first. It publishes the project, credited source assets, license notices and screenshots. Build archives are kept separately; they can be attached to a GitHub Release or uploaded to itch.io.

## Hack Club reference and authorship

The [Jumpstart guide](https://daydream.jumpstart.hackclub.com/attendee/guide.html) was consulted for the Godot/GitHub/itch.io workflow. This is an original chair-flipping game, not a copy of its platformer. The current [Jumpstart page](https://jumpstart.hackclub.com/) lists January-February 2026 dates; check your event's own submission process and AI rules. No Hackatime hours, event eligibility, or submission are claimed.

**AI assistance:** OpenAI Codex wrote and assembled the code, downloaded the listed assets, and ran checks. This disclosure is included so the project can be represented accurately at the event. The assets are licensed work by the named creators.

## Local data

The game makes no network requests during play. Credit links open their named source sites only when clicked. Best score is stored locally in Godot's `user://chair-score.cfg`; no account, analytics or payment system is used. Source-site and hosting-site policies apply when visiting those services.
