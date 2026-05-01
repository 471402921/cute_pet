# Flutter convenience commands. Wraps `flutter pub` operations with the
# CN pub mirror so dependency resolution works without modifying ~/.zshrc.
# Run `make` (no args) to see the available targets.

PUB_MIRROR := PUB_HOSTED_URL=https://pub.flutter-io.cn FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

.PHONY: help get upgrade outdated add run test test-coverage analyze fmt fmt-check clean codegen codegen-watch

help:
	@echo "Pub:"
	@echo "  make get                       flutter pub get                       (mirror)"
	@echo "  make upgrade                   flutter pub upgrade                   (mirror)"
	@echo "  make outdated                  flutter pub outdated                  (mirror)"
	@echo "  make add PKG=<name> [DEV=1] [SDK=flutter]"
	@echo "                                 flutter pub add <name>                (mirror)"
	@echo ""
	@echo "Codegen:"
	@echo "  make codegen                   build_runner build                    (mirror)"
	@echo "  make codegen-watch             build_runner watch                    (mirror)"
	@echo ""
	@echo "Run / test / quality:"
	@echo "  make run                       flutter run                           (mirror)"
	@echo "  make test                      flutter test"
	@echo "  make test-coverage             flutter test --coverage"
	@echo "  make analyze                   flutter analyze"
	@echo "  make fmt                       dart format ."
	@echo "  make fmt-check                 dart format --set-exit-if-changed ."
	@echo "  make clean                     flutter clean"

get:
	$(PUB_MIRROR) flutter pub get

upgrade:
	$(PUB_MIRROR) flutter pub upgrade

outdated:
	$(PUB_MIRROR) flutter pub outdated

add:
	@if [ -z "$(PKG)" ]; then echo "Usage: make add PKG=<package_name> [DEV=1] [SDK=flutter]"; exit 1; fi
	$(PUB_MIRROR) flutter pub add $(if $(DEV),--dev) $(if $(SDK),--sdk=$(SDK)) $(PKG)

codegen:
	$(PUB_MIRROR) dart run build_runner build --delete-conflicting-outputs

codegen-watch:
	$(PUB_MIRROR) dart run build_runner watch --delete-conflicting-outputs

run:
	$(PUB_MIRROR) flutter run

test:
	flutter test

test-coverage:
	flutter test --coverage

analyze:
	flutter analyze

fmt:
	dart format .

fmt-check:
	dart format --set-exit-if-changed .

clean:
	flutter clean
