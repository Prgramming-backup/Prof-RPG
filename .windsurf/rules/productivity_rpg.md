\# Productivity RPG Development Rules



You are working on a Flutter productivity RPG application.



The app lets users create real-life productivity tasks such as:

\- Gym

\- Reading

\- Studying

\- Walking

\- Programming

\- Cleaning

\- Meditation



Completing tasks gives XP.

XP levels up the user's avatar.

Consecutive productive days provide a small positive XP multiplier.

Missing days cause a smaller negative effect.



\## Development Rules



1\. ALWAYS inspect the existing code before modifying it.

2\. NEVER rebuild or rewrite working functionality unnecessarily.

3\. Preserve all existing features unless the current task explicitly requires changing them.

4\. Make the smallest safe changes needed for the current task.

5\. Do not implement future features unless explicitly requested.

6\. Do not create duplicate models, services, repositories, providers, or utilities.

7\. Keep business logic separate from Flutter widgets.

8\. Use Riverpod for application state.

9\. Use Drift for local persistence.

10\. Keep XP, level, streak, penalty, and achievement calculations in dedicated services.

11\. Important business logic must have unit tests.

12\. Run `flutter analyze` after changes.

13\. Run `flutter test` after changes.

14\. Fix errors before finishing.

15\. Never solve database problems by deleting the database.

16\. Use proper Drift migrations when the schema changes.

17\. Avoid adding dependencies unless genuinely necessary.

18\. Do not put magic numbers throughout the codebase. Game constants should live in a central location.

19\. UI should consume application state; UI widgets should not calculate game mechanics.

20\. Do not change visual design unrelated to the current task.



\## Game Rules



Difficulty:



Easy = 10 XP

Normal = 20 XP

Hard = 35 XP

Major = 50 XP



Positive streak:



Day 1 = 1.00x

Day 2 = 1.05x

Day 3 = 1.10x

Day 4 = 1.15x

Day 5 = 1.20x

Day 6 = 1.25x

Day 7+ = 1.30x maximum



Negative streak:



1 missed day = -10 XP



2 missed days = 0.98x

3 missed days = 0.96x

4+ missed days = 0.90x maximum



XP must never become negative.



A task can only reward XP once per calendar day.



The positive streak is based on consecutive calendar days where the user completes at least one active task.



Positive and negative multipliers must be calculated from persisted data.



The game should encourage consistency without being overly punishing.



\## Architecture



Prefer:



lib/

&#x20; app/

&#x20; core/

&#x20; database/

&#x20; models/

&#x20; providers/

&#x20; services/

&#x20; features/



Features:



home/

tasks/

avatar/

statistics/

settings/



Important services may include:



XPService

StreakService

AchievementService

NotificationService



\## Completion Requirement



Before considering a task complete:



\- inspect existing implementation

\- implement only the requested scope

\- run flutter analyze

\- run flutter test

\- fix errors

\- summarize changed files and tests

