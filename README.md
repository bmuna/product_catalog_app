# Product Catalog App

Flutter app that shows a product catalog from the [DummyJSON API](https://dummyjson.com/products). Custom design system, light/dark theme, and a responsive layout (list on phones, master-detail on tablets).

## Run it

- Flutter 3.x (tested on 3.10+).
- `flutter pub get` then `flutter run`.
- Tests: `flutter test`.

## What’s in here

- **app/** — GoRouter setup, deep links, responsive routes (phone vs tablet).
- **core/** — Constants (API URL, pagination, debounce) and theme (light/dark).
- **data/** — API client, Product/Category models, repository that ties API + cache together.
- **design_system/** — Reusable bits: search bar, category chips, product cards, empty/error/skeleton states, loading footer.
- **features/** — Products list (with search, category filter, infinite scroll) and product detail screen. Cubits hold the state.

On tablets (width ≥ 768px) you get a split view: list on the left, detail on the right. On phones it’s the usual push navigation. Deep link to `/products/123` and you land on that product.

## Tech choices

- **Cubit** for list and detail state. Repository does the API/cache logic; UI just reads state and calls methods.
- **GoRouter** for routes. Same paths work on phone and tablet; the builder decides which layout to show.
- **Design system** doesn’t depend on domain models — e.g. `ProductCard` takes a `ProductCardData` DTO.
- **Performance**: `GridView.builder`, `CachedNetworkImage`, 300 ms search debounce, const where it makes sense.

## Offline & polish

- **Cache**: First page of products + categories cached with Hive. Valid 5 minutes; pull-to-refresh clears it and refetches. A small “Cached” banner shows when you’re seeing cached data.
- **Animations**: Hero transition from list thumb to detail image, staggered list item fade-in, theme toggle in the app bar, pull-to-refresh on the list.

## Limitations

- **Search + category**: When you pick a category and type a search term, the app fetches that category from the API and then filters by search on the device. So the total count and “load more” are based on the full category, not the filtered results. Also, when you tap back from a product detail, the list resets — scroll position and your filters aren’t saved.
- **Tests**: We test cubit state changes, JSON parsing (`Product.fromJson`), and two design system widgets. There are no tests that mock the repository and run full load/pagination flows.

## AI use

I used an AI assistant for structure ideas, boilerplate, and debugging (e.g. fixing linter/API quirks). Logic, architecture, and product decisions are mine; the assistant helped with syntax and turning notes into README text.
