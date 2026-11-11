**Mobile Development** **Practice 15: Interview Day**

---

**Submission:** Upload your work to GitHub repo till the end of week 15 (the endterm is in the practice slot; this practice is the week's homework)

**Interview Day**

Ninety seconds on your GitHub → the project paragraph → twenty questions in three sentences → three live-coding warm-ups → a bug story

This is the only practice with no new Flutter in it. The code is done — Lab 2 is defended, the app is on a GitHub Release. This week is about how it looks from outside: to a reviewer who gives your profile ninety seconds and your CV thirty, and to an interviewer who asks a question you have already answered in this room and then hands you a laptop. Both are practised skills, and both are practised out loud.

**One sentence carries the whole lab:** every word on a CV is a question you volunteered for. Keep the ones with a file behind them, cut the rest, and rehearse the answers until the first sentence comes without thinking.

**Build Levels**

| **Level** | **Topic** | **Key Widgets** |
| --- | --- | --- |
| Level 1 | **Ninety seconds on GitHub** | profile, pinned repos, repository name and description, README above the fold, commit history, the Release |
| Level 2 | **The project paragraph** | a one-page CV, the project paragraph with a link, skills you can defend, "learning" for the rest |
| Level 3 | **Twenty questions** | the junior question bank, three-sentence answers: definition · where · one level deeper |
| Level 4 | **Three warm-ups** | twenty minutes each, timer on, narrate, run after every change, finish something |
| Level 5 | **A bug story** | symptom · wrong first guess · what found it · the fix · the habit; a design decision; one thing you would change |
**Starter Code**

The starter is a `README.md` skeleton for the Lab 2 repository. Replace every bracket; keep the order — it is the order a reviewer reads in.

`# [App name] — a Flutter REST client`

` `

`[One sentence: what it is and who it is for.]`

` `

`| ![list](docs/list.png) | ![offline](docs/offline.png) |`

`|---|---|`

` `

`## Run it`

```` ``` ````

`flutter pub get`

`flutter run --dart-define=USE_FAKES=true        # no network needed`

`flutter run --dart-define-from-file=env/prod.json`

```` ``` ````

`Release APK (arm64): see **Releases** → v1.0.1 — install on any Android phone.`

` `

`## Architecture (five lines)`

``- `features/<name>/` — screen, ChangeNotifier, repository, per feature``

``- `core/api/` — ApiClient: Uri.https, 10 s timeout, sealed ApiException``

`- repositories behind interfaces; fakes for tests and demo mode`

`- storage: shared_preferences (settings), secure storage (token), file cache`

``- `flutter test`: [N] tests — models, error mapping, one widget test``

` `

`## Team`

`| Area | Owner | Reviewer |`

`|---|---|---|`

`| [feature] | [name] | [name] |`

---

**Tasks (5)**

**1.** **Level 1: Ninety seconds on your GitHub**

Do this to the Lab 2 repository and to your profile, in the order a reviewer sees them:

• **Profile.** A real name, a photo, one line — "Flutter developer · KBTU · 2026". Pin Lab 2 and one more repository (a practice you are proud of, cleaned). Look at your contribution graph: if the last two months are one green square — the final push — write in `NOTES.md` what the reviewer concludes from that, and commit the rest of this practice as you go, not at the end

• **Repository.** A name that says what it is (`students-app`, `campus-events`), not `lab2_final_v3`; a one-sentence description; three topics (`flutter`, `dart`, `provider`); public. The README from the starter: what it is, two screenshots (the list and the error or offline state), how to run — including the `USE_FAKES` line — then architecture in five lines and the test count

• **Tree and history.** `features/`, `core/`, `test/` visible at the top; no `build/`, no `key.properties`, no `.jks` ever committed (the `git log --all --diff-filter=A --name-only` check from Practice 14); `git log --oneline` reads like a plan. If it does not, you cannot rewrite history now — but you can write the plan into the README as "Decisions" and make the next repository different

• **The Release.** `v1.0.1` (or later) with the arm64 APK attached and the version from pubspec in its title. "Try it on your phone" is the strongest line a junior CV can back up

**The test of whether you did this right:**

• Open your profile in a private browser window, start a timer, stop at ninety seconds. Write down what you saw and did not see. Then do the same for a classmate's profile and tell them, in three sentences, what you would ask them first. Both notes go into `NOTES.md`.

**2.** **Level 2: The project paragraph — this is the CV**

One page, PDF, committed as `docs/cv.pdf` (or a link in `NOTES.md` if you would rather not publish it):

• Name, city, email, GitHub, LinkedIn. Education with the year. **One or two projects with links**, each a paragraph like the lecture's: "Students app — Flutter. Multi-screen client for a REST API with provider state management, offline cache, secure token storage, 12 unit/widget tests, signed release APK. github.com/…" — every noun in that sentence is a file in your repository

• Skills in two groups. **Keep:** Flutter, Dart, provider, REST with `http` and JSON models, `shared_preferences` and secure storage, unit and widget tests, git, a signed Android release — each with a file behind it. **Cut, or mark "learning":** anything you followed one tutorial in. No GraphQL you cannot defend for five minutes; no "MS Office"; no objective paragraph; no photo of a certificate

• Send it to two people — one who hires developers and one who does not — and ask both: "what would you ask me first?" Write their two answers into `NOTES.md`

**The test of whether you did this right:**

• Pick any word in the skills list at random. Can you talk about it for five minutes with a file open? If not, it moves to "learning" or disappears. The project paragraph fits in four lines and ends with a link that opens.

**3.** **Level 3: Twenty questions in three sentences**

The junior question bank from the lecture — all twenty, answered the lecture's way: definition, where you use it, one level deeper, then stop:

• Write the twenty answers into `INTERVIEW.md`, three sentences each, in your own words, **without opening the slides first** — then check against the slides and mark what you got wrong or vague. Each answer names the place in your own code where it lives (`"in users_model.dart, load() catches on ApiException…"`)

• Practise in pairs, out loud, with a timer: one asks a random number from 1 to 20, the other answers in under forty seconds, swap. Ten rounds each. The ones that took more than forty seconds or started with "it depends" get a star in `INTERVIEW.md` — those are the ones to rehearse again tomorrow

• Record yourself answering five of them on your phone, listen once, and write down the two things you would change (a filler word, a silence, a definition that turned into a paragraph)

**The test of whether you did this right:**

• A classmate asks you question 10 (watch / read / select) and question 14 (JSON int vs double) cold, in the corridor. Three sentences each, the first one a definition, the third one a fact a tutorial would not give. If the answer is a paragraph, it is not ready.

**4.** **Level 4: Three live-coding warm-ups**

Twenty minutes each, timer on, out loud, from an empty `flutter create`. The first two minutes are reading and saying the plan; then narrate and run after every change; finish something:

• **Warm-up 1.** The counter app → add a `ChangeNotifier`, a second screen that shows the same count, and a button on each screen that changes it. Provider above `MaterialApp`; `watch` in `build`, `read` in `onPressed`

• **Warm-up 2.** A list from a fake repository that fails on demand → loading, error with Retry, empty state, data. Four branches in one `switch`, the model takes the repository through its constructor, a `mounted`-free model

• **Warm-up 3.** A form with two fields → validators, controllers created once in `State` and disposed, `Form` + `GlobalKey<FormState>`, and one unit test for the validation rule as a plain function

• Each warm-up is its own small repository (or a folder in one `warmups` repository), committed when the timer stops — whatever state it is in. In `NOTES.md`: how far you got in twenty minutes, where you stalled, and what you would say to the interviewer at minute eighteen ("I would extract this into a ChangeNotifier and test it — want me to start?")

**The test of whether you did this right:**

• Do warm-up 2 a second time, two days later, without looking at the first attempt. It should take less time and the plan should come out in the first two minutes without hesitation. The difference between the two attempts, in minutes, goes into `NOTES.md` — that number is the practice working.

**5.** **Level 5: Three stories**

Prepared before any interview, each one a minute long, each one from this semester:

• **A bug** in five beats — symptom, wrong first guess, what actually found it, the fix, the habit. Pick a real one: the empty list on a real phone, the `setState` after dispose from a stream, the `int` that was not a `double`. The last beat is a habit you still have

• **A design decision** — why provider and not setState for the cart; why the repository takes an `http.Client`; why the future is a field. Say what the alternative was and what it would have cost

• **One thing you would do differently in Lab 2** — honest and specific: "I would write the fake repository first and build every screen against it; the real API came late and the screens were built around its quirks." A concrete regret is more convincing than a perfect project

• Write all three into `INTERVIEW.md` under their headings, and tell one of them to the group in the practice session, timed

**The test of whether you did this right:**

• Someone who was not in this course can follow the bug story and name the habit at the end without being told. The design-decision story names the alternative. The "differently" story would make your next project better, not just sound humble. `flutter analyze` is not run this week — the only green you need is on the contribution graph.

**Tip:** The interview is thirty minutes of questions you have already answered in this room, then twenty minutes of live coding with a stranger watching. Neither is about knowing more than you know. The first is about the first sentence coming without thinking; the second is about talking while you type and running after every change. Both come from repetition, not from reading — which is why every level of this practice says "out loud" and "with a timer".

**Requirements**

• GitHub profile: name, photo, one-line bio, two pinned repositories, commits spread over the semester, not one final push

• The Lab 2 repository: a descriptive name and description, three topics, public, the README from the starter with two screenshots, the run lines including `USE_FAKES`, architecture in five lines, the test count, the team table

• A GitHub Release with the arm64 APK attached and the pubspec version in its title; no keystore or `key.properties` anywhere in history

• `docs/cv.pdf` (or a private link in `NOTES.md`): one page, the project paragraph with a link, skills split into "keep" and "learning"; the two "what would you ask first" answers in `NOTES.md`

• `INTERVIEW.md`: twenty answers in three sentences each, each naming a file in your code; starred ones marked; the three stories under their headings

• Three warm-up repositories (or folders) committed at the twenty-minute mark, with the honest state in `NOTES.md`; warm-up 2 done twice, with the time difference

• `NOTES.md`: the ninety-second notes on your profile and a classmate's, the recording notes, the two warm-up timings

• One of the three stories told to the group in the practice session, timed under ninety seconds

**Useful Links**

1. **Setting up your GitHub profile README:** [docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/customizing-your-profile/managing-your-profile-readme](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/customizing-your-profile/managing-your-profile-readme)

2. **About GitHub Releases:** [docs.github.com/en/repositories/releasing-projects-on-github/about-releases](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases)

3. **Effective Dart (what a reviewer expects to see):** [dart.dev/effective-dart](https://dart.dev/effective-dart)

4. **Flutter DevTools (for the live-coding narration):** [docs.flutter.dev/tools/devtools](https://docs.flutter.dev/tools/devtools)

**GOOD LUCK!** :)
