# Theme Image Assets

Use these directories for theme-based images:

- `assets/images/`：亮色资源与默认资源
- `assets/images/dark/`：暗色资源

Suggested filenames:

- `logo.png`
- `empty_state.png`
- `tab_todo.svg`
- `tab_todo_selected.svg`
- `tab_profile.svg`
- `tab_profile_selected.svg`

Both light and dark resources should keep the same filenames to make runtime mapping simple.
Light assets are placed directly in `assets/images/`; no separate `light/` directory is required.

Feature-owned assets may live under `assets/features/<feature>/`, with matching dark variants under `assets/features/<feature>/dark/`. Declare each Feature asset directory in `pubspec.yaml`; keep the path mapping in that Feature's `AssetData` subclass instead of adding Feature fields to the global `AppAsset`.
