# Clean Reactive Architecture — Flutter Sample

A sample application that demonstrates
[Clean Reactive Architecture](https://github.com/clean-reactive/documentation/blob/main/docs/architecture.md)
implemented with Flutter and Riverpod.

The sample shows a concrete, working mapping of every architectural unit from
the diagram to idiomatic Flutter + Riverpod code. It covers entities, the
gateway interface, the repository, use cases, selectors, presenters,
controllers, drivers, and the user interface — with unit, integration and
widget tests across them.

## Getting started

The Flutter version is pinned in `.fvmrc`. With [fvm](https://fvm.app/):

```sh
fvm install
fvm flutter pub get
```

Run the application:

```sh
fvm flutter run
```

Run the tests and the analyzer:

```sh
fvm flutter test
fvm flutter analyze
```

Without fvm, drop the `fvm` prefix and use Flutter 3.47.1.

## Tech stack

- [Flutter](https://flutter.dev/) 3.47.1, Dart SDK `^3.13.1`
- [Riverpod](https://riverpod.dev/) (`flutter_riverpod` 3.x), including the
  experimental `Mutation` API for per-operation write state
- [fast_immutable_collections](https://pub.dev/packages/fast_immutable_collections)
  for selectors that must compare equal across reads
- [flutter_test](https://docs.flutter.dev/testing) + [mocktail](https://pub.dev/packages/mocktail)
- [flutter_lints](https://pub.dev/packages/flutter_lints)

## Architecture mapping

The table below shows how each unit from the Clean Reactive Architecture
diagram maps to this codebase.

| Architectural unit              | Flutter / Riverpod equivalent           | Location                                                    |
| ------------------------------- | --------------------------------------- | ----------------------------------------------------------- |
| Enterprise business entity      | Plain Dart class                        | `repositories/order_entities.dart`                          |
| Application business entity     | `Notifier` store                        | `stores/orders_presentation.dart`, `orders_repository.dart` |
| Gateway interface               | `abstract interface class`              | `repositories/orders_gateway.dart`                          |
| Repository (gateway + entities) | `AsyncNotifier`                         | `repositories/orders_repository.dart`                       |
| Gateway implementation          | `OrdersGateway` implementation          | `repositories/orders_service/`                              |
| Use case interactor             | Callable class behind a `Provider`      | `use_cases/delete_order_item_use_case.dart`                 |
| Selector                        | `Provider` derived from the repository  | `selectors/orders_selector.dart`, …                         |
| Presenter                       | `Provider` returning a view model       | `widgets/order/order_presenter.dart`, …                     |
| Controller                      | `Provider` returning callbacks          | `widgets/order_item/order_item_controller.dart`             |
| ViewModel                       | Record `typedef`                        | `widgets/order/order_types.dart`, …                         |
| User interface                  | `ConsumerWidget` + `_UserInterface`     | `widgets/orders.dart`, `order/order.dart`, …                |
| Driver                          | Widget that listens and renders nothing | `drivers/toast_driver.dart`                                 |
| External resource               | Whatever a service talks to             | behind `RemoteOrdersService`                                |

## Key design decisions

**The repository is the gateway/entities composite.** `OrdersRepository` is an
`AsyncNotifier<List<OrderEntity>>`: it holds the entities and reaches the
resource through `OrdersGateway`, which it consumes rather than defines. The
interface is declared separately in `orders_gateway.dart`, so the repository
cannot quietly become the one that dictates the contract.

**The gateway implementation is resolved at runtime.** `ordersServiceProvider`
watches `ordersPresentationStore` and answers with either the in-memory or the
remote service. Swapping the resource is a value change in an application
business entity, not a structural change — and it is what
`OrdersResourcePicker` writes to.

**Optimistic writes with a single revalidation.** A write drops the entity from
the held state before the resource is asked, restores it if the write fails,
and re-reads afterwards so the resource has the last word. Because several
writes can be in flight at once and each read answers with the resource as it
stood when the read started, only the write that finishes last re-reads —
otherwise an earlier read stands back up orders the user has already been shown
as gone.

**Write state is an application business entity.**
`OrdersRepositoryWritesInFlight` counts the writes running right now;
`isOrdersMutatingSelector` reads it for the status label. Per-operation state
comes from Riverpod's `Mutation` API, which `isDeletingOrderSelector` and
`isDeletingItemSelector` read to disable the button belonging to one order or
item.

**Renders follow the read path only.** A widget watches its presenter and reads
its controller. Watching a controller would let the write path trigger a
rebuild, which the architecture's separation of paths exists to prevent.

**The user interface is one driver among several.** `OrdersToastDriver` renders
nothing: it listens to the repository and announces a failed read. It sits
beside the feature in `app.dart`, not inside it.

## Folder structure

```console
lib
├── app.dart                                # application shell
├── main.dart                               # composition root (ProviderScope)
└── features
    └── orders
        ├── orders.dart                     # what the app is allowed to place
        ├── drivers                         # drivers other than the user interface
        │   └── toast_driver.dart
        ├── repositories                    # repository, gateway interface, gateway implementations
        │   ├── order_entities.dart         # enterprise business entities
        │   ├── orders_gateway.dart         # gateway interface
        │   ├── orders_repository.dart      # repository (gateway + entities)
        │   └── orders_service
        │       ├── in_memory_orders_service.dart
        │       ├── orders_service.dart     # picks the implementation at runtime
        │       └── remote_orders_service.dart
        ├── selectors                       # selectors
        │   ├── is_deleting_item_selector.dart
        │   ├── is_deleting_order_selector.dart
        │   ├── is_orders_mutating_selector.dart
        │   ├── item_by_id_selector.dart
        │   ├── order_by_id_selector.dart
        │   ├── order_ids_selector.dart
        │   ├── order_item_ids_selector.dart
        │   ├── orders_selector.dart
        │   └── total_items_quantity_selector.dart
        ├── stores                          # application business entities
        │   └── orders_presentation.dart
        ├── use_cases                       # use case interactors
        │   └── delete_order_item_use_case.dart
        └── widgets                         # user interface, presenters, controllers
            ├── field.dart
            ├── order
            │   ├── order.dart              # user interface + inline controller
            │   ├── order_presenter.dart
            │   └── order_types.dart        # view models
            ├── order_item
            │   ├── order_item.dart
            │   ├── order_item_controller.dart
            │   ├── order_item_presenter.dart
            │   └── order_item_types.dart
            ├── orders.dart                 # user interface + inline presenter
            ├── orders_resource_picker.dart # every unit inline
            ├── orders_statistics.dart      # every unit inline
            ├── pill.dart
            └── section_label.dart
```

## Tests

The test tree mirrors `lib`, and the levels follow the
[testing pyramid](https://github.com/clean-reactive/documentation/blob/main/docs/architecture.md):

- _Unit_ — one unit with everything below it stood in for, e.g.
  `repositories/orders_repository_test.dart` and
  `selectors/total_items_quantity_selector_test.dart`.
- _Integration_ — units composed with only the resource doubled, e.g. the
  `selectors/*_integration_test.dart` files reading through a real repository,
  `widgets/orders_integration_test.dart` driving the screen down to the
  gateway, and `drivers/toast_driver_test.dart` placing the driver beside the
  screen.

Run them all:

```sh
fvm flutter test
```

## Further reading

- [Clean Reactive Architecture](https://github.com/clean-reactive/documentation/blob/main/docs/architecture.md)
- [Development Methodology](https://github.com/clean-reactive/documentation/blob/main/docs/methodology.md)
